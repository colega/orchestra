local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local grafana = import 'grafana/grafana.libsonnet';
local json_exporter = import 'json-exporter/json-exporter.libsonnet';
local prometheus = import 'prometheus/prometheus.libsonnet';
local ingress = import 'traefik/ingress.libsonnet';
local middleware = import 'traefik/middleware.libsonnet';

{
  _config+:: {
    cluster_name: 'xeon.colega.eu',
    namespace: 'climbing-grafana-es',

    grafana_admin_password_secret_name: 'grafana-admin-password',
  },

  namespace: k.core.v1.namespace.new($._config.namespace),

  grafana_ingress: ingress.new(['climbing.grafana.es'])
                   + ingress.withService('grafana'),

  mimir_datasource:: grafana.datasource.new('climbing @ mimir-reads.colega.eu', 'https://mimir-reads.colega.eu/prometheus', type='prometheus', default=true)
                     + grafana.datasource.withBasicAuth('climbing', importstr 'mimir-reads-climbing.secret.password.txt'),

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
          home_page: '/d/climbing-madrid/?kiosk=tv',
        },
      },
    })
    + grafana.addFolder('Climbing')
    + grafana.addDashboard('climbing-madrid', (import 'dashboards/climbing-madrid.json'), folder='Climbing')
    + grafana.addDatasource('mimir-reads.colega.eu', $.mimir_datasource)
    + grafana.withRootUrl('https://climbing.grafana.es'),


  json_exporters: {
    sputnik_alcobendas: json_exporter {
      scrape_address:: 'https://clientes.sputnikclimbing.com/ScheduleV2/GetPeopleInTheGym',
      _config+:: {
        name: 'json-exporter-sputnik-alcobendas-climbing',
        config_yaml: importstr 'json_exporter_sputnik_alcobendas.yaml',
      },
    },
    sputnik_lasrozas: json_exporter {
      scrape_address:: 'https://clientes.sputnikclimbing.com/ScheduleV2/GetPeopleInTheGym',
      _config+:: {
        name: 'json-exporter-sputnik-lasrozas-climbing',
        config_yaml: importstr 'json_exporter_sputnik_lasrozas.yaml',
      },
    },
  },

  prometheus: prometheus {
    _config+:: {
      name: 'prometheus-%s' % $._config.namespace,
      namespace: $._config.namespace,
      prometheus_requests_cpu: '100m',
      prometheus_requests_memory: '128Mi',
      prometheus_limits_cpu: null,
      prometheus_limits_memory: '256Mi',
    },
    prometheus_config+:: {
      global: {
        scrape_interval: '60s',
      },
      remote_write: [
        {
          name: 'climbing@mimir-writes.colega.eu',
          url: 'https://mimir-writes.colega.eu/api/v1/push',
          basic_auth: {
            username: 'climbing',
            password: importstr 'mimir-writes-climbing.secret.password.txt',
          },
        },
      ],
    },
    scrape_configs:: {
      'sputnik-alcobendas-climbing': {
        job_name: 'sputnik-alcobendas-climbing',
        metrics_path: '/probe',
        static_configs: [{ targets: [$.json_exporters.sputnik_alcobendas.scrape_address] }],
        relabel_configs: json_exporter.relabel_configs('json-exporter-sputnik-alcobendas-climbing:7979'),
      },
      'sputnik-lasrozas-climbing': {
        job_name: 'sputnik-lasrozas-climbing',
        metrics_path: '/probe',
        static_configs: [{ targets: [$.json_exporters.sputnik_lasrozas.scrape_address] }],
        relabel_configs: json_exporter.relabel_configs('json-exporter-sputnik-lasrozas-climbing:7979'),
      },
    },
    prometheus_pvc+::
      k.core.v1.persistentVolumeClaim.mixin.spec.resources.withRequests({ storage: '512Mi' }),
  },
}
