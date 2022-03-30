local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local staticSite = import 'static-site/static-site.libsonnet';

staticSite {
  _config+:: {
    namespace: 'lainiciativasecastiga-com',
    name: 'lainiciativasecastiga-com',
    image: 'colega/lainiciativasecastiga.com:latest',
    domains: ['lainiciativasecastiga.com'],
    port: 8043,
    clusterIssuer: 'letsencrypt-prod',
  },

  namespace: k.core.v1.namespace.new($._config.namespace),
}
