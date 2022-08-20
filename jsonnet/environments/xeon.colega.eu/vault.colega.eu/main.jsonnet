local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet',
      container = k.core.v1.container,
      containerPort = k.core.v1.containerPort,
      configMap = k.core.v1.configMap,
      pvc = k.core.v1.persistentVolumeClaim,
      statefulSet = k.apps.v1.statefulSet,
      volumeMount = k.core.v1.volumeMount;

local ingress = import 'traefik/ingress.libsonnet';

{
  _images+:: {
    vaultwarden: 'vaultwarden/server:1.25.2',
  },

  _config+:: {
    cluster_name: 'xeon.colega.eu',
    namespace: 'vault-colega-eu',

    pvc_size+: '8Gi',
    pvc_class+: 'local-path',
  },

  namespace: k.core.v1.namespace.new($._config.namespace),

  local data_pvc =
    pvc.new() +
    pvc.mixin.spec.resources.withRequests({ storage: $._config.pvc_size }) +
    pvc.mixin.spec.withAccessModes(['ReadWriteOnce']) +
    pvc.mixin.spec.withStorageClassName($._config.pvc_class) +
    pvc.mixin.metadata.withName('vaultwarden-data'),

  vaultwarden+: {
    container::
      container.new('vaultwarden', $._images.vaultwarden)
      + container.withPorts([containerPort.new('http', 80)])
      + container.withVolumeMountsMixin([volumeMount.new('vaultwarden-data', '/data')])
      + k.util.resourcesRequests('500m', '256Mi'),

    statefulSet:
      statefulSet.new('vaultwarden', 1, [self.container], data_pvc)
      + statefulSet.mixin.spec.withServiceName('vaultwarden'),

    service: k.util.serviceFor(self.statefulSet),

    ingress: ingress.new(['vault.colega.eu'])
             + ingress.withService('vaultwarden', 'vaultwarden-http'),
  },
}
