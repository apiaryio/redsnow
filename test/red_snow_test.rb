require '_helper'

class RedSnowTest < Test::Unit::TestCase

  context "RedSnow" do
    should "convert api blueprint to AST" do

      blueprint = FFI::MemoryPointer.new :pointer
      result = FFI::MemoryPointer.new :pointer

      ret = RedSnow.parse("meta: data\nfoo:bar\n#XXXX\ndescription for it", 0, result, blueprint)

      blueprint = blueprint.get_pointer(0)
      result = result.get_pointer(0)
      assert_equal "XXXX", RedSnow.bp_name(blueprint)

      assert_equal "description for it", RedSnow.bp_desc(blueprint)

      meta_data_col = RedSnow.bp_metadata_collection_handle(blueprint)
      assert_equal 2, RedSnow.bp_metadata_collection_size(meta_data_col)

      warnings = RedSnow.sc_warnings_handler(result)
      assert_equal 0, RedSnow.sc_warnings_size(warnings)

      RedSnow.bp_clean(blueprint)
      RedSnow.rs_clean(result)

    end
  end

end
