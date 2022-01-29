{
  redirectToHTTPSDefaultName: 'redirect-https',
  newRedirectToHTTPS(name=self.redirectToHTTPSDefaultName, permanent=false): {
    apiVersion: 'traefik.containo.us/v1alpha1',
    kind: 'Middleware',

    metadata: {
      name: name,
    },

    spec: {
      redirectScheme: {
        scheme: 'https',
        permanent: permanent,
      },
    },
  },

  basicAuthDefaultName: 'basic-auth',
  newBasicAuth(name=self.basicAuthDefaultName, secretName='basic-auth'): {
    apiVersion: 'traefik.containo.us/v1alpha1',
    kind: 'Middleware',

    metadata: {
      name: 'basic-auth',
    },
    spec: {
      basicAuth: {
        secret: 'basic-auth',
        removeHeader: true,
      },
    },
  },
}
