#!/bin/sh

# Update & Upgrade
apt update
apt upgrade -y

# Tools
apt install -y		\
	bash		\
	bash-completion	\
	iproute2	\
	man		\
	net-tools	\
	vim		\
	exuberant-ctags	\
	openssh-server	\
	gcc		\
	make		\
	git

# Change to bash
rm /usr/bin/sh
ln -s /bin/bash /usr/bin/sh

# Add user
useradd dingtao

# Remove password
passwd -d root
passwd -d dingtao

# Personal config
su dingtao

git config --global user.email "i@dingtao.org"
git config --global user.name "Ding Tao"

