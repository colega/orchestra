local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';

{
  local container = k.core.v1.container,
  local containerPort = k.core.v1.containerPort,

  json_write_proxy_container::
    container.new('json-write-proxy', 'colega/prometheus-json-remote-write-proxy:latest')
    + container.withImagePullPolicy('Always')
    + container.withPorts([containerPort.new('http-metrics', 9091)])
    + container.withArgsMixin(k.util.mapToFlags({
      '-path': '/api/v1/json/push',
      '-log-headers': 'X-Scope-OrgID',
      '-forward-headers': 'X-Scope-OrgID',
      '-remote-write-address': 'http://distributor:8080/api/v1/push',
    }))
    + k.util.resourcesRequests('50m', '50Mi'),

  json_write_proxy_deployment: k.apps.v1.deployment.new('json-write-proxy', 1, [$.json_write_proxy_container]),
  json_write_proxy_service: $.util.serviceFor($.json_write_proxy_deployment),
}
