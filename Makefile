fmt: fmt-jsonnet fmt-yaml

fmt-jsonnet:
	find . -name 'vendor' -prune \
		-o -name '*.libsonnet' -print \
		-o -name '*.jsonnet' -print \
		-exec jsonnetfmt -i {} \;

install-yamlfmt:
	go install github.com/devopyio/yamlfmt@latest

fmt-yaml:
	find . -name 'vendor' -prune \
		-o -name 'charts' -prune \
		-o -name 'chartfile.yaml' -prune \
		-o -name '*.yml' -print \
		-o -name '*.yaml' -print \
		-exec yamlfmt -f {} \;

