local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local traefik = import 'traefik/traefik.libsonnet';

{
  _config+:: {
    cluster_name: 'xeon.colega.eu',
    namespace: 'traefik',
  },

  traefik: traefik,

  traefik_https_ingress: {
    apiVersion: 'traefik.containo.us/v1alpha1',
    kind: 'IngressRoute',
    metadata: {
      name: 'traefik-dashboard-https',
      namespace: 'traefik',
    },
    spec: {
      entryPoints: ['websecure'],
      routes: [
        {
          kind: 'Rule',
          match: 'Host(`traefik.xeon.colega.eu`)',
          services: [
            { kind: 'TraefikService', name: 'api@internal' },
          ],
          middlewares: [
            { name: 'basic-auth' },  // this will try to find <namespace>-<name>@kubernetescrd
          ],
        },
      ],
      tls: { options: { name: '' } },  // Otherwise doesn't work, see https://community.traefik.io/t/ingressroute-without-secretname-field-yields-404-response/1006
    },
  },

  traefik_http_ingress: {
    apiVersion: 'traefik.containo.us/v1alpha1',
    kind: 'IngressRoute',
    metadata: {
      name: 'traefik-dashboard-http',
      namespace: 'traefik',
    },
    spec: {
      entryPoints: ['web'],
      routes: [
        {
          kind: 'Rule',
          match: 'Host(`traefik.xeon.colega.eu`)',
          services: [
            { kind: 'TraefikService', name: 'api@internal' },  // TODO point to something dumb?
          ],
          middlewares: [
            { name: 'redirect-https' }
            { name: 'basic-auth' },  // TODO remove once not pointing to real service
          ],
        },
      ],
    },
  },

  traefik_basic_auth_middleware: {
    apiVersion: 'traefik.containo.us/v1alpha1',
    kind: 'Middleware',

    metadata: {
      name: 'basic-auth',
    },
    spec: {
      basicAuth: {
        secret: 'basic-auth',
      },
    },
  },


  traefik_redirect_https_middleware: {
    apiVersion: 'traefik.containo.us/v1alpha1',
    kind: 'Middleware',

    metadata: {
      name: 'redirect-https',
    },

    spec: {
      redirectScheme: {
        scheme: 'https',
        permanent: false,  // TODO make permanent
      },
    },
  },
}
