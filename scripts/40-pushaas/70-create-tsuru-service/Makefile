PASSWORD := $(shell cat ../20-create-tsuru-service-credentials/credentials | grep "PASSWORD" | cut -d "=" -f 2)
USERNAME := $(shell cat ../20-create-tsuru-service-credentials/credentials | grep "USERNAME" | cut -d "=" -f 2)

.PHONY: info
info:
	@echo "Registers a service on Tsuru target"

.PHONY: setup
setup:
	@echo "noop"

.PHONY: config
config:
	@cp template-manifest.yaml manifest.yaml
	@# thanks https://stackoverflow.com/a/12170504/1717979
	@read -p "Enter pushaas-app service public IP: " PUBLIC_IP && sed -i.bak "s/VAR_PUBLIC_IP/$$PUBLIC_IP/" manifest.yaml
	@sed -i.bak "s/VAR_USERNAME/$(USERNAME)/" manifest.yaml
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
	@tsuru service-create manifest.yaml

.PHONY: undo
undo:
	tsuru service-destroy pushaas -y
