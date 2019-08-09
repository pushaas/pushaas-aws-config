SUBNET := $(shell cat "../../10-vpc/10-create-vpc/terraform.tfstate" | jq -r '.outputs.subnet.value')
NAMESPACE := $(shell cat "../../30-dns/10-create-namespace/terraform.tfstate" | jq -r '.outputs.namespace.value')

CLUSTER_ID := $(shell cat "../30-create-cluster/terraform.tfstate" | jq -r '.outputs.cluster_id.value')
SG_PUSHAAS_ID := $(shell cat "../30-create-cluster/terraform.tfstate" | jq -r '.outputs.sg_pushaas_id.value')

.PHONY: info
info:
	@echo "Create PushaaS Redis service on ECS"

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
		-var-file="../../variables/pushaas_redis.tfvars" \
		-var "cluster_id=$(CLUSTER_ID)" \
		-var "namespace_id=$(NAMESPACE)" \
		-var "sg_pushaas_id=$(SG_PUSHAAS_ID)" \
		-var "subnet_id=$(SUBNET)"

.PHONY: undo
undo:
	terraform destroy \
		-auto-approve \
		-var-file="../../variables/aws.tfvars" \
		-var-file="../../variables/pushaas_redis.tfvars" \
		-var "cluster_id=$(CLUSTER_ID)" \
		-var "namespace_id=$(NAMESPACE)" \
		-var "sg_pushaas_id=$(SG_PUSHAAS_ID)" \
		-var "subnet_id=$(SUBNET)"
