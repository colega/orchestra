local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local oauth2_proxy = import 'oauth2-proxy.libsonnet';
local traefik_helmchartconfig = import 'traefik-helmchartconfig.jsonnet';

{
  _config+:: {
    cluster_name: 'io32.colega.eu',
    namespace: 'kube-system',
  },

  local ingress = k.networking.v1beta1.ingress,
  local rule = k.networking.v1beta1.ingressRule,
  local path = k.networking.v1beta1.httpIngressPath,

  traefik_oauth2_ingress:
    ingress.new('traefik-oauth2-ingress') +
    ingress.mixin.metadata.withNamespace($._config.namespace) +
    ingress.mixin.spec.withRules(
      rule.withHost('traefik.io32.colega.eu') +
      rule.http.withPaths([
        path.withPath('/')
        + path.backend.withServiceName('oauth2-traefik')
        + path.backend.withServicePort(4180),
      ])
    ),

  oauth2_traefik: oauth2_proxy.new(
    namespace=$._config.namespace,
    redirect='http://traefik.io32.colega.eu/oauth2/callback',
    upstream='c',
    name='oauth2-traefik',
    secret_name='oauth2-traefik',
    emails=importstr 'email.txt',
  ),

  traefik_helmchartconfig: traefik_helmchartconfig,
}
