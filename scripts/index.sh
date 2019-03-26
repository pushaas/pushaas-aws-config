#!/bin/sh

COMMAND=$1
DIRS=$(ls -d */)
TASK=do

if [ $COMMAND = "undo" ]; then
	DIRS=$(ls -r -d */)
	TASK=undo
fi

for DIR in $DIRS; do
	echo
	echo "======================================================="
	echo "$DIR - $(make --directory $DIR info)"
	echo "======================================================="
	echo

	make --directory $DIR $TASK
done
