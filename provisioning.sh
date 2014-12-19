#!/bin/bash

# GCC 4.7
sudo apt-get update -y
sudo apt-get install -y python-software-properties
sudo apt-get update -y
sudo apt-get install -y build-essential git-core curl mc vim

# Ruby
gem install bundler
# RVM gpg key
gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
# RVM Install
curl -sSL https://get.rvm.io | bash -s stable
source /home/vagrant/.rvm/scripts/rvm
# Installing required packages: libreadline6-dev, zlib1g-dev, libssl-dev, libyaml-dev, libsqlite3-dev, sqlite3, autoconf, libgdbm-dev, libncurses5-dev, automake, libtool, bison, pkg-config, libffi-dev
rvm install 2.1.5
rvm ruby-2.1.5
gem install bundler
