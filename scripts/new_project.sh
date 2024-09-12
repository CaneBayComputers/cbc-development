#!/bin/bash

set -e

shopt -s expand_aliases

ORIG_DIR=$(pwd)

cd $(dirname "$(realpath "$0")")

cd ..

DEV_DIR=$(pwd)

source extras/.bash_aliases


# Main
cd scripts

source pre_check.sh

cd ..


# Function to display usage
usage() {
    echo "Usage: $0 <project_name>"
    exit 1
}


# Check if repository argument is provided
if [ -z "$1" ]; then
    echo "Error: Project name is required."
    usage
fi


# Assign arguments to variables
PROJECT_NAME=$1

# Convert to lowercase, replace spaces with dashes, and remove non-alphanumeric characters
PROJECT_NAME=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-_')

# Set project name
cd projects

# if [ -d "$PROJECT_NAME" ]; then
# 	echo "Error: Project name already exists"
# 	exit 1
# fi

# mkdir $PROJECT_NAME

cd $PROJECT_NAME

git init

git remote add laravel https://github.com/laravel/laravel.git

git ls-remote --heads laravel