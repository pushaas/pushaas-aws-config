.PHONY: \
	do \
	info \
	setup \
	undo

info:
	@echo "will create VPC and SUBNET on AWS"

setup:
	terraform init

do:
	terraform apply -auto-approve

undo:
	terraform destroy -auto-approve
