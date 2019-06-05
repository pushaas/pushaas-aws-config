.PHONY: \
	do \
	info \
	plan-do \
	plan-undo \
	setup \
	undo

info:
	@echo "Create Tsuru VPC and SUBNET on AWS"

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
		-var-file="../../variables/aws.tfvars"

undo:
	terraform destroy \
		-auto-approve \
		-var-file="../../variables/aws.tfvars"
