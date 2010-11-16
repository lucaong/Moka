module Moka
  module SiteTree
    RESERVED_NAMES = %w(path order layout name children parent site group groups pages variables vars find_child find_group find_page initialize)

    class TreeNode
      attr_accessor :name
      attr_accessor :parent

      def initialize(name, params = {}, parent = nil)
        @name = name
        @parent = parent
        @children = NodeArray.new
        @params = {"name" => @name}
        @variables = {}
      end

      # Returns a NodeArray object containing all the children nodes of the current node
      def children
        return @children.sort do |a, b|
          if a.respond_to?(:order) and b.respond_to?(:order)
            a.send(:order) <=> b.send(:order)
          else
            if b.respond_to?(:order)
              -1
            else
              1
            end
          end
        end
      end

      # Returns the child node having the name equal to the string passed as argument or nil if such child does not exist
      def find_child(child_name)
        children.find(child_name)
      end

      # Returns a Hash with the node's defined variable names (as keys) and their respective value (as values).
      def variables(include_defined_in_parent = true)
        unless self.parent.nil? or include_defined_in_parent == false
          v = self.parent.variables
        else
          v = {}
        end
        v.merge!(@variables)
      end

      # Returns a Hash containing the node's parameters (as keys) and their respective value (as values).
      def params
        @params
      end

      # Alias for variables
      def vars(include_defined_in_parent = true)
        variables(include_defined_in_parent)
      end

      protected

      # Creates an INSTANCE method dynamically
      def create_method(name, &block)
        self.metaclass.send(:define_method, name, &block)
      end
    end



    class SiteNode < TreeNode
      def initialize(name, params = {}, parent = nil)
        super(name, params, parent)
        if File.exist? File.expand_path("project/site/variables.yml", MOKA_ROOT)
          site_vars = YAML.load_file(File.expand_path("project/site/variables.yml", MOKA_ROOT)) || {}
          site_vars.each do |key, value|
            unless RESERVED_NAMES.include? key
              self.instance_variable_set "@#{key}", value
              @variables[key.to_s] = value
              self.create_method(key) do self.instance_variable_get("@#{key}") end
              self.create_method("#{key}=") do |v| self.instance_variable_set("@#{key}", v); @variables[key.to_s] = v end
            end
          end
        end

        params.each do |key, value|
          key.gsub!(/\s/, "_")
          if value.is_a?(Hash)
            self.instance_variable_set "@#{key}", GroupNode.new(key, value, self)
            @children << instance_eval("@#{key}")
          else
            self.instance_variable_set "@#{key}", value
            @params[key.to_s] = value
          end
          self.create_method(key) do self.instance_variable_get("@#{key}") end
        end
      end

      # Returns a NodeArray object containing all the site's groups (the children of the site node)
      def groups
        self.children
      end

      # Returns the group having the name equal to the string passed as argument or nil if such group does not exist
      def find_group(group_name)
        children.find(group_name)
      end

      # Save site variables in the variables.yml file
      def save
        f = File.open( File.expand_path("project/site/variables.yml", MOKA_ROOT), 'w' ) do |out|
          YAML.dump( variables(false), out )
        end
      end
    end



    class GroupNode < TreeNode
      attr_accessor :site

      def initialize(name, params = {}, parent = nil)
        super(name, params, parent)
        @site = parent

        if File.exist? File.expand_path("project/site/#{name}/variables.yml", MOKA_ROOT)
          group_vars = YAML.load_file(File.expand_path("project/site/#{name}/variables.yml", MOKA_ROOT)) || {}
        else
          group_vars = {}
        end
        @site.variables.merge(group_vars).each do |key, value|
          unless RESERVED_NAMES.include? key
            self.instance_variable_set "@#{key}", value
            @variables[key.to_s] = value if group_vars.keys.include? key.to_s
            self.create_method(key) do self.instance_variable_get("@#{key}") end
            self.create_method("#{key}=") do |v| self.instance_variable_set("@#{key}", v); @variables[key.to_s] = v end
          end
        end

        params.each do |key, value|
          key.gsub!(/\s/, "_")
          if value.is_a?(Hash)
            self.instance_variable_set "@#{key}", PageNode.new(key, value, self)
            @children << instance_eval("@#{key}")
          else
            self.instance_variable_set "@#{key}", value
            @params[key.to_s] = value
          end
          self.create_method(key) do self.instance_variable_get("@#{key}") end
        end
      end

      # Returns a NodeArray object containing all the pages in the group (its children nodes)
      def pages
        self.children
      end

      # Looks for a page in the group having the name equal to the string passed as argument. Returns the page or nil if no such page was found.
      def find_page(page_name)
        children.find(page_name)
      end

      # Save group variables in the variables.yml file
      def save
        f = File.open( File.expand_path("project/site/#{self.name}/variables.yml", MOKA_ROOT), 'w' ) do |out|
          YAML.dump( variables(false), out )
        end
      end
    end



    class PageNode < TreeNode
      attr_accessor :group
  
      def initialize(name, params = {}, parent = nil)
        super(name, params, parent)
        @group = parent

        if File.exist? File.expand_path("project/site/#{@group.name}/#{name}/variables.yml", MOKA_ROOT)
          page_vars = YAML.load_file(File.expand_path("project/site/#{@group.name}/#{name}/variables.yml", MOKA_ROOT)) || {}
        else
          page_vars = {}
        end
        @group.variables.merge(page_vars).each do |key, value|
          unless RESERVED_NAMES.include? key
            self.instance_variable_set("@#{key}", value)
            @variables[key.to_s] = value if page_vars.keys.include? key.to_s
            self.create_method(key) do self.instance_variable_get("@#{key}") end
            self.create_method("#{key}=") do |v| self.instance_variable_set("@#{key}", v); @variables[key.to_s] = v end
          end
        end

        params.each do |key, value|
          key.gsub!(/\s/, "_")
          self.instance_variable_set "@#{key}", value
          @params[key.to_s] = value
          self.create_method(key) do self.instance_variable_get("@#{key}") end
        end
      end

      # Save page variables in the variables.yml file
      def save
        f = File.open( File.expand_path("project/site/#{@group.name}/#{self.name}/variables.yml", MOKA_ROOT), 'w' ) do |out|
          YAML.dump( variables(false), out )
        end
      end
    end

    class NodeArray < Array
    # Like an Array, but with some other helpful methods to filter, order and select elements. The methods are intended to work with elements being instances of classes extending TreeNode (like SiteNode, GroupNode or PageNode).

      # Returns the element having the value of the variable name equal to the argument, or nil if such an element does not exist.
      def find(name)
        self.each do |c|
          if c.respond_to?(:name) and c.name == name.to_s
            return c
          end
        end
        return nil
      end

      # Orders the elements by a variable. The elements that do not have that variable are placed last.
      def order_by(ordering_var)
        return self.sort do |a, b|
          if a.respond_to?(ordering_var.to_sym) and b.respond_to?(ordering_var.to_sym)
            a.send(ordering_var.to_sym) <=> b.send(ordering_var.to_sym)
          else
            if b.respond_to?(ordering_var.to_sym)
              -1
            else
              1
            end
          end
        end
      end

      # Returns another NodeArray containing only the elements satisfying the conditions. conditions can be a Hash containing pairs variable_name => variable_value or a string to be evalued as ruby code.
      #
      # ==== Examples:
      #
      # @site.groups.where({:somevar => somevalue, :another_var => another_value})
      #
      # @site.groups.where("order < 5")
      #
      def where(conditions)
        found = NodeArray.new
        self.each do |c|
          if conditions.is_a? Hash
            satisfied = true
            conditions.each do |var_name, var_value|
              unless c.respond_to?(var_name.to_sym) and c.send(var_name.to_sym) == var_value
                satisfied = false
                break
              end
            end
            if satisfied
              found << c
            end
          else # conditions should be a string (or something that acts like one)
            if c.instance_eval(conditions)
              found << c
            end
          end
        end
        return found
      end

    end
  end
end

class Object
  # Needed for define_method to add INSTANCE methods dynamically
  def metaclass
    class << self; self; end
  end
end
