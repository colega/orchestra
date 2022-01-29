local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local ingress = import 'traefik/ingress.libsonnet';
local middleware = import 'traefik/middleware.libsonnet';
local traefik = import 'traefik/traefik.libsonnet';

{
  traefik: traefik,

  ingress: ingress.new(['traefik.xeon.colega.eu'])
           + ingress.withMiddleware('basic-auth')
           + ingress.withCustomService({ kind: 'TraefikService', name: 'api@internal' }),

  local container = k.core.v1.container,
  nginx_container::
    container.new('nginx', 'nginx:latest') +
    container.withPorts(k.core.v1.containerPort.new('http', 80)),

  local deployment = k.apps.v1.deployment,
  nginx_deployment:
    deployment.new('noop-nginx', 1, [$.nginx_container]),

  local service = k.core.v1.service,
  local servicePort = k.core.v1.servicePort,
  nginx_service:
    k.util.serviceFor(self.nginx_deployment) +
    service.mixin.spec.withPorts([
      servicePort.newNamed(
        name='http',
        port=80,
        targetPort=80,
      ),
    ]),

  basic_auth: middleware.newBasicAuth(),
  redirect_to_https: middleware.newRedirectToHTTPS(),
}
