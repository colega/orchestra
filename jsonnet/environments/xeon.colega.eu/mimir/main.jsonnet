local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';

local credentials = import 'credentials.libsonnet';
local ingress = import 'ingress.libsonnet';
local mimir = import 'mimir/mimir.libsonnet';
local ring = import 'ring.libsonnet';
local scaling = import 'scaling.libsonnet';

mimir + scaling + credentials + ring + ingress {
  namespace: k.core.v1.namespace.new($._config.namespace),

  _images+:: {
    mimir: 'grafana/mimir:r183-5299284',
  },

  _config+:: {
    namespace: 'mimir',
    blocks_storage_backend: 'gcs',
    blocks_storage_bucket_name: 'mimir-colega',

    compactor_data_disk_class: 'local-path',  // k3s magic provisioned by rancher.io/local-path
    compactor_data_disk_size: '16Gi',
    ingester_data_disk_class: 'local-path',  // k3s magic provisioned by rancher.io/local-path
    ingester_data_disk_size: '8Gi',
    store_gateway_data_disk_class: 'local-path',  // k3s magic provisioned by rancher.io/local-path
    store_gateway_data_disk_size: '8Gi',
  },
}
