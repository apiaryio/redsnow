require "red_snow/version"
require "red_snow/binding"
require "red_snow/blueprint"
require "ffi"

module RedSnow
  include Binding

  def self.get_parameters(sc_parameter_collection_handle, sc_parameter_collection_size)
    collection = Array.new
    if sc_parameter_collection_size > 0
      parameters_size = sc_parameter_collection_size - 1
      for index in 0..parameters_size do
        sc_parameter_handle = RedSnow::Binding.sc_parameter_handle(sc_parameter_collection_handle, index)
        parameter = Parameter.new
        parameter.name = RedSnow::Binding.sc_parameter_name(sc_parameter_handle)
        parameter.description = RedSnow::Binding.sc_parameter_description(sc_parameter_handle)
        parameter.type = RedSnow::Binding.sc_parameter_type(sc_parameter_handle)
        use =  RedSnow::Binding.sc_parameter_parameter_use(sc_parameter_handle)
        case use
          when 1
            parameter.use = :optional
          when 2
            parameter.use = :required
          else
            parameter.use = :undefined
        end
        parameter.default_value = RedSnow::Binding.sc_parameter_default_value(sc_parameter_handle)
        parameter.example_value = RedSnow::Binding.sc_parameter_example_value(sc_parameter_handle)
        parameter.values = Array.new
        sc_value_collection_handle = RedSnow::Binding.sc_value_collection_handle(sc_parameter_handle)
        sc_value_collection_size = RedSnow::Binding.sc_value_collection_size(sc_value_collection_handle)
        if sc_value_collection_size > 0
          values_size = sc_value_collection_size - 1
          for valueIndex in 0..values_size do
            sc_value_handle = RedSnow::Binding.sc_value_handle(sc_value_collection_handle, valueIndex)
            value = RedSnow::Binding.sc_value_string(sc_value_handle)
            parameter.values << value
          end
        end
        collection << parameter
      end
    end
    return collection
  end

  def self.get_payload(payload, sc_payload_handle_resource)
    payload.name = RedSnow::Binding.sc_payload_name(sc_payload_handle_resource)
    payload.description = RedSnow::Binding.sc_payload_description(sc_payload_handle_resource)
    payload.body = RedSnow::Binding.sc_payload_body(sc_payload_handle_resource)
    payload.schema = RedSnow::Binding.sc_payload_schema(sc_payload_handle_resource)

    sc_header_collection_handle_payload = RedSnow::Binding.sc_header_collection_handle_payload(sc_payload_handle_resource)
    sc_header_collection_size = RedSnow::Binding.sc_header_collection_size(sc_header_collection_handle_payload)
    payload.headers = Headers.new
    if sc_header_collection_size > 0
      headers_size = sc_header_collection_size - 1
      collection = Array.new
      for index in 0..headers_size do
        sc_header_handle = RedSnow::Binding.sc_header_handle(sc_header_collection_handle_payload, index)
        collection << Hash[:name => RedSnow::Binding.sc_header_key(sc_header_handle), :value => RedSnow::Binding.sc_header_value(sc_header_handle)]
      end
      payload.headers.collection = collection
    end
    return payload
  end

  def self.parse(rawBlueprint, options = 0)

    bp = Blueprint.new

    blueprint = FFI::MemoryPointer.new :pointer
    result = FFI::MemoryPointer.new :pointer
    ret = RedSnow::Binding.sc_c_parse(rawBlueprint, options, result, blueprint)

    blueprint = blueprint.get_pointer(0)
    result = result.get_pointer(0)
    # BP name, desc
    bp.name = RedSnow::Binding.sc_blueprint_name(blueprint)
    bp.description = RedSnow::Binding.sc_blueprint_description(blueprint)
    # BP metadata
    bp.metadata = Metadata.new
    sc_metadata_collection_handle = RedSnow::Binding.sc_metadata_collection_handle(blueprint)
    sc_metadata_collection_size = RedSnow::Binding.sc_metadata_collection_size(sc_metadata_collection_handle)
    if sc_metadata_collection_size > 0
      metadata_size = sc_metadata_collection_size - 1
      metaCollection = Array.new
      for index in 0..metadata_size do
        sc_metadata_handle = RedSnow::Binding.sc_metadata_handle(sc_metadata_collection_handle, index)
        metaCollection << Hash[:name => RedSnow::Binding.sc_metadata_key(sc_metadata_handle), :value => RedSnow::Binding.sc_metadata_value(sc_metadata_handle)]
      end
      bp.metadata.collection = metaCollection
    end
    # BP resourceGroups
    sc_resource_groups_collection_handle = RedSnow::Binding.sc_resource_groups_collection_handle(blueprint)
    sc_resource_groups_collection_size = RedSnow::Binding.sc_resource_groups_collection_size(sc_resource_groups_collection_handle)
    bp.resource_groups = Array.new

    if sc_resource_groups_collection_size > 0
      group_size = sc_resource_groups_collection_size - 1
      for index in 0..group_size do
        sc_resource_groups_handle = RedSnow::Binding.sc_resource_groups_handle(sc_resource_groups_collection_handle, index)
        resource = ResourceGroup.new
        resource.name = RedSnow::Binding.sc_resource_groups_name(sc_resource_groups_handle)
        resource.description = RedSnow::Binding.sc_resource_groups_description(sc_resource_groups_handle)
        # BP Resources
        sc_resource_collection_handle = RedSnow::Binding.sc_resource_collection_handle(sc_resource_groups_handle)
        sc_resource_collection_size = RedSnow::Binding.sc_resource_collection_size(sc_resource_collection_handle)
        resource.resources = Array.new
        if sc_resource_collection_size > 0
          resource_size = sc_resource_collection_size - 1
          for index in 0..resource_size do
            sc_resource_handle = RedSnow::Binding.sc_resource_handle(sc_resource_collection_handle, index)
            res = Resource.new
            res.name = RedSnow::Binding.sc_resource_name(sc_resource_handle)
            res.description = RedSnow::Binding.sc_resource_description(sc_resource_handle)
            res.uri_template = RedSnow::Binding.sc_resource_uritemplate(sc_resource_handle)

            sc_payload_handle_resource = RedSnow::Binding.sc_payload_handle_resource(sc_resource_handle)
            if sc_payload_handle_resource
              res.model = Model.new
              res.model = self.get_payload(res.model, sc_payload_handle_resource)
            else
              res.model = nil
            end
            res.actions = Array.new
            sc_action_collection_handle = RedSnow::Binding.sc_action_collection_handle(sc_resource_handle)
            sc_action_collection_size = RedSnow::Binding.sc_action_collection_size(sc_action_collection_handle)
            if sc_action_collection_size > 0
              action_size = sc_action_collection_size - 1
              for index in 0..action_size do
                action = Action.new
                sc_action_handle = RedSnow::Binding.sc_action_handle(sc_action_collection_handle, index)
                action.method = RedSnow::Binding.sc_action_httpmethod(sc_action_handle)
                action.name = RedSnow::Binding.sc_action_name(sc_action_handle)
                action.description = RedSnow::Binding.sc_action_description(sc_action_handle)
                action.parameters = Parameters.new
                sc_parameter_collection_handle_action = RedSnow::Binding.sc_parameter_collection_handle_action(sc_action_handle)
                sc_parameter_collection_size_action = RedSnow::Binding.sc_parameter_collection_size(sc_parameter_collection_handle_action)
                action.parameters.collection = RedSnow.get_parameters(sc_parameter_collection_handle_action, sc_parameter_collection_size_action)
                action.examples = Array.new
                sc_transaction_example_collection_handle = RedSnow::Binding.sc_transaction_example_collection_handle(sc_action_handle)
                sc_transaction_example_collection_size = RedSnow::Binding.sc_transaction_example_collection_size(sc_transaction_example_collection_handle)
                if sc_transaction_example_collection_size > 0
                  examples_size = sc_transaction_example_collection_size - 1
                  for index in 0..examples_size do
                    example = TransactionExample.new
                    sc_transaction_example_handle = RedSnow::Binding.sc_transaction_example_handle(sc_transaction_example_collection_handle, index)
                    example.name  = RedSnow::Binding.sc_transaction_example_name(sc_transaction_example_handle)
                    example.description = RedSnow::Binding.sc_transaction_example_description(sc_transaction_example_handle)
                    example.requests = Array.new
                    sc_payload_collection_handle_requests = RedSnow::Binding.sc_payload_collection_handle_requests(sc_transaction_example_handle)
                    sc_payload_collection_size_requests = RedSnow::Binding.sc_payload_collection_size(sc_payload_collection_handle_requests)
                    if sc_payload_collection_size_requests > 0
                      requests_size = sc_payload_collection_size_requests - 1
                      for index in 0..requests_size do
                        request = Request.new
                        sc_payload_handle = RedSnow::Binding.sc_payload_handle(sc_payload_collection_handle_requests, index)
                        request = RedSnow.get_payload(request, sc_payload_handle)
                        example.requests << request
                      end
                    end
                    example.responses = Array.new
                    sc_payload_collection_handle_responses = RedSnow::Binding.sc_payload_collection_handle_responses(sc_transaction_example_handle)
                    sc_payload_collection_size_responses = RedSnow::Binding.sc_payload_collection_size(sc_payload_collection_handle_responses)
                    if sc_payload_collection_size_responses > 0
                      responses_size = sc_payload_collection_size_responses - 1
                      for index in 0..responses_size do
                        response = Response.new
                        sc_payload_handle = RedSnow::Binding.sc_payload_handle(sc_payload_collection_handle_responses, index)
                        response = RedSnow.get_payload(response, sc_payload_handle)
                        example.responses << response
                      end
                    end
                    action.examples << example
                  end
                end
                res.actions << action
              end
            end
            res.parameters = Parameters.new
            sc_parameter_collection_handle_resource = RedSnow::Binding.sc_parameter_collection_handle_resource(sc_resource_handle)
            sc_parameter_collection_size_resource = RedSnow::Binding.sc_parameter_collection_size(sc_parameter_collection_handle_resource)
            res.parameters.collection = RedSnow.get_parameters(sc_parameter_collection_handle_resource, sc_parameter_collection_size_resource)
            resource.resources << res
          end
        end
        bp.resource_groups << resource
      end
    end
    return bp
  ensure
    RedSnow::Binding.sc_blueprint_free(blueprint)
    RedSnow::Binding.sc_result_free(result)
  end

end
