local tanka = import 'github.com/grafana/jsonnet-libs/tanka-util/main.libsonnet';
local helm = tanka.helm.new(std.thisFile);

{
  traefik: helm.template('traefik', './charts/traefik', {
    namespace: 'traefik',  // TODO: make configurable?
    values: {
      dashboard: { enabled: true },
      rbac: { enabled: true },
      nodeSelector: { 'node-role.kubernetes.io/master': 'true' },
      additionalArguments: [
        '--api.dashboard=true',
        '--log.level=DEBUG',
        //'--providers.kubernetesingress.ingressclass=traefik-internal',
        '--serversTransport.insecureSkipVerify=true',
      ],
    },
  }),
}
