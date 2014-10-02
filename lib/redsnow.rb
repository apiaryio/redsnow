require "redsnow/version"
require "redsnow/binding"
require "redsnow/blueprint"
require "redsnow/sourcemap"
require "redsnow/parseresult"
require "ffi"

module RedSnow
  include Binding
  # parse
  #   parsing API Blueprint into Ruby objects
  # @param rawBlueprint [String] API Blueprint
  # @param options [Number] Parsing Options
  #
  # @return [ParseResult]
  def self.parse(rawBlueprint, options = 0)

    raise ArgumentError.new("Expected string value") unless rawBlueprint.is_a?(String)

    blueprint = FFI::MemoryPointer.new :pointer
    sourcemap = FFI::MemoryPointer.new :pointer
    report = FFI::MemoryPointer.new :pointer

    ret = RedSnow::Binding.sc_c_parse(rawBlueprint, options, report, blueprint, sourcemap)

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
