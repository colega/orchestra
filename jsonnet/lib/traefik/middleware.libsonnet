{
  basicAuthDefaultName: 'basic-auth',
  newBasicAuth(name=self.basicAuthDefaultName, secretName='basic-auth', headerField=null): {
    apiVersion: 'traefik.containo.us/v1alpha1',
    kind: 'Middleware',

    metadata: {
      name: name,
    },
    spec: {
      basicAuth: {
        secret: secretName,
        removeHeader: true,
        [if headerField != null then 'headerField']: headerField,
      },
    },
  },
}
