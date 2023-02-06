local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local policyRule = k.rbac.v1.policyRule;
local role = k.rbac.v1.role;
local roleBinding = k.rbac.v1.roleBinding;
local serviceAccount = k.core.v1.serviceAccount;
local users = import 'users/users.libsonnet';

{
  _config:: {
    namespace: 'tu-social',
  },

  namespace: k.core.v1.namespace.new($._config.namespace),

  service_accounts+: {
    [name]: {
      role:
        role.new(name)
        + role.withRulesMixin([
          policyRule.withApiGroups('*')
          + policyRule.withResources(['*'])
          + policyRule.withVerbs(['*']),
        ]),
      rolebinding:
        roleBinding.new(name)
        + roleBinding.mixin.metadata.withNamespace($._config.namespace)
        + roleBinding.mixin.roleRef.withApiGroup('rbac.authorization.k8s.io')
        + roleBinding.mixin.roleRef.withKind('Role')
        + roleBinding.mixin.roleRef.withName(name)
        + roleBinding.withSubjectsMixin({
          kind: 'ServiceAccount',
          name: name,
          namespace: 'default',
        }),
    }
    for name in users
  },
}
