// There's also a grafana-agent here installed from plain helmchart using Grafana Cloud Kubernetes integration instructions.
// That is not handled by tanka.

local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local grafana = import 'grafana/grafana.libsonnet';
local prometheus = import 'prometheus-ksonnet/prometheus-ksonnet.libsonnet';


{
  _config+:: {
    cluster_name: 'xeon.colega.eu',
    namespace: 'default',
  },

  prometheus: prometheus +
              grafana.withRootUrl('http://grafana.grafana.me')
              { _config+:: $._config },

  // TODO deduplicate this from traefik
  // docs: https://doc.traefik.io/traefik/routing/providers/kubernetes-crd/
  grafana_https_ingress: {
    apiVersion: 'traefik.containo.us/v1alpha1',
    kind: 'IngressRoute',
    metadata: {
      name: 'grafana-https',
    },
    spec: {
      entryPoints: ['websecure'],
      routes: [
        {
          kind: 'Rule',
          match: 'Host(`grafana.grafana.me`)',
          services: [
            { kind: 'Service', name: 'grafana', port: 'http' },
          ],
          middlewares: [
            { name: 'basic-auth-noheader' },
          ],
        },
      ],
      tls: { options: { name: '' } },  // Otherwise doesn't work, see https://community.traefik.io/t/ingressroute-without-secretname-field-yields-404-response/1006
    },
  },

  grafana_http_ingress: {
    apiVersion: 'traefik.containo.us/v1alpha1',
    kind: 'IngressRoute',
    metadata: {
      name: 'grafana-http',
    },
    spec: {
      entryPoints: ['web'],
      routes: [
        {
          kind: 'Rule',
          match: 'Host(`grafana.grafana.me`)',
          services: [
            { kind: 'Service', name: 'grafana', port: 'http' },
          ],
          middlewares: [
            { name: 'redirect-https' },
            { name: 'basic-auth-noheader' },  // TODO just in case since we're pointing to the real service
          ],
        },
      ],
    },
  },

  prometheus_https_ingress: {
    apiVersion: 'traefik.containo.us/v1alpha1',
    kind: 'IngressRoute',
    metadata: {
      name: 'prometheus-https',
    },
    spec: {
      entryPoints: ['websecure'],
      routes: [
        {
          kind: 'Rule',
          match: 'Host(`prometheus.grafana.me`)',
          services: [
            { kind: 'Service', name: 'prometheus', port: 9090 },
          ],
          middlewares: [
            { name: 'basic-auth' },
          ],
        },
      ],
      tls: { options: { name: '' } },  // Otherwise doesn't work, see https://community.traefik.io/t/ingressroute-without-secretname-field-yields-404-response/1006
    },
  },

  prometheus_http_ingress: {
    apiVersion: 'traefik.containo.us/v1alpha1',
    kind: 'IngressRoute',
    metadata: {
      name: 'prometheus-http',
    },
    spec: {
      entryPoints: ['web'],
      routes: [
        {
          kind: 'Rule',
          match: 'Host(`prometheus.grafana.me`)',
          services: [
            { kind: 'Service', name: 'prometheus', port: 9090 },  // TODO: point to some dumb endpoint
          ],
          middlewares: [
            { name: 'redirect-https' },
            { name: 'basic-auth' },  // TODO just in case since we're pointing to the real service
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

  traefik_basic_auth_noheader_middleware: {
    apiVersion: 'traefik.containo.us/v1alpha1',
    kind: 'Middleware',

    metadata: {
      name: 'basic-auth-noheader',
    },

    spec: {
      basicAuth: {
        secret: 'basic-auth',
        removeHeader: true,
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
