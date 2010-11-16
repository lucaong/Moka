#!/usr/bin/env ruby

require 'getoptlong'

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ]
)

opts.each do |opt, arg|
  case opt
    when '--help'
      puts <<-EOT

Usage:

 moka inspect page group_name:page_name

 or

 moka inspect group group_name

 or

 moka inspect site

Examples:
 moka inspect page groupname:mypagename
   show variables and parameters available in page 'mypagename' belonging to group 'groupname'

 moka inspect page index
   show variables and parameters available in page 'index' belonging to group 'root'

 moka inspect group mygroup
   show variables, parameters and pages available in group 'mygroup'

 moka inspect site
   show site-level variables, parameters and groups
      EOT
      exit
  end
end

thing_to_be_inspected = ARGV.shift

case thing_to_be_inspected
  when 'page', 'p'
    require File.expand_path('page/inspect', File.dirname(__FILE__))
  when 'group', 'g'
    require File.expand_path('group/inspect', File.dirname(__FILE__))
  when 'site', 's'
    require File.expand_path('site/inspect', File.dirname(__FILE__))
  else
    puts "ERROR: invalid option #{thing_to_be_inspected}. Valid options are 'page', 'group' and 'site'."
    exit
end