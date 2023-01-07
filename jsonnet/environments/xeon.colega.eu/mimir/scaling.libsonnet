local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet',
      deployment = k.apps.v1.deployment,
      statefulSet = k.apps.v1.statefulSet;
{
  _config+:: {
    distributor_allow_multiple_replicas_on_same_node: true,
    ingester_allow_multiple_replicas_on_same_node: true,
    querier_allow_multiple_replicas_on_same_node: true,
    query_frontend_allow_multiple_replicas_on_same_node: true,
    ruler_allow_multiple_replicas_on_same_node: true,
    store_gateway_allow_multiple_replicas_on_same_node: true,
  },

  compactor_container+::
    k.util.resourcesRequests('100m', '128Mi')
    + k.util.resourcesLimits(null, '1Gi'),
  compactor_statefulset+: statefulSet.mixin.spec.withReplicas(1),

  distributor_container+::
    k.util.resourcesRequests('100m', '256Mi')
    + k.util.resourcesLimits(null, '1Gi'),
  distributor_args+: { 'mem-ballast-size-bytes': '0' },
  distributor_deployment+: deployment.mixin.spec.withReplicas(2),

  ingester_container+::
    k.util.resourcesRequests('100m', '128Mi')
    + k.util.resourcesLimits(null, '1Gi'),
  ingester_statefulset+: statefulSet.mixin.spec.withReplicas(3),

  querier_container+::
    k.util.resourcesRequests('100m', '256Mi')
    + k.util.resourcesLimits(null, '1Gi'),
  querier_deployment+: deployment.mixin.spec.withReplicas(2),

  query_frontend_container+::
    k.util.resourcesRequests('100m', '128Mi')
    + k.util.resourcesLimits(null, '512Mi'),
  query_frontend_deployment+: deployment.mixin.spec.withReplicas(2),

  store_gateway_container+::
    k.util.resourcesRequests('100m', '128Mi')
    + k.util.resourcesLimits(null, '1Gi'),
  store_gateway_statefulset+: statefulSet.mixin.spec.withReplicas(3),

  query_scheduler_deployment+: deployment.mixin.spec.withReplicas(1),
  query_scheduler_container+::
    k.util.resourcesRequests('100m', '64Mi')
    + k.util.resourcesLimits(null, '512Mi'),

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
