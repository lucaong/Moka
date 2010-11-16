require "rubygems"
require "thor"
require "thor/group"

module Moka
  module Generators
    class MokaPageGenerator < Thor::Group

      require "yaml"
      require File.expand_path('../lib/utilities', File.dirname(__FILE__))
      require File.expand_path('../lib/site_tree', File.dirname(__FILE__))

      include Thor::Actions
      include Moka::SiteTree

      argument :name
      class_option :template, :type => :string, :aliases => "-t"
      class_option :vars, :aliases => %w(-v), :type => :hash

      def self.source_root
        File.expand_path('template/', File.dirname(__FILE__))
      end

      def parse_page_group_and_name
        if name.nil?
          say_status "ERROR:", "you need to specify a page name.", :red
          exit
        end
        @page_name, @group = Moka::Utilities.parse_grouppage name
      end

      def load_manifest
        @manifest = YAML.load_file(File.expand_path("manifest.yml", MOKA_ROOT))
        @site = SiteNode.new("site", @manifest["site"])
      end

      def verify_if_page_exists
        unless @site.find_group(@group).nil? or @site.find_group(@group).find_page(@page_name).nil?
          say_status "ERROR:", "page '#{@page_name}' already exists in group '#{@group}'!", :red
          exit
        end
      end

      def create_page_dir_and_files
        unless options[:template].nil?
          @template_name, @template_group = Moka::Utilities.parse_grouppage options[:template]
          if @site.find_group(@template_group).nil?
            say_status "ERROR:", "cannot find group '#{@template_group}'", :red
            exit
          elsif @site.find_group(@template_group).find_page(@template_name).nil?
            say_status "ERROR:", "cannot find page '#{@template_name}' in group '#{@template_group}'", :red
            exit
          end
          directory(File.expand_path("project/site/#{@template_group}/#{@template_name}", MOKA_ROOT), File.expand_path("project/site/#{@group}/#{@page_name}", MOKA_ROOT))
        else
          directory("pagedir", File.expand_path("project/site/#{@group}/#{@page_name}", MOKA_ROOT))
        end
      end

      def update_manifest
        @page_params = {"order" => Time.new.utc.to_i}
        unless options[:template].nil? or @manifest["site"][@template_group][@template_name]["layout"].nil?
          @page_params["layout"] = @manifest["site"][@template_group][@template_name]["layout"]
        end
        unless @group == "root"
          @page_params["path"] = File.join [@group, @page_name + "." + (@site.respond_to?(:default_extension) ? @site.default_extension : "html")]
        else
          @page_params["path"] = @page_name + "." + (@site.respond_to?(:default_extension) ? @site.default_extension : "html")
        end
        unless @site.find_group(@group).nil?
          @manifest["site"][@group][@page_name] = @page_params
        else
          @manifest["site"][@group] = {"order" => Time.new.utc.to_i, @page_name => @page_params}
        end
        # dump manifest
        f = File.open( File.expand_path('manifest.yml', MOKA_ROOT), 'w' ) do |out|
          YAML.dump( @manifest, out )
        end
        say_status "update", "manifest.yml", :green
      end

      def delete_variables_using_reserved_name
        unless options[:vars].nil?
          options[:vars].each do |var_name, var_value|
            if Moka::SiteTree::RESERVED_NAMES.include? var_name.to_s
              say_status "WARNING:", "variable '#{var_name}' is a reserved word, and will not be set as a variable", :yellow
            end
          end
          options[:vars].delete_if {|var_name, var_value| Moka::SiteTree::RESERVED_NAMES.include? var_name.to_s }
        end
      end

      def dump_variables
        if File.exists? File.expand_path("project/site/#{@group}/#{@page_name}/variables.yml", MOKA_ROOT)
          @page_variables = YAML.load_file(File.expand_path("project/site/#{@group}/#{@page_name}/variables.yml", MOKA_ROOT))
        else
          @page_variables = {}
        end
        unless options[:vars].nil?
          @page_variables.merge! options[:vars]
          f = File.open( File.expand_path("project/site/#{@group}/#{@page_name}/variables.yml", MOKA_ROOT), 'w' ) do |out|
            YAML.dump( @page_variables, out )
          end
          say_status "update", "project/site/#{@group}/#{@page_name}/variables.yml", :green
        end
      end

      def notify_about_creation
        say ""
        if options[:template].nil?
          say "Generated page #{@group}:#{@page_name}"
        else
          say "Generated page #{@group}:#{@page_name} using page #{@template_group}:#{@template_name} as a template"
        end
        say ""
        say " Page Parameters:"
        @page_params.each do |param_name, param_value|
          say "  #{param_name} = #{param_value}"
        end

        say ""
        say " Page Variables:"
        @page_variables.each do |var_name, var_value|
          puts "  #{var_name} = #{var_value}"
        end
        say ""
      end
    end
  end
end