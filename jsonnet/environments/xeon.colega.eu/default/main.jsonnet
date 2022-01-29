// There's also a grafana-agent here installed from plain helmchart using Grafana Cloud Kubernetes integration instructions.
// That is not handled by tanka.

local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local prometheus = import 'prometheus-ksonnet/prometheus-ksonnet.libsonnet';
local ingress = import 'traefik/ingress.libsonnet';
local middleware = import 'traefik/middleware.libsonnet';

{
  _config+:: {
    cluster_name: 'xeon.colega.eu',
    namespace: 'default',
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
  redirect_to_https: middleware.newRedirectToHTTPS(),
}
