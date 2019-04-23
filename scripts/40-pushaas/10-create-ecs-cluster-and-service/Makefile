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

info:
	@echo "Create PushaaS cluster on AWS"

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
		-var "namespace_id=$(NAMESPACE)"

undo:
	terraform destroy \
		-auto-approve \
		-var-file="../../common.tfvars" \
		-var "vpc_id=$(VPC)" \
		-var "subnet_id=$(SUBNET)" \
		-var "namespace_id=$(NAMESPACE)"
