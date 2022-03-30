local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet',
      container = k.core.v1.container,
      containerPort = k.core.v1.containerPort;
local ingress = import 'traefik/ingress.libsonnet';

{
  _config+: {
    namespace: error 'should define namespace',
    name: $._config.namespace,
    image: error 'should define image',
    domains: error 'should define domains',
    port: 8043,
    clusterIssuer: 'letsencrypt-staging',
  },
  container::
    container.new($._config.name, $._config.image)
    + container.withPorts([containerPort.new('http', $._config.port)])
    + k.util.resourcesRequests('50m', '32Mi'),

  deployment: k.apps.v1.deployment.new($._config.name, 1, [$.container]),
  service: k.util.serviceFor($.deployment),
  ingress: ingress.new($._config.domains, clusterIssuer=$._config.clusterIssuer) + ingress.withService($._config.name, $._config.port),
}
