require '_helper'

class RedSnowTest < Test::Unit::TestCase

  context "RedSnow Binding" do
    should "convert API Blueprint to AST" do

      blueprint = FFI::MemoryPointer.new :pointer
      result = FFI::MemoryPointer.new :pointer

      ret = RedSnow::Binding.parse("meta: data\nfoo:bar\n#XXXX\ndescription for it", 0, result, blueprint)

      blueprint = blueprint.get_pointer(0)
      result = result.get_pointer(0)
      assert_equal "XXXX", RedSnow::Binding.bp_name(blueprint)

      assert_equal "description for it", RedSnow::Binding.bp_desc(blueprint)

      meta_data_col = RedSnow::Binding.bp_metadata_collection_handle(blueprint)
      assert_equal 2, RedSnow::Binding.bp_metadata_collection_size(meta_data_col)

      warnings = RedSnow::Binding.sc_warnings_handler(result)
      assert_equal 0, RedSnow::Binding.sc_warnings_size(warnings)

      RedSnow::Binding.bp_clean(blueprint)
      RedSnow::Binding.rs_clean(result)

    end
  end

  context "RedSnow" do
    should "convert API Blueprint to AST" do
      result = RedSnow.parse("# My API")
      assert_equal result, 'My API'
    end
  end

end
