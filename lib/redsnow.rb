require 'redsnow/version'
require 'redsnow/binding'
require 'redsnow/blueprint'
require 'redsnow/sourcemap'
require 'redsnow/parseresult'
require 'ffi'

module RedSnow
  include Binding

  # Options
  EXPORT_SOURCEMAP_OPTION_KEY = :'exportSourcemap'
  REQUIRE_BLUEPRINT_NAME_OPTION_KEY = :'requireBlueprintName'

  # Parse options
  attr_accessor :options
  def self.parse_options(options)
    # Parse Options
    unless options.is_a?(Numeric)
      opt = 0
      if options.key?(REQUIRE_BLUEPRINT_NAME_OPTION_KEY)
        if options[REQUIRE_BLUEPRINT_NAME_OPTION_KEY]
          opt = opt | (1 << 1)
        end
      end

      if options.key?(EXPORT_SOURCEMAP_OPTION_KEY)
        if options[EXPORT_SOURCEMAP_OPTION_KEY]
          opt = opt | (1 << 2)
        end
      end

      return opt
    else
      return options
    end
  end

  # parse
  #   parsing API Blueprint into Ruby objects
  # @param rawBlueprint [String] API Blueprint
  # @param options [Number] Parsing Options
  #
  # @return [ParseResult]
  def self.parse(rawBlueprint, options = 0)
    fail ArgumentError.new('Expected string value') unless rawBlueprint.is_a?(String)

    blueprintOptions = parse_options(options)

    blueprint = FFI::MemoryPointer.new :pointer
    sourcemap = FFI::MemoryPointer.new :pointer
    report = FFI::MemoryPointer.new :pointer

    RedSnow::Binding.sc_c_parse(rawBlueprint, blueprintOptions, report, blueprint, sourcemap)

    blueprint = blueprint.get_pointer(0)
    sourcemap = sourcemap.get_pointer(0)
    report = report.get_pointer(0)

    parseResult = ParseResult.new(report, blueprint, sourcemap)

    return parseResult
  ensure
    RedSnow::Binding.sc_sm_blueprint_free(sourcemap)
    RedSnow::Binding.sc_blueprint_free(blueprint)
    RedSnow::Binding.sc_report_free(report)
  end
end
