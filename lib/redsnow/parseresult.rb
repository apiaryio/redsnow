require 'json'

module RedSnow
  # Parse Result
  # @see https://github.com/apiaryio/api-blueprint-ast/blob/master/Parse%20Result.md
  # @param ast [Blueprint]
  # @param error [Hash] Description of a parsing error as occurred during parsing. If this field is present && code different from 0 then the content of ast field should be ignored.
  # @param warnings [Array<Hash>] Ordered array of parser warnings as occurred during the parsing.
  # @param sourcemap [BlueprintSourcemap]
  class ParseResult
    attr_accessor :ast
    attr_accessor :error
    attr_accessor :warnings
    attr_accessor :sourcemap

    # Version key
    VERSION_KEY = :_version

    # Supported version of Api Blueprint
    SUPPORTED_VERSIONS = ['2.1']

    # @param parse_result [ string or nil ]
    def initialize(parse_result)
      parse_result = JSON.parse(parse_result)

      @ast = Blueprint.new(parse_result['ast'])
      @sourcemap = RedSnow::Sourcemap::Blueprint.new(parse_result['sourcemap'])

      @warnings = []
      parse_result.key?('warnings') && parse_result['warnings'].each do |warning|
        @warnings << source_annotation(warning)
      end

      @error = source_annotation(parse_result['error'])
    end

    protected

    def source_annotation(json)
      annotation = {}

      annotation[:message] = json['message']
      annotation[:code] = json['code']
      annotation[:ok] = json.fetch('code', 0)

      annotation[:location] = []
      json.key?('location') && json['location'].each do |location|
        annotation[:location] << Location.new(location)
      end

      annotation
    end
  end

  # Array of possibly non-continuous blocks of the source API Blueprint.
  # @param index [Number] Zero-based index of the character where warning has occurred.
  # @param length [Number] Number of the characters from index where warning has occurred.
  class Location
    attr_accessor :index
    attr_accessor :length

    # @param location [json]
    def initialize(location)
      @length = location['length']
      @index = location['index']
    end
  end

  # Warnning Codes
  # @see https://github.com/apiaryio/snowcrash/blob/master/src/SourceAnnotation.h#L128
  class WarningCodes
    NO_WARNING = 0
    API_NAME_WARNING = 1
    DUPLICATE_WARNING = 2
    FORMATTING_WARNING = 3
    REDEFINITION_WARNING = 4
    IGNORING_WARNING = 5
    EMPTY_DEFINITION_WARNING = 6
    NOT_EMPTY_DEFINITION_WARNING = 7
    LOGICAL_ERROR_WARNING = 8
    DEPRECATED_WARNING = 9
    INDENTATION_WARNING = 10
    AMBIGUITY_WARNING = 11
    URI_WARNING = 12
  end
  # Error Codes
  # @see https://github.com/apiaryio/snowcrash/blob/master/src/SourceAnnotation.h#L113
  class ErrorCodes
    NO_ERROR = 0
    APPLICATION_ERROR = 1
    BUSINESS_ERROR = 2
    SYMBOL_ERROR = 3
  end
end
