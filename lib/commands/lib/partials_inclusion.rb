module Moka
  module PartialsInclusion
  
    require File.expand_path('utilities', File.dirname(__FILE__))

    # Include a partial. The method looks for a partial named as the argument and with extension .erb or .haml searching for it first in the current page directory, then in the current group directory and, finally, in the site directory. In other words, the partial which gets included is always the most specific one. If no partial with that name is found, an empty string is returned.
    def partial(partial_name)
      partial_name = partial_name.to_s
      ext = nil
      partial_dir = File.join [@current_group.name, @current_page.name]
    
      partial_string = ""
      partial_file = nil
    
      while ext.nil? do
        if File.exist?(File.expand_path("project/site/#{partial_dir}/#{partial_name}.erb", MOKA_ROOT))
          partial_file = File.new(File.expand_path("project/site/#{partial_dir}/#{partial_name}.erb", MOKA_ROOT), "r")
          ext = "erb"
        elsif File.exist?(File.expand_path("project/site/#{partial_dir}/#{partial_name}.haml", MOKA_ROOT))
          partial_file = File.new(File.expand_path("project/site/#{partial_dir}/#{partial_name}.haml", MOKA_ROOT), "r")
          ext = "haml"
        end
        if partial_dir == "" and ext.nil?
          puts "WARNING: cannot find partial file #{partial_name}.erb or #{partial_name}.haml"
          break
        end
        partial_dir = File.dirname partial_dir
        if partial_dir == "."
          partial_dir = ""
        end
      end
    
      unless partial_file.nil?
        partial_string = partial_file.read
        partial_file.close
      end
    
      return Moka::Utilities.eval_erb_haml(partial_string, ext, self.get_binding)
    end

  end
end