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
        '--providers.kubernetescrd.allowCrossNamespace=true',
      ],
      // Prometheus metrics port should end in `-metrics` in order to be scraped.
      // So we drop the `metrics` port and add an `http-metrics` one.
      // https://github.com/grafana/jsonnet-libs/blob/5fb2525/prometheus/scrape_configs.libsonnet#L25-L30
      ports: {
        metrics: null,
        'http-metrics': {
          port: 9100,
          protocol: 'TCP',
          expose: false,
        },
      },
      metrics: {
        prometheus: {
            entryPoint:  'http-metrics',
        },
      },
      // Pod should have a `name` label in order to be scraped.
      // https://github.com/grafana/jsonnet-libs/blob/5fb2525/prometheus/scrape_configs.libsonnet#L32-L37
      deployment: {
        podLabels: {
          name: 'traefik',
        },
      },
    },
  }),
}
