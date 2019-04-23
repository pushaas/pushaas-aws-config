.PHONY: \
	do \
	info \
	plan-do \
	plan-undo \
	setup \
	undo

VPC := $(shell cat "../../10-vpc/10-create-vpc/terraform.tfstate" | jq -r '.modules[0].outputs.vpc.value')
SUBNET := $(shell cat "../../10-vpc/10-create-vpc/terraform.tfstate" | jq -r '.modules[0].outputs.subnet.value')

info:
	@echo "Creates hosted zone"

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
		-var "subnet_id=$(SUBNET)"

undo:
	terraform destroy \
		-auto-approve \
		-var-file="../../common.tfvars" \
		-var "vpc_id=$(VPC)" \
		-var "subnet_id=$(SUBNET)"
