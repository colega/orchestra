local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet',
      container = k.core.v1.container,
      envVar = k.core.v1.envVar,
      secret = k.core.v1.secret,
      statefulSet = k.apps.v1.statefulSet,
      volume = k.core.v1.volume,
      volumeMount = k.core.v1.volumeMount;

{
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
}
