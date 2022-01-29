{
  newRedirectToHTTPS(name='redirect-https', permanent=false): {
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

  newBasicAuth(name='basic-auth', secretName='basic-auth'): {
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
