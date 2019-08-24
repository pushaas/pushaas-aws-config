.PHONY: info
info:
	@echo "Create Tsuru roles for users to create apps and services"

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
	tsuru role-add team-member team
	tsuru role-permission-add team-member app.build app.create app.delete app.deploy app.read app.run app.update service-instance

.PHONY: undo
undo:
	tsuru role-remove team-member -y
