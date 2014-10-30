module RedSnow
  # Parse Result
  # @see https://github.com/apiaryio/api-blueprint-ast/blob/master/Parse%20Result.md
  # @param ast [Blueprint]
  # @param error [Hash] Description of a parsing error as occurred during parsing. If this field is present and code different from 0 then the content of ast field should be ignored.
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

    # @param report_handle [FFI::Pointer]
    def initialize(report_handle, blueprint_handle, sourcemap_handle)
      @ast = Blueprint.new(blueprint_handle)
      @sourcemap = RedSnow::Sourcemap::Blueprint.new(sourcemap_handle)

      warnings = RedSnow::Binding.sc_warnings_handler(report_handle)
      warnings_size = RedSnow::Binding.sc_warnings_size(warnings)

      @warnings = []

      (0..(warnings_size - 1)).each do |index|
        sc_warning_handler = RedSnow::Binding.sc_warning_handler(warnings, index)

        warning = {}
        warning[:message] = RedSnow::Binding.sc_warning_message(sc_warning_handler)
        warning[:code] = RedSnow::Binding.sc_warning_code(sc_warning_handler)
        warning[:ok] = RedSnow::Binding.sc_warning_ok(sc_warning_handler)

        sc_location_handler = RedSnow::Binding.sc_location_handler(sc_warning_handler)
        sc_location_size = RedSnow::Binding.sc_location_size(sc_location_handler)
        warning[:location] = []

        if sc_location_size > 0
          (0..(sc_location_size - 1)).each do |index_size|
            location = Location.new(sc_location_handler, index_size)
            warning[:location] << location
          end
        end
        @warnings << warning
      end

      error_handler = RedSnow::Binding.sc_error_handler(report_handle)
      @error = {}
      @error[:message] = RedSnow::Binding.sc_error_message(error_handler)
      @error[:code] = RedSnow::Binding.sc_error_code(error_handler)
      @error[:ok] = RedSnow::Binding.sc_error_ok(error_handler)

      sc_location_handler = RedSnow::Binding.sc_location_handler(error_handler)
      sc_location_size = RedSnow::Binding.sc_location_size(sc_location_handler)
      @error[:location] = []

      return if sc_location_size == 0

      (0..(sc_location_size - 1)).each do |index|
        location = Location.new(sc_location_handler, index)
        @error[:location] << location
      end
    end
  end

  # Array of possibly non-continuous blocks of the source API Blueprint.
  # @param index [Number] Zero-based index of the character where warning has occurred.
  # @param length [Number] Number of the characters from index where warning has occurred.
  class Location
    attr_accessor :index
    attr_accessor :length

    # @param location_hander [FFI:Pointer]
    # @param index [Number]
    def initialize(location_hander, index)
      @length = RedSnow::Binding.sc_location_length(location_hander, index)
      @index = RedSnow::Binding.sc_location_location(location_hander, index)
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
