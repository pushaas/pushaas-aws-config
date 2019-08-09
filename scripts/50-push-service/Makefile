.PHONY: info
info:
	@echo "Setup infrastructure for the push service instances"

.PHONY: setup
setup: info
	@./index.sh "setup"

###################
# main
###################
.PHONY: plan-do
plan-do: info
	@./index.sh "plan-do"

.PHONY: plan-undo
plan-undo: info
	@./index.sh "plan-undo"

.PHONY: do
do:
	@./index.sh "do"

.PHONY: undo
undo:
	@./index.sh "undo"
