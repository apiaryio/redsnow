require '_helper'
require 'unindent'
# RedSnowParseResultTest
class RedSnowParseResultTest < Test::Unit::TestCase
  context 'Simple API' do
    setup do
      @result = RedSnow.parse('# My API')
    end

    should 'have name' do
      assert_equal 'My API', @result.ast.name
    end

    should "don't have error" do
      assert_equal 0, @result.error[:ok]
    end
  end

  context 'Simple API with warning' do
    setup do
      @source = <<-STR
        FORMAT: 1A
        # My API
        ## GET /
      STR
      @result = RedSnow.parse(@source.unindent, 4)
    end

    should 'have name' do
      assert_equal 'My API', @result.ast.name
    end

    should "don't have error" do
      assert_equal 0, @result.error[:code]
    end

    should 'have source map for api name' do
      assert_equal [[11, 9]], @result.sourcemap.name
    end

    should 'have some warning' do
      assert_equal RedSnow::WarningCodes::EMPTY_DEFINITION_WARNING, @result.warnings[0][:code]
      assert_equal 'action is missing a response', @result.warnings[0][:message]

      assert_equal 20, @result.warnings[0][:location][0].index
      assert_equal 9, @result.warnings[0][:location][0].length

      assert_equal "## GET /\n", @source.unindent[20..@source.unindent.length]
      # Line in blueprint
      assert_equal 3, @source.unindent[0..20].lines.count
    end
  end
end
