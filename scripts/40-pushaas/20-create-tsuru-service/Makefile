PASSWORD := $$RANDOM$$RANDOM

.PHONY: info
info:
	@echo "Registers a service on Tsuru target"

.PHONY: setup
setup:
	@echo "noop"

.PHONY: config
config:
	@cp template-manifest.yaml manifest.yaml
	@sed -i.bak "s/VAR_PASSWORD/$(PASSWORD)/" manifest.yaml
	@rm manifest.yaml.bak

###################
# main
###################
.PHONY: plan-do
plan-do: info

.PHONY: plan-undo
plan-undo: info

.PHONY: do
do: config
	tsuru service-create manifest.yaml

.PHONY: undo
undo: config
	tsuru service-destroy pushaas -y
