.PHONY: info
info:
	@echo "Create Tsuru VPC and SUBNET on AWS"

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
		-var-file="../../variables/aws.tfvars"

.PHONY: undo
undo:
	terraform destroy \
		-auto-approve \
		-var-file="../../variables/aws.tfvars"
