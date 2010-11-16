require "rubygems"
require "thor"
require "thor/group"

module Moka
  module Generators
    class MokaGroupGenerator < Thor::Group
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

      def load_manifest
        @manifest = YAML.load_file(File.expand_path("manifest.yml", MOKA_ROOT))
        @site = SiteNode.new("site", @manifest["site"])
      end

      def verify_if_group_exists
        @group = name
        unless @site.find_group(@group).nil?
          say_status "ERROR:", "group '#{@group}' already exists!", :red
          exit
        end
      end

      def update_manifest
        unless options[:template].nil?
          @template_group = options[:template]
          if @site.find_group(@template_group).nil?
            say_status "ERROR:", "cannot find group '#{@template_group}'", :red
            exit
          end
          template_manifest = Moka::Utilities.deepcopy(@manifest["site"][@template_group])
          @site.find_group(@template_group).pages.each do |page|
            template_manifest[page.name]["path"] = File.join "#{@group}", "#{page.name}.#{@site.respond_to?(:default_extension) ? @site.default_extension : "html"}"
          end
        else
          template_manifest = {}
        end
        @group_params = {"order" => Time.new.utc.to_i}
        @manifest["site"][@group] = template_manifest.merge @group_params
        # dump manifest
        f = File.open( File.expand_path('manifest.yml', MOKA_ROOT), 'w' ) do |out|
          YAML.dump( @manifest, out )
        end
        say_status "update", "manifest.yml", :green
      end

      def create_group_dir_and_files
        unless options[:template].nil?
          directory(File.expand_path("project/site/#{@template_group}", MOKA_ROOT), File.expand_path("project/site/#{@group}", MOKA_ROOT))
        else
          directory("groupdir", File.expand_path("project/site/#{@group}", MOKA_ROOT))
        end
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
        if File.exists? File.expand_path("project/site/#{@group}/variables.yml", MOKA_ROOT)
          @group_variables = YAML.load_file(File.expand_path("project/site/#{@group}/variables.yml", MOKA_ROOT))
        else
          @group_variables = {}
        end
        unless options[:vars].nil?
          @group_variables.merge! options[:vars]
          f = File.open( File.expand_path("project/site/#{@group}/variables.yml", MOKA_ROOT), 'w' ) do |out|
            YAML.dump( @group_variables, out )
          end
          say_status "update", "project/site/#{@group}/variables.yml", :green
        end
      end

      def notify_about_creation
        say ""
        if options[:template].nil?
          say "Generated group #{@group}"
        else
          say "Generated group #{@group} using group #{@template_group} as a template"
        end
        say ""
        say " Group Parameters:"
        @group_params.each do |param_name, param_value|
          say "  #{param_name} = #{param_value}"
        end

        say ""
        say " Group Variables:"
        @group_variables.each do |var_name, var_value|
          puts "  #{var_name} = #{var_value}"
        end
        say ""
      end
    end
  end
end