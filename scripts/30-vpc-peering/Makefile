.PHONY: \
	do \
	info \
	plan-do \
	plan-undo \
	setup \
	undo

VPC_TSURU = `cat ../10-tsuru/10-aws-tsuru-vpc/terraform.tfstate | jq '.modules[0].outputs.vpc.value'`
SUBNET_TSURU = `cat ../10-tsuru/10-aws-tsuru-vpc/terraform.tfstate | jq '.modules[0].outputs.subnet.value'`
VPC_PUSHAAS = `cat ../20-pushaas/10-aws-pushaas-cluster/terraform.tfstate | jq '.modules[0].outputs.vpc.value'`
SUBNET_PUSHAAS = `cat ../20-pushaas/10-aws-pushaas-cluster/terraform.tfstate | jq '.modules[0].outputs.subnet.value'`

info:
	@echo "Setup VPC peering between Tsuru VPC and Pushaas VPC"

setup:
	terraform init

###################
# main
###################
plan-do: info

plan-undo: info

do:
	TF_VAR_VPC_TSURU=$(VPC_TSURU) TF_VAR_SUBNET_TSURU=$(SUBNET_TSURU) TF_VAR_VPC_PUSHAAS=$(VPC_PUSHAAS) TF_VAR_SUBNET_PUSHAAS=$(SUBNET_PUSHAAS) terraform apply -auto-approve

undo:
	TF_VAR_VPC_TSURU=$(VPC_TSURU) TF_VAR_SUBNET_TSURU=$(SUBNET_TSURU) TF_VAR_VPC_PUSHAAS=$(VPC_PUSHAAS) TF_VAR_SUBNET_PUSHAAS=$(SUBNET_PUSHAAS) terraform destroy -auto-approve
