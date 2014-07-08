#!/bin/bash

# GCC 4.7
sudo apt-get update -y
sudo apt-get install -y python-software-properties
sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
sudo apt-get update -y
sudo apt-get install -y gcc-4.7 g++-4.7 gdb build-essential git-core curl mc vim
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.6 60 --slave /usr/bin/g++ g++ /usr/bin/g++-4.6
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.7 70 --slave /usr/bin/g++ g++ /usr/bin/g++-4.7

#sudo update-alternatives --config gcc

# Ruby
gem install bundler
# RVM
curl -sSL https://get.rvm.io | bash -s stable
/home/vagrant/.rvm/bin/rvm install 2.1.0
rvm ruby-2.1.0
gem install bundler
