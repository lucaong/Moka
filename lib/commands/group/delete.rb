require "yaml"
require "fileutils"
require File.expand_path('../lib/utilities', File.dirname(__FILE__))

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ]
)

opts.each do |opt, arg|
  case opt
    when '--help'
      RDoc::usage
  end
end

if ARGV.first.nil?
  puts "you need to specify a group name."
  exit
end

group = ARGV.first

paths = []
manifest = YAML.load_file(File.expand_path("manifest.yml", MOKA_ROOT))

unless manifest["site"][group].nil?
  unless manifest["site"][group].is_a? Hash
    puts "ERROR: '#{group}' is a variable, not a group"
    exit
  end
  manifest["site"][group].each do |page, page_vars|
    if page_vars.is_a? Hash
      paths << page_vars["path"] unless page_vars["path"].nil?
    end
  end
else
  puts "ERROR: cannot find any group named '#{group}'"
  exit
end

manifest["site"].delete group

f = File.open( File.expand_path('manifest.yml', MOKA_ROOT), 'w' ) do |out|
  YAML.dump( manifest, out )
end

FileUtils.rm_r(File.expand_path("project/site/#{group}", MOKA_ROOT))
paths.each do |path|
  if File.exists? File.expand_path("compiled/"+path, MOKA_ROOT)
    FileUtils.rm(File.expand_path("compiled/"+path, MOKA_ROOT))
  end
end
if File.exists? File.expand_path("compiled/#{group}", MOKA_ROOT)
  FileUtils.rm_r(File.expand_path("compiled/#{group}", MOKA_ROOT))
end

puts ""
puts "Removed group '#{group}' and all its pages"
puts ""
