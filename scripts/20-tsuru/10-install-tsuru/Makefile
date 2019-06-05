.PHONY: \
	config \
	do \
	info \
	plan-do \
	plan-undo \
	setup \
	undo

VPC := $(shell cat "../../10-vpc/10-create-vpc/terraform.tfstate" | jq -r '.outputs.vpc.value')
SUBNET := $(shell cat "../../10-vpc/10-create-vpc/terraform.tfstate" | jq -r '.outputs.subnet.value')
ACCESS_KEY := $(shell cat ../../aws_credentials | grep aws_access_key_id | cut -d " " -f 3)
SECRET_KEY := $(shell cat ../../aws_credentials | grep aws_secret_access_key | cut -d " " -f 3)

info:
	@echo "Create a Tsuru installation on AWS"

setup:
	@echo "noop"

config:
	@cp template-install-config.yml install-config.yml
	@sed -i.bak "s/VAR_VPC/$(VPC)/" install-config.yml
	@sed -i.bak "s/VAR_SUBNET/$(SUBNET)/" install-config.yml
	@sed -i.bak "s/VAR_ACCESS_KEY/$(ACCESS_KEY)/" install-config.yml
	@sed -i.bak "s~VAR_SECRET_KEY~$(SECRET_KEY)~" install-config.yml
	@rm install-config.yml.bak

###################
# main
###################
plan-do: info

plan-undo: info

do: config
	tsuru install-create -c install-config.yml

undo: config
	tsuru install-remove -y -c install-config.yml
