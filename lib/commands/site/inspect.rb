require "yaml"
require "fileutils"
require File.expand_path('../lib/utilities', File.dirname(__FILE__))
require File.expand_path('../lib/site_tree', File.dirname(__FILE__))

include Moka::SiteTree

manifest = YAML.load_file(File.expand_path("manifest.yml", MOKA_ROOT))
@site = SiteNode.new("site", manifest["site"])

puts "\nSite #{@site.name}"
puts "\n Variables:"
@site.variables.each do |var_name, var_value|
  puts "  #{var_name} = #{var_value.inspect}"
end

puts "\n Parameters:"
@site.params.each do |par_name, par_value|
  puts "  #{par_name} = #{par_value.inspect}"
end

puts "\n Groups:"
@site.groups.each do |group|
  puts "  #{group.name}"
end

puts ""

