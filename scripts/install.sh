#!/bin/bash

set -e

shopt -s expand_aliases

ORIG_DIR=$(pwd)

cd $(dirname "$(realpath "$0")")

cd ..

DEV_DIR=$(pwd)

source extras/.bash_aliases


# Generate stack id
STACK_ID=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8)


# Check for and set up environment variables
if ! [ -f docker-stack/.env ]; then

	cp docker-stack/.env.example docker-stack/.env

	# Generate random numbers for B and C classes
	B_CLASS=$((RANDOM % 255 + 1))
	C_CLASS=$((RANDOM % 256))

	VPC_SUBNET="10.$B_CLASS.$C_CLASS"

	sed -i "/^#VPC_SUBNET=/c\VPC_SUBNET=$VPC_SUBNET" docker-stack/.env

	sed -i "/^#STACK_ID=/c\STACK_ID=$STACK_ID" docker-stack/.env

else

	source docker-stack/.env

fi


# Check for and set up docker compose yaml
if ! [ -f docker-stack/docker-compose.yaml ]; then

	cp docker-stack/docker-compose.example.yaml docker-stack/docker-compose.yaml

	sed -i "s/STACK_ID/${STACK_ID}/g" docker-stack/docker-compose.yaml

fi


# Check and fix root perms
if [[ "$(whoami)" == "root" ]]; then

	ORIG_USER=$SUDO_USER

	# On first sudo or root run we are going to look to see if sudo group is set
	# up as NOPASSWD. If not we are going to alter the sudoers file so that it
	# is. On subsequent root runs, if sudo is already set as NOPASSWD, we are
	# going to remind user to now run as the regular user.

	SUDO_GROUP=$(cat /etc/sudoers | grep -n '%sudo' | grep 'ALL:ALL')

	if ! echo $SUDO_GROUP | grep NOPASSWD > /dev/null; then

		SUDO_GROUP_LINE=$(echo $SUDO_GROUP | cut -d : -f 1)

		sed -i "${SUDO_GROUP_LINE}s/.*/]\\%%sudo   ALL=(ALL:ALL) NOPASSWD: ALL/" /etc/sudoers

		echo; echo-green 'Password now not needed for sudo.'

		echo; echo-white 'Please run as regular user.'; echo

		exit 0

	else

		echo; echo-red "Do NOT run with sudo or as root!";

		echo; echo-white "Remove sudo or log in as regular user."; echo

		exit 1;

	fi

fi

echo; echo

echo-cyan 'Sudo password is not set.'

echo; echo-white 'If you want to remove the password requirement for sudo run this script with sudo.'

echo; echo 'Press Ctrl + C to exit script and run: sudo ./install.sh'

echo; echo

if ! sudo -v; then

	echo; echo-red "No sudo privileges. Root access required!"; echo

	exit 1;

fi

clear


# Check for Ubuntu distribution
if ! uname -a | grep Ubuntu > /dev/null; then

	if ! uname -a | grep pop-os > /dev/null; then

		echo-red "This script is for an Ubuntu based distribution!"

		exit 1

	fi

fi


# Set bash aliases
if ! [ -f ~/.bash_aliases ]; then

	echo "source $DEV_DIR/extras/.bash_aliases" > ~/.bash_aliases

else

	if ! cat ~/.bash_aliases | grep "$DEV_DIR/extras/.bash_aliases"  > /dev/null; then

		echo "source $DEV_DIR/extras/.bash_aliases" >> ~/.bash_aliases

	fi

fi

clear

echo; echo


# Welcome screen
echo "
              WELCOME TO THE DEV INSTALLER !

Leave answers blank if you do not know the info. You can re-run the
installer to enter in new info when have it."



###############################
# Initial update and package installations
###############################

echo; echo-cyan 'Updating and installing initial packages ...'

echo-white

sudo apt-get update -y

sudo apt-get -y install ca-certificates curl python3-pip python3-venv figlet mariadb-client apt-transport-https gnupg lsb-release s3fs acl unzip jq p7zip-full p7zip-rar

echo-green 'Packages installed!'; echo-white; echo



###############################
# Create ssh key
###############################
if ! [ -f ~/.ssh/id_rsa ]; then

  if ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa; then true; fi

fi



###############################
# Set up git committer info
###############################
echo; echo-cyan 'Setting up Git ...'; echo-white

if ! git config --global mergetool.keepBackup > /dev/null 2>&1; then

	git config --global mergetool.keepBackup false

