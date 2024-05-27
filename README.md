# A Simple, Turn-Key, Bootstrap Laravel PHP Development Environment for Windows, Linux and Mac for Beginners to Advanced Users!

If you just want to get to coding, using, practicing or checking out Laravel right away then my friend you are at the right place. If you want things to go smoothly please carefully read and **follow the instructions**. This project was designed for the absolute beginner in mind but advanced users can find this useful. This bootstrapped Laravel project tries to take all of the time consuming and difficult development environment setup down to a few simple steps.

## TLDR

Git clone this repo on an Ubuntu based Linux distribution in a `repos` folder created in the home directory then run the `./install.sh` script.

See more [Linux installation instructions below](#linux-development-option).

## Post Installation Information: PLEASE READ

After the installer is finished there will be two important folders.

`cbc-laravel-php7` and `cbc-laravel-php8`

They are located in the `repos` directory that will be created in the [Linux user home directory](https://www.computerhope.com/jargon/h/homedir.htm).

The first is Laravel 7 running on PHP 7 and the other is Laravel 11 (newest as of this writing) running on PHP 8.

Currently, the Laravel 7 folder has a pre-built, bootstrapped, web site framework.

But you can develop and code Laravel PHP in either one.


## Development Environment Options

Choose an installation option:  

- [Install on Windows](#windows-development-option)
- [Install on Linux](#linux-development-option)
- [Install on Mac](#mac-development-option)

To get to using this bootstrap environment after installing visit the [How To and Features](#how-to-and-features) section below.


### Windows Development Option

You will be installing VirtualBox which is software that enables you to run other operating systems on your current Windows system.

There are some requirements your system must meet for the virtual machine to run well.

> Minimum Requirements:
>
> 1. 8GB RAM memory
> 2. 40GB of available storage space
> 3. Quad-core CPU with virtualization (VT-x / AMD-V enabled)

DOWNLOAD ALL FILES IN THE SAME DIRECTORY!!!

Do NOT manually run any of the .exe files after downloading!

All files are safe and come from original source website.

##### Download each required file:

- [Click to download Microsoft C++ Redistributable 2019](https://aka.ms/vs/17/release/vc_redist.x64.exe)

- [Click to download VirtualBox](https://download.virtualbox.org/virtualbox/7.0.14/VirtualBox-7.0.14-161095-Win.exe)

- [Click to download VirtualBox extensions](https://download.virtualbox.org/virtualbox/7.0.14/Oracle_VM_VirtualBox_Extension_Pack-7.0.14.vbox-extpack)

- Right click [INSTALL.BAT](https://raw.githubusercontent.com/CaneBayComputers/cbc-windows-setup/main/INSTALL.BAT) and select *Save link as ...*

- [Click to download Linux Ubuntu 24](https://s3.amazonaws.com/canebaycomputers.cdn/virtual-machines/cbc-linux-ubuntu-24.ova)

Open your Downloads folder and just double-click the INSTALL.BAT file.

__BEFORE YOU RUN THE INSTALLER KEEP READING...__

A blue warning box will pop up. Just select *More Info* and select *Run anyway*.

If the Microsoft Redistributable gives you a choice to *Repair*, *Uninstall* or *Close* just select *Close*.

Do NOT run VirtualBox after installation. Uncheck box to run after install.

Just answer `y` when it asks you.

You will have to enter the default password to get into the VM:

Pass: `1234`

After the installer is finished open the pre-installed web browser, look at the bookmarks bar and select the cbc-laravel-php7 or 8 bookmark.

You can also view the database with the cbc-phpmyadmin bookmark.

The two Laravel installations can be edited in Sublime Text which is pre-installed as well.

In Sublime Text you should see the two Laravel PHP folders talked about at the [top of this readme file](#).


### Linux Development Option

You can install this Laravel PHP bootstrap development environment directly on to Linux natively or in an existing Linux virtual machine.

> It must be installed on Ubuntu or an Ubuntu variant such as but not limited to: Mint, Xubuntu, ZorinOS or PopOS.

Run the following commands in a terminal to install git version control if not installed already:

Install git:
```bash
sudo apt-get update

sudo apt-get install git
```

A `repos` directory MUST exist in your user home directory

Create the directory:

```bash
cd ~

mkdir repos
```

Clone this repo:
```bash
cd ~/repos

git clone https://github.com/CaneBayComputers/cbc-development-setup.git
```

Run installer:
```bash
cd ~/repos/cbc-development-setup

./install.sh
```

### Mac Development Option

Well, to be honest there isn't exactly one however you should be able to cobble it together by installing VirtualBox on Mac and importing one of the [Linux Ubuntu 24 OVA file](https://s3.amazonaws.com/canebaycomputers.cdn/virtual-machines/cbc-linux-ubuntu-24.ova) which will have Laravel PHP on it ready to go.



## HOW-TO AND FEATURES


### Viewing Web Pages

To view either of the bootstrap Laravel PHP 7 or PHP 8 projects in a web browser simply open the web browser and navigate to the corresponding version:

`http://cbc-laravel-php7` or `http://cbc-laravel-php8`

If you are using one of the virtual Linux machines you MUST use the browser IN the virtual machine. NOT the browser on your host machine, ie. NOT your main computer's browser.

You also MUST include the `http://` part or it will not resolve the domain correctly.

If you are using a virtual machine, by default, there should be bookmarks of these links at the top of the pre-installed browser.


### Creating Web Pages

Currently, the Laravel PHP 7 folder has a pre-built, bootstrapped, web site framework.

At the moment, to output content for the Laravel PHP 8 project you must refer to its [routing section](https://laravel.com/docs/11.x/routing).

If you have installed one of the virtual machines you can open Sublime Text.

Open the `cbc-laravel-php7` folder and go to app > resources > views > content.

The location of this folders is mentioned at the [top of this readme](#).

Page index.blade.php refers the to the home page.

Page services.blade.php refers to the 

Pages are created by naming them:  
page-name.blade.php

Creating a sub-folder will also correspond to a link folder such as:  
cbc-laravel-php8/sub-folder/page-name


### Viewing and Accessing the MySQL Database

This project uses [phpMyAdmin](https://www.phpmyadmin.net/) to manage the database server however feel free to install a different client of choice.

If you are running a virtual machine you will have to install a different client within the virtual machine and not on the host machine.

To access phpMyAdmin simply open the browser and go to `http://cbc-phpmyadmin`.

If you are running a virtual machine there is a bookmark already saved in the pre-installed browser.


### Accessing Other Pre-Installed Services

There are other services running in the background due thanks to Docker.

To access these services you can refer to them by their Docker internal IP addresses:

>10.2.0.2 - [MariaDB (MySQL)](https://mariadb.org/)  
>10.2.0.4 - [MongoDB](https://www.mongodb.com/)  
>10.2.0.5 - [Redis](https://redis.io/)  
>10.2.0.6 - [Exim4 (Email server)](https://www.exim.org/)  
>10.2.0.7 - [Memcached](https://memcached.org/)  


### MORE INFO COMING SOON ...