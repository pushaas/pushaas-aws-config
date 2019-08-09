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
do: config
	tsuru team-create pushaas-team

.PHONY: undo
undo: config
	tsuru team-remove pushaas-team -y