fi

if ! git config --global init.defaultBranch > /dev/null 2>&1; then

	git config --global init.defaultBranch master

fi

if ! git config --global pull.rebase > /dev/null 2>&1; then

	git config --global pull.rebase false

fi

if ! git config user.name > /dev/null 2>&1; then

	echo-yellow -ne 'Enter your full name for Git commits: '

	echo-white -ne

	read GIT_NAME

	if ! [ -z "${GIT_NAME}" ]; then

		git config --global user.name "$GIT_NAME"

		sudo git config --global user.name "$GIT_NAME"

	fi

	echo

fi

if ! git config user.email > /dev/null 2>&1; then

	echo-yellow -ne 'Enter your email address for Git commits: '

	echo-white -ne

	read GIT_EMAIL

	if ! [ -z "${GIT_EMAIL}" ]; then

		git config --global user.email $GIT_EMAIL

		sudo git config --global user.email $GIT_EMAIL

	fi

	echo

fi

git --version; echo

echo-green "Git configured!"; echo-white; echo



###############################
# Set up Github
###############################
echo; echo-cyan 'Setting up Github ...'; echo-white

if ! gh --version > /dev/null 2>&1; then

	curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /usr/share/keyrings/githubcli-archive-keyring.gpg > /dev/null

	sudo apt-add-repository \
	    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main"

	sudo apt update

	sudo apt install gh

fi

if ! gh auth status > /dev/null 2>&1; then

	echo-yellow 'Choose SSH for protocol, id_rsa.pub for SSH public key and paste an authentication token:'; echo-white

	gh auth login --hostname github.com

fi

echo; echo-green "Github authentication complete!"; echo-white; echo



###############################
# AWS
###############################

echo-cyan 'Installing AWS ...'

mkdir -p ~/s3

echo-white

if ! aws --version > /dev/null 2>&1; then

	curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" > awscli-bundle.zip

	7z x awscli-bundle.zip

	rm -f awscli-bundle.zip

	sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update

	# Bug fix
	sudo chmod -R o+rx /usr/local/aws-cli/v2/current/dist

	rm -fR aws

fi

if ! aws configure get default.region > /dev/null; then

	aws configure set default.region us-east-1

fi

if ! aws configure get default.output > /dev/null; then

	aws configure set default.output json

fi

aws configure

if ! [ -f ~/.passwd-s3fs ]; then

	# Extract the AWS access key ID
	if AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id); then

		# Extract the AWS secret access key
		if AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key); then

			echo $AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY > ~/.passwd-s3fs

			chmod 600 ~/.passwd-s3fs

		fi

	fi

fi

echo

aws --version

echo

echo-green "AWS installed!"

echo-white



###############################
# Docker
###############################

echo-cyan 'Installing Docker ...'

echo-white

for PKG in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do

	if sudo apt-get -y purge $PKG; then true; fi

done

if ! [ -f /etc/apt/sources.list.d/docker.list ]; then

  sudo install -m 0755 -d /etc/apt/keyrings

  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc

  sudo chmod a+r /etc/apt/keyrings/docker.asc

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$UBUNTU_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt-get update -y -q

fi

sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo

docker --version

echo

echo-green "Docker installed!"

echo-white



###############################
# NPM / Nodejs
###############################

echo-cyan 'Installing Node / NPM ...'

echo-white

if ! command -v node > /dev/null 2>&1; then

    # Install nvm (Node Version Manager)
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash

    # Explicitly source nvm to make it available in the script
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    # Install Node.js using nvm
    nvm install 20

    # Verify Node.js installation
    node -v
fi

npm -v

echo; echo-green 'Node / NPM installed!'; echo-white; echo



###############################
# Clean up apt get stuff
###############################
echo-cyan 'Cleaning up ...'

echo-white

sudo apt-get -y -q autoremove

echo



###############################
# Hosts
###############################
echo-cyan 'Writing domain names to hosts file ...'

echo-white

while read HOST; do

	if ! cat /etc/hosts | grep "$HOST"; then

		echo "$VPC_SUBNET$HOST" | sudo tee -a /etc/hosts

	fi

done < extras/hosts.txt

echo



###############################
# Yay all done
###############################

touch is_installed



###############################
# Start services
###############################

cd scripts

source start_services.sh

cd ..



###############################
# Yay all done
###############################

cd $ORIG_DIR