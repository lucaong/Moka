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

 moka delete page group_name:page_name

 or

 moka delete group group_name

Examples:

   moka delete page mypage
     delete page 'mypage' in group 'root' also eliminating, if existing, the compiled version in the compiled directory

   moka delete page mygroup:mypage
     delete page 'mypage' in group 'mygroup'

   moka delete group mygroup
     delete group 'mygroup' and all its pages
      EOT
      exit
  end
end

thing_to_be_deleted = ARGV.shift

case thing_to_be_deleted
  when 'page', 'p'
    require File.expand_path('page/delete', File.dirname(__FILE__))
  when 'group', 'g'
    require File.expand_path('group/delete', File.dirname(__FILE__))
  else
    puts "ERROR: invalid option #{thing_to_be_deleted}. Valid options are 'page' and 'group'."
    exit
end
