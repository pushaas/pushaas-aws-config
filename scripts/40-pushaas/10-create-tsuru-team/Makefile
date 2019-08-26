PASSWORD := $$RANDOM$$RANDOM

.PHONY: info
info:
	@echo "Creates the team 'pushaas' on Tsuru target"

.PHONY: setup
setup:
	@echo "noop"

###################
# main
###################
.PHONY: plan-do
plan-do: info

.PHONY: plan-undo
plan-undo: info

.PHONY: do
do:
	tsuru team-create pushaas-team

.PHONY: undo
undo:
	tsuru team-remove pushaas-team -y
