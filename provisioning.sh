#!/bin/bash

# GCC 4.7
sudo apt-get update -y
sudo apt-get install -y python-software-properties
sudo apt-get update -y
sudo apt-get install -y build-essential git-core curl mc vim

# Ruby
gem install bundler
# RVM
curl -sSL https://get.rvm.io | bash -s stable
/home/vagrant/.rvm/bin/rvm install 2.1.0
rvm ruby-2.1.0
gem install bundler
