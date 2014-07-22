require "bundler/gem_tasks"
require 'rake/testtask'
require 'rake/extensiontask'
require 'ffi'


task :default => :compile

desc "Compile extension"
task :compile do
  prefix = "lib.target/"
  if FFI::Platform.mac?
    prefix = ""
  end
  path = File.expand_path("ext/snowcrash/build/out/Release/#{prefix}libsnowcrash.#{FFI::Platform::LIBSUFFIX}", File.dirname(__FILE__))
  puts path
  if !File.exists?(path) || ENV['RECOMPILE']
    puts "Compiling extension..."
    `cd #{File.expand_path("ext/snowcrash/")} && ./configure --shared && make`
  else
    puts "Extension already compiled. To recompile set env variable RECOMPILE=true."
  end
end

Rake::TestTask.new(:test) do |test|
  Rake::Task["compile"].invoke

  test.libs << 'lib' << 'test'
  test.test_files = FileList['test/*_test.rb']
  test.verbose = true
end

