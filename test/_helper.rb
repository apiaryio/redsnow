require 'bundler/setup'

require 'test/unit'
require 'shoulda'
require 'turn' unless ENV['TM_FILEPATH'] || ENV['CI']
require 'mocha'
require File.join(File.expand_path('../../lib/redsnow.rb', __FILE__))
# Test Helper
class Test::Unit::TestCase
  def fixture_file(name)
    File.read File.expand_path("../fixtures/#{name}", __FILE__)
  end
end
