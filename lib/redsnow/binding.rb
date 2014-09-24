require "ffi"

module RedSnow
  # C-binding with Snow Crash Library using [FFI](https://github.com/ffi/ffi)
  # @see https://github.com/apiaryio/snowcrash/blob/master/src/csnowcrash.cc
  # @see https://github.com/apiaryio/snowcrash/blob/master/src/CBlueprint.cc
  module Binding
    extend FFI::Library

    prefix = "lib.target/"
    if FFI::Platform.mac?
      prefix = ""
    end

    ffi_lib File.expand_path("../../../ext/snowcrash/build/out/Release/#{prefix}libsnowcrash.#{FFI::Platform::LIBSUFFIX}", __FILE__)
    # @see https://github.com/apiaryio/snowcrash/blob/master/src/BlueprintParserCore.h#L31
    enum :option, [
        :render_descriptions_option,
        :require_blueprint_name_option,
        :export_sourcemap_option
    ]

    attach_function("sc_c_parse", "sc_c_parse", [ :string, :option, :pointer, :pointer, :pointer ], :int)

    attach_function("sc_blueprint_free", "sc_blueprint_free", [ :pointer ], :void)
    attach_function("sc_blueprint_name", "sc_blueprint_name", [ :pointer ], :string)
    attach_function("sc_blueprint_description", "sc_blueprint_description", [ :pointer ], :string)

    attach_function("sc_metadata_collection_handle", "sc_metadata_collection_handle", [ :pointer ], :pointer)
    attach_function("sc_metadata_collection_size", "sc_metadata_collection_size", [ :pointer ], :int)

    attach_function("sc_metadata_handle", "sc_metadata_handle", [ :pointer, :int ], :pointer)
    attach_function("sc_metadata_key", "sc_metadata_key", [ :pointer ], :string)
    attach_function("sc_metadata_value", "sc_metadata_value",[ :pointer ], :string)

    attach_function("sc_resource_group_collection_handle", "sc_resource_group_collection_handle", [ :pointer ], :pointer)
    attach_function("sc_resource_group_collection_size", "sc_resource_group_collection_size", [ :pointer ], :int)

    attach_function("sc_resource_group_handle", "sc_resource_group_handle", [ :pointer, :int ], :pointer)
    attach_function("sc_resource_group_name", "sc_resource_group_name", [ :pointer ], :string)
    attach_function("sc_resource_group_description", "sc_resource_group_description", [ :pointer ], :string)

    attach_function("sc_resource_collection_handle", "sc_resource_collection_handle", [ :pointer ] , :pointer)
    attach_function("sc_resource_collection_size", "sc_resource_collection_size", [ :pointer ], :int)
    # Resource
    attach_function("sc_resource_handle", "sc_resource_handle", [ :pointer, :int ] , :pointer)
    attach_function("sc_resource_uritemplate", "sc_resource_uritemplate", [ :pointer ], :string)
    attach_function("sc_resource_name", "sc_resource_name", [ :pointer ], :string)
    attach_function("sc_resource_description", "sc_resource_description", [ :pointer ], :string)

    attach_function("sc_payload_collection_handle_requests", "sc_payload_collection_handle_requests", [ :pointer ], :pointer)
    attach_function("sc_payload_collection_handle_responses", "sc_payload_collection_handle_responses", [ :pointer ], :pointer)
    attach_function("sc_payload_collection_size", "sc_payload_collection_size", [ :pointer ], :int)
    # Resource.model
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

    # @see https://github.com/apiaryio/snowcrash/blob/master/src/Blueprint.h#L85
    enum :parameter_use, [:undefined,
                          :optional,
                          :required,
                         ]

    attach_function("sc_parameter_handle", "sc_parameter_handle", [ :pointer, :int ], :pointer)
    attach_function("sc_parameter_name", "sc_parameter_name", [ :pointer ], :string)
    attach_function("sc_parameter_description", "sc_parameter_description", [ :pointer ], :string)
    attach_function("sc_parameter_type", "sc_parameter_type", [ :pointer ], :string)
    attach_function("sc_parameter_parameter_use", "sc_parameter_parameter_use", [ :pointer ], :parameter_use)
    attach_function("sc_parameter_default_value", "sc_parameter_default_value", [ :pointer ], :string)
    attach_function("sc_parameter_example_value", "sc_parameter_example_value", [ :pointer ], :string)

    attach_function("sc_value_collection_handle", "sc_value_collection_handle", [ :pointer], :pointer)
    attach_function("sc_value_collection_size", "sc_value_collection_size", [ :pointer ], :int)

    attach_function("sc_value_handle", "sc_value_handle", [ :pointer, :int ], :pointer)
    attach_function("sc_value", "sc_value", [ :pointer], :string)

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

    attach_function("sc_report_free", "sc_report_free", [ :pointer ], :void)

    attach_function("sc_location_handler", "sc_location_handler", [ :pointer ], :pointer)
    attach_function("sc_location_size", "sc_location_size", [ :pointer ], :int)
    attach_function("sc_location_length", "sc_location_length", [ :pointer, :int ], :int)
    attach_function("sc_location_location", "sc_location_location", [ :pointer, :int ], :int)

    attach_function("sc_error_handler", "sc_error_handler", [ :pointer ], :pointer)
    attach_function("sc_error_message", "sc_error_message", [ :pointer ], :string)
    attach_function("sc_error_code", "sc_error_code", [ :pointer ], :int)
    attach_function("sc_error_ok", "sc_error_ok", [ :pointer ], :int)

    attach_function("sc_warnings_handler", "sc_warnings_handler", [ :pointer ], :pointer)
    attach_function("sc_warnings_size", "sc_warnings_size", [ :pointer ], :int)
    attach_function("sc_warning_handler", "sc_warning_handler", [ :pointer, :int ], :pointer)
    attach_function("sc_warning_message", "sc_warning_message", [ :pointer ], :string)
    attach_function("sc_warning_code", "sc_warning_code", [ :pointer], :int)
    attach_function("sc_warning_ok", "sc_warning_ok", [ :pointer ], :int)

    # Sourcemap's c-interface functions
    attach_function("sc_source_map_size", "sc_source_map_size", [ :pointer ], :int)
    attach_function("sc_source_map_length", "sc_source_map_length", [ :pointer, :int ], :int)
    attach_function("sc_source_map_location", "sc_source_map_location", [ :pointer, :int ], :int)

    attach_function("sc_sm_blueprint_free", "sc_sm_blueprint_free", [ :pointer ], :void)
    attach_function("sc_sm_blueprint_name", "sc_sm_blueprint_name", [ :pointer ], :pointer)
    attach_function("sc_sm_blueprint_description", "sc_sm_blueprint_description", [ :pointer ], :pointer)

    attach_function("sc_sm_metadata_collection_handle", "sc_sm_metadata_collection_handle", [ :pointer ], :pointer)
    attach_function("sc_sm_metadata_collection_size", "sc_sm_metadata_collection_size", [ :pointer ], :int)

    attach_function("sc_sm_metadata_handle", "sc_sm_metadata_handle", [ :pointer, :int ], :pointer)
    attach_function("sc_sm_metadata", "sc_sm_metadata", [ :pointer ], :pointer)

    attach_function("sc_sm_resource_group_collection_handle", "sc_sm_resource_group_collection_handle", [ :pointer ], :pointer)
    attach_function("sc_sm_resource_group_collection_size", "sc_sm_resource_group_collection_size", [ :pointer ], :int)

    attach_function("sc_sm_resource_group_handle", "sc_sm_resource_group_handle", [ :pointer, :int ], :pointer)
    attach_function("sc_sm_resource_group_name", "sc_sm_resource_group_name", [ :pointer ], :pointer)
    attach_function("sc_sm_resource_group_description", "sc_sm_resource_group_description", [ :pointer ], :pointer)

    attach_function("sc_sm_resource_collection_handle", "sc_sm_resource_collection_handle", [ :pointer ] , :pointer)
    attach_function("sc_sm_resource_collection_size", "sc_sm_resource_collection_size", [ :pointer ], :int)
    # Resource
    attach_function("sc_sm_resource_handle", "sc_sm_resource_handle", [ :pointer, :int ] , :pointer)
    attach_function("sc_sm_resource_uritemplate", "sc_sm_resource_uritemplate", [ :pointer ], :pointer)
    attach_function("sc_sm_resource_name", "sc_sm_resource_name", [ :pointer ], :pointer)
    attach_function("sc_sm_resource_description", "sc_sm_resource_description", [ :pointer ], :pointer)

    attach_function("sc_sm_payload_collection_handle_requests", "sc_sm_payload_collection_handle_requests", [ :pointer ], :pointer)
    attach_function("sc_sm_payload_collection_handle_responses", "sc_sm_payload_collection_handle_responses", [ :pointer ], :pointer)
    attach_function("sc_sm_payload_collection_size", "sc_sm_payload_collection_size", [ :pointer ], :int)
    # Resource.model
    attach_function("sc_sm_payload_handle", "sc_sm_payload_handle", [ :pointer, :int ], :pointer)
    attach_function("sc_sm_payload_handle_resource", "sc_sm_payload_handle_resource", [ :pointer ], :pointer)
    attach_function("sc_sm_payload_name", "sc_sm_payload_name", [ :pointer ], :pointer)
    attach_function("sc_sm_payload_description", "sc_sm_payload_description", [ :pointer ], :pointer)
    attach_function("sc_sm_payload_body", "sc_sm_payload_body", [ :pointer ], :pointer)
    attach_function("sc_sm_payload_schema", "sc_sm_payload_schema", [ :pointer ], :pointer)

    attach_function("sc_sm_parameter_collection_handle_payload", "sc_sm_parameter_collection_handle_payload", [ :pointer ], :pointer)
    attach_function("sc_sm_parameter_collection_handle_resource", "sc_sm_parameter_collection_handle_resource", [ :pointer ], :pointer)
    attach_function("sc_sm_parameter_collection_handle_action", "sc_sm_parameter_collection_handle_action", [ :pointer ], :pointer)
    attach_function("sc_sm_parameter_collection_size", "sc_sm_parameter_collection_size", [ :pointer ], :int)

    attach_function("sc_sm_parameter_handle", "sc_sm_parameter_handle", [ :pointer, :int ], :pointer)
    attach_function("sc_sm_parameter_name", "sc_sm_parameter_name", [ :pointer ], :pointer)
    attach_function("sc_sm_parameter_description", "sc_sm_parameter_description", [ :pointer ], :pointer)
    attach_function("sc_sm_parameter_type", "sc_sm_parameter_type", [ :pointer ], :pointer)
    attach_function("sc_sm_parameter_parameter_use", "sc_sm_parameter_parameter_use", [ :pointer ], :pointer)
    attach_function("sc_sm_parameter_default_value", "sc_sm_parameter_default_value", [ :pointer ], :pointer)
    attach_function("sc_sm_parameter_example_value", "sc_sm_parameter_example_value", [ :pointer ], :pointer)

    attach_function("sc_sm_value_collection_handle", "sc_sm_value_collection_handle", [ :pointer], :pointer)
    attach_function("sc_sm_value_collection_size", "sc_sm_value_collection_size", [ :pointer ], :int)

    attach_function("sc_sm_value_handle", "sc_sm_value_handle", [ :pointer, :int ], :pointer)
    attach_function("sc_sm_value", "sc_sm_value", [ :pointer], :pointer)

    attach_function("sc_sm_header_collection_handle_payload", "sc_sm_header_collection_handle_payload", [ :pointer ], :pointer)
    attach_function("sc_sm_header_collection_handle_resource", "sc_sm_header_collection_handle_resource", [ :pointer ], :pointer)
    attach_function("sc_sm_header_collection_handle_action", "sc_sm_header_collection_handle_action", [ :pointer ], :pointer)
    attach_function("sc_sm_header_collection_size", "sc_sm_header_collection_size", [ :pointer ], :int)

    attach_function("sc_sm_header_handle", "sc_sm_header_handle", [ :pointer, :int ], :pointer)
    attach_function("sc_sm_header", "sc_sm_header", [ :pointer], :pointer)

    attach_function("sc_sm_action_collection_handle", "sc_sm_action_collection_handle", [ :pointer ], :pointer)
    attach_function("sc_sm_action_collection_size", "sc_sm_action_collection_size", [ :pointer], :int)

    attach_function("sc_sm_action_handle", "sc_sm_action_handle", [ :pointer, :int ], :pointer)
    attach_function("sc_sm_action_httpmethod", "sc_sm_action_httpmethod", [ :pointer], :pointer)
    attach_function("sc_sm_action_name", "sc_sm_action_name", [ :pointer], :pointer)
    attach_function("sc_sm_action_description", "sc_sm_action_description", [ :pointer ], :pointer)

    attach_function("sc_sm_transaction_example_collection_handle", "sc_sm_transaction_example_collection_handle", [ :pointer ], :pointer)
    attach_function("sc_sm_transaction_example_collection_size", "sc_sm_transaction_example_collection_size", [ :pointer ], :int)

    attach_function("sc_sm_transaction_example_handle", "sc_sm_transaction_example_handle", [ :pointer, :int ], :pointer)
    attach_function("sc_sm_transaction_example_name", "sc_sm_transaction_example_name", [ :pointer ], :pointer)
    attach_function("sc_sm_transaction_example_description", "sc_sm_transaction_example_description", [ :pointer ], :pointer)

  end

end
