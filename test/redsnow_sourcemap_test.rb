require '_helper'
require 'unindent'
# RedSnowParsingTest
class RedSnowSourcemapTest < Minitest::Test
  context 'API Blueprint parser' do
    context 'API' do
      setup do
        @result = RedSnow.parse('# My API', 4)
      end

      should 'have name' do
        assert_equal [[0, 8]], @result.sourcemap.name
      end
    end

    context 'API' do
      setup do
        source = <<-STR
        **description**
        STR

        @result = RedSnow.parse(source.unindent, 4)
      end

      should 'have description' do
        assert_equal [], @result.sourcemap.name
        assert_equal [[0, 16]], @result.sourcemap.description
      end
    end

    context 'Group' do
      setup do
        source = <<-STR
          # Group Name
          _description_

          ## My Resource [/resource]
          Resource description

          ## My Alternative Resource [/alternative_resource]
          Alternative resource description

        STR

        @result = RedSnow.parse(source.unindent, 4)
        @sourcemap = @result.sourcemap
      end

      should 'have resource group' do
        assert_equal 1, @sourcemap.resource_groups.count
        assert_equal 2, @sourcemap.resource_groups[0].resources.count
      end

      should 'have resource' do
        assert_equal [[28, 27]], @sourcemap.resource_groups[0].resources[0].name
        assert_equal [[28, 27]], @sourcemap.resource_groups[0].resources[0].uri_template
      end

      should 'have alternative resource' do
        assert_equal [[77, 51]], @sourcemap.resource_groups[0].resources[1].name
      end
    end

    context 'Resource' do
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

        @result = RedSnow.parse(source.unindent, 4)
        @resource_group = @result.sourcemap.resource_groups[0]
        @resource = @resource_group.resources[0]
      end

      should 'have resource group' do
        assert_equal [], @resource_group.name
        assert_equal 1, @resource_group.resources.count
      end

      should 'have resource' do
        assert_equal [[0, 26]], @resource.uri_template
        assert_equal [[26, 22]], @resource.description
      end

      should 'have resource model' do
        assert_equal [[0, 26]], @resource.model.name
        assert_equal [[74, 16]], @resource.model.body
        assert_equal 1, @resource.model.headers.collection.count
        assert_equal [[50, 20]], @resource.model.headers.collection[0]
      end

      should 'have actions' do
        assert_equal 2, @resource.actions.count
        assert_equal [[91, 27]], @resource.actions[0].method
        assert_equal [[91, 27]], @resource.actions[0].name
      end

      should 'have reference' do
        assert_equal [[354, 16]], @resource.actions[1].examples[0].responses[0].reference
      end
    end

    context 'Action' do
      setup do
        source = <<-STR
          # My Resource [/resource]
          Resource description

          ## Retrieve Resource [GET]
          Method description

            + Parameters
                + limit = `20` (optional, number, `42`) ... This is a limit

            + Response 202

            + Response 203

          STR

        @result = RedSnow.parse(source.unindent, 4)
        @resource_group = @result.sourcemap.resource_groups[0]
        @resource = @resource_group.resources[0]
        @action = @resource.actions[0]
        @parameter = @action.parameters.collection.first
      end

      should 'have 1 example' do
        assert_equal 1, @action.examples.count
      end

      should 'have the right parameters' do
        assert_equal [[118, 58]], @parameter.name
        assert_equal [[118, 58]], @parameter.type
        assert_equal [[118, 58]], @parameter.use
        assert_equal [[118, 58]], @parameter.default_value
        assert_equal [[118, 58]], @parameter.example_value
        assert_equal 0, @parameter.values.count
      end
    end

    context 'parses resource parameters' do
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

        @result = RedSnow.parse(source.unindent, 4)
        @resource_group = @result.sourcemap.resource_groups[0]
        @resource = @resource_group.resources[0]
        @parameter = @resource.parameters.collection[0]
        @values = @parameter.values
      end

      should 'have parameters' do
        assert_equal [[39, 58]], @parameter.name
        assert_equal [[39, 58]], @parameter.description
        assert_equal [[39, 58]], @parameter.type
        assert_equal [[39, 58]], @parameter.use
        assert_equal [[39, 58]], @parameter.default_value
        assert_equal [[39, 58]], @parameter.example_value
        assert_equal 3, @parameter.values.count

        assert_equal [[122, 7]], @values[0]
        assert_equal [[139, 7]], @values[1]
        assert_equal [[156, 7]], @values[2]
      end
    end

    context 'parses multiple transactions' do
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
        @result = RedSnow.parse(source.unindent, 4)
        @resource_group = @result.sourcemap.resource_groups[0]
        @action = @resource_group.resources[0].actions[0]
        @examples = @action.examples
      end

      should 'have multiple requests and responses' do
        assert_equal 2, @examples.count
        assert_equal 1, @examples[0].requests.count
        assert_equal 1, @examples[0].responses.count

        assert_equal 2, @examples[0].requests[0].headers.collection.count

        assert_equal 1, @examples[1].requests.count
        assert_equal [[549, 52]], @examples[1].requests[0].body
      end
    end
  end
end
