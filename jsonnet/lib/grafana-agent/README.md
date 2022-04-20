# `grafana-agent` jsonnet lib

This is just a jsonnet-ised version of grafana-agent that is supposed to be installed when following Grafana Cloud instructions. 

It's based on https://raw.githubusercontent.com/grafana/agent/v0.23.0/production/kubernetes/agent-bare.yaml

This allows us having the grafana-agent installed from jsonnet like everything else, plus it automatically reloads the agent whenever the yaml config changes.