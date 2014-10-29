require '_helper'

class RedSnowBindingTest < Test::Unit::TestCase

  context "RedSnow Binding" do
    should "convert API Blueprint to AST" do

      report = FFI::MemoryPointer.new :pointer
      blueprint = FFI::MemoryPointer.new :pointer
      sourcemap = FFI::MemoryPointer.new :pointer

      RedSnow::Binding.sc_c_parse("meta: data\nfoo:bar\n#XXXX\ndescription for it", 4, report, blueprint, sourcemap)

      blueprint = blueprint.get_pointer(0)
      report = report.get_pointer(0)
      sourcemap = sourcemap.get_pointer(0)

      assert_equal "XXXX", RedSnow::Binding.sc_blueprint_name(blueprint)

      sm_bluperint_name = RedSnow::Binding.sc_sm_blueprint_name(sourcemap)
      assert_equal 1, RedSnow::Binding.sc_source_map_size(sm_bluperint_name)
      assert_equal 19, RedSnow::Binding.sc_source_map_location(sm_bluperint_name, 0)
      assert_equal 6, RedSnow::Binding.sc_source_map_length(sm_bluperint_name, 0)

      assert_equal "description for it", RedSnow::Binding.sc_blueprint_description(blueprint)

      sm_bluperint_description = RedSnow::Binding.sc_sm_blueprint_description(sourcemap)
      assert_equal 1, RedSnow::Binding.sc_source_map_size(sm_bluperint_description)
      assert_equal 25, RedSnow::Binding.sc_source_map_location(sm_bluperint_description, 0)
      assert_equal 18, RedSnow::Binding.sc_source_map_length(sm_bluperint_description, 0)

      meta_data_col = RedSnow::Binding.sc_metadata_collection_handle(blueprint)
      assert_equal 2, RedSnow::Binding.sc_metadata_collection_size(meta_data_col)

      sm_meta_data_col = RedSnow::Binding.sc_sm_metadata_collection_handle(sourcemap)
      assert_equal 2, RedSnow::Binding.sc_sm_metadata_collection_size(sm_meta_data_col)

      warnings = RedSnow::Binding.sc_warnings_handler(report)
      assert_equal 0, RedSnow::Binding.sc_warnings_size(warnings)

      error = RedSnow::Binding.sc_error_handler(report)
      assert_equal '', RedSnow::Binding.sc_error_message(error)
      assert_equal 0, RedSnow::Binding.sc_error_code(error)
      assert_equal 0, RedSnow::Binding.sc_error_ok(error)

      RedSnow::Binding.sc_blueprint_free(blueprint)
      RedSnow::Binding.sc_sm_blueprint_free(sourcemap)
      RedSnow::Binding.sc_report_free(report)

    end
  end
end
