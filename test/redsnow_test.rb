require '_helper'
require 'unindent'

class RedSnowParsingTest < Test::Unit::TestCase

  # https://github.com/apiaryio/protagonist/blob/master/test/parser-test.coffee
  context "API Blueprint parser" do

    context "API" do
      setup do
        @result = RedSnow.parse(1)
      end

      should "haven't name" do
        assert_equal "", @result.ast.name
      end
    end

    context "API" do
      setup do
        @result = RedSnow.parse("# My API")
      end

      should "have name" do
        assert_equal "My API", @result.ast.name
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
        assert_equal "", @result.ast.name
        assert_equal "**description**\n", @result.ast.description
      end
    end

    context "Group" do
      setup do
        source = <<-STR
          # Group Name
          _description_

          ## My Resource [/resource]
          Resource description

          ## My Alternative Resource [/alternative_resource]
          Alternative resource description

        STR

        @result = RedSnow.parse(source.unindent)
        @resource_group = @result.ast.resource_groups[0]
        @resource = @resource_group.resources[0]
        @alternative_resource = @resource_group.resources[1]
      end

      should "have resource group" do
        assert_equal 1, @result.ast.resource_groups.count
        assert_equal "Name", @resource_group.name
        assert_equal "_description_\n\n", @resource_group.description
      end

      should "have resource" do
        assert_equal "/resource", @resource.uri_template
        assert_equal "My Resource", @resource.name
        assert_equal "Resource description\n\n", @resource.description
      end

      should "have alternative resource" do
        assert_equal "/alternative_resource", @alternative_resource.uri_template
        assert_equal "My Alternative Resource", @alternative_resource.name
        assert_equal "Alternative resource description\n\n", @alternative_resource.description
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
        @resourceGroup = @result.ast.resource_groups[0]
        @resource = @resourceGroup.resources[0]
        @action = @resource.actions[0]
        @response = @resource.actions[1].examples[0].responses[0]
      end

      should "have resource group" do
        assert_equal 1, @result.ast.resource_groups.count
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
        assert_equal "text/plain", @resource.model.headers['content-type']
        assert_equal "text/plain", @resource.model.headers['Content-Type']
      end

      should "have actions" do
        assert_equal 2, @resource.actions.count
        assert_equal "GET", @action.method
        assert_equal "Retrieve Resource", @action.name
        assert_equal "Method description\n\n", @action.description
      end

      should "have reference" do
        assert_equal "My Resource", @response.reference.id
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
        @metadata = @result.ast.metadata
        @collection = @metadata.collection
      end

      should "have metadata" do
        assert_equal 'FORMAT', @collection[0][:name]
        assert_equal '1A', @collection[0][:value]

        assert_equal 'A', @collection[1][:name]
        assert_equal '1', @collection[1][:value]

        assert_equal 'B', @collection[2][:name]
        assert_equal '2', @collection[2][:value]

        assert_equal 'C', @collection[3][:name]
        assert_equal '3', @collection[3][:value]
      end
      
      should "return metadata values by element reference method" do
        assert_equal '1A', @metadata['FORMAT']
        assert_equal '1', @metadata['A']
        assert_equal '2', @metadata['B']
        assert_equal '3', @metadata['C']
        assert_equal nil, @metadata['D']
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
        @resourceGroup = @result.ast.resource_groups[0]
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
        @resourceGroup = @result.ast.resource_groups[0]
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
        @resourceGroup = @result.ast.resource_groups[0]
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
        assert_equal "application/json", @examples[1].requests[0].headers['content-type']
        assert_equal "Prefer", @examples[1].requests[0].headers.collection[1][:name]
        assert_equal "testing", @examples[1].requests[0].headers['prefer']
        assert_equal '{ "ti": "Buy cheese and bread for breakfast." }' + "\n", @examples[1].requests[0].body
        assert_equal "500", @examples[1].responses[0].name
      end
    end

  end

end
