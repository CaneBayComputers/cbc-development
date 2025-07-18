#!/bin/bash

set -e

shopt -s expand_aliases

ORIG_DIR=$(pwd)

cd $(dirname "$(realpath "$0")")

cd ..

DEV_DIR=$(pwd)

source extras/.bash_aliases


# Pre check to make sure development is installed
cd scripts

source pre_check.sh

cd ..


# Env vars
source docker-stack/.env


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

PROJECT_DIR="projects/$PROJECT_NAME"


# Check for project folder existence
if ! [ -d "$PROJECT_DIR" ]; then

    echo-red "Project folder does not exist!"; echo-white

    exit 1

fi


# Start micro services
cd scripts

source start_services.sh

cd ..


# Shutdown project in case it is running
cd scripts

source shutdown.sh $PROJECT_NAME

cd ..


# Enter into project and get PHP version
cd "$PROJECT_DIR"

pwd; echo

if grep -q '"php":\s*"^7' composer.json; then

    PHP_VERSION="7"

elif grep -q '"php":\s*"^8' composer.json; then

    PHP_VERSION="8"

else

    echo-red "ERROR: Could not determine PHP version requirement from composer.json. Exiting."; echo-white

    exit 1

fi


# Convert dashes to underscores
PROJECT_NAME_SNAKE=$(echo "$PROJECT_NAME" | sed 's/-/_/g')


# Get a random D class number and make sure it doesn' already exist in hosts file
echo -n "Docker IP Address: "

while true; do

    D_CLASS=$((RANDOM % (250 - 100 + 1) + 100))

    IP_ADDRESS="$VPC_SUBNET.$D_CLASS"

    if ! cat /etc/hosts | grep "$IP_ADDRESS"; then break; fi

done

# Write the new project host and Docker IP address
while true; do

    HOST_LINE=$(grep -n -m 1 " $PROJECT_NAME$" /etc/hosts | cut -d : -f 1)

    if ! [[ -z $HOST_LINE ]]; then

        sudo sed -i "${HOST_LINE}d" /etc/hosts

    else

        break

    fi

done


# Enter new Docker IP address
echo "$IP_ADDRESS      $PROJECT_NAME" | sudo tee -a /etc/hosts

echo


# Set up Docker compose file
unalias cp

cp -f ../../extras/docker-compose.example.yaml docker-compose.yaml

sed -i "s/IPV4_ADDRESS/$IP_ADDRESS/g" docker-compose.yaml

sed -i "s/CONTAINER_NAME/$PROJECT_NAME/g" docker-compose.yaml

sed -i "s/STACK_ID/$STACK_ID/g" docker-compose.yaml

sed -i "s/PHP_VERSION/$PHP_VERSION/g" docker-compose.yaml

if [ -d "public" ]; then

    sed -i "s/PUBLIC//g" docker-compose.yaml

else

    sed -i "s/PUBLIC/\/public/g" docker-compose.yaml

fi

cd ../..


# Start Docker instance
cd scripts

source startup.sh --no-status $PROJECT_NAME

cd ..


# Install Composer libraries
cd "$PROJECT_DIR"

echo-cyan "Current directory: $(pwd)"; echo-white

if [ -f "composer.json" ]; then

    echo-cyan "Installing vendor libs with composer ..."; echo-white

    composer-docker install

    echo-green "Vendor libs installed!"; echo-white

fi


# Install and setup .env file
unalias cp

