local k = import 'ksonnet-util/kausal.libsonnet';

{
  new(namespace='', redirect='', upstream='', name='oauth2-proxy', secret_name='oauth2-proxy', emails=''):: {
    local instance = self,

    _images+:: {
      oauth2_proxy: 'quay.io/oauth2-proxy/oauth2-proxy:v7.1.3',
    },

    local container = k.core.v1.container,
    local containerPort = k.core.v1.containerPort,
    local envFrom = k.core.v1.envFromSource,

    oauth2_proxy_container::
      container.new(name, instance._images.oauth2_proxy) +
      container.withPorts(containerPort.new('http', 4180)) +
      container.withArgs([
        '--http-address=0.0.0.0:4180',
        '--redirect-url=' + redirect,
        '--upstream=' + upstream,
        '--authenticated-emails-file=/etc/oauth2/emails.txt',
        '--cookie-secure=false', // TODO until we have ssl
      ]) +
      container.withEnvFrom(
        envFrom.secretRef.withName(secret_name),
      ),

    local deployment = k.apps.v1.deployment,
    oauth2_proxy_deployment:
      deployment.new(name, 1, [instance.oauth2_proxy_container])
      + k.util.configVolumeMount(name + '-emails', '/etc/oauth2/'),

    oauth2_proxy_service:
      k.util.serviceFor(instance.oauth2_proxy_deployment),

    local configMap = k.core.v1.configMap,
    oauth2_proxy_emails_secret:
      configMap.new(name + '-emails')
      + configMap.mixin.metadata.withNamespace(namespace)
      + configMap.withData({
        'emails.txt': emails,
      }),
  },
}
