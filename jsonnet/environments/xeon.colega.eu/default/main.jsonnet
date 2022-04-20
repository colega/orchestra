local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet',
      configMap = k.core.v1.configMap,
      pvc = k.core.v1.persistentVolumeClaim,
      secret = k.core.v1.secret;

local promtail = import 'github.com/grafana/loki/production/ksonnet/promtail/promtail.libsonnet';
local mimir_mixin = import 'github.com/grafana/mimir/operations/mimir-mixin/mixin.libsonnet';
local traefik_mixin = import 'github.com/grafana/jsonnet-libs/traefik-mixin/mixin.libsonnet';
local prometheus = import 'prometheus-ksonnet/prometheus-ksonnet.libsonnet';
local ingress = import 'traefik/ingress.libsonnet';
local middleware = import 'traefik/middleware.libsonnet';
local grafana_agent = import 'grafana-agent/grafana-agent.libsonnet';

{
  _config+:: {
    cluster_name: 'xeon.colega.eu',
    namespace: 'default',
  },
  _images+:: {
    promtail: 'grafana/promtail:2.4.2',
    grafana_agent: 'grafana/agent:v0.23.0',
  },

  namespace: k.core.v1.namespace.new($._config.namespace),

  // See lib/grafana-agent
  grafana_agent: grafana_agent {
    _images+:: $._images,
    _config+:: {
      namespace: $._config.namespace,
      grafana_agent_yaml: import 'grafana-agent.yaml.libsonnet',
    },
  },

  // This is not just a prometheus, it's also a grafana, rules, dashboards, etc.
  prometheus: prometheus {
    _config+:: $._config {
      grafana_root_url: 'https://grafana.grafana.me',
    },
    // Increase the default 200m to avoid cpu throttling alert.
    node_exporter_container+:: k.util.resourcesLimits('500m', '100Mi'),

    prometheus+: {
      _config+: {
        prometheus_requests_cpu: '250m',
        prometheus_requests_memory: '256Mi',
        prometheus_limits_cpu: null,
        prometheus_limits_memory: '512Mi',
      },
      prometheus_pvc+:: pvc.mixin.spec.resources.withRequests({ storage: '32Gi' }),
    },

    mixins+:: {
      mimir: mimir_mixin,
      traefik: traefik_mixin,
    },
  },

  ingress: {
    local basicAuthSecretName = 'basic-auth',
    basic_auth_secret: secret.new(
      basicAuthSecretName,
      { users: std.base64(importstr 'basic-auth.secret.users.htpasswd') }
    ),
    basic_auth: middleware.newBasicAuth(secretName=basicAuthSecretName),

    grafana: ingress.new(['grafana.grafana.me'])
             + ingress.withMiddleware('basic-auth')
             + ingress.withService('grafana'),
    prometheus: ingress.new(['prometheus.grafana.me'])
                + ingress.withMiddleware('basic-auth')
                + ingress.withService('prometheus', 9090),
  },

  promtail: promtail {
    _config+:: $._config,
    promtail_config+:: {
      clients: [{
        url: 'https://logs-prod-eu-west-0.grafana.net/loki/api/v1/push',
        basic_auth: {
          username: '155183',
          password_file: '/etc/promtail_auth/api_key.yml',
        },
      }],
    },
    _images+:: $._images,

    promtailApiKeyConfigMap:
      configMap.new('grafana-cloud-mykubernetes-writes-api-key')
      + configMap.withData({
        'api_key.yml': importstr 'grafana-cloud-mykubernetes-writes-api-key.secret.api_key.yml',
      }),

    promtail_daemonset+:
      k.util.configVolumeMount('grafana-cloud-mykubernetes-writes-api-key', '/etc/promtail_auth'),
  },
}
