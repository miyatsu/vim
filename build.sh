#!/bin/sh

# Update & Upgrade
apt update
apt upgrade -y
yes | unminimize

###############################################################################
###### Special package

### tzdata
#
# Note: tzdata installation requires command line interactive, handle it here
#
DEBIAN_FRONTEND=noninteractive
TZ=Asia/Shanghai

apt install -y	tzdata

###############################################################################
###### Global base tools

### shell and mutiplexing
apt install -y		\
	bash		\
	bash-completion	\
	tmux
### net related
apt install -y		\
	net-tools	\
	iproute2

### editor
apt install -y		\
	vim		\
	exuberant-ctags	\
	global

### remote ssh
apt install -y		\
	openssh-server

### helper
apt install -y		\
	man

###############################################################################
###### Dev related

### base tools
apt install -y		\
	gcc		\
	make		\
	git		\
	python3

### cross base tools
apt install -y		\
	gcc-aarch64-linux-gnu

###############################################################################
### Package dev tools

### linux
apt install -y		\
	flex		\
	bison

### edk2
apt install -y		\
	uuid-dev

### optee_os
apt install -y			\
	python3-pyelftools	\
	python3-pycryptodome

###############################################################################
###### Other stuff

# Change to bash
rm /usr/bin/sh
ln -s /bin/bash /usr/bin/sh

# Add user
adduser --quiet dingtao

# Remove password
passwd -d root
passwd -d dingtao

# Personal config
su dingtao

git config --global core.editor "vim"
git config --global user.email "miyatsu@qq.com"
git config --global user.name "Ding Tao"

