#!/usr/bin/env ruby

require "yaml"
require "fileutils"
require 'getoptlong'
require File.expand_path('lib/utilities', File.dirname(__FILE__))
require File.expand_path('lib/compiler', File.dirname(__FILE__))

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ]
)

opts.each do |opt, arg|
  case opt
    when '--help'
      puts <<-EOT

Usage:

 moka compile [page1] [page2] ...

Examples:
   moka compile index about othergroup:contacts
     compile pages 'index' and 'about' belonging to group 'root' and page 'contacts' belonging to group 'othergroup'

   moka compile
     compile all pages
      EOT
      exit
  end
end

compiler = Moka::Compiler.new

manifest = YAML.load_file(File.expand_path("manifest.yml", MOKA_ROOT))

puts ""

if ARGV.size < 1
  # compile all pages
  manifest["site"].each do |group, pages|
    if pages.is_a? Hash
      pages.each do |page, page_vars|
        if page_vars.is_a? Hash
          compiler.compile! group, page, manifest
        end
      end
    end
  end
else
  # compile only pages passed as command line arguments
  to_compile = {}

  ARGV.each do |arg|
    # parse arg to support syntax groupname:pagename
    tc_page_name, tc_group = Moka::Utilities.parse_grouppage(arg)
    if to_compile[tc_group].nil?
      to_compile[tc_group] = [tc_page_name]
    else
      to_compile[tc_group] << tc_page_name
    end
  end
  # compile each page to be compiled
  to_compile.each do |group, pages|
    pages.each do |page|
      unless manifest["site"][group].nil? or manifest["site"][group][page].nil?
        compiler.compile! group, page, manifest
      end
    end
  end
end

# compile sass stylesheets
puts ""
puts "compiling stylesheets..."
compiler.compile_styles!
puts ""
