fmt-jsonnet:
	find . -name 'vendor' -prune -o -name '*.libsonnet' -print -o -name '*.jsonnet' -print -exec jsonnetfmt -i {} \;
