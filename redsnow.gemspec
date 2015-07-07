# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'redsnow/version'

Gem::Specification.new do |gem|
  gem.name          = 'redsnow'
  gem.version       = RedSnow::VERSION
  gem.authors       = ['Ladislav Prskavec']
  gem.email         = ['ladislav@apiary.io']
  gem.description   = 'Ruby bindings for Snow Crash'
  gem.summary       = 'Ruby bindings for Snow Crash'
  gem.homepage      = 'https://github.com/apiaryio/redsnow'
  gem.license       = 'MIT'
  gem.files         = Dir['lib/**/*']
  gem.files << Dir['*']
  gem.files << Dir['ext/drafter/**/*'].reject { |f| f =~ /cmdline|test|features|README*|LICENSE|Gemfile*|\.xcode*/   }
  gem.executables   = gem.files.grep(/^bin/).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(/^(test|spec|features)/)
  gem.require_paths = %w(lib ext)

  gem.required_ruby_version = '>= 1.9.3'

  gem.extensions   = %w(Rakefile)

  gem.add_dependency 'ffi', '~> 1.9.3'
  gem.add_dependency 'rake', '>= 10.3.2'
  gem.add_dependency 'bundler', '>= 1.7.0'
  gem.add_dependency 'yard', '~> 0.8.7.4'

  gem.add_development_dependency 'minitest'
  gem.add_development_dependency 'shoulda'
  gem.add_development_dependency 'mocha'
  gem.add_development_dependency 'unindent'
  gem.add_development_dependency 'rubocop'
  gem.add_development_dependency 'guard-rubocop'
end
