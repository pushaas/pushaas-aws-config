.PHONY: \
	do \
	info \
	plan-do \
	plan-undo \
	setup \
	undo

info:
	@echo "Create VPC and SUBNET on AWS"

setup:
	terraform init

###################
# main
###################
plan-do: info

plan-undo: info

do:
	terraform apply -auto-approve

undo:
	terraform destroy -auto-approve
