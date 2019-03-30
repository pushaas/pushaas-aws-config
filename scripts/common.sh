##################
# functions
##################
ordered_dirs () {
	local DIRS=$(ls -d */ 2> /dev/null)
	local RESULT=$?
	if [ "$RESULT" -eq 0 ]; then
		echo "$DIRS"
	fi
	echo ""
}

reversed_dirs () {
	local DIRS=$(ls -d -r */ 2> /dev/null)
	local RESULT=$?
	if [ "$RESULT" -eq 0 ]; then
		echo "$DIRS"
	fi
	echo ""
}

make_children() {
	local DIRS_FUNC=$1
	local DIRS=$($DIRS_FUNC)
	local TASK=$2

	for DIR in $DIRS; do
		echo "\n================================================================================"
		echo "$TASK - $PWD/$DIR"
		echo "================================================================================\n"

		make --directory $DIR $TASK
	done
}

do_children() {
	make_children ordered_dirs "do"
}

plan_do_children() {
	make_children ordered_dirs "plan-do"
}

undo_children() {
	make_children reversed_dirs "undo"
}

plan_undo_children() {
	make_children reversed_dirs "plan-undo"
}

main() {
	local TASK=$1
	if [ "$TASK" = "do" ]; then
		do_children
	elif [ "$TASK" = "undo" ]; then
		undo_children
	elif [ "$TASK" = "plan-do" ]; then
		plan_do_children
	elif [ "$TASK" = "plan-undo" ]; then
		plan_undo_children
	else
		echo "invalid task: \"$TASK\""
		exit 1
	fi
}
