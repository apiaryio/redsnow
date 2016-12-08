![logo](https://raw.github.com/apiaryio/api-blueprint/master/assets/logo_apiblueprint.png)

# RedSnow [![Build Status](https://travis-ci.org/apiaryio/redsnow.png?branch=master)](https://travis-ci.org/apiaryio/redsnow)
### API Blueprint Parser for Ruby

**NOTE**: *This library is deprecated and unmaintained. We recommend using [drafter](https://github.com/apiaryio/drafter) directly via [libffi](https://github.com/ffi/ffi/wiki).*

Ruby binding for the [Snow Crash](https://github.com/apiaryio/snowcrash) library, also a thermonuclear weapon.

API Blueprint is Web API documentation language. You can find API Blueprint documentation on the [API Blueprint site](http://apiblueprint.org).

## Install
The best way to install RedSnow is by using its [GEM package](https://rubygems.org/gems/redsnow).

    gem install redsnow

Installation instructions for Ubuntu 14.04 are described in detail [here](Installation.md).

## Documentation

- [Documentation at rubydoc](http://rubydoc.info/gems/redsnow/)

## Getting started

```ruby
require 'redsnow'

result = RedSnow.parse('# My API', exportSourcemap: true)
puts result.ast.name
puts result.sourcemap.name
```

## Parsing options

Options can be number or hash. We support `:requireBlueprintName` and `:exportSourcemap` option.

```ruby
require 'redsnow'

result = RedSnow::parse('# My API', { :exportSourcemap => true })
puts result.ast.name
puts result.sourcemap.name
```

## Hacking Redsnow
You are welcome to contribute. Use following steps to build & test Redsnow.

### Build


1. If needed, install bundler:

    ```sh
    $ gem install bundler
    ```

2. Clone the repo + fetch the submodules:

    ```sh
    $ git clone git://github.com/apiaryio/redsnow.git
    $ cd redsnow
    $ git submodule update --init --recursive
    ```

3. Build:

    ```sh
    $ rake
    ```

### Test
Inside the redsnow repository run:

```sh
$ bundle install
$ rake test
```

### Release
Use `rake install` to test locally released version.

```sh
$ rake release
```

### Contribute
Fork & Pull Request.

## License
MIT License. See the [LICENSE](https://github.com/apiaryio/protagonist/blob/master/LICENSE) file.
