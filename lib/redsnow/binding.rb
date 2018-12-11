require 'ffi'

module RedSnow
  # expose function free() to allow release memory allocated by C-interface
  module Memory
    extend FFI::Library
    ffi_lib FFI::Library::LIBC

    attach_function :free, [:pointer], :void
  end

  # C-binding with Snow Crash Library using [FFI](https://github.com/ffi/ffi)
  # @see https://github.com/apiaryio/drafter/blob/master/src/cdrafter.h
  module Binding
    extend FFI::Library

    # for unix/mac either a .so (unix) or .dylib (mac) is built
    # Mac will accept both .so or .dylib so the below will work cross platform
    ffi_lib  Dir.glob("./ext/drafter/build/out/Release/**/libdrafter.*").first
    enum :option, [
      :render_descriptions_option,
      :require_blueprint_name_option,
      :export_sourcemap_option
    ]

    attach_function('drafter_c_parse', 'drafter_c_parse', [:string, :option, :pointer], :int)
  end
end
