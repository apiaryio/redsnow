require "red_snow/version"
require "red_snow/binding"
require "red_snow/blueprint"
require "ffi"

module RedSnow
  include Binding

  def self.parse(rawBlueprint, options = 0)
    blueprint = FFI::MemoryPointer.new :pointer
    result = FFI::MemoryPointer.new :pointer
    ret = RedSnow::Binding.sc_c_parse(rawBlueprint, options, result, blueprint)

    blueprint = blueprint.get_pointer(0)
    result = result.get_pointer(0)

    bp = Blueprint.new(blueprint)

    return bp
  ensure
    RedSnow::Binding.sc_blueprint_free(blueprint)
    RedSnow::Binding.sc_result_free(result)
  end

end
