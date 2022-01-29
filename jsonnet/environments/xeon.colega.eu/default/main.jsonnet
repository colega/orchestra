// There's also a grafana-agent here installed from plain helmchart using Grafana Cloud Kubernetes integration instructions.
// That is not handled by tanka.

local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local grafana = import 'grafana/grafana.libsonnet';
local prometheus = import 'prometheus-ksonnet/prometheus-ksonnet.libsonnet';
local middleware = import 'traefik/middleware.libsonnet';
local ingress = import 'traefik/ingress.libsonnet';

{
  _config+:: {
    cluster_name: 'xeon.colega.eu',
    namespace: 'default',
  },

  prometheus: prometheus +
              grafana.withRootUrl('http://grafana.grafana.me')
              { _config+:: $._config },

  grafana_ingress: ingress.new(['grafana.grafana.me'])
           + ingress.withMiddleware('basic-auth')
           + ingress.withService('grafana'),
  prometheus_ingress: ingress.new(['prometheus.grafana.me'])
           + ingress.withMiddleware('basic-auth')
           + ingress.withService('prometheus', 9090),

  basic_auth: middleware.newBasicAuth(),
  redirect_to_https: middleware.newRedirectToHTTPS(),


}
