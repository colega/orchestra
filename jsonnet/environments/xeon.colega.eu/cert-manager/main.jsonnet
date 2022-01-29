local cert_manager = import 'cert-manager/cert-manager.libsonnet';
local default_issuers = import 'cert-manager/default-clusterissuers.libsonnet';
local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';

cert_manager + default_issuers {
  _config:: {
    namespace: 'cert-manager',
    issuer_email: 'mail@olegzaytsev.com',
  },

  namespace: k.core.v1.namespace.new($._config.namespace),

  cluster_issuer_self_signed: {
    apiVersion: 'cert-manager.io/v1',
    kind: 'ClusterIssuer',
    metadata: {
      name: 'selfsigned',
    },
    spec: {
      selfSigned: {},
    },
  },

  cluster_issuer_staging:
    self.clusterIssuer.new('letsencrypt-staging')
    + self.clusterIssuer.withACME($._config.issuer_email, 'https://acme-staging-v02.api.letsencrypt.org/directory')
    + self.clusterIssuer.withACMESolverHttp01(class='traefik'),

  cluster_issuer_prod:
    self.clusterIssuer.new('letsencrypt-prod')
    + self.clusterIssuer.withACME($._config.issuer_email)
    + self.clusterIssuer.withACMESolverHttp01(class='traefik'),
}
