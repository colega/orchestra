local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';

local mimir = import 'mimir/mimir.libsonnet';
local scaling = import 'scaling.libsonnet';
local credentials = import 'credentials.libsonnet';
local ring = import 'ring.libsonnet';
local ingress = import 'ingress.libsonnet';

mimir + scaling + credentials + ring + ingress {
  namespace: k.core.v1.namespace.new($._config.namespace),

  _images+:: {
    mimir: 'grafana/mimir:r181-760e953',
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

  consul: null,  // TODO: make mimir jsonnet skip consul if not needed.
  etcd: null,  // TODO: I don't have etcd, so I can't enable this
  distributor_args+:: {
    'distributor.ha-tracker.enable': false,  // TODO: I don't have etcd, so I can't enable this
  },
}
