local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local oauth2_proxy = import 'oauth2-proxy.libsonnet';

{
  _config+:: {
    cluster_name: 'io32.colega.eu',
    namespace: 'kube-system',
  },

  local ingress = k.networking.v1beta1.ingress,
  local rule = k.networking.v1beta1.ingressRule,
  local path = k.networking.v1beta1.httpIngressPath,
}
