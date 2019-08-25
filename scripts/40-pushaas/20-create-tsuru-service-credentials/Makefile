.PHONY: info
info:
	@echo "Create credentials for the PushaaS service and output to 'credentials' file"

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
	@rm -f ./credentials
	@echo "USERNAME=tsuru" > ./credentials
	@echo "PASSWORD=$$RANDOM$$RANDOM" >> ./credentials

.PHONY: undo
undo:
	rm -f ./credentials
