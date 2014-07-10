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
  # https://github.com/apiaryio/protagonist/blob/master/test/parser-test.coffee
  context "API Blueprint parser" do
    should "parses API name" do
      result = RedSnow.parse("# My API")
      assert_equal "My API", result.name
    end

    should "parses API description" do

      source = <<-STR
        **description**
        STR

      result = RedSnow.parse(source.unindent)
      assert_equal "", result.name
      assert_equal "**description**\n", result.description
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

    should "parses resource" do

      source = <<-STR
        # My Resource [/resource]
        Resource description

        + Model (text/plain)

                Hello World

        ## Retrieve Resource [GET]
        Method description

        + Response 200 (text/plain)

          Response description

          + Headers

                    X-Response-Header: Fighter

          + Body

                    Y.T.

          + Schema

                    Kourier

        ## Delete Resource [DELETE]

        + Response 200

            [My Resource][]

        STR

      result = RedSnow.parse(source.unindent)

      assert_equal 1, result.resource_groups.count

      resourceGroup = result.resource_groups[0]
      assert_equal "", resourceGroup.name
      assert_equal "", resourceGroup.description

      assert_equal 1, resourceGroup.resources.count

      resource = resourceGroup.resources[0]
      assert_equal "/resource", resource.uri_template
      assert_equal "My Resource", resource.name
      assert_equal "Resource description\n\n", resource.description

      assert_equal "My Resource", resource.model.name
      assert_equal "", resource.model.description
      assert_equal "Hello World\n", resource.model.body
      assert_equal 1, resource.model.headers.collection.count
      assert_equal "Content-Type", resource.model.headers.collection[0][:name]
      assert_equal "text/plain", resource.model.headers.collection[0][:value]

    end

  end

end
