#!/bin/bash

set -e

sleep 5

if ! git config user.name; then

	echo-yellow -ne 'Enter your full name for Git commits: '

	read GIT_NAME

	echo

	git config --global user.name "$GIT_NAME"

	sudo git config --global user.name "$GIT_NAME"

fi

if ! git config user.email; then

	echo-yellow -ne 'Enter your email address for Git commits: '

	read GIT_EMAIL

	echo

	git config --global user.email $GIT_EMAIL

	sudo git config --global user.email $GIT_EMAIL

fi

sleep 5

read -n 1 -r -s -p $'Press enter to continue...\n'