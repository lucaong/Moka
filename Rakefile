require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('moka') do |p|
  p.summary        = "An damn simple static website framework."
  p.description    = "Moka is a damn simple framework designed to build static websites like portfolios, showcases, minisites, HTML mockups, etc. Moka setup takes a single command, and it provides you with a hierarchical template system and some super-convenient helper functions so you never have to write more code than necessary. The result of your work is compiled to plain HTML, CSS and Javascript: you just need to upload it to your server to deploy it. Add as a bonus the Lipsum helpers, with which you can generate dummy text with a single line of code during development or in HTML mockups."
  p.url            = "https://github.com/DukeLeNoir/Moka"
  p.author         = ["Luca Ongaro", "Luca Tironi"]
  p.email          = ["mail@lucaongaro.eu", "luca.tironi@gmail.com"]
  p.install_message= "Welcome aboard Moka. You'll love it!"
  p.ignore_pattern = ["TODOs"]
  p.runtime_dependencies = ["thor", "haml"]
  p.development_dependencies = []
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }