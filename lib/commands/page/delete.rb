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
  puts "you need to specify a page name."
  exit
end

# parse ARGV[0] to support syntax groupname:pagename
page_name, group = Moka::Moka::Utilities.parse_grouppage ARGV.first

path = ""
manifest = YAML.load_file(File.expand_path("manifest.yml", MOKA_ROOT))

unless manifest["site"][group].nil? or manifest["site"][group][page_name].nil?
  path = manifest["site"][group][page_name]["path"]
else
  puts "ERROR: cannot find any page named '#{page_name}' in group '#{group}'"
  exit
end

manifest["site"][group].delete page_name

f = File.open( File.expand_path('manifest.yml', MOKA_ROOT), 'w' ) do |out|
  YAML.dump( manifest, out )
end

FileUtils.rm_r(File.expand_path("project/site/#{group}/#{page_name}", MOKA_ROOT))
if File.exists? File.expand_path("compiled/"+path, MOKA_ROOT)
  FileUtils.rm(File.expand_path("compiled/"+path, MOKA_ROOT))
end

puts ""
puts "Removed page #{group}:#{page_name}"
puts ""
