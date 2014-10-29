require 'redsnow/object'

# The classes in this module should be 1:1 with the Snow Crash Blueprint sourcemap
# counterparts (https://github.com/apiaryio/snowcrash/blob/master/src/BlueprintSourcemap.h).
module RedSnow
  module Sourcemap
    class Node
    end

    class SourceMap < Array
      def initialize(sc_source_map_handle)
        source_map_size = RedSnow::Binding.sc_source_map_size(sc_source_map_handle) - 1

        for index in 0..source_map_size do
          location = RedSnow::Binding.sc_source_map_location(sc_source_map_handle, index)
          length = RedSnow::Binding.sc_source_map_length(sc_source_map_handle, index)

          self << [location, length]
        end
      end
    end

    # Blueprint sourcemap node with name and description associated
    #
    # @attr name [SourceMap] name of the node
    # @attr description [SourceMap] description of the node
    #
    # @abstract
    class NamedNode < Node
      attr_accessor :name
      attr_accessor :description
    end

    # Metadata source map collection node
    class Metadata < Node
      attr_accessor :collection

      # @param sc_sm_metadata_collection_handle [FFI::Pointer]
      def initialize(sc_sm_metadata_collection_handle)
        sc_sm_metadata_collection_size = RedSnow::Binding.sc_sm_metadata_collection_size(sc_sm_metadata_collection_handle)

        if sc_sm_metadata_collection_size > 0
          metadata_size = sc_sm_metadata_collection_size - 1
          @collection = []

          for index in 0..metadata_size do
            sc_sm_metadata_handle = RedSnow::Binding.sc_sm_metadata_handle(sc_sm_metadata_collection_handle, index)
            @collection << SourceMap.new(RedSnow::Binding.sc_sm_metadata(sc_sm_metadata_handle))
          end
        end
      end
    end

    # Headers source map collection node
    class Headers < Node
      attr_accessor :collection

      # @param sc_header_collection_handle_payload [FFI::Pointer]
      def initialize(sc_sm_header_collection_handle_payload)
        sc_sm_header_collection_size = RedSnow::Binding.sc_sm_header_collection_size(sc_sm_header_collection_handle_payload)

        if sc_sm_header_collection_size > 0
          headers_size = sc_sm_header_collection_size - 1
          @collection = []

          for index in 0..headers_size do
            sc_sm_header_handle = RedSnow::Binding.sc_sm_header_handle(sc_sm_header_collection_handle_payload, index)
            @collection << SourceMap.new(RedSnow::Binding.sc_sm_header(sc_sm_header_handle))
          end
        end
      end
    end

    # Parameter source map node
    #
    # @attr type [Sourcemap] an arbitrary type of the parameter or nil
    # @attr use [Sourcemap] parameter necessity flag, `:required` or `:optional`
    # @attr default_value [Sourcemap] default value of the parameter or nil
    # @attr example_value [Sourcemap] example value of the parameter or nil
    # @attr values [Array<Sourcemap>] an enumeration of possible parameter values
    class Parameter < NamedNode
      attr_accessor :type
      attr_accessor :use
      attr_accessor :default_value
      attr_accessor :example_value
      attr_accessor :values

      # @param sc_sm_parameter_handle [FFI::Pointer]
      def initialize(sc_sm_parameter_handle)
        @name = SourceMap.new(RedSnow::Binding.sc_sm_parameter_name(sc_sm_parameter_handle))
        @description = SourceMap.new(RedSnow::Binding.sc_sm_parameter_description(sc_sm_parameter_handle))
        @type = SourceMap.new(RedSnow::Binding.sc_sm_parameter_type(sc_sm_parameter_handle))
        @use =  SourceMap.new(RedSnow::Binding.sc_sm_parameter_parameter_use(sc_sm_parameter_handle))
        @default_value = SourceMap.new(RedSnow::Binding.sc_sm_parameter_default_value(sc_sm_parameter_handle))
        @example_value = SourceMap.new(RedSnow::Binding.sc_sm_parameter_example_value(sc_sm_parameter_handle))

        @values = []

        sc_sm_value_collection_handle = RedSnow::Binding.sc_sm_value_collection_handle(sc_sm_parameter_handle)
        sc_sm_value_collection_size = RedSnow::Binding.sc_sm_value_collection_size(sc_sm_value_collection_handle)

        if sc_sm_value_collection_size > 0
          values_size = sc_sm_value_collection_size - 1

          for valueIndex in 0..values_size do
            sc_sm_value_handle = RedSnow::Binding.sc_sm_value_handle(sc_sm_value_collection_handle, valueIndex)
            @values << SourceMap.new(RedSnow::Binding.sc_sm_value(sc_sm_value_handle))
          end
        end
      end
    end

    # Parameters source map collection node
    #
    # @attr collection [Array<Parameter>] an array of URI parameters
    class Parameters < Node
      attr_accessor :collection

      # @param sc_sm_parameter_collection_handle [FFI::Pointer]
      def initialize(sc_sm_parameter_collection_handle)
        sc_sm_parameter_collection_size = RedSnow::Binding.sc_sm_parameter_collection_size(sc_sm_parameter_collection_handle)
        @collection = []

        if sc_sm_parameter_collection_size > 0
          parameters_size = sc_sm_parameter_collection_size - 1

          for index in 0..parameters_size do
            sc_sm_parameter_handle = RedSnow::Binding.sc_sm_parameter_handle(sc_sm_parameter_collection_handle, index)
            @collection << Parameter.new(sc_sm_parameter_handle)
          end
        end
      end
    end

    # Payload source map node
    #
    # @abstract
    # @attr parameters [Parameters] ignored
    # @attr headers [Headers] array of HTTP header fields of the message or nil
    # @attr body [Sourcemap] HTTP-message body or nil
    # @attr schema [Sourcemap] HTTP-message body validation schema or nil
    # @attr reference [Sourcemap] Symbol Reference sourcemap if the payload is a reference
    class Payload < NamedNode
      attr_accessor :headers
      attr_accessor :body
      attr_accessor :schema
      attr_accessor :reference

      # @param sc_sm_payload_handle_resource [FFI::Pointer]
      def initialize(sc_sm_payload_handle_resource)
        @name = SourceMap.new(RedSnow::Binding.sc_sm_payload_name(sc_sm_payload_handle_resource))
        @description = SourceMap.new(RedSnow::Binding.sc_sm_payload_description(sc_sm_payload_handle_resource))
        @body = SourceMap.new(RedSnow::Binding.sc_sm_payload_body(sc_sm_payload_handle_resource))
        @schema = SourceMap.new(RedSnow::Binding.sc_sm_payload_schema(sc_sm_payload_handle_resource))

        # Handle to reference source map
        sc_sm_reference_handle = RedSnow::Binding.sc_sm_reference_handle(sc_sm_payload_handle_resource)
        sc_sm_reference = RedSnow::Binding.sc_sm_reference(sc_sm_reference_handle)
        reference_source_map_size = RedSnow::Binding.sc_source_map_size(sc_sm_reference)

        if reference_source_map_size != 0
          @reference = SourceMap.new(sc_sm_reference)
        end

        sc_sm_header_collection_handle_payload = RedSnow::Binding.sc_sm_header_collection_handle_payload(sc_sm_payload_handle_resource)
        @headers = Headers.new(sc_sm_header_collection_handle_payload)
      end
    end

    # Transaction example source map node
    #
    # @attr requests [Array<Request>] example request payloads
    # @attr response [Array<Response>] example response payloads
    class TransactionExample < NamedNode
      attr_accessor :requests
      attr_accessor :responses

      # @param sc_sm_transaction_example_handle [FFI::Pointer]
      def initialize(sc_sm_transaction_example_handle)
        @name  = SourceMap.new(RedSnow::Binding.sc_sm_transaction_example_name(sc_sm_transaction_example_handle))
        @description = SourceMap.new(RedSnow::Binding.sc_sm_transaction_example_description(sc_sm_transaction_example_handle))

        # BP Resource Actions Examples Requests
        @requests = []
        sc_sm_payload_collection_handle_requests = RedSnow::Binding.sc_sm_payload_collection_handle_requests(sc_sm_transaction_example_handle)
        sc_sm_payload_collection_size_requests = RedSnow::Binding.sc_sm_payload_collection_size(sc_sm_payload_collection_handle_requests)

        if sc_sm_payload_collection_size_requests > 0
          requests_size = sc_sm_payload_collection_size_requests - 1

          for index in 0..requests_size do
            sc_sm_payload_handle = RedSnow::Binding.sc_sm_payload_handle(sc_sm_payload_collection_handle_requests, index)
            @requests << Payload.new(sc_sm_payload_handle)
          end
        end

        # BP Resource Actions Examples Responses
        @responses = []
        sc_sm_payload_collection_handle_responses = RedSnow::Binding.sc_sm_payload_collection_handle_responses(sc_sm_transaction_example_handle)
        sc_sm_payload_collection_size_responses = RedSnow::Binding.sc_sm_payload_collection_size(sc_sm_payload_collection_handle_responses)

        if sc_sm_payload_collection_size_responses > 0
          responses_size = sc_sm_payload_collection_size_responses - 1

          for index in 0..responses_size do
            sc_sm_payload_handle = RedSnow::Binding.sc_sm_payload_handle(sc_sm_payload_collection_handle_responses, index)
            @responses << Payload.new(sc_sm_payload_handle)
          end
        end
      end
    end

    # Action source map node
    #
    # @attr method [Sourcemap] HTTP request method or nil
    # @attr parameters [Parameters] action-specific URI parameters or nil
    # @attr examples [Array<TransactionExample>] action transaction examples
    class Action < NamedNode
      attr_accessor :method
      attr_accessor :parameters
      attr_accessor :examples

      # @param sc_sm_action_handle [FFI::Pointer]
      def initialize(sc_sm_action_handle)
        @name = SourceMap.new(RedSnow::Binding.sc_sm_action_name(sc_sm_action_handle))
        @description = SourceMap.new(RedSnow::Binding.sc_sm_action_description(sc_sm_action_handle))

        @method = SourceMap.new(RedSnow::Binding.sc_sm_action_httpmethod(sc_sm_action_handle))

        @parameters = Parameters.new(RedSnow::Binding.sc_sm_parameter_collection_handle_action(sc_sm_action_handle))

        @examples = []
        sc_sm_transaction_example_collection_handle = RedSnow::Binding.sc_sm_transaction_example_collection_handle(sc_sm_action_handle)
        sc_sm_transaction_example_collection_size = RedSnow::Binding.sc_sm_transaction_example_collection_size(sc_sm_transaction_example_collection_handle)

        if sc_sm_transaction_example_collection_size > 0
          examples_size = sc_sm_transaction_example_collection_size - 1

          for index in 0..examples_size do
            sc_sm_transaction_example_handle = RedSnow::Binding.sc_sm_transaction_example_handle(sc_sm_transaction_example_collection_handle, index)
            @examples << TransactionExample.new(sc_sm_transaction_example_handle)
          end
        end
      end
    end

    # Resource source map node
    #
    # @attr uri_template [Sourcemap] RFC 6570 URI template
    # @attr model [Payload] model payload for the resource or nil
    # @attr parameters [Parameters] action-specific URI parameters or nil
    # @attr actions [Array<Action>] array of resource actions or nil
    class Resource < NamedNode
      attr_accessor :uri_template
      attr_accessor :model
      attr_accessor :parameters
      attr_accessor :actions

      # @param sc_sm_resource_handle [FFI::Pointer]
      def initialize(sc_sm_resource_handle)
        @name = SourceMap.new(RedSnow::Binding.sc_sm_resource_name(sc_sm_resource_handle))
        @description = SourceMap.new(RedSnow::Binding.sc_sm_resource_description(sc_sm_resource_handle))
        @uri_template = SourceMap.new(RedSnow::Binding.sc_sm_resource_uritemplate(sc_sm_resource_handle))

        sc_sm_payload_handle_resource = RedSnow::Binding.sc_sm_payload_handle_resource(sc_sm_resource_handle)
        @model = Payload.new(sc_sm_payload_handle_resource)

        @actions = []
        sc_sm_action_collection_handle = RedSnow::Binding.sc_sm_action_collection_handle(sc_sm_resource_handle)
        sc_sm_action_collection_size = RedSnow::Binding.sc_sm_action_collection_size(sc_sm_action_collection_handle)

        if sc_sm_action_collection_size > 0
          action_size = sc_sm_action_collection_size - 1

          for index in 0..action_size do
            sc_sm_action_handle = RedSnow::Binding.sc_sm_action_handle(sc_sm_action_collection_handle, index)
            @actions << Action.new(sc_sm_action_handle)
          end
        end

        @parameters = Parameters.new(RedSnow::Binding.sc_sm_parameter_collection_handle_resource(sc_sm_resource_handle))
      end
    end

    # Resource group source map node
    #
    # @attr resources [Array<Resource>] array of resources in the group
    class ResourceGroup < NamedNode
      attr_accessor :resources

      # @param sc_sm_resource_group_handle [FFI::Pointer]
      def initialize(sc_sm_resource_group_handle)
        @name = SourceMap.new(RedSnow::Binding.sc_sm_resource_group_name(sc_sm_resource_group_handle))
        @description = SourceMap.new(RedSnow::Binding.sc_sm_resource_group_description(sc_sm_resource_group_handle))

        @resources = []
        sc_sm_resource_collection_handle = RedSnow::Binding.sc_sm_resource_collection_handle(sc_sm_resource_group_handle)
        sc_sm_resource_collection_size = RedSnow::Binding.sc_sm_resource_collection_size(sc_sm_resource_collection_handle)

        if sc_sm_resource_collection_size > 0
          resource_size = sc_sm_resource_collection_size - 1

          for index in 0..resource_size do
            sc_sm_resource_handle = RedSnow::Binding.sc_sm_resource_handle(sc_sm_resource_collection_handle, index)
            @resources << Resource.new(sc_sm_resource_handle)
          end
        end
      end
    end

    # Blueprint source map node
    #
    # @attr metadata [Metadata] tool-specific metadata collection or nil
    # @attr resource_groups [Array<ResourceGroup>] array of resource groups
    class Blueprint < NamedNode
      attr_accessor :metadata
      attr_accessor :resource_groups

      # @param handle [FFI:Pointer]
      def initialize(handle)
        # BP name, desc
        @name = SourceMap.new(RedSnow::Binding.sc_sm_blueprint_name(handle))
        @description = SourceMap.new(RedSnow::Binding.sc_sm_blueprint_description(handle))

        # BP metadata
        sc_sm_metadata_collection_handle = RedSnow::Binding.sc_sm_metadata_collection_handle(handle)
        @metadata = Metadata.new(sc_sm_metadata_collection_handle)

        # BP Resource Groups
        sc_sm_resource_group_collection_handle = RedSnow::Binding.sc_sm_resource_group_collection_handle(handle)
        sc_sm_resource_group_collection_size = RedSnow::Binding.sc_sm_resource_group_collection_size(sc_sm_resource_group_collection_handle)
        @resource_groups = []

        if sc_sm_resource_group_collection_size > 0
          group_size = sc_sm_resource_group_collection_size - 1

          for index in 0..group_size do
            sc_sm_resource_group_handle = RedSnow::Binding.sc_sm_resource_group_handle(sc_sm_resource_group_collection_handle, index)
            @resource_groups << ResourceGroup.new(sc_sm_resource_group_handle)
          end
        end
      end
    end
  end
end
