local tanka = import 'github.com/grafana/jsonnet-libs/tanka-util/main.libsonnet';
local helm = tanka.helm.new(std.thisFile);

{
  cert_manager: helm.template('cert-manager', './charts/cert-manager', {
    namespace: 'cert-manager',  // TODO: make configurable?
    values: {
      installCRDs: true,
    },
  }),
}
