local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet',
      secret = k.core.v1.secret;
local k_util = import 'k-util/k-util.libsonnet';
local promtail = import 'github.com/grafana/loki/production/ksonnet/promtail/promtail.libsonnet';
local grafana_agent = import 'grafana-agent/grafana-agent.libsonnet';
{
  grafana_cloud_api_key: {
    filename:: 'api_key.txt',
    dir:: '/etc/grafana_cloud/',
    full_path:: self.dir + self.filename,

    secret: secret.new('grafana-cloud-mykubernetes-writes-api-key', {
      'api_key.txt': std.base64(importstr 'grafana-cloud-mykubernetes.secret.writes-api-key.txt'),
    }),

    secret_volume_mount_mixin:: k_util.secretVolumeMountWithHash(self.secret, self.dir),
  },

  grafana_agent: grafana_agent {
    _images+:: $._images,
    _config+:: {
      namespace: $._config.namespace,
      cluster: $._config.cluster_name,
      metrics_url: 'https://prometheus-prod-01-eu-west-0.grafana.net/api/prom/push',
      metrics_tenant_id: 312426,
      metrics_api_key_path: $.grafana_cloud_api_key.full_path,
    },
    deployment+: $.grafana_cloud_api_key.secret_volume_mount_mixin,
  },

  promtail: promtail {
    _config+:: $._config,
    promtail_config+:: {
      clients: [{
        url: 'https://logs-prod-eu-west-0.grafana.net/loki/api/v1/push',
        basic_auth: {
          username: '155183',
          password_file: $.grafana_cloud_api_key.full_path,
        },
        external_labels: { scraper: 'promtail' },
      }],
    },
    _images+:: $._images,

    promtail_daemonset+: $.grafana_cloud_api_key.secret_volume_mount_mixin,
  },
}
