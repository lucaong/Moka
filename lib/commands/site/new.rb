require "script_moka_loader"

if Moka::ScriptMokaLoader.in_moka_application?
  puts "ERROR: cannot create a new moka project into an existing one."
  exit
end

require File.expand_path('site_generator', File.dirname(__FILE__))

Moka::Generators::MokaSiteGenerator.start