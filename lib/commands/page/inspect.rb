require "yaml"
require "fileutils"
require File.expand_path('../lib/utilities', File.dirname(__FILE__))
require File.expand_path('../lib/site_tree', File.dirname(__FILE__))

include Moka::SiteTree

if ARGV.first.nil?
  puts "you need to specify a page name."
  exit
end

# parse ARGV[0] to support syntax groupname:pagename
page_name, group = Moka::Moka::Utilities.parse_grouppage ARGV.first

manifest = YAML.load_file(File.expand_path("manifest.yml", MOKA_ROOT))
@site = SiteNode.new("site", manifest["site"])

if @site.find_group(group).nil? or @site.find_group(group).find_page(page_name).nil?
  puts "ERROR: cannot find page #{group}:#{page_name}"
  exit
end

puts "\nPage #{page_name}"
puts "\n Variables:"
@site.find_group(group).find_page(page_name).variables.each do |var_name, var_value|
  puts "  #{var_name} = #{var_value.inspect}"
end
puts "\n Parameters:"
@site.find_group(group).find_page(page_name).params.each do |par_name, par_value|
  puts "  #{par_name} = #{par_value.inspect}"
end

puts ""

