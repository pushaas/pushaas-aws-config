.PHONY: \
	config \
	do \
	info \
	plan-do \
	plan-undo \
	setup \
	undo

PASSWORD := $$RANDOM$$RANDOM

info:
	@echo "Creates the team 'pushaas' on Tsuru target"

setup:
	@echo "noop"

###################
# main
###################
plan-do: info

plan-undo: info

do: config
	tsuru team-create pushaas-team

undo: config
	tsuru team-remove pushaas-team -y
