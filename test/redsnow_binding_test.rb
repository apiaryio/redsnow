require '_helper'
require 'json'
# RedSnowBindingTest
class RedSnowBindingTest < Test::Unit::TestCase
  context 'RedSnow Binding' do
    should 'convert API Blueprint to AST' do
      report = FFI::MemoryPointer.new :pointer

      RedSnow::Binding.drafter_c_parse("meta: data\nfoo:bar\n#XXXX\ndescription for it", 4, report)

      report = report.get_pointer(0)
      assert !report.null?

      report_as_string = report.null? ? nil : report.read_string()
      assert_not_nil report_as_string

      parsed = JSON.parse(report_as_string)

      assert_equal 'XXXX', parsed["ast"]["name"]
      assert_equal 'description for it', parsed["ast"]["description"]
    end
  end
end
