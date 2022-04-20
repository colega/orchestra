local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet',
      configMap = k.core.v1.configMap,
      pvc = k.core.v1.persistentVolumeClaim,
      secret = k.core.v1.secret;

local k_util = import 'k-util/k-util.libsonnet';

local promtail = import 'github.com/grafana/loki/production/ksonnet/promtail/promtail.libsonnet';
local mimir_mixin = import 'github.com/grafana/mimir/operations/mimir-mixin/mixin.libsonnet';
local traefik_mixin = import 'github.com/grafana/jsonnet-libs/traefik-mixin/mixin.libsonnet';
local prometheus = import 'prometheus-ksonnet/prometheus-ksonnet.libsonnet';
local ingress = import 'traefik/ingress.libsonnet';
local middleware = import 'traefik/middleware.libsonnet';
local grafana_agent = import 'grafana-agent/grafana-agent.libsonnet';

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

  grafana_cloud_api_key: {
    filename:: 'api_key.txt',
    dir:: '/etc/grafana_cloud/',
    full_path:: self.dir + self.filename,

    secret: secret.new('grafana-cloud-mykubernetes-writes-api-key', {
      'api_key.txt': std.base64(importstr 'grafana-cloud-mykubernetes.secret.writes-api-key.txt'),
    }),

    secret_volume_mount_mixin:: k_util.secretVolumeMountWithHash(self.secret, self.dir),
  },


  // See lib/grafana-agent
  grafana_agent: grafana_agent {
    _images+:: $._images,
    _config+:: {
      namespace: $._config.namespace,
      cluster: $._config.cluster_name,
      metrics_url: 'https://prometheus-prod-01-eu-west-0.grafana.net/api/prom/push',
      metrics_tenant_id: 312426,
      metrics_api_key_path: $.grafana_cloud_api_key.full_path,
      logs_url: 'https://logs-prod-eu-west-0.grafana.net/api/prom/push',
      logs_tenant_id: 155183,
      logs_api_key_path: $.grafana_cloud_api_key.full_path,
    },
    deployment+: $.grafana_cloud_api_key.secret_volume_mount_mixin,
  },

  // This is not just a prometheus, it's also a grafana, rules, dashboards, etc.
  prometheus: prometheus {
    _config+:: $._config {
      grafana_root_url: 'https://grafana.grafana.me',
    },
    // Increase the default 200m to avoid cpu throttling alert.
    node_exporter_container+:: k.util.resourcesLimits('500m', '100Mi'),

    prometheus+: {
      _config+: {
        prometheus_requests_cpu: '250m',
        prometheus_requests_memory: '256Mi',
        prometheus_limits_cpu: null,
        prometheus_limits_memory: '512Mi',
      },
      prometheus_pvc+:: pvc.mixin.spec.resources.withRequests({ storage: '32Gi' }),
    },

    prometheus_config+: {
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

    grafana: ingress.new(['grafana.grafana.me'])
             + ingress.withMiddleware('basic-auth')
             + ingress.withService('grafana'),
    prometheus: ingress.new(['prometheus.grafana.me'])
                + ingress.withMiddleware('basic-auth')
                + ingress.withService('prometheus', 9090),
  },

  // TODO: remove this promtail config once we've fixed grafana-agent
  promtail: promtail {
    _config+:: $._config,
    promtail_config+:: {
      clients: [{
        url: 'https://logs-prod-eu-west-0.grafana.net/loki/api/v1/push',
        basic_auth: {
          username: '155183',
          password_file: $.grafana_cloud_api_key.full_path,
        },
        external_labels: { scraper: 'promtail' },
      }],
    },
    _images+:: $._images,

    promtail_daemonset+: $.grafana_cloud_api_key.secret_volume_mount_mixin,
  },
}
