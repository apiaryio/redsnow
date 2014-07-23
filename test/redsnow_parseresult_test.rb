require '_helper'
require 'unindent'

class RedSnowParseResultTest < Test::Unit::TestCase

  context "Simple API" do
    setup do
      @result = RedSnow.parse("# My API")
    end

    should "have name" do
      assert_equal "My API", @result[0].name
    end

    should "don't have error" do
      assert_equal 0, @result[1].error[:ok]
    end
  end

  context "Simple API with warning" do
    setup do
      @source = <<-STR
        FORMAT: 1A
        # My API
        ## GET /
      STR
      @result = RedSnow.parse(@source.unindent)
    end

    should "have name" do
      assert_equal "My API", @result[0].name
    end

    should "don't have error" do
      assert_equal 0, @result[1].error[:code]
    end

    should "have some warning" do
      assert_equal RedSnow::WarningCodes::EmptyDefinitionWarning, @result[1].warnings[0][:code]
      assert_equal "no response defined for 'GET /'", @result[1].warnings[0][:message]

      assert_equal 20, @result[1].warnings[0][:location][0].index
      assert_equal 9, @result[1].warnings[0][:location][0].length

      assert_equal "## GET /\n", @source.unindent[20..@source.unindent.length]
      # Line in blueprint
      assert_equal 3, @source.unindent[0..20].lines.count
    end
  end
end
