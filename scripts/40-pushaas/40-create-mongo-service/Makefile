.PHONY: \
	do \
	info \
	plan-do \
	plan-undo \
	setup \
	undo

SUBNET := $(shell cat "../../10-vpc/10-create-vpc/terraform.tfstate" | jq -r '.modules[0].outputs.subnet.value')

CLUSTER_ID := $(shell cat "../30-create-cluster/terraform.tfstate" | jq -r '.modules[0].outputs.cluster_id.value')
SG_PUSHAAS_ID := $(shell cat "../30-create-cluster/terraform.tfstate" | jq -r '.modules[0].outputs.sg_pushaas_id.value')
TASK_PUSHAAS_MONGO_ARN := $(shell cat "../30-create-cluster/terraform.tfstate" | jq -r '.modules[0].outputs.task_pushaas_mongo_arn.value')
SERVICE_PUSHAAS_MONGO_ARN := $(shell cat "../30-create-cluster/terraform.tfstate" | jq -r '.modules[0].outputs.service_pushaas_mongo_arn.value')

info:
	@echo "Create PushaaS Mongodb service on ECS"

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
		-var "cluster_id=$(CLUSTER_ID)" \
		-var "sg_pushaas_id=$(SG_PUSHAAS_ID)" \
		-var "task_pushaas_mongo_arn=$(TASK_PUSHAAS_MONGO_ARN)" \
		-var "service_pushaas_mongo_arn=$(SERVICE_PUSHAAS_MONGO_ARN)" \
		-var "subnet_id=$(SUBNET)"

undo:
	terraform destroy \
		-auto-approve \
		-var-file="../../common.tfvars" \
		-var "cluster_id=$(CLUSTER_ID)" \
		-var "sg_pushaas_id=$(SG_PUSHAAS_ID)" \
		-var "task_pushaas_mongo_arn=$(TASK_PUSHAAS_MONGO_ARN)" \
		-var "service_pushaas_mongo_arn=$(SERVICE_PUSHAAS_MONGO_ARN)" \
		-var "subnet_id=$(SUBNET)"
