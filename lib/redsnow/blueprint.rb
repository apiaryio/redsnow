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
  # @abstract
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
      item && item[:value]
    end

    def get_item(key)
      @collection.select { |item| item[:name].downcase == key.downcase }.first
    end
  end

  # Metadata collection Blueprint AST node
  #   represents 'metadata section'
  class Metadata < KeyValueCollection

    # @param metadata [json]
    def initialize(metadata)
      return if metadata.nil?

      @collection = []
      metadata.each do |item|
        @collection << Hash[name: item["name"], value: item.fetch("value", nil)]
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

    # @param headers [json]
    def initialize(headers)
      @collection = []

      return if headers.nil?

      headers.each do |item|
        @collection << Hash[name: item["name"], value: item["value"]]
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

    # @param parameter [json]
    def initialize(parameter)
      @name = parameter.fetch("name", "")
      @description = parameter.fetch("description", "")
      @type = parameter.fetch("type", "")

      case parameter["required"]
      when true
        @use = :required
      when false
        @use = :optional
      else
        @use = :undefined
      end

      @default_value = parameter.fetch("default", nil)
      @example_value = parameter.fetch("example", nil)

      @values = []
      parameter.has_key?("values") and parameter["values"].each do |value|
        @values << value["value"]
      end
    end
  end

  # Collection of URI parameters Blueprint AST node
  #   represents 'parameters section'
  #
  # @attr collection [Array<Parameter>] an array of URI parameters
  class Parameters < BlueprintNode
    attr_accessor :collection

    # @param parameters [json]
    def initialize(parameters)
      @collection = []

      return if parameters.nil?

      parameters.each do |item|
        @collection << Parameter.new(item)
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

    # @param payload [json]
    def initialize(payload)
       @name = payload.fetch("name", "")
       @description = payload.fetch("description", "")
       @body = payload.fetch("body", "")
       @schema = payload.fetch("schema", "")

       if payload.has_key?("reference") and payload["reference"].has_key?("id")
         @reference = ReferenceNode.new(payload["reference"]["id"])
       end

       @headers = Headers.new(payload.fetch("headers", nil))
    end
  end

  # Transaction example Blueprint AST node
  #
  # @attr requests [Array<Request>] example request payloads
  # @attr response [Array<Response>] example response payloads
  class TransactionExample < NamedBlueprintNode
    attr_accessor :requests
    attr_accessor :responses

    # @param example [json]
    def initialize(example)
      @name = example.fetch("name", "")
      @description = example.fetch("description", "")

      @requests = []
      example.has_key?("requests") and example["requests"].each do |request|
        @requests << Payload.new(request).tap do |inst|
          example_instance = self
          inst.define_singleton_method(:example) { example_instance }
        end
      end

      @responses = []
      example.has_key?("responses") and example["responses"].each do |response|
        @responses << Payload.new(response).tap do |inst|
          example_instance = self
          inst.define_singleton_method(:example) { example_instance }
        end
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

    # @param action [json]
    def initialize(action)
      @name = action.fetch("name", "")
      @description = action.fetch("description", "")

      @method = action.fetch("method", "")

      @parameters = Parameters.new(action.fetch("parameters", nil))

      @examples = []
      action.has_key?("examples") and action["examples"].each do |example|
        @examples << TransactionExample.new(example).tap do |inst|
          action_instance = self
          inst.define_singleton_method(:action) { action_instance }
        end
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

    # @param resource [json]
    def initialize(resource)
      @name = resource.fetch("name", "")
      @description = resource.fetch("description", "")
      @uri_template = resource.fetch("uriTemplate", "")

      @model = Payload.new(resource.fetch("model", nil))

      @parameters = Parameters.new(resource.fetch("parameters", nil))

      @actions = []
      resource.has_key?("actions") and resource["actions"].each do |action|
        @actions << Action.new(action).tap do |inst|
          resource_instance = self
          inst.define_singleton_method(:resource) { resource_instance }
        end
      end
    end
  end

  # Resource group Blueprint AST node
  #   represents 'resource group section'
  #
  # @attr resources [Array<Resource>] array of resources in the group
  class ResourceGroup < NamedBlueprintNode
    attr_accessor :resources

    # @param resource_group [json]
    def initialize(resource_group)
      @name = resource_group.fetch("name", "")
      @description = resource_group.fetch("description", "")

      @resources = []
      resource_group.has_key?("resources") and resource_group["resources"].each do |resource|
        @resources << Resource.new(resource).tap do |inst|
          resource_group_instance = self
          inst.define_singleton_method(:resource_group) { resource_group_instance }
        end
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

    # @param ast [json]
    def initialize(ast)
      @name = ast.fetch("name", "")
      @description = ast.fetch("description", "")
      @metadata = Metadata.new(ast.fetch("metadata", nil))

      @resource_groups = []
      ast.has_key?("resourceGroups") and ast["resourceGroups"].each do |resource_group|
        @resource_groups << ResourceGroup.new(resource_group)
      end
    end
  end
end
