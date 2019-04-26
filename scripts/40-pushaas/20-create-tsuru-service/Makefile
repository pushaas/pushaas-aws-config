.PHONY: \
	config \
	do \
	info \
	plan-do \
	plan-undo \
	setup \
	undo

PASSWORD := $$RANDOM$$RANDOM

info:
	@echo "Registers a service on Tsuru target"

setup:
	@echo "noop"

config:
	@cp template-manifest.yaml manifest.yaml
	@sed -i.bak "s/VAR_PASSWORD/$(PASSWORD)/" manifest.yaml
	@rm manifest.yaml.bak

###################
# main
###################
plan-do: info

plan-undo: info

do: config
	tsuru service-create manifest.yaml

undo: config
	tsuru service-destroy pushaas -y
