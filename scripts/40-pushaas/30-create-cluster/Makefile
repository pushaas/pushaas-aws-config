VPC := $(shell cat "../../10-vpc/10-create-vpc/terraform.tfstate" | jq -r '.outputs.vpc.value')
SUBNET := $(shell cat "../../10-vpc/10-create-vpc/terraform.tfstate" | jq -r '.outputs.subnet.value')

.PHONY: info
info:
	@echo "Create PushaaS cluster on ECS and register tasks definitions"

.PHONY: setup
setup:
	terraform init

###################
# main
###################
.PHONY: plan-do
plan-do: info

.PHONY: plan-undo
plan-undo: info

.PHONY: do
do:
	terraform apply \
		-auto-approve \
		-var-file="../../variables/aws.tfvars" \
		-var "subnet_id=$(SUBNET)" \
		-var "vpc_id=$(VPC)"

.PHONY: undo
undo:
	terraform destroy \
		-auto-approve \
		-var-file="../../variables/aws.tfvars" \
		-var "subnet_id=$(SUBNET)" \
		-var "vpc_id=$(VPC)"
