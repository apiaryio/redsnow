require "red_snow/version"
require "ffi"

module RedSnow

  module Binding
    extend FFI::Library

    prefix = "lib.target/"
    if FFI::Platform.mac?
      prefix = ""
    end

    ffi_lib File.expand_path("../../ext/snowcrash/build/out/Release/#{prefix}libsnowcrash.#{FFI::Platform::LIBSUFFIX}", __FILE__)

    attach_function("sc_c_parse", "sc_c_parse", [ :string, :int, :pointer, :pointer ], :int)

    attach_function("sc_blueprint_name", "sc_blueprint_name", [ :pointer ], :string)
    attach_function("sc_blueprint_description", "sc_blueprint_description", [ :pointer ], :string)

    attach_function("sc_metadata_collection_handle", "sc_metadata_collection_handle", [ :pointer ], :pointer)
    attach_function("sc_metadata_collection_size", "sc_metadata_collection_size", [ :pointer ], :int)

    attach_function("sc_metadata_handle", "sc_metadata_handle", [:pointer, :int], :string)
    attach_function("sc_metadata_key", "sc_metadata_key", [:pointer], :string)
    attach_function("sc_metadata_value", "sc_metadata_value",[:pointer], :string)

    attach_function("sc_blueprint_free", "sc_blueprint_free", [ :pointer ], :void)
    attach_function("sc_result_free", "sc_result_free", [ :pointer ], :void)

    attach_function("sc_warnings_handler", "sc_warnings_handler", [:pointer], :pointer)
    attach_function("sc_warnings_size", "sc_warnings_size", [ :pointer ], :int)

  end


  def self.parse(rawBlueprint)
    blueprint = FFI::MemoryPointer.new :pointer
    result = FFI::MemoryPointer.new :pointer
    output = ''
    ret = RedSnow::Binding.sc_c_parse(rawBlueprint, 0, result, blueprint)

    blueprint = blueprint.get_pointer(0)
    result = result.get_pointer(0)

    return RedSnow::Binding.sc_blueprint_name(blueprint)
  ensure
    RedSnow::Binding.sc_blueprint_free(blueprint)
    RedSnow::Binding.sc_result_free(result)
  end

end
