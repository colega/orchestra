local middleware = import 'middleware.libsonnet';

{
  new(domains=[], clusterIssuer='letsencrypt-prod'):
    {
      local name = domains[0],
      local secretName = name + '-certificate',
      local this = self,

      middlewares:: [],
      services:: [],
      host_matcher:: std.join(' || ', ['Host(`%s`)' % domain for domain in domains]),
      extra_routes:: [],

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
              match: '(%(host_matcher)s) && PathPrefix(`%(prefix)s`)' % {
                host_matcher: this.host_matcher,
                prefix: route.prefix,
              },
              services: route.services,
              middlewares: this.middlewares,
            }
            for route in this.extra_routes
          ] + [
            {
              kind: 'Rule',
              match: this.host_matcher,
              services: this.services,
              middlewares: this.middlewares,
            },
          ],
          tls: {
            secretName: secretName,
          },
        },
      },

      local redirectToHTTPSMiddlewareName = name + '-redirect-to-https',

      redirect_to_https_middleware: {
        apiVersion: 'traefik.containo.us/v1alpha1',
        kind: 'Middleware',

        metadata: {
          name: redirectToHTTPSMiddlewareName,
        },

        spec: {
          redirectScheme: {
            scheme: 'https',
            permanent: true,
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
              match: this.host_matcher,
              services: [{ kind: 'TraefikService', name: 'noop@internal' }],
              middlewares: [{ name: redirectToHTTPSMiddlewareName }],
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

  withRoutePrefixService(serviceName, prefix, port='http', namespace=null):: {
    extra_routes+:: [{
      services: [{ kind: 'Service', namespace: namespace, name: serviceName, port: port }],
      prefix: prefix,
    }],
  },
}
