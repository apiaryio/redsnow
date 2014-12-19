
# RedSnow Installation

For installing Ruby we recommend use [RVM](https://rvm.io/rvm/install).

## Ubuntu 14.04 ([Vagrantfile](Vagrantfile))

Install ruby and prerequisites

    # GCC 4.7
    sudo apt-get update -y
    sudo apt-get install -y python-software-properties
    sudo apt-get update -y
    sudo apt-get install -y build-essential git-core curl

    # RVM gpg key
    gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3

    # RVM Install
    curl -sSL https://get.rvm.io | bash -s stable
    source ~/.rvm/scripts/rvm

    # Installing required packages: libreadline6-dev, zlib1g-dev, libssl-dev, libyaml-dev, libsqlite3-dev, sqlite3, autoconf, libgdbm-dev, libncurses5-dev, automake, libtool, bison, pkg-config, libffi-dev
    rvm install 2.1.5
    rvm ruby-2.1.5
    gem install bundler

Install RedSnow

    gem install redsnow

Run example for test

    $ ruby test/example.rb

This should be the output

    My API
    0
    8




