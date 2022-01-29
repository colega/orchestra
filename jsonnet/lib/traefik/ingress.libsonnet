local middleware = import 'middleware.libsonnet';

{
  new(domains=[], clusterIssuer='letsencrypt-prod'):
    {
      local name = domains[0],
      local secretName = name + '-certificate',
      local this = self,

      middlewares:: [],
      services:: [],

      certificate: {
        apiVersion: 'cert-manager.io/v1',
        kind: 'Certificate',
        metadata: {
          name: name,
        },
        spec: {
          dnsNames: domains,
          secretName: secretName,
          issuerRef: {
            name: clusterIssuer,
            kind: 'ClusterIssuer',
          },
        },
      },

      https: {
        apiVersion: 'traefik.containo.us/v1alpha1',
        kind: 'IngressRoute',
        metadata: {
          name: name + '-https',
        },
        spec: {
          entryPoints: ['websecure'],
          routes: [
            {
              kind: 'Rule',
              match: std.join(' || ', ['Host(`%s`)' % domain for domain in domains]),
              services: this.services,
              middlewares: this.middlewares,
            },
          ],
          tls: {
            secretName: secretName,
          },
        },
      },


      http: {
        apiVersion: 'traefik.containo.us/v1alpha1',
        kind: 'IngressRoute',
        metadata: {
          name: name + '-http',
        },
        spec: {
          entryPoints: ['web'],
          routes: [
            {
              kind: 'Rule',
              match: std.join(' || ', ['Host(`%s`)' % domain for domain in domains]),
              services: [
                { kind: 'Service', namespace: 'traefik', name: 'noop-nginx', port: 'http' },
              ],
              middlewares: [
                { name: middleware.redirectToHTTPSDefaultName },
              ],
            },
          ],
        },
      },


    },

  withMiddleware(name):: {
    middlewares+:: [{ name: name }],
  },

  withCustomService(service):: {
    services+:: [service],
  },

  withService(name, port='http', namespace=null):: {
    services+:: [{ kind: 'Service', namespace: namespace, name: name, port: port }],
  },
}
