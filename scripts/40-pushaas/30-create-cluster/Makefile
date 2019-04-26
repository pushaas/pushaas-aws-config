.PHONY: \
	do \
	info \
	plan-do \
	plan-undo \
	setup \
	undo

VPC := $(shell cat "../../10-vpc/10-create-vpc/terraform.tfstate" | jq -r '.modules[0].outputs.vpc.value')
SUBNET := $(shell cat "../../10-vpc/10-create-vpc/terraform.tfstate" | jq -r '.modules[0].outputs.subnet.value')
NAMESPACE := $(shell cat "../../30-dns/10-create-namespace/terraform.tfstate" | jq -r '.modules[0].outputs.namespace.value')

PUSHAAS_API__BASIC_AUTH_USER := $(shell cat ../20-create-tsuru-service/manifest.yaml | grep "username" | cut -d' ' -f2-)
PUSHAAS_API__BASIC_AUTH_PASSWORD := $(shell cat ../20-create-tsuru-service/manifest.yaml | grep "password" | cut -d' ' -f2-)

info:
	@echo "Create PushaaS cluster on ECS and register tasks definitions"

setup:
	terraform init

###################
# main
###################
plan-do: info

plan-undo: info

do:
	terraform apply \
		-auto-approve \
		-var-file="../../common.tfvars" \
		-var "vpc_id=$(VPC)" \
		-var "subnet_id=$(SUBNET)" \
		-var "namespace_id=$(NAMESPACE)" \
		-var "basic_auth_user=$(PUSHAAS_API__BASIC_AUTH_USER)" \
		-var "basic_auth_password=$(PUSHAAS_API__BASIC_AUTH_PASSWORD)"

undo:
	terraform destroy \
		-auto-approve \
		-var-file="../../common.tfvars" \
		-var "vpc_id=$(VPC)" \
		-var "subnet_id=$(SUBNET)" \
		-var "namespace_id=$(NAMESPACE)" \
		-var "basic_auth_user=$(PUSHAAS_API__BASIC_AUTH_USER)" \
		-var "basic_auth_password=$(PUSHAAS_API__BASIC_AUTH_PASSWORD)"
