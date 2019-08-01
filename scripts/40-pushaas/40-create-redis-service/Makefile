.PHONY: \
	do \
	info \
	plan-do \
	plan-undo \
	setup \
	undo

SUBNET := $(shell cat "../../10-vpc/10-create-vpc/terraform.tfstate" | jq -r '.outputs.subnet.value')

CLUSTER_ID := $(shell cat "../30-create-cluster/terraform.tfstate" | jq -r '.outputs.cluster_id.value')
SG_PUSHAAS_ID := $(shell cat "../30-create-cluster/terraform.tfstate" | jq -r '.outputs.sg_pushaas_id.value')
TASK_PUSHAAS_REDIS_ARN := $(shell cat "../30-create-cluster/terraform.tfstate" | jq -r '.outputs.task_pushaas_redis_arn.value')
SERVICE_PUSHAAS_REDIS_ARN := $(shell cat "../30-create-cluster/terraform.tfstate" | jq -r '.outputs.service_pushaas_redis_arn.value')

info:
	@echo "Create PushaaS Redis service on ECS"

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
		-var-file="../../variables/pushaas_redis.tfvars" \
		-var "cluster_id=$(CLUSTER_ID)" \
		-var "sg_pushaas_id=$(SG_PUSHAAS_ID)" \
		-var "task_pushaas_redis_arn=$(TASK_PUSHAAS_REDIS_ARN)" \
		-var "service_pushaas_redis_arn=$(SERVICE_PUSHAAS_REDIS_ARN)" \
		-var "subnet_id=$(SUBNET)"

undo:
	terraform destroy \
		-auto-approve \
		-var-file="../../variables/aws.tfvars" \
		-var-file="../../variables/pushaas_redis.tfvars" \
		-var "cluster_id=$(CLUSTER_ID)" \
		-var "sg_pushaas_id=$(SG_PUSHAAS_ID)" \
		-var "task_pushaas_redis_arn=$(TASK_PUSHAAS_REDIS_ARN)" \
		-var "service_pushaas_redis_arn=$(SERVICE_PUSHAAS_REDIS_ARN)" \
		-var "subnet_id=$(SUBNET)"
