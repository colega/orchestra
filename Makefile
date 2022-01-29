fmt-jsonnet:
	find jsonnet/environments -name "*.jsonnet" -or -name "*.libsonnet" | xargs -n1 jsonnetfmt -i
	find jsonnet/lib -name "*.jsonnet" -or -name "*.libsonnet" | xargs -n1 jsonnetfmt -i
