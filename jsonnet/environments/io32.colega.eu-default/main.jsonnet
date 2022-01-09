local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local grafana = import 'grafana/grafana.libsonnet';
local prometheus = import 'prometheus-ksonnet/prometheus-ksonnet.libsonnet';

{
  _config+:: {
    cluster_name: 'io32.colega.eu',
    namespace: 'default',
  },

  prometheus: prometheus +
              grafana.withRootUrl('http://grafana.grafana.me') +
              {
                _config+:: $._config,
                node_exporter_container+:
                  k.core.v1.container.withPorts(
                    k.core.v1.containerPort.new('http-metrics', 9200)  // 9100 is used by grafana agent
                  ) +
                  k.core.v1.container.withArgs([
                    // port override:
                    '--web.listen-address=:9200',
                    // defaults from jsonnet-libs/node-exporter:
                    '--path.procfs=/host/proc',
                    '--path.sysfs=/host/sys',
                  ]),
              },

  local ingress = k.networking.v1beta1.ingress,
  local rule = k.networking.v1beta1.ingressRule,
  local path = k.networking.v1beta1.httpIngressPath,

  grafana_ingress:
    ingress.new('grafana-ingress') +
    ingress.mixin.metadata.withNamespace($._config.namespace) +
    //ingress.mixin.metadata.withAnnotations({
    //  'traefik.ingress.kubernetes.io/rule-type': 'PathPrefix',
    //}) +
    ingress.mixin.spec.withRules(
      rule.withHost('grafana.grafana.me') +
      rule.http.withPaths([
        path.withPath('/')
        + path.backend.withServiceName('grafana')
        + path.backend.withServicePort('http'),
      ])
    ),

  prometheus_ingress:
    ingress.new('prometheus-ingress') +
    ingress.mixin.metadata.withNamespace($._config.namespace) +
    ingress.mixin.spec.withRules(
      rule.withHost('prometheus.grafana.me') +
      rule.http.withPaths([
        path.withPath('/')
        + path.backend.withServiceName('prometheus')
        + path.backend.withServicePort(9090),
      ])
    ),
}
