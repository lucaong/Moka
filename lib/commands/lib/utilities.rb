module Moka
  class Utilities

    def self.parse_grouppage(grouppage)
      # parse group:page syntax and return [page, group]
      semicolon = grouppage.index ":"
      unless semicolon.nil?
        return [grouppage[(semicolon + 1)..-1], grouppage[0..(semicolon-1)]]
      else
        return [grouppage, "root"]
      end
    end

    def self.parse_argvalue(argvalue)
      # parse argument=value syntax and return [argument, value]
      equal = argvalue.index "="
      unless equal.nil?
        arg_name = argvalue[0..(equal-1)]
        arg_value = argvalue[(equal + 1)..-1]
      else
        arg_name = argvalue
        arg_value = nil
      end
      return [arg_name, arg_value]
    end
  
    def self.eval_erb_haml(code, ext, scope)
      require "rubygems"
      # evaluates erb or haml code
      if ext == "erb"
        require 'erb'
        eval_string = ERB.new(code).result(scope)
      elsif ext == "haml"
        require 'haml'
        eval_string = Haml::Engine.new(code).render(scope)
      end
      return eval_string
    end
  
    def self.deepcopy(obj)
      Marshal::load(Marshal::dump(obj))
    end

  end
end
