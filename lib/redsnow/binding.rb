require 'ffi'

module RedSnow
  # C-binding with Snow Crash Library using [FFI](https://github.com/ffi/ffi)
  # @see https://github.com/apiaryio/drafter/blob/master/src/cdrafter.h
  module Memory
    extend FFI::Library
    ffi_lib FFI::Library::LIBC

    attach_function :free, [:pointer], :void
  end

  module Binding
    extend FFI::Library

    prefix = FFI::Platform.mac? ? '' : 'lib.target/'

    ffi_lib File.expand_path("../../../ext/drafter/build/out/Release/#{prefix}libdrafter.#{FFI::Platform::LIBSUFFIX}", __FILE__)
    enum :option, [
      :render_descriptions_option,
      :require_blueprint_name_option,
      :export_sourcemap_option
    ]

    attach_function('drafter_c_parse', 'drafter_c_parse', [:string, :option, :pointer], :int)

  end
end
