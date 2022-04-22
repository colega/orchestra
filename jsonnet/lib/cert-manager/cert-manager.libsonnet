local tanka = import 'github.com/grafana/jsonnet-libs/tanka-util/main.libsonnet';
local helm = tanka.helm.new(std.thisFile);

local cluster_issuers = import 'cluster-issuers.libsonnet';

cluster_issuers {
  cert_manager: helm.template('cert-manager', './charts/cert-manager', {
    namespace: $._config.namespace,
    values: {
      installCRDs: true,
    },
  }),

  cluster_issuer_selfsigned:
    $.cluster_issuer.new('selfsigned') + {
      spec: {
        selfSigned: {},
      },
    },
}
