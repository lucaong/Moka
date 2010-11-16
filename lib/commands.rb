ARGV << '--help' if ARGV.empty?

aliases = {
  "n"  => "new",
  "i" => "inspect",
  "d"  => "delete",
  "s"  => "server",
  "op"  => "order_pages",
  "og"  => "order_groups",
  "c" => "compile"
}

command = ARGV.shift
command = aliases[command] || command

case command
when 'new'
  require "commands/new"

when 'inspect'
  require 'commands/inspect'

when 'delete'
  require "commands/delete"

when 'order_groups'
  require "commands/order_groups"

when 'order_pages'
  require "commands/order_pages"

when 'server'
  require 'commands/server'

when 'compile'
  require 'commands/compile'

else
  puts "Error: Command not recognized" unless %w(-h --help).include?(command)
  puts <<-EOT
Usage: moka COMMAND [ARGS]

The most common moka commands are:
 new            Generate a new site, page or group (short-cut alias: "n")
 inspect        Inspect site, a group or a page (short-cut alias: "i")
 delete         Delete a group or page (short-cut alias "d")
 compile        Compile the project into html and css (short-cut alias "c")
 server         Start a development server (short-cut alias "s")
 order_pages    Start a utility to change pages ordering (short-cut alias "op")
 order_groups   Start a utility to change groups ordering (short-cut alias "og")

All commands can be run with -h for more information.
  EOT
end