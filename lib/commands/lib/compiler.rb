module Moka
  class Compiler
    require File.expand_path('page_scope', File.dirname(__FILE__))
    require File.expand_path('utilities', File.dirname(__FILE__))
    require "rubygems"

    # Compile page creating its file in the compiled dir
    def compile!(group, page_name, manifest = nil)
      if manifest.nil?
        manifest = YAML.load_file(File.expand_path("manifest.yml", MOKA_ROOT))
      end

      puts "compiling #{group}:#{page_name}..."

      page_string = compile(group, page_name, manifest)
      path = manifest["site"][group][page_name]["path"]

      page_dir = File.dirname(path)
      unless page_dir == "."
        FileUtils.mkdir_p(File.expand_path("compiled/"+page_dir, MOKA_ROOT))
      end
      compiled_file = File.new(File.expand_path("compiled/"+path, MOKA_ROOT), "w")
      compiled_file.print(page_string)
      compiled_file.close
    end


    # Compile page into a string and returns it
    def compile(group, page_name, manifest = nil)
      path = nil

      if manifest.nil?
        manifest = YAML.load_file(File.expand_path("manifest.yml", MOKA_ROOT))
      end

      m_page_data = manifest["site"][group][page_name]
      layout = m_page_data["layout"].nil? ? "layout" : m_page_data["layout"]
      path = m_page_data["path"]

      # load layout file
      ext = nil
      layout_dir = File.join [group, page_name]
      while ext.nil? do
        if File.exist?(File.expand_path("project/site/#{layout_dir}/#{layout}.erb", MOKA_ROOT))
          layout_file = File.new(File.expand_path("project/site/#{layout_dir}/#{layout}.erb", MOKA_ROOT), "r")
          ext = "erb"
        elsif File.exist?(File.expand_path("project/site/#{layout_dir}/#{layout}.haml", MOKA_ROOT))
          layout_file = File.new(File.expand_path("project/site/#{layout_dir}/#{layout}.haml", MOKA_ROOT), "r")
          ext = "haml"
        end
        if layout_dir == "" and ext.nil?
          puts "ERROR: cannot find layout file #{layout}.erb or #{layout}.haml"
          exit
        end
        layout_dir = File.dirname layout_dir
        if layout_dir == "."
          layout_dir = ""
        end
      end
  
      page_string = ""
      layout_file.each_line do |line|
        page_string += line
      end
      layout_file.close
  
      # this object is the scope in which erb/haml code will be evaluated
      code_evaluator = PageScope.new(Moka::Utilities.deepcopy(manifest), group, page_name )

      return Moka::Utilities.eval_erb_haml(page_string, ext, code_evaluator.get_binding)
    end


    # Compile a sass stylesheet and returns a css string
    def compile_style(style_name)
      require 'sass'
      style_file = File.expand_path("project/styles/#{style_name}.sass", MOKA_ROOT)
      unless File.exists? style_file
        style_file = File.expand_path("project/styles/#{style_name}.scss", MOKA_ROOT)
      end
      if File.exists? style_file
        return Sass::Engine.new(File.new(style_file).read, {
          :load_paths => [File.expand_path("project/styles/", MOKA_ROOT)],
          :style => :compact,
          :syntax => File.extname(style_file) == ".sass" ? :sass : :scss
        }).render
      else
        puts "ERROR: style file '#{style_file}' not found"
        return nil
      end
    end


    # Compile sass stylesheets into css creating files in the compiled/stylesheets dir
    def compile_styles!
      require 'sass'
      if File.directory? File.expand_path("project/styles/", MOKA_ROOT)
        Dir.glob(File.expand_path("project/styles/[^_]*.{sass,scss}", MOKA_ROOT)).each do |style_file|
          style_string = Sass::Engine.new(File.new(style_file).read, {
            :load_paths => [File.expand_path("project/styles/", MOKA_ROOT)],
            :style => :compact,
            :syntax => File.extname(style_file) == ".sass" ? :sass : :scss
          }).render
          compiled_style = File.new(File.expand_path("compiled/stylesheets/#{File.basename(style_file, File.extname(style_file))}.css", MOKA_ROOT), "w")
          compiled_style.print(style_string)
          compiled_style.close
        end
      else
        puts "WARNING: styles directory not found"
      end
    end

  end
end