// Brought from:
// https://github.com/grafana/jsonnet-libs/blob/master/cert-manager/default_clusterissuers.libsonnet
// But updated api version
{
  cluster_issuer_selfsigned:
    $.cluster_issuer.new('selfsigned') + {
      spec: {
        selfSigned: {},
      },
    },

  cluster_issuer:: {
    new(name): {
      apiVersion: 'cert-manager.io/v1',
      kind: 'ClusterIssuer',
      metadata: {
        name: name,
      },
    },
    withACME(email, server='https://acme-v02.api.letsencrypt.org/directory'): {
      local name = super.metadata.name,
      spec+: {
        acme: {
          // You must replace this email address with your own.
          // Let's Encrypt will use this to contact you about expiring
          // certificates, and issues related to your account.
          email: email,
          server: server,
          privateKeySecretRef: {
            // Secret resource used to store the account's private key.
            name: '%s-account' % name,
          },
        },
      },
    },
    reuseAccount(secret_name): {
      spec+: {
        acme+: {
          // re-use an existing account
          // https://cert-manager.io/docs/configuration/acme/#reusing-an-acme-account
          disableAccountKeyGeneration: true,
          privateKeySecretRef: {
            // Secret resource used to retrieve the account's private key.
            name: secret_name,
          },
        },
      },
    },
    withACMESolverHttp01(class='nginx'): {
      spec+: {
        acme+: {
          // Add a single challenge solver, HTTP01 using nginx
          solvers: [
            {
              http01: {
                ingress: {
                  class: class,
                },
              },
            },
          ],
        },
      },
    },
  },
}