if [ -f ".env.example" ]; then

    echo-cyan "Setting up .env file ..."; echo-white

    cp -f .env.example .env

    APP_KEY="base64:$(head -c 32 /dev/urandom | base64)"

    sed -i "/^#*\s*APP_NAME=/c\APP_NAME=$PROJECT_NAME" .env
    sed -i "/^#*\s*APP_KEY=/c\APP_KEY=$APP_KEY" .env
    sed -i "/^#*\s*APP_URL=/c\APP_URL=http:\/\/$PROJECT_NAME" .env
    sed -i "/^#*\s*DB_CONNECTION=/c\DB_CONNECTION=mysql" .env
    sed -i "/^#*\s*DB_HOST=/c\DB_HOST=mariadb" .env
    sed -i "/^#*\s*DB_DATABASE=/c\DB_DATABASE=$PROJECT_NAME_SNAKE" .env
    sed -i "/^#*\s*CACHE_DRIVER=/c\CACHE_DRIVER=redis" .env
    sed -i "/^#*\s*SESSION_DRIVER=/c\SESSION_DRIVER=redis" .env
    sed -i "/^#*\s*QUEUE_CONNECTION=/c\QUEUE_CONNECTION=redis" .env
    sed -i "/^#*\s*CACHE_STORE=/c\CACHE_STORE=redis" .env
    sed -i "/^#*\s*CACHE_PREFIX=/c\CACHE_PREFIX=$PROJECT_NAME" .env
    sed -i "/^#*\s*MEMCACHED_HOST=/c\MEMCACHED_HOST=memcached" .env
    sed -i "/^#*\s*REDIS_HOST=/c\REDIS_HOST=redis" .env
    sed -i "/^#*\s*MAIL_MAILER=/c\MAIL_MAILER=smtp" .env
    sed -i "/^#*\s*MAIL_HOST=/c\MAIL_HOST=exim4" .env
    sed -i "/^#*\s*MAIL_PORT=/c\MAIL_PORT=25" .env
    echo "" >> .env
    echo "XDG_CONFIG_HOME=/usr/share/nginx/html/storage/app" >> .env

    echo-green "The .env file has been created!"; echo-white

# Install config.inc file
elif [ -f "config.example.inc.php" ]; then

    cp -f config.example.inc.php config.inc.php

    sed -i "s/DB_HOSTNAME/mariadb/" config.inc.php
    sed -i "s/DB_USERNAME/root/" config.inc.php
    sed -i "s/DB_PASSWORD//" config.inc.php
    sed -i "s/DB_NAME/$PROJECT_NAME_SNAKE/" config.inc.php

# Install wp-config file
elif [ -f "wp-config-sample.php" ]; then

    if ! wp --version > /dev/null 2>&1; then

        curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

        chmod +x wp-cli.phar

        sudo mv wp-cli.phar /usr/local/bin/wp

    fi

    wp --version

    if ! wp core is-installed > /dev/null 2>&1; then

        wp config create --dbname="$PROJECT_NAME_SNAKE" --dbuser="root" --dbpass="" --dbhost="mariadb" --force

    fi

fi

echo; echo


# Make storage writable for all
if [ -d "storage" ]; then

    echo-cyan 'Setting folder permissions ...'; echo-white

    find storage -type d -exec chmod 777 {} +

    find storage -type d -exec setfacl -m "default:group::rw" {} +

    echo-green 'Storage folder permissions set!'; echo-white

fi

# NOT CONVINCED THIS IS NECESSARY
# if [ -d "bootstrap" ]; then

#     chmod 777 bootstrap/cache

# fi


# Create new database, run migration and seed
echo-cyan "Creating database $PROJECT_NAME_SNAKE ..."; echo-white

mysql -h"mariadb" -u"root" -e "CREATE DATABASE IF NOT EXISTS $PROJECT_NAME_SNAKE;"

echo-green 'Database created!'; echo-white

if [ -f "artisan" ]; then

    echo-cyan 'Running migrations ...'; echo-white

    if art-docker migrate:fresh; then

        echo-green 'Migrations successful'; echo-white

        echo-cyan 'Seeding database ...'; echo-white

        if art-docker db:seed; then

            echo-green 'Database seeded!'; echo-white

        fi

    fi

elif [ -f "create_tables.sql" ]; then

    echo-cyan 'Creating tables ...'; echo-white

    mysql -h"mariadb" -u"root" $PROJECT_NAME_SNAKE < create_tables.sql

fi

echo; echo


# Show status of running Docker project
cd ../../scripts

source status.sh $PROJECT_NAME


# Return to original directory
cd $ORIG_DIR
