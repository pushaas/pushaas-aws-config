.PHONY: \
	config \
	do \
	info \
	plan-do \
	plan-undo \
	undo

VPC = `cat ../10-aws-tsuru-vpc/terraform.tfstate | jq '.modules[0].outputs.vpc.value'`
SUBNET = `cat ../10-aws-tsuru-vpc/terraform.tfstate | jq '.modules[0].outputs.subnet.value'`
ACCESS_KEY = `cat ./aws_credentials | grep aws_access_key_id | cut -d " " -f 3`
SECRET_KEY = `cat ./aws_credentials | grep aws_secret_access_key | cut -d " " -f 3`

info:
	@echo "Create a Tsuru installation on AWS"

config:
	@sed "s/VAR_VPC/$(VPC)/; s/VAR_SUBNET/$(SUBNET)/; s/VAR_ACCESS_KEY/$(ACCESS_KEY)/; s/VAR_SECRET_KEY/$(SECRET_KEY)/;" template-install-config.yml > install-config.yml

###################
# main
###################
plan-do: info

plan-undo: info

do: config
	tsuru install-create -c install-config.yml

undo: config
	tsuru install-remove -y -c install-config.yml
	sleep 5
