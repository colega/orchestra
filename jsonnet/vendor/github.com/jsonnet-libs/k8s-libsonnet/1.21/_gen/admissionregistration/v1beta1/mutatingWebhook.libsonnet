{
  local d = (import 'doc-util/main.libsonnet'),
  '#':: d.pkg(name='mutatingWebhook', url='', help='MutatingWebhook describes an admission webhook and the resources and operations it applies to.'),
  '#clientConfig':: d.obj(help='WebhookClientConfig contains the information to make a TLS connection with the webhook'),
  clientConfig: {
    '#service':: d.obj(help='ServiceReference holds a reference to Service.legacy.k8s.io'),
    service: {
      '#withName':: d.fn(help='`name` is the name of the service. Required', args=[d.arg(name='name', type=d.T.string)]),
      withName(name): { clientConfig+: { service+: { name: name } } },
      '#withNamespace':: d.fn(help='`namespace` is the namespace of the service. Required', args=[d.arg(name='namespace', type=d.T.string)]),
      withNamespace(namespace): { clientConfig+: { service+: { namespace: namespace } } },
      '#withPath':: d.fn(help='`path` is an optional URL path which will be sent in any request to this service.', args=[d.arg(name='path', type=d.T.string)]),
      withPath(path): { clientConfig+: { service+: { path: path } } },
      '#withPort':: d.fn(help='If specified, the port on the service that hosting webhook. Default to 443 for backward compatibility. `port` should be a valid port number (1-65535, inclusive).', args=[d.arg(name='port', type=d.T.integer)]),
      withPort(port): { clientConfig+: { service+: { port: port } } },
    },
    '#withCaBundle':: d.fn(help="`caBundle` is a PEM encoded CA bundle which will be used to validate the webhook's server certificate. If unspecified, system trust roots on the apiserver are used.", args=[d.arg(name='caBundle', type=d.T.string)]),
    withCaBundle(caBundle): { clientConfig+: { caBundle: caBundle } },
    '#withUrl':: d.fn(help='`url` gives the location of the webhook, in standard URL form (`scheme://host:port/path`). Exactly one of `url` or `service` must be specified.\n\nThe `host` should not refer to a service running in the cluster; use the `service` field instead. The host might be resolved via external DNS in some apiservers (e.g., `kube-apiserver` cannot resolve in-cluster DNS as that would be a layering violation). `host` may also be an IP address.\n\nPlease note that using `localhost` or `127.0.0.1` as a `host` is risky unless you take great care to run this webhook on all hosts which run an apiserver which might need to make calls to this webhook. Such installs are likely to be non-portable, i.e., not easy to turn up in a new cluster.\n\nThe scheme must be "https"; the URL must begin with "https://".\n\nA path is optional, and if present may be any string permissible in a URL. You may use the path to pass an arbitrary string to the webhook, for example, a cluster identifier.\n\nAttempting to use a user or basic auth e.g. "user:password@" is not allowed. Fragments ("#...") and query parameters ("?...") are not allowed, either.', args=[d.arg(name='url', type=d.T.string)]),
    withUrl(url): { clientConfig+: { url: url } },
  },
  '#namespaceSelector':: d.obj(help='A label selector is a label query over a set of resources. The result of matchLabels and matchExpressions are ANDed. An empty label selector matches all objects. A null label selector matches no objects.'),
  namespaceSelector: {
    '#withMatchExpressions':: d.fn(help='matchExpressions is a list of label selector requirements. The requirements are ANDed.', args=[d.arg(name='matchExpressions', type=d.T.array)]),
    withMatchExpressions(matchExpressions): { namespaceSelector+: { matchExpressions: if std.isArray(v=matchExpressions) then matchExpressions else [matchExpressions] } },
    '#withMatchExpressionsMixin':: d.fn(help='matchExpressions is a list of label selector requirements. The requirements are ANDed.\n\n**Note:** This function appends passed data to existing values', args=[d.arg(name='matchExpressions', type=d.T.array)]),
    withMatchExpressionsMixin(matchExpressions): { namespaceSelector+: { matchExpressions+: if std.isArray(v=matchExpressions) then matchExpressions else [matchExpressions] } },
    '#withMatchLabels':: d.fn(help='matchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels map is equivalent to an element of matchExpressions, whose key field is "key", the operator is "In", and the values array contains only "value". The requirements are ANDed.', args=[d.arg(name='matchLabels', type=d.T.object)]),
    withMatchLabels(matchLabels): { namespaceSelector+: { matchLabels: matchLabels } },
    '#withMatchLabelsMixin':: d.fn(help='matchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels map is equivalent to an element of matchExpressions, whose key field is "key", the operator is "In", and the values array contains only "value". The requirements are ANDed.\n\n**Note:** This function appends passed data to existing values', args=[d.arg(name='matchLabels', type=d.T.object)]),
    withMatchLabelsMixin(matchLabels): { namespaceSelector+: { matchLabels+: matchLabels } },
  },
  '#objectSelector':: d.obj(help='A label selector is a label query over a set of resources. The result of matchLabels and matchExpressions are ANDed. An empty label selector matches all objects. A null label selector matches no objects.'),
  objectSelector: {
    '#withMatchExpressions':: d.fn(help='matchExpressions is a list of label selector requirements. The requirements are ANDed.', args=[d.arg(name='matchExpressions', type=d.T.array)]),
    withMatchExpressions(matchExpressions): { objectSelector+: { matchExpressions: if std.isArray(v=matchExpressions) then matchExpressions else [matchExpressions] } },
    '#withMatchExpressionsMixin':: d.fn(help='matchExpressions is a list of label selector requirements. The requirements are ANDed.\n\n**Note:** This function appends passed data to existing values', args=[d.arg(name='matchExpressions', type=d.T.array)]),
    withMatchExpressionsMixin(matchExpressions): { objectSelector+: { matchExpressions+: if std.isArray(v=matchExpressions) then matchExpressions else [matchExpressions] } },
    '#withMatchLabels':: d.fn(help='matchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels map is equivalent to an element of matchExpressions, whose key field is "key", the operator is "In", and the values array contains only "value". The requirements are ANDed.', args=[d.arg(name='matchLabels', type=d.T.object)]),
    withMatchLabels(matchLabels): { objectSelector+: { matchLabels: matchLabels } },
    '#withMatchLabelsMixin':: d.fn(help='matchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels map is equivalent to an element of matchExpressions, whose key field is "key", the operator is "In", and the values array contains only "value". The requirements are ANDed.\n\n**Note:** This function appends passed data to existing values', args=[d.arg(name='matchLabels', type=d.T.object)]),
    withMatchLabelsMixin(matchLabels): { objectSelector+: { matchLabels+: matchLabels } },
  },
  '#withAdmissionReviewVersions':: d.fn(help="AdmissionReviewVersions is an ordered list of preferred `AdmissionReview` versions the Webhook expects. API server will try to use first version in the list which it supports. If none of the versions specified in this list supported by API server, validation will fail for this object. If a persisted webhook configuration specifies allowed versions and does not include any versions known to the API Server, calls to the webhook will fail and be subject to the failure policy. Default to `['v1beta1']`.", args=[d.arg(name='admissionReviewVersions', type=d.T.array)]),
  withAdmissionReviewVersions(admissionReviewVersions): { admissionReviewVersions: if std.isArray(v=admissionReviewVersions) then admissionReviewVersions else [admissionReviewVersions] },
  '#withAdmissionReviewVersionsMixin':: d.fn(help="AdmissionReviewVersions is an ordered list of preferred `AdmissionReview` versions the Webhook expects. API server will try to use first version in the list which it supports. If none of the versions specified in this list supported by API server, validation will fail for this object. If a persisted webhook configuration specifies allowed versions and does not include any versions known to the API Server, calls to the webhook will fail and be subject to the failure policy. Default to `['v1beta1']`.\n\n**Note:** This function appends passed data to existing values", args=[d.arg(name='admissionReviewVersions', type=d.T.array)]),
  withAdmissionReviewVersionsMixin(admissionReviewVersions): { admissionReviewVersions+: if std.isArray(v=admissionReviewVersions) then admissionReviewVersions else [admissionReviewVersions] },
  '#withFailurePolicy':: d.fn(help='FailurePolicy defines how unrecognized errors from the admission endpoint are handled - allowed values are Ignore or Fail. Defaults to Ignore.', args=[d.arg(name='failurePolicy', type=d.T.string)]),
  withFailurePolicy(failurePolicy): { failurePolicy: failurePolicy },
  '#withMatchPolicy':: d.fn(help='matchPolicy defines how the "rules" list is used to match incoming requests. Allowed values are "Exact" or "Equivalent".\n\n- Exact: match a request only if it exactly matches a specified rule. For example, if deployments can be modified via apps/v1, apps/v1beta1, and extensions/v1beta1, but "rules" only included `apiGroups:["apps"], apiVersions:["v1"], resources: ["deployments"]`, a request to apps/v1beta1 or extensions/v1beta1 would not be sent to the webhook.\n\n- Equivalent: match a request if modifies a resource listed in rules, even via another API group or version. For example, if deployments can be modified via apps/v1, apps/v1beta1, and extensions/v1beta1, and "rules" only included `apiGroups:["apps"], apiVersions:["v1"], resources: ["deployments"]`, a request to apps/v1beta1 or extensions/v1beta1 would be converted to apps/v1 and sent to the webhook.\n\nDefaults to "Exact"', args=[d.arg(name='matchPolicy', type=d.T.string)]),
  withMatchPolicy(matchPolicy): { matchPolicy: matchPolicy },
  '#withName':: d.fn(help='The name of the admission webhook. Name should be fully qualified, e.g., imagepolicy.kubernetes.io, where "imagepolicy" is the name of the webhook, and kubernetes.io is the name of the organization. Required.', args=[d.arg(name='name', type=d.T.string)]),
  withName(name): { name: name },
  '#withReinvocationPolicy':: d.fn(help='reinvocationPolicy indicates whether this webhook should be called multiple times as part of a single admission evaluation. Allowed values are "Never" and "IfNeeded".\n\nNever: the webhook will not be called more than once in a single admission evaluation.\n\nIfNeeded: the webhook will be called at least one additional time as part of the admission evaluation if the object being admitted is modified by other admission plugins after the initial webhook call. Webhooks that specify this option *must* be idempotent, able to process objects they previously admitted. Note: * the number of additional invocations is not guaranteed to be exactly one. * if additional invocations result in further modifications to the object, webhooks are not guaranteed to be invoked again. * webhooks that use this option may be reordered to minimize the number of additional invocations. * to validate an object after all mutations are guaranteed complete, use a validating admission webhook instead.\n\nDefaults to "Never".', args=[d.arg(name='reinvocationPolicy', type=d.T.string)]),
  withReinvocationPolicy(reinvocationPolicy): { reinvocationPolicy: reinvocationPolicy },
  '#withRules':: d.fn(help='Rules describes what operations on what resources/subresources the webhook cares about. The webhook cares about an operation if it matches _any_ Rule. However, in order to prevent ValidatingAdmissionWebhooks and MutatingAdmissionWebhooks from putting the cluster in a state which cannot be recovered from without completely disabling the plugin, ValidatingAdmissionWebhooks and MutatingAdmissionWebhooks are never called on admission requests for ValidatingWebhookConfiguration and MutatingWebhookConfiguration objects.', args=[d.arg(name='rules', type=d.T.array)]),
  withRules(rules): { rules: if std.isArray(v=rules) then rules else [rules] },
  '#withRulesMixin':: d.fn(help='Rules describes what operations on what resources/subresources the webhook cares about. The webhook cares about an operation if it matches _any_ Rule. However, in order to prevent ValidatingAdmissionWebhooks and MutatingAdmissionWebhooks from putting the cluster in a state which cannot be recovered from without completely disabling the plugin, ValidatingAdmissionWebhooks and MutatingAdmissionWebhooks are never called on admission requests for ValidatingWebhookConfiguration and MutatingWebhookConfiguration objects.\n\n**Note:** This function appends passed data to existing values', args=[d.arg(name='rules', type=d.T.array)]),
  withRulesMixin(rules): { rules+: if std.isArray(v=rules) then rules else [rules] },
  '#withSideEffects':: d.fn(help='SideEffects states whether this webhook has side effects. Acceptable values are: Unknown, None, Some, NoneOnDryRun Webhooks with side effects MUST implement a reconciliation system, since a request may be rejected by a future step in the admission chain and the side effects therefore need to be undone. Requests with the dryRun attribute will be auto-rejected if they match a webhook with sideEffects == Unknown or Some. Defaults to Unknown.', args=[d.arg(name='sideEffects', type=d.T.string)]),
  withSideEffects(sideEffects): { sideEffects: sideEffects },
  '#withTimeoutSeconds':: d.fn(help='TimeoutSeconds specifies the timeout for this webhook. After the timeout passes, the webhook call will be ignored or the API call will fail based on the failure policy. The timeout value must be between 1 and 30 seconds. Default to 30 seconds.', args=[d.arg(name='timeoutSeconds', type=d.T.integer)]),
  withTimeoutSeconds(timeoutSeconds): { timeoutSeconds: timeoutSeconds },
  '#mixin': 'ignore',
  mixin: self,
}
