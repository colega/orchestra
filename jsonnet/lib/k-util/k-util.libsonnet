local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';

{
  // secretVolumeMountWithHash is like secretVolumeMount from grafana/jsonnet-libs/ksonnet-util/util.libsonnet
  // but it also adds an annotation with the hash of the secret to the deployment (or whatever it's mixed with).
  secretVolumeMountWithHash(secret, path, defaultMode=256, volumeMountMixin={})::
    local name = secret.metadata.name;
    local annotations = { ['%s-secret-hash' % name]: std.md5(std.toString(secret)) };
    local container = k.core.v1.container,
          deployment = k.apps.v1.deployment,
          volumeMount = k.core.v1.volumeMount,
          volume = k.core.v1.volume;

    local addMount(c) = c + container.withVolumeMountsMixin(
      volumeMount.new(name, path) +
      volumeMountMixin,
    );

    deployment.mapContainers(addMount)
    + deployment.mixin.spec.template.spec.withVolumesMixin([
      volume.fromSecret(name, secretName=name) +
      volume.mixin.secret.withDefaultMode(defaultMode),
    ])
    + deployment.mixin.spec.template.metadata.withAnnotationsMixin(annotations),
}
