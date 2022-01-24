# tk tool charts

https://tanka.dev/helm

# Installing CRDs

Before using this lib in a cluster, we need to install the CRDs:

```shell
k apply -f ./jsonnet/lib/traefik/charts/traefik/crds/
```