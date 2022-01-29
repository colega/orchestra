local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local traefik = import 'traefik/traefik.libsonnet';
local middleware = import 'traefik/middleware.libsonnet';

{
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
      tls: {
        secretName: 'traefik.xeon.colega.eu-cert',
      },
    },
  },

  traefik_https_ingress_certificate: {
    apiVersion: 'cert-manager.io/v1',
    kind: 'Certificate',
    metadata: {
      name: 'traefik.xeon.colega.eu',
      namespace: 'traefik',
    },
    spec: {
      dnsNames: [
        'traefik.xeon.colega.eu',
      ],
      secretName: 'traefik.xeon.colega.eu-cert',
      issuerRef: {
        name: 'letsencrypt-prod',
        kind: 'ClusterIssuer',
      },
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
            { name: 'redirect-https' },
            { name: 'basic-auth' },  // TODO remove once not pointing to real service
          ],
        },
      ],
    },
  },

  basic_auth: middleware.newBasicAuth(),
  redirect_to_https: middleware.newRedirectToHTTPS(),
}
