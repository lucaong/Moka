#!/usr/bin/env ruby

require 'getoptlong'

if ARGV.include? '--help' or ARGV.include? '-h'
  puts <<-EOT

Usage:

  moka new site site_name

  or

  moka new page page_name

  or

  moka new page group_name:page_name...

  or

  moka new group group_name...

Examples:

  moka new site my_site_name
    create a brand new moka project named 'my_site_name'

  moka new page groupname:pagename -vars=var_name:var_value other_var_name:other_var_value
    create a page named 'pagename' in group 'groupname' using layout 'custom_layout' that will compile in 'mydir/mypage.php' and has a custom variable 'customvar' with value 'customvalue'

  moka new page groupname:pagename -t anothergroup:anotherpage
    create a page named 'pagename' in group 'groupname' that replicates partials and variables used by page 'anotherpage' in group 'anothergroup'

  moka new group group_name -t anothergroup
    create a group named 'group_name' that replicates the same pages, partials and variables of group 'anothergroup'

Options:

  -t, --template:
     specify another page or group or moka site to use as a template to create the new page/group/site. The new page/group/site will have a copy of all the partials, variables and pages of the template page/group/site, apart from those variables that are explicitly set as command line arguments.
  -v, --vars:
     set variables in the appropriate variables.yml file. Syntax is:
       -vars=var_name:var_value other_var_name:other_var_value ...
       or
       -v var_name:var_value other_var_name:other_var_value ...
     variables are saved as strings. Other variable types can be set by editing directly the variables.yml file with a text editor.
  EOT
  exit
end

thing_to_be_created = ARGV.shift

case thing_to_be_created
  when 'page', 'p'
    require File.expand_path('page/new', File.dirname(__FILE__))
  when 'group', 'g'
    require File.expand_path('group/new', File.dirname(__FILE__))
  when 'site', 'project', 's'
    require File.expand_path('site/new', File.dirname(__FILE__))
  else
    puts "ERROR: invalid option #{thing_to_be_created}. Valid options are 'site', 'page' and 'group'."
    exit
end