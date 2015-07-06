require 'bundler/setup'

require 'minitest/autorun'
require 'shoulda'
require 'mocha'
require File.join(File.expand_path('../../lib/redsnow.rb', __FILE__))
# Test Helper
class TestHelper < Minitest::Test
  def fixture_file(name)
    File.read File.expand_path("../fixtures/#{name}", __FILE__)
  end
end
