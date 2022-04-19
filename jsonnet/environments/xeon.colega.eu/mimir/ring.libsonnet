{
  _config+:: {
    memberlist_ring_enabled: true,
  },

  consul: null,  // TODO: make mimir jsonnet skip consul if not needed.
  etcd: null,  // TODO: I don't have etcd, so I can't enable this.
  distributor_args+:: {
    'distributor.ha-tracker.enable': false,  // TODO: I don't have etcd, so I can't enable this.
  },
}
