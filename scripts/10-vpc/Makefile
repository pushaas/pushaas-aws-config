.PHONY: \
	do \
	info \
	plan-do \
	plan-undo \
	setup \
	undo

info:
	@echo "Setup infrastructure for the PushaaS service"

setup: info
	@./index.sh "setup"

###################
# main
###################
plan-do: info
	@./index.sh "plan-do"

plan-undo: info
	@./index.sh "plan-undo"

do:
	@./index.sh "do"

undo:
	@./index.sh "undo"
