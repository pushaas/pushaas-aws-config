VPC := $(shell cat "../../10-vpc/10-create-vpc/terraform.tfstate" | jq -r '.outputs.vpc.value')
SUBNET := $(shell cat "../../10-vpc/10-create-vpc/terraform.tfstate" | jq -r '.outputs.subnet.value')
NAMESPACE := $(shell cat "../../30-dns/10-create-namespace/terraform.tfstate" | jq -r '.outputs.namespace.value')

CLUSTER_ID := $(shell cat "../30-create-cluster/terraform.tfstate" | jq -r '.outputs.cluster_id.value')
SG_PUSHAAS_ID := $(shell cat "../30-create-cluster/terraform.tfstate" | jq -r '.outputs.sg_pushaas_id.value')

PUSHAAS_API__BASIC_AUTH_PASSWORD := $(shell cat ../20-create-tsuru-service-credentials/credentials | grep "PASSWORD" | cut -d "=" -f 2)
PUSHAAS_API__BASIC_AUTH_USER := $(shell cat ../20-create-tsuru-service-credentials/credentials | grep "USERNAME" | cut -d "=" -f 2)

AWS_ACCESS_KEY := $(shell cat ../../aws_credentials | grep aws_access_key_id | cut -d " " -f 3)
AWS_SECRET_KEY := $(shell cat ../../aws_credentials | grep aws_secret_access_key | cut -d " " -f 3)

.PHONY: info
info:
	@echo "Create PushaaS app service on ECS"

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
		-var-file="../../variables/pushaas_app.tfvars" \
		-var "aws_access_key=$(AWS_ACCESS_KEY)" \
		-var "aws_secret_key=$(AWS_SECRET_KEY)" \
		-var "basic_auth_password=$(PUSHAAS_API__BASIC_AUTH_PASSWORD)" \
		-var "basic_auth_user=$(PUSHAAS_API__BASIC_AUTH_USER)" \
		-var "cluster_id=$(CLUSTER_ID)" \
		-var "namespace_id=$(NAMESPACE)" \
		-var "sg_pushaas_id=$(SG_PUSHAAS_ID)" \
		-var "subnet_id=$(SUBNET)" \
		-var "vpc_id=$(VPC)"

.PHONY: undo
undo:
	terraform destroy \
		-auto-approve \
		-var-file="../../variables/aws.tfvars" \
		-var-file="../../variables/pushaas_app.tfvars" \
		-var "aws_access_key=$(AWS_ACCESS_KEY)" \
		-var "aws_secret_key=$(AWS_SECRET_KEY)" \
		-var "basic_auth_password=$(PUSHAAS_API__BASIC_AUTH_PASSWORD)" \
		-var "basic_auth_user=$(PUSHAAS_API__BASIC_AUTH_USER)" \
		-var "cluster_id=$(CLUSTER_ID)" \
		-var "namespace_id=$(NAMESPACE)" \
		-var "sg_pushaas_id=$(SG_PUSHAAS_ID)" \
		-var "subnet_id=$(SUBNET)" \
		-var "vpc_id=$(VPC)"
