.PHONY: \
	do \
	info \
	plan-do \
	plan-undo \
	setup \
	undo

SUBNET := $(shell cat "../../10-vpc/10-create-vpc/terraform.tfstate" | jq -r '.outputs.subnet.value')
NAMESPACE := $(shell cat "../../30-dns/10-create-namespace/terraform.tfstate" | jq -r '.outputs.namespace.value')

CLUSTER_ID := $(shell cat "../30-create-cluster/terraform.tfstate" | jq -r '.outputs.cluster_id.value')
SG_PUSHAAS_ID := $(shell cat "../30-create-cluster/terraform.tfstate" | jq -r '.outputs.sg_pushaas_id.value')

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
		-var "namespace_id=$(NAMESPACE)" \
		-var "sg_pushaas_id=$(SG_PUSHAAS_ID)" \
		-var "subnet_id=$(SUBNET)"

undo:
	terraform destroy \
		-auto-approve \
		-var-file="../../variables/aws.tfvars" \
		-var-file="../../variables/pushaas_redis.tfvars" \
		-var "cluster_id=$(CLUSTER_ID)" \
		-var "namespace_id=$(NAMESPACE)" \
		-var "sg_pushaas_id=$(SG_PUSHAAS_ID)" \
		-var "subnet_id=$(SUBNET)"
