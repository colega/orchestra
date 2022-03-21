# Wireguard setup

This requires `wireguard` kernel module on the host
```shell
sudo modprobe wireguard
echo 'wireguard' | sudo tee -a /etc/modules 
```