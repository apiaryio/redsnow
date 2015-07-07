require '_helper'
require 'json'
# RedSnowBindingTest
class RedSnowBindingTest < Minitest::Test
  context 'RedSnow Binding' do
    should 'convert API Blueprint to AST' do
      parse_result = FFI::MemoryPointer.new :pointer

      RedSnow::Binding.drafter_c_parse("meta: data\nfoo:bar\n#XXXX\ndescription for it", 4, parse_result)

      parse_result = parse_result.get_pointer(0)
      assert !parse_result.null?

      parse_result_as_string = parse_result.null? ? nil : parse_result.read_string
      refute_nil parse_result_as_string

      parsed = JSON.parse(parse_result_as_string)

      assert_equal 'XXXX', parsed['ast']['name']
      assert_equal 'description for it', parsed['ast']['description']
    end
  end
end
