local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet',
      secret = k.core.v1.secret;

local ingress = import 'traefik/ingress.libsonnet';
local middleware = import 'traefik/middleware.libsonnet';

{
  ingress: {
    reads: {
      local authMiddlewareName = 'basic-auth-reads',
      basic_auth_secret: secret.new(authMiddlewareName, { users: std.base64(importstr 'basic-auth-reads.secret.users.htpasswd') }),
      basic_auth: middleware.newBasicAuth(name=authMiddlewareName, secretName=authMiddlewareName, headerField='X-Scope-OrgID'),

      ingress: ingress.new(['mimir-reads.colega.eu'])
               + ingress.withMiddleware(authMiddlewareName)
               + ingress.withService('query-frontend', 8080),
    },

    writes: {
      local authMiddlewareName = 'basic-auth-writes',
      basic_auth_secret: secret.new(authMiddlewareName, { users: std.base64(importstr 'basic-auth-writes.secret.users.htpasswd') }),
      basic_auth: middleware.newBasicAuth(name=authMiddlewareName, secretName=authMiddlewareName, headerField='X-Scope-OrgID'),

      ingress: ingress.new(['mimir-writes.colega.eu'])
               + ingress.withMiddleware(authMiddlewareName)
               + ingress.withService('distributor', 8080),
    },

    admin: {
      local authMiddlewareName = 'basic-auth-admin',
      basic_auth_secret: secret.new(authMiddlewareName, { users: std.base64(importstr 'basic-auth-admin.secret.users.htpasswd') }),
      basic_auth: middleware.newBasicAuth(name=authMiddlewareName, secretName=authMiddlewareName, headerField='X-Scope-OrgID'),

      ingress: ingress.new(['mimir-admin.colega.eu'])
               + ingress.withMiddleware(authMiddlewareName)
               + ingress.withService('query-frontend', 8080)
               + ingress.withRoutePrefixService('store-gateway', '/store-gateway', port=8080),
    },
  },
}