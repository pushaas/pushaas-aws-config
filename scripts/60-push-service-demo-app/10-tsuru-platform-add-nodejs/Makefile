.PHONY: info
info:
	@echo "Add nodejs platform to Tsuru"

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
	tsuru platform-add nodejs

.PHONY: undo
undo:
	tsuru platform-remove nodejs -y
