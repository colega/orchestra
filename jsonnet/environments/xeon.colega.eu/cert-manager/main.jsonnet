local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';

local cert_manager = import 'cert-manager/cert-manager.libsonnet';
local cluster_issuers = import 'cert-manager/cluster-issuers.libsonnet';

cert_manager + cluster_issuers {
  _config:: {
    namespace: 'cert-manager',
    issuer_email: 'mail@olegzaytsev.com',
  },

  namespace: k.core.v1.namespace.new($._config.namespace),

  cluster_issuer_staging:
    $.cluster_issuer.new('letsencrypt-staging')
    + $.cluster_issuer.withACME($._config.issuer_email, 'https://acme-staging-v02.api.letsencrypt.org/directory')
    + $.cluster_issuer.withACMESolverHttp01(class='traefik'),

  cluster_issuer_prod:
    $.cluster_issuer.new('letsencrypt-prod')
    + $.cluster_issuer.withACME($._config.issuer_email)
    + $.cluster_issuer.withACMESolverHttp01(class='traefik'),
}
