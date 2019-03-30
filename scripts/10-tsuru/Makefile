.PHONY: \
	do \
	info \
	plan-do \
	plan-undo \
	undo

info:
	@echo "Setup Tsuru infrastructure"

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
