local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet',
      container = k.core.v1.container,
      envVar = k.core.v1.envVar,
      secret = k.core.v1.secret,
      statefulSet = k.apps.v1.statefulSet,
      volume = k.core.v1.volume,
      volumeMount = k.core.v1.volumeMount;
local mimir = import 'mimir/mimir.libsonnet';
local scaling = import 'scaling.libsonnet';

local ingress = import 'traefik/ingress.libsonnet';
local middleware = import 'traefik/middleware.libsonnet';

mimir + scaling {
  namespace: k.core.v1.namespace.new($._config.namespace),

  _images+:: {
    mimir: 'grafana/mimir:r181-760e953',
  },

  _config+:: {
    namespace: 'mimir',
    blocks_storage_backend: 'gcs',
    blocks_storage_bucket_name: 'mimir-colega',

    memberlist_ring_enabled: true,

    distributor_allow_multiple_replicas_on_same_node: true,
    ingester_allow_multiple_replicas_on_same_node: true,
    ruler_allow_multiple_replicas_on_same_node: true,
    querier_allow_multiple_replicas_on_same_node: true,
    query_frontend_allow_multiple_replicas_on_same_node: true,

    compactor_data_disk_class: 'local-path',  // k3s magic provisioned by rancher.io/local-path
    compactor_data_disk_size: '16Gi',
    ingester_data_disk_class: 'local-path',  // k3s magic provisioned by rancher.io/local-path
    ingester_data_disk_size: '8Gi',
    store_gateway_data_disk_class: 'local-path',  // k3s magic provisioned by rancher.io/local-path
    store_gateway_data_disk_size: '8Gi',
  },

  local gcsCredentialsSecretName = 'gcs-credentials-json',
  gcsCredentialsSecret: secret.new(
    gcsCredentialsSecretName,
    { 'credentials.json': std.base64(importstr 'mimir-colega-eu.secret.credentials.json') }
  ),

  local gcsContainerCredentials =
    container.withVolumeMountsMixin([volumeMount.new(gcsCredentialsSecretName, '/var/secrets/', true)]) +
    container.withEnvMixin([envVar.new('GOOGLE_APPLICATION_CREDENTIALS', '/var/secrets/credentials.json')]),

  local gcsCredentialsVolume =
    statefulSet.mixin.spec.template.spec.withVolumesMixin([
      volume.fromSecret(gcsCredentialsSecretName, gcsCredentialsSecretName),
    ]),

  compactor_container+:: gcsContainerCredentials,
  compactor_statefulset+: gcsCredentialsVolume,
  ingester_container+:: gcsContainerCredentials,
  ingester_statefulset+: gcsCredentialsVolume,
  querier_container+:: gcsContainerCredentials,
  querier_deployment+: gcsCredentialsVolume,
  store_gateway_container+:: gcsContainerCredentials,
  store_gateway_statefulset+: gcsCredentialsVolume,

  consul: {},  // TODO: make mimir jsonnet skip consul if not needed.
  etcd: {},  // TODO: I don't have etcd, so I can't enable this
  distributor_args+:: {
    'distributor.ha-tracker.enable': false,  // TODO: I don't have etcd, so I can't enable this
  },

  ingress: {
    reads: {
      local authMiddlewareName = 'basic-auth-reads',
      basic_auth_secret: secret.new(authMiddlewareName, { users: std.base64(importstr 'basic-auth-reads.secret.users.htpasswd') }),
      basic_auth: middleware.newBasicAuth(name=authMiddlewareName, secretName=authMiddlewareName, headerField='X-Scope-OrgID'),

      ingress: ingress.new(['mimir-reads.colega.eu'])
               + ingress.withMiddleware(authMiddlewareName)
               + ingress.withService('query-frontend', 8080),
    },

    writes: {
      local authMiddlewareName = 'basic-auth-writes',
      basic_auth_secret: secret.new(authMiddlewareName, { users: std.base64(importstr 'basic-auth-writes.secret.users.htpasswd') }),
      basic_auth: middleware.newBasicAuth(name=authMiddlewareName, secretName=authMiddlewareName, headerField='X-Scope-OrgID'),

      ingress: ingress.new(['mimir-writes.colega.eu'])
               + ingress.withMiddleware(authMiddlewareName)
               + ingress.withService('distributor', 8080),
    },
  },
}
