.PHONY: info
info:
	@echo "Create Tsuru team for developer users"

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
	tsuru team-create developers

.PHONY: undo
undo:
	tsuru team-remove developers -y
