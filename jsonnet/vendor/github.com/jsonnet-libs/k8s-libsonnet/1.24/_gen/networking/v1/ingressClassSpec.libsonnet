{
  local d = (import 'doc-util/main.libsonnet'),
  '#':: d.pkg(name='ingressClassSpec', url='', help='"IngressClassSpec provides information about the class of an Ingress."'),
  '#parameters':: d.obj(help='"IngressClassParametersReference identifies an API object. This can be used to specify a cluster or namespace-scoped resource."'),
  parameters: {
    '#withApiGroup':: d.fn(help='"APIGroup is the group for the resource being referenced. If APIGroup is not specified, the specified Kind must be in the core API group. For any other third-party types, APIGroup is required."', args=[d.arg(name='apiGroup', type=d.T.string)]),
    withApiGroup(apiGroup): { parameters+: { apiGroup: apiGroup } },
    '#withKind':: d.fn(help='"Kind is the type of resource being referenced."', args=[d.arg(name='kind', type=d.T.string)]),
    withKind(kind): { parameters+: { kind: kind } },
    '#withName':: d.fn(help='"Name is the name of resource being referenced."', args=[d.arg(name='name', type=d.T.string)]),
    withName(name): { parameters+: { name: name } },
    '#withNamespace':: d.fn(help='"Namespace is the namespace of the resource being referenced. This field is required when scope is set to \\"Namespace\\" and must be unset when scope is set to \\"Cluster\\"."', args=[d.arg(name='namespace', type=d.T.string)]),
    withNamespace(namespace): { parameters+: { namespace: namespace } },
    '#withScope':: d.fn(help='"Scope represents if this refers to a cluster or namespace scoped resource. This may be set to \\"Cluster\\" (default) or \\"Namespace\\"."', args=[d.arg(name='scope', type=d.T.string)]),
    withScope(scope): { parameters+: { scope: scope } },
  },
  '#withController':: d.fn(help='"Controller refers to the name of the controller that should handle this class. This allows for different \\"flavors\\" that are controlled by the same controller. For example, you may have different Parameters for the same implementing controller. This should be specified as a domain-prefixed path no more than 250 characters in length, e.g. \\"acme.io/ingress-controller\\". This field is immutable."', args=[d.arg(name='controller', type=d.T.string)]),
  withController(controller): { controller: controller },
  '#mixin': 'ignore',
  mixin: self,
}
