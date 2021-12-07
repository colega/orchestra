Command:

```shell
kubectl create secret generic oauth2-traefik --from-env-file=oauth2_traefik.env -o yaml --dry-run -n default | tee oauth2-traefik.yaml
```

