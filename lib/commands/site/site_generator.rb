require "rubygems"
require "thor"
require "thor/group"

module Moka
  module Generators
    class MokaSiteGenerator < Thor::Group
      require "yaml"
      require File.expand_path('../lib/utilities', File.dirname(__FILE__))
      require File.expand_path('../lib/site_tree', File.dirname(__FILE__))

      include Thor::Actions
      include Moka::SiteTree

      argument :site_name
      class_option :template, :type => :string, :aliases => "-t"
      class_option :vars, :aliases => %w(-v), :type => :hash

      def self.source_root
        File.expand_path('template/', File.dirname(__FILE__))
      end

      def create_app_dir
        empty_directory(site_name)
      end

      def create_script_dir
        directory('script', "#{site_name}/script")
      end

      def set_permissions
        chmod("#{site_name}/script/moka", 0755)
      end

      def create_project_dir
        unless options[:template].nil?
          source_paths << "."
          directory(File.join(options[:template], 'project'), "#{site_name}/project")
        else
          directory('project', "#{site_name}/project")
        end
      end

      def create_compiled_dir
        unless options[:template].nil?
          directory(File.join(options[:template], 'compiled'), "#{site_name}/compiled")
        else
          empty_directory("#{site_name}/compiled")
          empty_directory("#{site_name}/compiled/javascripts")
          empty_directory("#{site_name}/compiled/images")
          empty_directory("#{site_name}/compiled/stylesheets")
        end
      end

      def create_manifest_file
        unless options[:template].nil?
          template(File.join(options[:template], 'manifest.yml'), File.join("#{site_name}", "manifest.yml"))
        else
          template('manifest.yml', File.join("#{site_name}", "manifest.yml"))
        end
      end

      def update_variables
        unless options[:vars].nil?
          options[:vars].each do |var_name, var_value|
            if Moka::SiteTree::RESERVED_NAMES.include? var_name.to_s
              say_status "WARNING:", "variable '#{var_name}' is a reserved word, and will not be set as a variable", :yellow
            end
          end
          options[:vars].delete_if {|var_name, var_value| Moka::SiteTree::RESERVED_NAMES.include? var_name.to_s }
          @variables = YAML.load_file(File.join(site_name, "project", "site", "variables.yml"))
          @variables.merge! options[:vars]
          f = File.open( File.join(site_name, "project", "site", "variables.yml"), 'w' ) do |out|
            YAML.dump( @variables, out )
          end
          say_status "update", File.join(site_name, "project", "site", "variables.yml"), :green
        end
      end

      def update_manifest_file
        unless options[:template].nil?
          @manifest = YAML.load_file(File.join(site_name, "manifest.yml"))
          @manifest['site']['name'] = site_name
          f = File.open( File.join(site_name, "manifest.yml"), 'w' ) do |out|
            YAML.dump( @manifest, out )
          end
          say_status "update", File.join(site_name, "manifest.yml"), :green
        end
      end

    end
  end
end