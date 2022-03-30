local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';

{
  namespace: k.core.v1.namespace.new('wireguard'),

  local container = k.core.v1.container,
  local containerPort = k.core.v1.containerPort,

  container::
    container.new('wireguard', 'masipcat/wireguard-go:latest')
    + container.withEnv([
      { name: 'LOG_LEVEL', value: 'info' },
    ])
    + container.withPorts([
      containerPort.newUDP('wireguard', 51820),
    ])
    + container.withVolumeMountsMixin([
      k.core.v1.volumeMount.new('wireguard-config', '/etc/wireguard'),
      k.core.v1.volumeMount.new('lib-modules', '/lib/modules'),
    ])
    + container.securityContext.capabilities.withAdd('NET_ADMIN')
    + k.util.resourcesRequests('50m', '50Mi'),

  local deployment = k.apps.v1.deployment,
  local volume = k.core.v1.volume,
  deployment:
    deployment.new('wireguard', 1, [$.container])
    + deployment.spec.template.spec.withNodeSelectorMixin({ 'kubernetes.io/hostname': 'xeon' })
    + deployment.spec.template.spec.withVolumesMixin([
      volume.fromHostPath('wireguard-config', '/etc/wireguard'),
      volume.fromHostPath('lib-modules', '/lib/modules'),
    ]),

  local service = k.core.v1.service,
  local servicePort = k.core.v1.servicePort,
  service: service.new(
    name='wireguard',
    selector={ name: 'wireguard' },
    ports=[
      servicePort.newNamed('wireguard', 31820, 51820)
      + servicePort.withNodePort(31820)
      + servicePort.withProtocol('UDP'),
    ]
  ) + service.mixin.spec.withType('NodePort'),
}
