require "yaml"
require "fileutils"
require File.expand_path('../lib/utilities', File.dirname(__FILE__))
require File.expand_path('../lib/site_tree', File.dirname(__FILE__))

include Moka::SiteTree

if ARGV.first.nil?
  puts "you need to specify a group name."
  exit
end

group = ARGV.first

manifest = YAML.load_file(File.expand_path("manifest.yml", MOKA_ROOT))
@site = SiteNode.new("site", manifest["site"])

if manifest["site"][group].nil?
  puts "ERROR: cannot find group '#{group}'"
  exit
end

puts "\nGroup #{group}"
puts "\n Variables:"
@site.find_group(group).variables.each do |var_name, var_value|
  puts "  #{var_name} = #{var_value.inspect}"
end

puts "\n Parameters:"
@site.find_group(group).params.each do |par_name, par_value|
  puts "  #{par_name} = #{par_value.inspect}"
end

puts "\n Pages:"
@site.find_group(group).pages.each do |page|
  puts "  #{page.name}"
end

puts ""

