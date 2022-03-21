local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';

{
  local container = k.core.v1.container,
  local containerPort = k.core.v1.containerPort,

  container::
    container.new('wireguard', 'masipcat/wireguard-go:latest')
    + container.withEnv([
      { name: 'LOG_LEVEL', value: 'info' },
    ])
    + container.withPorts([
      containerPort.newUDP('udp', 51820) + containerPort.withHostPort(51820),
    ])
    + container.withVolumeMountsMixin([
      k.core.v1.volumeMount.new('wireguard-config', '/etc/wireguard'),
      k.core.v1.volumeMount.new('lib-modules', '/lib/modules'),
    ])
    + container.securityContext.capabilities.withAdd('NET_ADMIN')
    + k.util.resourcesRequests('50m', '50Mi'),

  local daemonSet = k.apps.v1.daemonSet,
  local volume = k.core.v1.volume,
  daemonset:
    daemonSet.new('wireguard', [$.container])
    + daemonSet.spec.template.spec.withNodeSelectorMixin({ 'kubernetes.io/hostname': 'xeon' })
    + daemonSet.spec.template.spec.withVolumesMixin([
      volume.fromHostPath('wireguard-config', '/etc/wireguard'),
      volume.fromHostPath('lib-modules', '/lib/modules'),
    ]),
}
