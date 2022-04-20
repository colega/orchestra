local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet',
      clusterRole = k.rbac.v1.clusterRole,
      clusterRoleBinding = k.rbac.v1.clusterRoleBinding,
      configMap = k.core.v1.configMap,
      container = k.core.v1.container,
      containerPort = k.core.v1.containerPort,
      deployment = k.apps.v1.deployment,
      policyRule = k.rbac.v1.policyRule,
      roleBinding = k.rbac.v1.roleBinding,
      serviceAccount = k.core.v1.serviceAccount;

{
  _images+:: {
    grafana_agent: 'grafana/agent:v0.23.0',
  },

  _config+:: {
    grafana_agent_yaml: error 'must provide grafana_agent_yaml contents (as an object to be rendered as YAML)',
  },

  service_account: serviceAccount.new('grafana-agent'),

  cluster_role:
    clusterRole.new('grafana-agent') +
    clusterRole.mixin.metadata.withNamespace($._config.namespace) +
    clusterRole.withRulesMixin([
      policyRule.withApiGroups('')
      + policyRule.withResources(['nodes', 'nodes/proxy', 'services', 'endpoints', 'pods'])
      + policyRule.withVerbs(['get', 'list', 'watch']),
      policyRule.withNonResourceUrls('/metrics')
      + policyRule.withVerbs(['get']),
    ]),

  cluster_role_binding:
    clusterRoleBinding.new('grafana-agent') +
    clusterRoleBinding.mixin.metadata.withNamespace($._config.namespace) +
    clusterRoleBinding.mixin.roleRef.withApiGroup('rbac.authorization.k8s.io') +
    clusterRoleBinding.mixin.roleRef.withKind('ClusterRole') +
    clusterRoleBinding.mixin.roleRef.withName('grafana-agent') +
    clusterRoleBinding.withSubjectsMixin({
      kind: 'ServiceAccount',
      name: 'grafana-agent',
      namespace: $._config.namespace,
    }),


  container::
    container.new('agent', $._images.grafana_agent)
    + container.withCommand(['/bin/agent'])
    + container.withPorts(containerPort.new('http-metrics', 12345))
    //    + container.withVolumeMountsMixin([
    //      k.core.v1.volumeMount.new('grafana-agent', '/etc/agent'),
    //    ])
    + container.withEnvMixin([
      { name: 'HOSTNAME', valueFrom: { fieldRef: { fieldPath: 'spec.nodeName' } } },
    ])
    + container.withArgsMixin([
      '-config.file=/etc/agent/agent.yaml',
    ]),


  config_map:
    configMap.new('grafana-agent')
    + configMap.withData({
      'agent.yaml': k.util.manifestYaml($._config.grafana_agent_yaml),
    }),

  deployment:
    deployment.new('grafana-agent', 1, [$.container])
    + k.util.configMapVolumeMount($.config_map, '/etc/agent'),
}
