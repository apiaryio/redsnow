# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'red_snow/version'

Gem::Specification.new do |gem|
  gem.name          = "red_snow"
  gem.version       = RedSnow::VERSION
  gem.authors       = ["Ladislav Prskavec"]
  gem.email         = ["ladislav@apiary.io"]
  gem.description   = %q{Ruby bindings for Snow Crash}
  gem.summary       = %q{Ruby bindings for Snow Crash}
  gem.homepage      = "https://github.com/apiaryio/redsnow"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "ffi"
  gem.add_dependency "rake"

  gem.add_development_dependency "shoulda"
  gem.add_development_dependency "mocha"
  gem.add_development_dependency "turn"
  gem.add_development_dependency "unindent"
end
