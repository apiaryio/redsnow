require 'redsnow/object'

# The classes in this module should be 1:1 with the Snow Crash AST
# counterparts (https://github.com/apiaryio/snowcrash/blob/master/src/Blueprint.h).
module RedSnow
  # Blueprint AST node
  #   Base class for API Blueprint AST nodes
  #
  # @abstract
  class BlueprintNode
  end

  # Blueprint AST Reference node
  #
  # @attr id [String] identifier of the reference
  #
  # @abstrac
  class ReferenceNode < BlueprintNode
    attr_accessor :id

    def initialize(id)
      @id = id
    end
  end

  # Blueprint AST node with name and description associated
  #
  # @attr name [String] name of the node
  # @attr description [String] description of the node
  #
  # @abstract
  class NamedBlueprintNode < BlueprintNode
    attr_accessor :name
    attr_accessor :description

    # Ensure the input string buffer ends with two newlines.
    #
    # @param buffer [String] a buffer to check
    #   If the buffer does not ends with two newlines the newlines are added.
    def ensure_description_newlines(buffer)
      return if description.empty?

      if description[-1, 1] != "\n"
        buffer << "\n\n"
      elsif description.length > 1 && description[-2, 1] != "\n"
        buffer << "\n"
      end
    end
  end

  # Blueprint AST node for key-value collections
  #
  # @abstract
  # @attr collection [Array<Hash>] array of key value hashes
  class KeyValueCollection < BlueprintNode
    attr_accessor :collection

    # Retrieves the value of the collection item by its key
    #
    # @param key [String] Name of the item key to retrieve
    # @return [NilClass] if the collection does not have an item with the key
    # @return [String] if the collection has an item with the key
    def [](key)
      return nil if @collection.nil?
      return_item_value key
    end
    # Filter collection keys
    #
    # @return [Array<Hash>] collection without ignored keys
    def filter_collection(ignore_keys)
      return @collection if ignore_keys.blank?
      @collection.select { |kv_item| !ignore_keys.include?(kv_item.keys.first) }
    end

    private

    def return_item_value(key)
      item = get_item(key.to_s)
      item.nil? ? nil : item[:value]
    end

    def get_item(key)
      @collection.select { |item| item[:name].downcase == key.downcase }.first
    end
  end

  # Metadata collection Blueprint AST node
  #   represents 'metadata section'
  class Metadata < KeyValueCollection
    # Constructor
    # @param sc_metadata_collection_handle [FFI::Pointer]
    def initialize(sc_metadata_collection_handle)
      sc_metadata_collection_size = RedSnow::Binding.sc_metadata_collection_size(sc_metadata_collection_handle)
      @collection = []

      return if sc_metadata_collection_size == 0

      metadata_size = sc_metadata_collection_size - 1
      (0..metadata_size).each do |index|
        sc_metadata_handle = RedSnow::Binding.sc_metadata_handle(sc_metadata_collection_handle, index)
        @collection << Hash[name: RedSnow::Binding.sc_metadata_key(sc_metadata_handle), value: RedSnow::Binding.sc_metadata_value(sc_metadata_handle)]
      end
    end
  end

  # Headers collection Blueprint AST node
  #   represents 'headers section'
  class Headers < KeyValueCollection
    # HTTP 'Content-Type' header
    CONTENT_TYPE_HEADER_KEY = :'Content-Type'

    # @return [String] the value of 'Content-type' header if present or nil
    def content_type
      content_type_header = @collection.find { |header| header.key?(CONTENT_TYPE_HEADER_KEY) }
      (content_type_header.nil?) ? nil : content_type_header[CONTENT_TYPE_HEADER_KEY]
    end

    # @param sc_header_collection_handle_payload [FFI::Pointer]
    def initialize(sc_header_collection_handle_payload)
      sc_header_collection_size = RedSnow::Binding.sc_header_collection_size(sc_header_collection_handle_payload)
      @collection = []

      return if sc_header_collection_size == 0

      headers_size = sc_header_collection_size - 1
      (0..headers_size).each do |index|
        sc_header_handle = RedSnow::Binding.sc_header_handle(sc_header_collection_handle_payload, index)
        @collection << Hash[name: RedSnow::Binding.sc_header_key(sc_header_handle), value: RedSnow::Binding.sc_header_value(sc_header_handle)]
      end
    end
  end

  # URI parameter Blueprint AST node
  #   represents one 'parameters section' parameter
  #
  # @attr type [String] an arbitrary type of the parameter or nil
  # @attr use [Symbol] parameter necessity flag, `:required`, `:optional` or :undefined
  #    Where `:undefined` implies `:required` according to the API Blueprint Specification
  # @attr default_value [String] default value of the parameter or nil
  #   This is a value used when the parameter is ommited in the request.
  # @attr example_value [String] example value of the parameter or nil
  # @attr values [Array<String>] an enumeration of possible parameter values
  class Parameter < NamedBlueprintNode
    attr_accessor :type
    attr_accessor :use
    attr_accessor :default_value
    attr_accessor :example_value
    attr_accessor :values

    # @param sc_parameter_handle [FFI::Pointer]
    def initialize(sc_parameter_handle)
      @name = RedSnow::Binding.sc_parameter_name(sc_parameter_handle)
      @description = RedSnow::Binding.sc_parameter_description(sc_parameter_handle)
      @type = RedSnow::Binding.sc_parameter_type(sc_parameter_handle)
      @use =  RedSnow::Binding.sc_parameter_parameter_use(sc_parameter_handle)
      @default_value = RedSnow::Binding.sc_parameter_default_value(sc_parameter_handle)
      @example_value = RedSnow::Binding.sc_parameter_example_value(sc_parameter_handle)

      @values = []

      sc_value_collection_handle = RedSnow::Binding.sc_value_collection_handle(sc_parameter_handle)
      sc_value_collection_size = RedSnow::Binding.sc_value_collection_size(sc_value_collection_handle)

      return if sc_value_collection_size == 0

      values_size = sc_value_collection_size - 1
      (0..values_size).each do |value_index|
        sc_value_handle = RedSnow::Binding.sc_value_handle(sc_value_collection_handle, value_index)
        @values << RedSnow::Binding.sc_value(sc_value_handle)
      end
    end
  end

  # Collection of URI parameters Blueprint AST node
  #   represents 'parameters section'
  #
  # @attr collection [Array<Parameter>] an array of URI parameters
  class Parameters < BlueprintNode
    attr_accessor :collection

    # @param sc_parameter_collection_handle [FFI::Pointer]
    def initialize(sc_parameter_collection_handle)
      sc_parameter_collection_size = RedSnow::Binding.sc_parameter_collection_size(sc_parameter_collection_handle)
      @collection = []

      return if sc_parameter_collection_size == 0

      parameters_size = sc_parameter_collection_size - 1
      (0..parameters_size).each do |index|
        sc_parameter_handle = RedSnow::Binding.sc_parameter_handle(sc_parameter_collection_handle, index)
        @collection << Parameter.new(sc_parameter_handle)
      end
    end
  end

  # HTTP message payload Blueprint AST node
  #   base class for 'payload sections'
  #
  # @abstract
  # @attr parameters [Array] ignored
  # @attr headers [Headers] array of HTTP header fields of the message or nil
  # @attr body [String] HTTP-message body or nil
  # @attr schema [String] HTTP-message body validation schema or nil
  # @attr reference [Hash] Symbol Reference if the payload is a reference
  class Payload < NamedBlueprintNode
    attr_accessor :headers
    attr_accessor :body
    attr_accessor :schema
    attr_accessor :reference

    # @param sc_payload_handle_resource [FFI::Pointer]
    def initialize(sc_payload_handle_resource)
      @name = RedSnow::Binding.sc_payload_name(sc_payload_handle_resource)
      @description = RedSnow::Binding.sc_payload_description(sc_payload_handle_resource)
      @body = RedSnow::Binding.sc_payload_body(sc_payload_handle_resource)
      @schema = RedSnow::Binding.sc_payload_schema(sc_payload_handle_resource)

      sc_reference_handle_payload = RedSnow::Binding.sc_reference_handle_payload(sc_payload_handle_resource)
      sc_reference_id = RedSnow::Binding.sc_reference_id(sc_reference_handle_payload)

      unless sc_reference_id.empty?
        @reference = ReferenceNode.new(sc_reference_id)
      end

      sc_header_collection_handle_payload = RedSnow::Binding.sc_header_collection_handle_payload(sc_payload_handle_resource)
      @headers = Headers.new(sc_header_collection_handle_payload)
    end
  end

  # Transaction example Blueprint AST node
  #
  # @attr requests [Array<Request>] example request payloads
  # @attr response [Array<Response>] example response payloads
  class TransactionExample < NamedBlueprintNode
    attr_accessor :requests
    attr_accessor :responses

    # @param sc_transaction_example_handle [FFI::Pointer]
    def initialize(sc_transaction_example_handle)
      @name  = RedSnow::Binding.sc_transaction_example_name(sc_transaction_example_handle)
      @description = RedSnow::Binding.sc_transaction_example_description(sc_transaction_example_handle)

      # BP Resource Actions Examples Requests
      @requests = []
      sc_payload_collection_handle_requests = RedSnow::Binding.sc_payload_collection_handle_requests(sc_transaction_example_handle)
      sc_payload_collection_size_requests = RedSnow::Binding.sc_payload_collection_size(sc_payload_collection_handle_requests)

      if sc_payload_collection_size_requests > 0
        requests_size = sc_payload_collection_size_requests - 1

        (0..requests_size).each do |index|
          sc_payload_handle = RedSnow::Binding.sc_payload_handle(sc_payload_collection_handle_requests, index)
          @requests << Payload.new(sc_payload_handle)
        end
      end

      # BP Resource Actions Examples Responses
      @responses = []
      sc_payload_collection_handle_responses = RedSnow::Binding.sc_payload_collection_handle_responses(sc_transaction_example_handle)
      sc_payload_collection_size_responses = RedSnow::Binding.sc_payload_collection_size(sc_payload_collection_handle_responses)

      return if sc_payload_collection_size_responses == 0

      responses_size = sc_payload_collection_size_responses - 1
      (0..responses_size).each do |index|
        sc_payload_handle = RedSnow::Binding.sc_payload_handle(sc_payload_collection_handle_responses, index)
        @responses << Payload.new(sc_payload_handle)
      end
    end
  end

  # Action Blueprint AST node
  #   represetns 'action sction'
  #
  # @attr method [String] HTTP request method or nil
  # @attr parameters [Parameters] action-specific URI parameters or nil
  # @attr examples [Array<TransactionExample>] action transaction examples
  class Action < NamedBlueprintNode
    attr_accessor :method
    attr_accessor :parameters
    attr_accessor :examples

    # @param sc_action_handle [FFI::Pointer]
    def initialize(sc_action_handle)
      @name = RedSnow::Binding.sc_action_name(sc_action_handle)
      @description = RedSnow::Binding.sc_action_description(sc_action_handle)

      @method = RedSnow::Binding.sc_action_httpmethod(sc_action_handle)

      @parameters = Parameters.new(RedSnow::Binding.sc_parameter_collection_handle_action(sc_action_handle))

      @examples = []
      sc_transaction_example_collection_handle = RedSnow::Binding.sc_transaction_example_collection_handle(sc_action_handle)
      sc_transaction_example_collection_size = RedSnow::Binding.sc_transaction_example_collection_size(sc_transaction_example_collection_handle)

      return if sc_transaction_example_collection_size == 0

      examples_size = sc_transaction_example_collection_size - 1
      (0..examples_size).each do |index|
        sc_transaction_example_handle = RedSnow::Binding.sc_transaction_example_handle(sc_transaction_example_collection_handle, index)
        @examples << TransactionExample.new(sc_transaction_example_handle)
      end
    end
  end

  # Resource Blueprint AST node
  #   represents 'resource section'
  #
  # @attr uri_template [String] RFC 6570 URI template
  # @attr model [Model] model payload for the resource or nil
  # @attr parameters [Parameters] action-specific URI parameters or nil
  # @attr actions [Array<Action>] array of resource actions or nil
  class Resource < NamedBlueprintNode
    attr_accessor :uri_template
    attr_accessor :model
    attr_accessor :parameters
    attr_accessor :actions

    # @param sc_resource_handle [FFI::Pointer]
    def initialize(sc_resource_handle)
      @name = RedSnow::Binding.sc_resource_name(sc_resource_handle)
      @description = RedSnow::Binding.sc_resource_description(sc_resource_handle)
      @uri_template = RedSnow::Binding.sc_resource_uritemplate(sc_resource_handle)

      sc_payload_handle_resource = RedSnow::Binding.sc_payload_handle_resource(sc_resource_handle)
      @model = Payload.new(sc_payload_handle_resource)

      @parameters = Parameters.new(RedSnow::Binding.sc_parameter_collection_handle_resource(sc_resource_handle))

      @actions = []
      sc_action_collection_handle = RedSnow::Binding.sc_action_collection_handle(sc_resource_handle)
      sc_action_collection_size = RedSnow::Binding.sc_action_collection_size(sc_action_collection_handle)

      return if sc_action_collection_size == 0

      action_size = sc_action_collection_size - 1
      (0..action_size).each do |index|
        sc_action_handle = RedSnow::Binding.sc_action_handle(sc_action_collection_handle, index)
        @actions << Action.new(sc_action_handle)
      end
    end
  end

  # Resource group Blueprint AST node
  #   represents 'resource group section'
  #
  # @attr resources [Array<Resource>] array of resources in the group
  class ResourceGroup < NamedBlueprintNode
    attr_accessor :resources

    # @param sc_resource_group_handle [FFI::Pointer]
    def initialize(sc_resource_group_handle)
      @name = RedSnow::Binding.sc_resource_group_name(sc_resource_group_handle)
      @description = RedSnow::Binding.sc_resource_group_description(sc_resource_group_handle)

      @resources = []
      sc_resource_collection_handle = RedSnow::Binding.sc_resource_collection_handle(sc_resource_group_handle)
      sc_resource_collection_size = RedSnow::Binding.sc_resource_collection_size(sc_resource_collection_handle)

      return if sc_resource_collection_size == 0

      resource_size = sc_resource_collection_size - 1
      (0..resource_size).each do |index|
        sc_resource_handle = RedSnow::Binding.sc_resource_handle(sc_resource_collection_handle, index)
        @resources << Resource.new(sc_resource_handle)
      end
    end
  end

  # Top-level Blueprint AST node
  #   represents 'blueprint section'
  #
  # @attr metadata [Metadata] tool-specific metadata collection or nil
  # @attr resource_groups [Array<ResourceGroup>] array of blueprint resource groups
  class Blueprint < NamedBlueprintNode
    attr_accessor :metadata
    attr_accessor :resource_groups

    # Version key
    VERSION_KEY = :_version

    # Supported version of Api Blueprint
    SUPPORTED_VERSIONS = ['2.1']

    # @param handle [FFI:Pointer]
    def initialize(handle)
      # BP name, desc
      @name = RedSnow::Binding.sc_blueprint_name(handle)
      @description = RedSnow::Binding.sc_blueprint_description(handle)

      # BP metadata
      sc_metadata_collection_handle = RedSnow::Binding.sc_metadata_collection_handle(handle)
      @metadata = Metadata.new(sc_metadata_collection_handle)

      # BP Resource Groups
      sc_resource_group_collection_handle = RedSnow::Binding.sc_resource_group_collection_handle(handle)
      sc_resource_group_collection_size = RedSnow::Binding.sc_resource_group_collection_size(sc_resource_group_collection_handle)
      @resource_groups = []

      return if sc_resource_group_collection_size == 0

      group_size = sc_resource_group_collection_size - 1
      (0..group_size).each do |index|
        sc_resource_group_handle = RedSnow::Binding.sc_resource_group_handle(sc_resource_group_collection_handle, index)
        @resource_groups << ResourceGroup.new(sc_resource_group_handle)
      end
    end
  end
end
