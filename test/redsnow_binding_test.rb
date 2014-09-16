require '_helper'

class RedSnowBindingTest < Test::Unit::TestCase

  context "RedSnow Binding" do
    should "convert API Blueprint to AST" do

      blueprint = FFI::MemoryPointer.new :pointer
      report = FFI::MemoryPointer.new :pointer

      ret = RedSnow::Binding.sc_c_parse("meta: data\nfoo:bar\n#XXXX\ndescription for it", 0, report, blueprint)

      blueprint = blueprint.get_pointer(0)
      report = report.get_pointer(0)
      assert_equal "XXXX", RedSnow::Binding.sc_blueprint_name(blueprint)

      assert_equal "description for it", RedSnow::Binding.sc_blueprint_description(blueprint)

      meta_data_col = RedSnow::Binding.sc_metadata_collection_handle(blueprint)
      assert_equal 2, RedSnow::Binding.sc_metadata_collection_size(meta_data_col)

      warnings = RedSnow::Binding.sc_warnings_handler(report)
      assert_equal 0, RedSnow::Binding.sc_warnings_size(warnings)

      error = RedSnow::Binding.sc_error_handler(report)
      assert_equal '', RedSnow::Binding.sc_error_message(error)
      assert_equal 0, RedSnow::Binding.sc_error_code(error)
      assert_equal 0, RedSnow::Binding.sc_error_ok(error)

      RedSnow::Binding.sc_blueprint_free(blueprint)
      RedSnow::Binding.sc_report_free(report)

    end
  end
end
