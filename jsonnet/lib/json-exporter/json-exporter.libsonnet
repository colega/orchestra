local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet',
      container = k.core.v1.container,
      containerPort = k.core.v1.containerPort,
      configMap = k.core.v1.configMap;

{
  relabel_configs(address):: [
    {
      source_labels: ['__address__'],
      target_label: '__param_target',
    },
    {
      source_labels: ['__param_target'],
      target_label: 'instance',
    },
    {
      target_label: '__address__',
      replacement: address,
    },
  ],

  _config:: {
    image: 'quay.io/prometheuscommunity/json-exporter',
    name: 'json-exporter',
    port: 7979,
    config_yaml: error 'must specify config.yaml contents',
  },

  container::
    container.new($._config.name, $._config.image)
    + container.withPorts([containerPort.new('http', $._config.port)])
    + container.withArgsMixin([
      '--config.file=/etc/json-exporter/config.yaml',
    ])
    + k.util.resourcesRequests('50m', '32Mi'),

  configMap:
    configMap.new('%s-config' % $._config.name)
    + configMap.withData({ 'config.yaml': $._config.config_yaml }),

  deployment:
    k.apps.v1.deployment.new($._config.name, 1, [$.container])
    + k.util.configMapVolumeMount($.configMap, '/etc/json-exporter'),
  service: k.util.serviceFor($.deployment),
}
