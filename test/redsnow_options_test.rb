require '_helper'
# RedSnowOptionsTest
class RedSnowOptionsTest < Test::Unit::TestCase
  context 'Test arguments' do

    context 'Arguments' do
      should "raise error if first parameter isn't String" do
        exception = assert_raise(ArgumentError) { RedSnow.parse(1) }
        assert_equal('Expected string value', exception.message)
      end

      should 'get option for sourcemaps' do
        options = RedSnow.parse_options(exportSourcemap: true)
        assert_equal 4, options
      end

      should 'get option for required Blueprint name' do
        options = RedSnow.parse_options(requireBlueprintName: true)
        assert_equal 2, options
      end

      should 'get option for required Blueprint name and sourcemaps' do
        options = RedSnow.parse_options(requireBlueprintName: true, exportSourcemap: true)
        assert_equal 6, options
      end

      should 'get option for required Blueprint name and not sourcemaps' do
        options = RedSnow.parse_options(requireBlueprintName: true, exportSourcemap: false)
        assert_equal 2, options
      end

      should 'no options' do
        options = RedSnow.parse_options(0)
        assert_equal 0, options
      end

    end

  end
end
