local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local grafana = import 'grafana/grafana.libsonnet';
local ingress = import 'traefik/ingress.libsonnet';
local middleware = import 'traefik/middleware.libsonnet';

{
  _config+:: {
    cluster_name: 'xeon.colega.eu',
    namespace: 'climbing-grafana-es',

    prometheus_url: 'https://prometheus.colega.eu',

    grafana_admin_password_secret_name: 'grafana-admin-password',
  },

  namespace: k.core.v1.namespace.new($._config.namespace),

  grafana_ingress: ingress.new(['climbing.grafana.es'])
                   + ingress.withService('grafana'),

  prometheus_datasource:: grafana.datasource.new('prometheus', $._config.prometheus_url, type='prometheus', default=true),

  grafana_admin_password_secret:
    k.core.v1.secret.new(
      $._config.grafana_admin_password_secret_name,
      {
        password: std.base64(importstr 'grafana.secret.password.txt'),
      },
    ),

  grafana:
    grafana {
      grafana_container+:: {
        env+: [
          k.core.v1.envVar.fromSecretRef('ADMIN_PASSWORD', $._config.grafana_admin_password_secret_name, 'password'),
        ],
      },
    }
    + grafana.withGrafanaIniConfig({
      sections+: {
        'auth.anonymous': {
          enabled: true,
          org_role: 'Viewer',
          hide_version: true,
        },
        security: {
          admin_password: '${ADMIN_PASSWORD}',
        },
        alerting: {
          enabled: false,
        },
        explore: {
          enabled: false,
        },
        users+: {
          // https://climbing.grafana.es
          home_page: '/d/climbing-madrid/?kiosk=tv',
        },
        dashboards+: {
          // hacky, this is where it will be mounted, unless there are too many dashboards in that folder and it might not be in 0.
          // default_home_dashboard_path: '/grafana/dashboards-climbing/dashboards-climbing-0/climbing-madrid.json',
        },
      },
    })
    + grafana.addFolder('Climbing')
    + grafana.addDashboard('climbing-madrid', (import 'dashboards/climbing-madrid.json'), folder='Climbing')
    + grafana.addDatasource('prometheus', $.prometheus_datasource)
    + grafana.withRootUrl('https://climbing.grafana.es'),
}
