local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local grafana = import 'grafana/grafana.libsonnet';
local ingress = import 'traefik/ingress.libsonnet';
local middleware = import 'traefik/middleware.libsonnet';

{
  _config+:: {
    cluster_name: 'xeon.colega.eu',
    namespace: 'covid-grafana-es',

    grafana_admin_password_secret_name: 'grafana-admin-password',
  },

  namespace: k.core.v1.namespace.new($._config.namespace),

  grafana_ingress: ingress.new(['covid.grafana.es'])
                   + ingress.withService('grafana'),

  prometheus_datasource:: grafana.datasource.new(
    'COVID-19 casos_tecnica_ccaa.csv',
    'https://cnecovid.isciii.es/covid19/resources/casos_tecnica_ccaa.csv',
    type='marcusolsson-csv-datasource',
    default=true,
  ),

  grafana_admin_password_secret:
    k.core.v1.secret.new(
      $._config.grafana_admin_password_secret_name,
      {
        password: std.base64(importstr 'grafana.secret.password.txt'),
      },
    ),

  grafana:
    grafana {
      _images+: {
        grafana: 'grafana/grafana:9.3.1',
      },
      grafana_container+:: {
        env+: [
          k.core.v1.envVar.fromSecretRef('ADMIN_PASSWORD', $._config.grafana_admin_password_secret_name, 'password'),
          { name: 'GF_INSTALL_PLUGINS', value: 'marcusolsson-csv-datasource' },
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
          home_page: '/d/covid-19-spain/',
        },
      },
    })
    + grafana.addFolder('Covid 19')
    + grafana.addDashboard('covid-19-spain', (import 'dashboards/covid-19-spain.json'), folder='Covid 19')
    + grafana.addDatasource('casos_tecnica_ccaa.csv', $.prometheus_datasource)
    + grafana.withRootUrl('https://covid.grafana.es'),
}
