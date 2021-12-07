# k3s

Install: https://rancher.com/docs/k3s/latest/en/quick-start/

Kubeconfig: /etc/rancher/k3s/k3s.yaml

```shell
sudo cp /etc/rancher/k3s/k3s.yaml .
sudo chown oleg:oleg k3s.yaml
```

```shell
scp io32.colega.eu:k3s.yaml .kube/
vim .kube/k3s.yaml
KUBECONFIG=~/.kube/config:~/.kube/k3s.yaml kubectl config view --raw > .kube/config_k3s_new
diff .kube/config .kube/config_k3s_new
mv .kube/config ./kube/config.bak
mv .kube/config_k3s_new .kube/config
```

