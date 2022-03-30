local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local staticSite = import 'static-site/static-site.libsonnet';

staticSite {
  _config+:: {
    namespace: 'olegzaytsev-com',
    name: 'olegzaytsev-com',
    image: 'colega/olegzaytsev.com:latest',
    domains: ['olegzaytsev.com'],
    port: 8043,
    clusterIssuer: 'letsencrypt-prod',
  },

  namespace: k.core.v1.namespace.new($._config.namespace),
}
