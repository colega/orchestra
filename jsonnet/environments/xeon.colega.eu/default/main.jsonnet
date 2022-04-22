local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet',
      pvc = k.core.v1.persistentVolumeClaim,
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
