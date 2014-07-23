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

      error = RedSnow::Binding.sc_error_handler(result)
      assert_equal '', RedSnow::Binding.sc_error_message(error)
      assert_equal 0, RedSnow::Binding.sc_error_code(error)
      assert_equal 0, RedSnow::Binding.sc_error_ok(error)

      RedSnow::Binding.sc_blueprint_free(blueprint)
      RedSnow::Binding.sc_result_free(result)

    end
  end
  # https://github.com/apiaryio/protagonist/blob/master/test/parser-test.coffee
  context "API Blueprint parser" do

    context "API" do
      setup do
        @result = RedSnow.parse("# My API")
      end

      should "have name" do
        assert_equal "My API", @result[0].name
      end
    end

    context "API" do
      setup do
        source = <<-STR
        **description**
        STR

        @result = RedSnow.parse(source.unindent)
      end

      should "have description" do
        assert_equal "", @result[0].name
        assert_equal "**description**\n", @result[0].description
      end
    end

    context "Group" do
      setup do
        source = <<-STR
          # Group Name
          _description_
        STR

        @result = RedSnow.parse(source.unindent)
      end
      should "have resource group" do
        assert_equal 1, @result[0].resource_groups.count
        assert_equal "Name", @result[0].resource_groups[0].name
        assert_equal "_description_\n", @result[0].resource_groups[0].description
      end
    end

    context "Resource" do

      setup do

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

        @result = RedSnow.parse(source.unindent)
        @resourceGroup = @result[0].resource_groups[0]
        @resource = @resourceGroup.resources[0]
        @action = @resource.actions[0]
      end

      should "have resource group" do
        assert_equal 1, @result[0].resource_groups.count
        assert_equal "", @resourceGroup.name
        assert_equal "", @resourceGroup.description
        assert_equal 1, @resourceGroup.resources.count
      end

      should "have resource" do
        assert_equal "/resource", @resource.uri_template
        assert_equal "My Resource", @resource.name
        assert_equal "Resource description\n\n", @resource.description
      end

      should "have resource model" do
        assert_equal "My Resource", @resource.model.name
        assert_equal "", @resource.model.description
        assert_equal "Hello World\n", @resource.model.body
        assert_equal 1, @resource.model.headers.collection.count
        assert_equal "Content-Type", @resource.model.headers.collection[0][:name]
        assert_equal "text/plain", @resource.model.headers.collection[0][:value]
      end

      should "have actions" do
        assert_equal 2, @resource.actions.count
        assert_equal "GET", @action.method
        assert_equal "Retrieve Resource", @action.name
        assert_equal "Method description\n\n", @action.description
      end

    end

    context "parses blueprint metadata" do
      setup do
        source = <<-STR
          FORMAT: 1A
          A: 1
          B: 2
          C: 3

          # API Name
        STR

        @result = RedSnow.parse(source.unindent)
        @metadata = @result[0].metadata.collection
      end

      should "have metadata" do
        assert_equal 'FORMAT', @metadata[0][:name]
        assert_equal '1A', @metadata[0][:value]

        assert_equal 'A', @metadata[1][:name]
        assert_equal '1', @metadata[1][:value]

        assert_equal 'B', @metadata[2][:name]
        assert_equal '2', @metadata[2][:value]

        assert_equal 'C', @metadata[3][:name]
        assert_equal '3', @metadata[3][:value]
      end
    end

    context "parses resource parameters" do
      setup do
        source = <<-STR
        # /machine{?limit}

        + Parameters
            + limit = `20` (optional, number, `42`) ... This is a limit
              + Values
                  + `20`
                  + `42`
                  + `53`

        ## GET

        + Response 204
        STR

        @result = RedSnow.parse(source.unindent)
        @resourceGroup = @result[0].resource_groups[0]
        @resource = @resourceGroup.resources[0]
        @parameter = @resource.parameters.collection[0]
        @values = @parameter.values
      end

      should "have parameters" do
        assert_equal 'limit', @parameter.name
        assert_equal 'This is a limit', @parameter.description
        assert_equal 'number', @parameter.type
        assert_equal :optional, @parameter.use
        assert_equal '20', @parameter.default_value
        assert_equal '42', @parameter.example_value
        assert_equal 3, @parameter.values.count


        assert_equal '20', @values[0]
        assert_equal '42', @values[1]
        assert_equal '53', @values[2]
      end
    end

    context "parses action parameters" do
      setup do
        source = <<-STR
        # GET /coupons/{id}

        + Parameters
            + id (number, `1001`) ... Id of coupon

        + Response 204
        STR

        @result = RedSnow.parse(source.unindent)
        @resourceGroup = @result[0].resource_groups[0]
        @resource = @resourceGroup.resources[0]
        @action = @resource.actions[0]
        @parameter = @action.parameters.collection[0]
      end

      should "have parameters" do
        assert_equal 'id', @parameter.name
        assert_equal :undefined, @parameter.use
      end
    end

    context "parses multiple transactions" do
      setup do
        source = <<-STR
        ## Notes Collection [/notes?id={id}&testingGroup={testtingGroup}&collection={collection}]
        ### Create a Note [POST]
        + Request Create a note

            + Headers

                    Content-Type: application/json
                    Prefer: creating

            + Body

                    { "title": "Buy cheese and bread for breakfast." }

        + Response 201 (application/json)

                { "id": 3, "title": "Buy cheese and bread for breakfast." }

        + Request Unable to create note

            + Headers

                    Content-Type: application/json
                    Prefer: testing


            + Body

                    { "ti": "Buy cheese and bread for breakfast." }

        + Response 500

                { "error": "can't create record" }
        STR
        @result = RedSnow.parse(source.unindent)
        @resourceGroup = @result[0].resource_groups[0]
        @examples = @resourceGroup.resources[0].actions[0].examples
      end

      should "have multiple requests and responses" do
        assert_equal 2, @examples.count
        assert_equal 1, @examples[0].requests.count
        assert_equal 1, @examples[0].responses.count
        assert_equal "", @examples[0].name
        assert_equal "", @examples[0].description
        assert_equal "Create a note", @examples[0].requests[0].name
        assert_equal "Content-Type", @examples[0].requests[0].headers.collection[0][:name]
        assert_equal "application/json", @examples[0].requests[0].headers.collection[0][:value]
        assert_equal "Prefer", @examples[0].requests[0].headers.collection[1][:name]
        assert_equal "creating", @examples[0].requests[0].headers.collection[1][:value]
        assert_equal "201", @examples[0].responses[0].name
        assert_equal "Unable to create note", @examples[1].requests[0].name
        assert_equal "Content-Type", @examples[1].requests[0].headers.collection[0][:name]
        assert_equal "application/json", @examples[1].requests[0].headers.collection[0][:value]
        assert_equal "Prefer", @examples[1].requests[0].headers.collection[1][:name]
        assert_equal "testing", @examples[1].requests[0].headers.collection[1][:value]
        assert_equal '{ "ti": "Buy cheese and bread for breakfast." }' + "\n", @examples[1].requests[0].body
        assert_equal "500", @examples[1].responses[0].name
      end
    end

  end

end
