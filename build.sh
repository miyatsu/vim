#!/bin/sh

# Update & Upgrade
apt update
apt upgrade -y

# Special package
DEBIAN_FRONTEND=noninteractive
TZ=Asia/Shanghai

apt install -y	tzdata

# Tools
apt install -y		\
	bash		\
	bash-completion	\
	iproute2	\
	man		\
	net-tools	\
	vim		\
	tmux		\
	exuberant-ctags	\
	openssh-server	\
	gcc		\
	make		\
	git

# Change to bash
rm /usr/bin/sh
ln -s /bin/bash /usr/bin/sh

# Add user
adduser --quit dingtao

# Remove password
passwd -d root
passwd -d dingtao

# Personal config
su dingtao

git config --global user.email "i@dingtao.org"
git config --global user.name "Ding Tao"

