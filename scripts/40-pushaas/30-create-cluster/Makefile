.PHONY: \
	do \
	info \
	plan-do \
	plan-undo \
	setup \
	undo

VPC := $(shell cat "../../10-vpc/10-create-vpc/terraform.tfstate" | jq -r '.outputs.vpc.value')
SUBNET := $(shell cat "../../10-vpc/10-create-vpc/terraform.tfstate" | jq -r '.outputs.subnet.value')

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
		-var-file="../../variables/aws.tfvars" \
		-var "subnet_id=$(SUBNET)" \
		-var "vpc_id=$(VPC)"

undo:
	terraform destroy \
		-auto-approve \
		-var-file="../../variables/aws.tfvars" \
		-var "subnet_id=$(SUBNET)" \
		-var "vpc_id=$(VPC)"
