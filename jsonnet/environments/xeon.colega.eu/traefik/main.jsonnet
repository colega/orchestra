local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local ingress = import 'traefik/ingress.libsonnet';
local middleware = import 'traefik/middleware.libsonnet';
local traefik = import 'traefik/traefik.libsonnet';

local secret = k.core.v1.secret;

{
  _config+:: {
    namespace: 'traefik',
  },

  namespace: k.core.v1.namespace.new($._config.namespace),

  traefik: traefik,

  ingress: ingress.new(['traefik.xeon.colega.eu'])
           + ingress.withMiddleware('basic-auth')
           + ingress.withCustomService({ kind: 'TraefikService', name: 'api@internal' }),

  local basicAuthSecretName = 'basic-auth',
  basic_auth_secret: secret.new(
    basicAuthSecretName,
    { users: std.base64(importstr 'basic-auth.secret.users.htpasswd') }
  ),
  basic_auth: middleware.newBasicAuth(secretName=basicAuthSecretName),
}
