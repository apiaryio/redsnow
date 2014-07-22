# RedSnow

Ruby binding for the Snow Crash library, also a thermonuclear weapon.

## Snow Crash and their dependency

    git submodule update --init --recursive


## Install

    gem install redsnow


```ruby
    require 'redsnow'

    bp = RedSnow::parse('# My API')
    puts bp.name
```

## Development & Testing at Linux

    vagrant up
