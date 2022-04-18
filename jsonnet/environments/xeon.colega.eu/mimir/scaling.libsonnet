local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet',
      deployment = k.apps.v1.deployment,
      statefulSet = k.apps.v1.statefulSet;
{
  compactor_container+:: k.util.resourcesRequests('100m', '128Mi'),
  compactor_statefulset+: statefulSet.mixin.spec.withReplicas(1),

  distributor_container+:: k.util.resourcesRequests('100m', '128Mi'),
  distributor_deployment+: deployment.mixin.spec.withReplicas(2),

  ingester_container+:: k.util.resourcesRequests('100m', '128Mi'),
  ingester_statefulset+: statefulSet.mixin.spec.withReplicas(3),

  querier_container+:: k.util.resourcesRequests('100m', '128Mi'),
  querier_deployment+: deployment.mixin.spec.withReplicas(2),

  query_frontend_container+:: k.util.resourcesRequests('100m', '128Mi'),
  query_frontend_deployment+: deployment.mixin.spec.withReplicas(2),

  store_gateway_container+:: k.util.resourcesRequests('100m', '128Mi'),
  store_gateway_statefulset+: statefulSet.mixin.spec.withReplicas(3),

  local smallMemcached = {
    cpu_requests:: '100m',
    memory_limit_mb:: 64,
    memory_request_overhead_mb:: 8,
    statefulSet+: statefulSet.mixin.spec.withReplicas(1),
  },

  memcached_chunks+: smallMemcached,
  memcached_frontend+: smallMemcached,
  memcached_index_queries+: smallMemcached,
  memcached_metadata+: smallMemcached,
}
