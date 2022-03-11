// There's also a grafana-agent here installed from plain helmchart using Grafana Cloud Kubernetes integration instructions.
// That is not handled by tanka.

local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local promtail = import 'github.com/grafana/loki/production/ksonnet/promtail/promtail.libsonnet';
local prometheus = import 'prometheus-ksonnet/prometheus-ksonnet.libsonnet';
local ingress = import 'traefik/ingress.libsonnet';
local middleware = import 'traefik/middleware.libsonnet';

{
  _config+:: {
    cluster_name: 'xeon.colega.eu',
    namespace: 'default',
  },
  _images+:: {
    promtail: 'grafana/promtail:2.4.2',
  },

  namespace: k.core.v1.namespace.new($._config.namespace),

  prometheus: prometheus {
    _config+:: $._config {
      grafana_root_url: 'https://grafana.grafana.me',
    },
    // Increase the default 200m to avoid cpu throttling alert.
    node_exporter_container+:: k.util.resourcesLimits('500m', '100Mi'),
  },

  grafana_ingress: ingress.new(['grafana.grafana.me'])
                   + ingress.withMiddleware('basic-auth')
                   + ingress.withService('grafana'),
  prometheus_ingress: ingress.new(['prometheus.grafana.me'])
                      + ingress.withMiddleware('basic-auth')
                      + ingress.withService('prometheus', 9090),

  basic_auth: middleware.newBasicAuth(),


  promtail: promtail {
    _config+:: $._config,
    promtail_config+:: {
      clients: [{
        url: 'https://logs-prod-eu-west-0.grafana.net/loki/api/v1/push',
        basic_auth: {
          username: '155183',
          password_file: '/etc/promtail_auth/api_key.yml',
        },
      }],
    },
    _images+:: $._images,

    promtail_daemonset+:
      k.util.configVolumeMount('grafana-cloud-mykubernetes-writes-api-key', '/etc/promtail_auth'),
  },
}
