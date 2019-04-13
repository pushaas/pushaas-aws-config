.PHONY: \
	do \
	info \
	plan-do \
	plan-undo \
	setup \
	undo

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
	terraform apply -auto-approve

undo:
	terraform destroy -auto-approve
