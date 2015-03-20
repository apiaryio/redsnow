require 'redsnow/object'

# The classes in this module should be 1:1 with the Snow Crash Blueprint sourcemap
# counterparts (https://github.com/apiaryio/snowcrash/blob/master/src/BlueprintSourcemap.h).
module RedSnow
  module Sourcemap
    # Base Node - holds @collection
    class Node
      attr_accessor :collection

      # @param sourcemap [json array or nil]
      def initialize(sourcemap)
        @collection = []

        return if sourcemap.nil?

        sourcemap.each do |sm|
          @collection << SourceMap.new(sm)
        end
      end
    end

    # SourceMap
    class SourceMap < Array
      # @param sourcemap [json array or nil]
      def initialize(sourcemap)
        return if sourcemap.nil?

        sourcemap.each do |position|
          self << position
        end
      end
    end

    # Blueprint sourcemap node with name && description associated
    #
    # @attr name [SourceMap] name of the node
    # @attr description [SourceMap] description of the node
    #
    # @abstract
    class NamedNode < Node
      attr_accessor :name
      attr_accessor :description

      # @param sourcemap [json array or nil]
      def initialize(sourcemap)
        return if sourcemap.nil?

        @name = SourceMap.new(sourcemap['name'])
        @description = SourceMap.new(sourcemap['description'])
      end
    end

    # Metadata source map collection node
    class Metadata < Node
      # @param sourcemap [json]
      def initialize(sourcemap)
        super(sourcemap)
      end
    end

    # Headers source map collection node
    class Headers < Node
      # @param sourcemap [json]
      def initialize(sourcemap)
        super(sourcemap)
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

      # @param sourcemap [json]
      def initialize(sourcemap)
        super(sourcemap)

        @type = SourceMap.new(sourcemap['type'])
        @use = SourceMap.new(sourcemap['required'])
        @default_value = SourceMap.new(sourcemap['default'])
        @example_value = SourceMap.new(sourcemap['example'])
        @values = []

        sourcemap.key?('values') && sourcemap['values'].each do |value|
          @values << SourceMap.new(value['value'])
        end
      end
    end

    # Parameters source map collection node
    #
    # @attr collection [Array<Parameter>] an array of URI parameters
    class Parameters < Node
      # @param sourcemap [json]
      def initialize(sourcemap)
        @collection = []

        return if sourcemap.nil?

        sourcemap.each do |parameter|
          @collection << Parameter.new(parameter)
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

      # @param sourcemap [json]
      def initialize(sourcemap)
        return if sourcemap.nil?

        super(sourcemap)

        @body = SourceMap.new(sourcemap['body'])
        @schema = SourceMap.new(sourcemap['schema'])
        @reference = SourceMap.new(sourcemap['reference'])
        @headers = Headers.new(sourcemap['headers'])
      end
    end

    # Transaction example source map node
    #
    # @attr requests [Array<Request>] example request payloads
    # @attr response [Array<Response>] example response payloads
    class TransactionExample < NamedNode
      attr_accessor :requests
      attr_accessor :responses

      # @param sourcemap [json]
      def initialize(sourcemap)
        super(sourcemap)

        @requests = []
        sourcemap.key?('requests') && sourcemap['requests'].each do |request|
          @requests << Payload.new(request)
        end

        @responses = []
        sourcemap.key?('responses') && sourcemap['responses'].each do |response|
          @responses << Payload.new(response)
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

      # @param sourcemap [json]
      def initialize(sourcemap)
        return if sourcemap.nil?

        super(sourcemap)

        @method = SourceMap.new(sourcemap['method'])
        @parameters = Parameters.new(sourcemap['parameters'])

        @examples = []
        sourcemap.key?('examples') && sourcemap['examples'].each do |example|
          @examples << TransactionExample.new(example)
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

      # @param sourcemap [json]
      def initialize(sourcemap)
        return if sourcemap.nil?

        super(sourcemap)
        @uri_template = SourceMap.new(sourcemap['uriTemplate'])
        @model = Payload.new(sourcemap['model'])
        @parameters = Parameters.new(sourcemap['parameters'])

        @actions = []
        sourcemap.key?('actions') && sourcemap['actions'].each do |action|
          @actions << Action.new(action)
        end
      end
    end

    # Resource group source map node
    #
    # @attr resources [Array<Resource>] array of resources in the group
    class ResourceGroup < NamedNode
      attr_accessor :resources

      # @param sourcemap [json]
      def initialize(sourcemap)
        super(sourcemap)

        @resources = []
        sourcemap.key?('resources') && sourcemap['resources'].each do |resource|
          @resources << Resource.new(resource)
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

      # @param sourcemap [json]
      def initialize(sourcemap)
        return if sourcemap.nil?

        super(sourcemap)

        @metadata = Metadata.new(sourcemap['metadata'])
        @resource_groups = []

        sourcemap.key?('resourceGroups') && sourcemap['resourceGroups'].each do |resource_group|
          @resource_groups << ResourceGroup.new(resource_group)
        end
      end
    end
  end
end
