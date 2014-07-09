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

    attach_function("sc_metadata_handle", "sc_metadata_handle", [ :pointer, :int ], :string)
    attach_function("sc_metadata_key", "sc_metadata_key", [ :pointer ], :string)
    attach_function("sc_metadata_value", "sc_metadata_value",[ :pointer ], :string)

    attach_function("sc_resource_groups_collection_handle", "sc_resource_groups_collection_handle", [ :pointer ], :pointer)
    attach_function("sc_resource_groups_collection_size", "sc_resource_groups_collection_size", [ :pointer ], :int)

    attach_function("sc_resource_groups_handle", "sc_resource_groups_handle", [ :pointer, :int ], :pointer)
    attach_function("sc_resource_groups_name", "sc_resource_groups_name", [ :pointer ], :string)
    attach_function("sc_resource_groups_description", "sc_resource_groups_description", [ :pointer ], :string)

    attach_function("sc_resource_collection_handle", "sc_resource_collection_handle", [ :pointer ] , :pointer)
    attach_function("sc_resource_collection_size", "sc_resource_collection_size", [ :pointer ], :int)

    attach_function("sc_resource_handle", "sc_resource_handle", [ :pointer, :int ] , :pointer)
    attach_function("sc_resource_uritemplate", "sc_resource_uritemplate", [ :pointer ], :string)
    attach_function("sc_resource_name", "sc_resource_name", [ :pointer ], :string)
    attach_function("sc_resource_description", "sc_resource_description", [ :pointer ], :string)

    attach_function("sc_payload_collection_handle_requests", "sc_payload_collection_handle_requests", [ :pointer ], :pointer)
    attach_function("sc_payload_collection_handle_responses", "sc_payload_collection_handle_responses", [ :pointer ], :pointer)
    attach_function("sc_payload_collection_size", "sc_payload_collection_size", [ :pointer ], :int)

    attach_function("sc_payload_handle", "sc_payload_handle", [ :pointer, :int ], :pointer)
    attach_function("sc_payload_handle_resource", "sc_payload_handle_resource", [ :pointer ], :pointer)
    attach_function("sc_payload_name", "sc_payload_name", [ :pointer ], :string)
    attach_function("sc_payload_description", "sc_payload_description", [ :pointer ], :string)
    attach_function("sc_payload_body", "sc_payload_body", [ :pointer ], :string)
    attach_function("sc_payload_schema", "sc_payload_schema", [ :pointer ], :string)

    attach_function("sc_parameter_collection_handle_payload", "sc_parameter_collection_handle_payload", [ :pointer ], :pointer)
    attach_function("sc_parameter_collection_handle_resource", "sc_parameter_collection_handle_resource", [ :pointer ], :pointer)
    attach_function("sc_parameter_collection_handle_action", "sc_parameter_collection_handle_action", [ :pointer ], :pointer)
    attach_function("sc_parameter_collection_size", "sc_parameter_collection_size", [ :pointer ], :int)

    attach_function("sc_parameter_handle", "sc_parameter_handle", [ :pointer, :int ], :pointer)
    attach_function("sc_parameter_name", "sc_parameter_name", [ :pointer ], :string)
    attach_function("sc_parameter_description", "sc_parameter_description", [ :pointer ], :string)
    attach_function("sc_parameter_type", "sc_parameter_type", [ :pointer ], :string)
    attach_function("sc_parameter_parameter_use", "sc_parameter_parameter_use", [ :pointer ], :int)
    attach_function("sc_parameter_default_value", "sc_parameter_default_value", [ :pointer ], :string)
    attach_function("sc_parameter_example_value", "sc_parameter_example_value", [ :pointer ], :string)

    attach_function("sc_value_collection_handle", "sc_value_collection_handle", [ :pointer], :pointer)
    attach_function("sc_value_collection_size", "sc_value_collection_size", [ :pointer ], :int)

    attach_function("sc_value_handle", "sc_value_handle", [ :pointer, :int ], :pointer)
    attach_function("sc_value_string", "sc_value_string", [ :pointer], :string)

    attach_function("sc_header_collection_handle_payload", "sc_header_collection_handle_payload", [ :pointer ], :pointer)
    attach_function("sc_header_collection_handle_resource", "sc_header_collection_handle_resource", [ :pointer ], :pointer)
    attach_function("sc_header_collection_handle_action", "sc_header_collection_handle_action", [ :pointer ], :pointer)
    attach_function("sc_header_collection_size", "sc_header_collection_size", [ :pointer ], :int)

    attach_function("sc_header_handle", "sc_header_handle", [ :pointer, :int ], :pointer)
    attach_function("sc_header_key", "sc_header_key", [ :pointer ], :string)
    attach_function("sc_header_value", "sc_header_value", [ :pointer], :string)

    attach_function("sc_action_collection_handle", "sc_action_collection_handle", [ :pointer ], :pointer)
    attach_function("sc_action_collection_size", "sc_action_collection_size", [ :pointer], :int)

    attach_function("sc_action_handle", "sc_action_handle", [ :pointer, :int ], :pointer)
    attach_function("sc_action_httpmethod", "sc_action_httpmethod", [ :pointer], :string)
    attach_function("sc_action_name", "sc_action_name", [ :pointer], :string)
    attach_function("sc_action_description", "sc_action_description", [ :pointer ], :string)

    attach_function("sc_transaction_example_collection_handle", "sc_transaction_example_collection_handle", [ :pointer ], :pointer)
    attach_function("sc_transaction_example_collection_size", "sc_transaction_example_collection_size", [ :pointer ], :int)

    attach_function("sc_transaction_example_handle", "sc_transaction_example_handle", [ :pointer, :int ], :pointer)
    attach_function("sc_transaction_example_name", "sc_transaction_example_name", [ :pointer ], :string)
    attach_function("sc_transaction_example_description", "sc_transaction_example_description", [ :pointer ], :string)

    attach_function("sc_blueprint_free", "sc_blueprint_free", [ :pointer ], :void)
    attach_function("sc_result_free", "sc_result_free", [ :pointer ], :void)

    attach_function("sc_warnings_handler", "sc_warnings_handler", [ :pointer ], :pointer)
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
