module RedSnow

  # Parse Result
  # @see https://github.com/apiaryio/api-blueprint-ast/blob/master/Parse%20Result.md
  # @param ast [String] The structure under this key is defined by the []AST Blueprint serialization Media Type v2.0](https://github.com/apiaryio/api-blueprint-ast#json-serialization)
  # @param error [Hash] Description of a parsing error as occurred during parsing. If this field is present and code different from 0 then the content of ast field should be ignored.
  # @param warnings [Array<Hash>] Ordered array of parser warnings as occurred during the parsing.
  class ParseResult
    attr_accessor :ast
    attr_accessor :error
    attr_accessor :warnings

    # Version key
    VERSION_KEY = :_version
    # Supported version of Api Blueprint
    SUPPORTED_VERSIONS = ["2.0"]

    # @param result_handle [FFI::Pointer]
    def initialize(result_handle)

      warnings = RedSnow::Binding.sc_warnings_handler(result_handle)
      warningsSize = RedSnow::Binding.sc_warnings_size(warnings)
      @warnings = Array.new
      for index in 0..(warningsSize - 1) do
        sc_warning_handler = RedSnow::Binding.sc_warning_handler(warnings, index)

        warning = Hash.new
        warning[:message] = RedSnow::Binding.sc_warning_message(sc_warning_handler)
        warning[:code] = RedSnow::Binding.sc_warning_code(sc_warning_handler)
        warning[:ok] = RedSnow::Binding.sc_warning_ok(sc_warning_handler)

        sc_location_handler = RedSnow::Binding.sc_location_handler(sc_warning_handler)
        sc_location_size = RedSnow::Binding.sc_location_size(sc_location_handler)
        warning[:location] = Array.new
        if sc_location_size > 0
          for index in 0..(sc_location_size - 1)
            location = Location.new(sc_location_handler, index)
            warning[:location] << location
          end
        end
        @warnings << warning
      end

      error_handler = RedSnow::Binding.sc_error_handler(result_handle)
      @error = Hash.new
      @error[:message] = RedSnow::Binding.sc_error_message(error_handler)
      @error[:code] = RedSnow::Binding.sc_error_code(error_handler)
      @error[:ok] = RedSnow::Binding.sc_error_ok(error_handler)

      sc_location_handler = RedSnow::Binding.sc_location_handler(error_handler)
      sc_location_size = RedSnow::Binding.sc_location_size(sc_location_handler)
      @error[:location] = Array.new
      if sc_location_size > 0
        for index in 0..(sc_location_size - 1) do
          location = Location.new(sc_location_handler, index)
          @error[:location] << location
        end
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

  class WarningCodes
    NoWarning = 0
    APINameWarning = 1
    DuplicateWarning = 2
    FormattingWarning = 3
    RedefinitionWarning = 4
    IgnoringWarning = 5
    EmptyDefinitionWarning = 6
    NotEmptyDefinitionWarning = 7
    LogicalErrorWarning = 8
    DeprecatedWarning = 9
    IndentationWarning = 10
    AmbiguityWarning = 11
    URIWarning = 12

  end

  class ErrorCodes
    NoError = 0
    ApplicationError = 1
    BusinessError = 2
    SymbolError = 3
  end

end
