#!/usr/bin/env ruby
require 'getoptlong'

module Moka
  class SimpleServer
    require 'webrick'
    require "yaml"
    require File.expand_path('lib/compiler', File.dirname(__FILE__))
    include WEBrick

    def run(config = {})
      start_webrick(config) do |server|
        compiler = Moka::Compiler.new
        server.mount_proc('/') do |req, resp|
          puts req
          if req.path == "" or req.path[-1] == ?/
            req.path << "index.html"
          end
          manifest = YAML.load_file(File.expand_path("manifest.yml", MOKA_ROOT))
          group_name, page_name = search_page_by_path(req.path.sub("/", ""), manifest)
          if group_name.nil? or page_name.nil?
            if File.extname(req.path) == ".css" and (File.exists?(File.expand_path("project/styles/#{File.basename(req.path, ".css") + ".sass"}", MOKA_ROOT)) or File.exists?(File.expand_path("project/styles/#{File.basename(req.path, ".css") + ".scss"}", MOKA_ROOT)))
              resp.status = 200
              resp["Content-Type"] = get_content_type(req.path)
              resp.body = compiler.compile_style(File.basename(req.path, ".css"))
            elsif File.exist?(File.expand_path("compiled#{req.path}", MOKA_ROOT))
              f = File.new(File.expand_path("compiled#{req.path}", MOKA_ROOT), "r")
              resp.status = 200
              resp["Content-Type"] = get_content_type(req.path)
              resp.body = f.read
              f.close
            else
              resp.status = 404
              resp["Content-Type"] = "text/plain"
              resp.body = "Sorry... it looks like the page you are searching doesn't exist..."
            end
          else
            resp.status = 200
            resp["Content-Type"] = get_content_type(req.path)
            resp.body = compiler.compile(group_name, page_name, manifest)
          end
        end
      end
    end

    private

    def start_webrick(config = {})
      # always listen on port 3333 if not explicitly specified
      config.update(:Port => 3333) if config[:Port].nil?
      server = HTTPServer.new(config)
      yield server if block_given?
      ['INT', 'TERM'].each {|signal| 
        trap(signal) {server.shutdown}
      }
      server.start
    end

    def search_page_by_path(path, manifest)
      manifest["site"].each do |group_name, pages|
        if pages.is_a? Hash
          pages.each do |page_name, page_vars|
            if page_vars.is_a?(Hash) and page_vars["path"] == path
              return [group_name, page_name]
            end
          end
        end
      end
      return [nil, nil]
    end

    def get_content_type(p)
      # some common extensions...
      case File.extname(p)
        when ".css"
          "text/css"
        when ".js"
          "text/javascript"
        when ".xml"
          "text/xml"
        when ".jpeg"
          "image/jpeg"
        when ".jpg"
          "image/jpeg"
        when ".gif"
          "image/gif"
        when ".png"
          "image/png"
        when ".tiff"
          "image/tiff"
        when ".ico"
          "image/x-icon"
        when ".txt"
          "text/plain"
        when ".pdf"
          "application/pdf"
        when ".swf"
          "application/x-shockwave-flash"
        else
          "text/html"
      end
    end
  end
end

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ]
)

opts.each do |opt, arg|
  case opt
    when '--help'
      puts <<-EOT

Usage:

 moka server [port]

 Start an extremely simple development server on http://localhost:8080/ or on the port specified as the first argument. This server eliminates the need to re-compile pages after each change, but it is only intended for development purpose. Currently, it only serves static HTML pages, and recognizes a limited number of content types.
      EOT
      exit
  end
end

Moka::SimpleServer.new.run({ :Port => (ARGV.size > 0) ? ARGV[0].to_i : 3333 })
