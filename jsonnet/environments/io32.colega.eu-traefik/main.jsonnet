local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local traefik = import 'traefik/traefik.libsonnet';

{
  _config+:: {
    cluster_name: 'io32.colega.eu',
    namespace: 'traefik',
  },

  traefik: traefik,

  local ingress = k.networking.v1beta1.ingress,
  local rule = k.networking.v1beta1.ingressRule,
  local path = k.networking.v1beta1.httpIngressPath,

  /*traefik_ingress:
    ingress.new('traefik-ingress') +
    ingress.mixin.metadata.withNamespace($._config.namespace) +
    ingress.mixin.spec.withRules(
      rule.withHost('traefik.io32.colega.eu') +
      rule.http.withPaths([
        path.withPath('/')
        //+ path.backend.resource.withName('api@internal')
        //+ path.backend.resource.withKind('TraefikService')
        + path.backend.withServiceName('traefik')
        + path.backend.withServicePort(9000),
      ])
    ),
    */
}