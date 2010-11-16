require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('moka', '0.1.1') do |p|
  p.summary        = "An damn simple static website framework."
  p.description    = "Moka is a damn simple framework designed to build static websites like portfolios, showcases, minisites, HTML mockups, etc. Moka setup takes a single command, and it provides a hierarchical template system and some hyper-convenient helper functions so you never have to write more code than necessary. The result of your work is compiled to plain HTML, CSS and Javascript, so you just have to upload it to your server. Plus, don't forget the Lipsum helper functions to generate dummy text with a single line of code during development or in HTML mockups."
  p.url            = "https://github.com/DukeLeNoir/Moka"
  p.author         = "Luca Ongaro"
  p.email          = "mail@lucaongaro.eu"
  p.install_message= "Welcome aboard Moka. You'll love it!"
  p.ignore_pattern = ["TODOs"]
  p.runtime_dependencies = ["thor", "haml"]
  p.development_dependencies = []
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }