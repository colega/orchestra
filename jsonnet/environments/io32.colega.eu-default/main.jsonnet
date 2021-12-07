local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local oauth2_proxy = import 'oauth2-proxy.libsonnet';
local prometheus = import 'prometheus-ksonnet/prometheus-ksonnet.libsonnet';

prometheus {
  _config+:: {
    cluster_name: 'io32.colega.eu',
    namespace: 'default',
  },
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

  local ingress = k.networking.v1beta1.ingress,
  local rule = k.networking.v1beta1.ingressRule,
  local path = k.networking.v1beta1.httpIngressPath,

  grafana_ingress:
    ingress.new('grafana-ingress') +
    ingress.mixin.metadata.withNamespace($._config.namespace) +
    ingress.mixin.spec.withRules(
      rule.withHost('grafana.io32.colega.eu') +
      rule.http.withPaths([
        path.withPath('/')
        + path.backend.withServiceName('grafana')
        + path.backend.withServicePort(3000),
      ])
    ),

  prometheus_ingress:
    ingress.new('prometheus-ingress') +
    ingress.mixin.metadata.withNamespace($._config.namespace) +
    ingress.mixin.spec.withRules(
      rule.withHost('prometheus.io32.colega.eu') +
      rule.http.withPaths([
        path.withPath('/')
        + path.backend.withServiceName('prometheus')
        + path.backend.withServicePort(9090),
      ])
    ),


  traefik_oauth2_ingress:
    ingress.new('traefik-oauth2-ingress') +
    ingress.mixin.metadata.withNamespace($._config.namespace) +
    ingress.mixin.spec.withRules(
      rule.withHost('traefik.io32.colega.eu') +
      rule.http.withPaths([
        path.withPath('/')
        + path.backend.withServiceName('oauth2-traefik')
        + path.backend.withServicePort(4180),
      ])
    ),

  oauth2_traefik: oauth2_proxy.new(
    namespace=$._config.namespace,
    redirect='http://traefik.io32.colega.eu/oauth2/callback',
    upstream='http://traefik.kube-system.svc.cluster.local:9000/',
    name='oauth2-traefik',
    secret_name='oauth2-traefik',
    emails=importstr 'email.txt',
  ),
}
