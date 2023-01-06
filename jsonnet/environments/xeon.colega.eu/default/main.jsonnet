local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet',
      configMap = k.core.v1.configMap,
      pvc = k.core.v1.persistentVolumeClaim,
      statefulSet = k.apps.v1.statefulSet,
      container = k.core.v1.container,
      volume = k.core.v1.volume,
      volumeMount = k.core.v1.volumeMount,
      secret = k.core.v1.secret;

local mimir_mixin = import 'github.com/grafana/mimir/operations/mimir-mixin/mixin.libsonnet';
local traefik_mixin = import 'github.com/grafana/jsonnet-libs/traefik-mixin/mixin.libsonnet';
local prometheus = import 'prometheus-ksonnet/prometheus-ksonnet.libsonnet';
local ingress = import 'traefik/ingress.libsonnet';
local middleware = import 'traefik/middleware.libsonnet';
local grafana_cloud_o11y = import 'grafana_cloud_o11y.libsonnet';
{
  _config+:: {
    cluster_name: 'xeon.colega.eu',
    namespace: 'default',
  },
  _images+:: {
    promtail: 'grafana/promtail:2.4.2',
    grafana_agent: 'grafana/agent:v0.23.0',
  },

  namespace: k.core.v1.namespace.new($._config.namespace),

  // This is not just a prometheus, it's also a grafana, rules, dashboards, etc.
  prometheus: prometheus {
    _config+:: $._config {
      grafana_root_url: 'https://grafana.xeon.colega.eu',
    },
    // Increase the default 200m to avoid cpu throttling alert.
    node_exporter_container+:: k.util.resourcesLimits('500m', '100Mi'),

    local mimirWritesDefaultPassword = 'mimir-writes-default-password',

    default_mimir_writes_password_secret:
      secret.new(mimirWritesDefaultPassword, { [mimirWritesDefaultPassword]: std.base64(importstr 'mimir-writes-default.secret.password.txt') }, 'Opaque'),

    prometheus+: {
      prometheus_container+:: container.withVolumeMountsMixin([
        volumeMount.new(mimirWritesDefaultPassword, '/mimir-auth'),
      ]),
      prometheus_statefulset+:
        statefulSet.mixin.spec.template.spec.withVolumesMixin([
          volume.fromSecret(mimirWritesDefaultPassword, mimirWritesDefaultPassword),
        ]),
      _config+: {
        prometheus_requests_cpu: '250m',
        prometheus_requests_memory: '256Mi',
        prometheus_limits_cpu: null,
        prometheus_limits_memory: '512Mi',
      },
      prometheus_pvc+:: pvc.mixin.spec.resources.withRequests({ storage: '32Gi' }),

      // For some reason the rules from the mixins are not propagated to prometheus, so we need to propagate them manually.
      prometheusRules+:: mimir_mixin.prometheusRules,
    },

    prometheus_config+: {
      remote_write: [
        {
          basic_auth: { username: 'default', password_file: '/mimir-auth/' + mimirWritesDefaultPassword },
          url: 'https://mimir-writes.colega.eu/api/v1/push',
        },
      ],
      scrape_configs: [
        config {
          relabel_configs+:
            [
              {
                // Add 'cluster' label to all metrics, this is required by some Grafana-authored mixins like mimir-mixin.
                target_label: 'cluster',
                replacement: $._config.cluster_name,
              },
            ],
        }
        for config in super.scrape_configs
      ],
    },

    local mimirReadsDefaultPassword = 'mimir-reads-default-password',

    default_mimir_reads_password_secret:
      secret.new(mimirReadsDefaultPassword, { [mimirReadsDefaultPassword]: std.base64(importstr 'mimir-reads-default.secret.password.txt') }, 'Opaque'),
    grafana_container+:: container.withEnvMixin([
      k.core.v1.envVar.fromSecretRef(
        'MIMIR_READS_DEFAULT_PASSWORD',
        mimirReadsDefaultPassword,
        mimirReadsDefaultPassword,
      ),
    ]),

    grafanaDatasources+:: {
      'mimir-default': $.prometheus.grafana_datasource_with_basicauth('default@mimir', 'https://mimir-reads.colega.eu/prometheus', 'default', '$MIMIR_READS_DEFAULT_PASSWORD', false, 'POST'),
    },

    mixins+:: {
      mimir: mimir_mixin,
      traefik: traefik_mixin,
    },
  },

  ingress: {
    local basicAuthSecretName = 'basic-auth',
    basic_auth_secret: secret.new(
      basicAuthSecretName,
      { users: std.base64(importstr 'basic-auth.secret.users.htpasswd') }
    ),
    basic_auth: middleware.newBasicAuth(secretName=basicAuthSecretName),

    grafana: ingress.new(['grafana.xeon.colega.eu'])
             + ingress.withMiddleware('basic-auth')
             + ingress.withService('grafana'),
    prometheus: ingress.new(['prometheus.xeon.colega.eu'])
                + ingress.withMiddleware('basic-auth')
                + ingress.withService('prometheus', 9090),
  },

  grafana_cloud_o11y: grafana_cloud_o11y {
    _images+:: $._images,
    _config+:: $._config,
  },
}
