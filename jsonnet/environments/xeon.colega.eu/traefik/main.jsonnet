local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local traefik = import 'traefik/traefik.libsonnet';

{
  _config+:: {
    cluster_name: 'xeon.colega.eu',
    namespace: 'traefik',
  },

  traefik: traefik,

  traefik_ingress: {
    apiVersion: 'traefik.containo.us/v1alpha1',
    kind: 'IngressRoute',
    metadata: {
      name: 'external-traefik-dashboard',
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
    },
    tls: { options: { name: '' } },  // Otherwise doesn't work, see https://community.traefik.io/t/ingressroute-without-secretname-field-yields-404-response/1006
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
}
