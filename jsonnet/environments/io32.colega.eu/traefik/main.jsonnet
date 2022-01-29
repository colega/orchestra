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
          match: 'Host(`traefik.io32.colega.eu`)',
          services: [
            { kind: 'TraefikService', name: 'api@internal' },
          ],
          middlewares: [
            { name: 'basic-auth' },  // this will try to find <namespace>-<name>@kubernetescrd
          ],
        },
      ],
      tls: {
        certResolver: 'le',
      },
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
}
