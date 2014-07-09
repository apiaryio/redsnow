require '_helper'
require 'unindent'

class RedSnowTest < Test::Unit::TestCase

  context "RedSnow Binding" do
    should "convert API Blueprint to AST" do

      blueprint = FFI::MemoryPointer.new :pointer
      result = FFI::MemoryPointer.new :pointer

      ret = RedSnow::Binding.sc_c_parse("meta: data\nfoo:bar\n#XXXX\ndescription for it", 0, result, blueprint)

      blueprint = blueprint.get_pointer(0)
      result = result.get_pointer(0)
      assert_equal "XXXX", RedSnow::Binding.sc_blueprint_name(blueprint)

      assert_equal "description for it", RedSnow::Binding.sc_blueprint_description(blueprint)

      meta_data_col = RedSnow::Binding.sc_metadata_collection_handle(blueprint)
      assert_equal 2, RedSnow::Binding.sc_metadata_collection_size(meta_data_col)

      warnings = RedSnow::Binding.sc_warnings_handler(result)
      assert_equal 0, RedSnow::Binding.sc_warnings_size(warnings)

      RedSnow::Binding.sc_blueprint_free(blueprint)
      RedSnow::Binding.sc_result_free(result)

    end
  end

  context "API Blueprint parser" do
    should "parses API name" do
      result = RedSnow.parse("# My API")
      assert_equal result.name, 'My API'
    end

    should "parses API description" do

      source = <<-STR
        **description**
        STR

      result = RedSnow.parse(source.unindent)
      assert_equal result.name, ""
      assert_equal result.description, "**description**\n"
    end

    should "parses resource group" do

      source = <<-STR
        # Group Name
        _description_
      STR

      result = RedSnow.parse(source.unindent)
      assert_equal 1, result.resource_groups.count
      assert_equal "Name", result.resource_groups[0].name
      assert_equal "_description_\n", result.resource_groups[0].description
    end

  end

end
