require 'redsnow/version'
require 'redsnow/binding'
require 'redsnow/blueprint'
require 'redsnow/sourcemap'
require 'redsnow/parseresult'
require 'ffi'

# RedSnow
module RedSnow
  include Binding

  # Options
  EXPORT_SOURCEMAP_OPTION_KEY = :exportSourcemap
  REQUIRE_BLUEPRINT_NAME_OPTION_KEY = :requireBlueprintName

  # Parse options
  attr_accessor :options
  def self.parse_options(options)
    # Parse Options
    if options.is_a?(Numeric)
      return options
    else
      opt = 0
      opt |= (1 << 1) if options[REQUIRE_BLUEPRINT_NAME_OPTION_KEY]
      opt |= (1 << 2) if options[EXPORT_SOURCEMAP_OPTION_KEY]
      return opt
    end
  end

  # parse
  #   parsing API Blueprint into Ruby objects
  # @param raw_blueprint [String] API Blueprint
  # @param options [Number] Parsing Options
  #
  # @return [ParseResult]
  def self.parse(raw_blueprint, options = 0)
    fail ArgumentError, 'Expected string value' unless raw_blueprint.is_a?(String)

    blueprint_options = parse_options(options)

    parse_result = FFI::MemoryPointer.new :pointer

    RedSnow::Binding.drafter_c_parse(raw_blueprint, blueprint_options, parse_result)

    parse_result = parse_result.get_pointer(0)

    ParseResult.new(parse_result.null? ? nil : parse_result.read_string)
  ensure

    RedSnow::Memory.free(parse_result)
  end
end
