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
  grafana_ingress: {
    apiVersion: 'traefik.containo.us/v1alpha1',
    kind: 'IngressRoute',
    metadata: {
      name: 'grafana',
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
            { name: 'basic-auth' },
          ],
        },
      ],
      tls: { options: { name: '' } },  // Otherwise doesn't work, see https://community.traefik.io/t/ingressroute-without-secretname-field-yields-404-response/1006
    },
  },

  prometheus_ingress: {
    apiVersion: 'traefik.containo.us/v1alpha1',
    kind: 'IngressRoute',
    metadata: {
      name: 'prometheus',
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
