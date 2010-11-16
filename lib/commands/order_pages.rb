#!/usr/bin/env ruby

require "rubygems"
require "thor"
require "thor/group"

module Moka
  module OrderGivers
    class PageOrderGiver < Thor::Group
      require "yaml"
      require File.expand_path('lib/utilities', File.dirname(__FILE__))
      require File.expand_path('lib/site_tree', File.dirname(__FILE__))

      include Thor::Actions
      include Moka::SiteTree

      argument :group_name, :required => false, :default => 'root'
      class_option :help, :type => :boolean, :aliases => "-h"

      def provide_help_if_needed
        if options[:help]
          say <<-EOT

    Usage:

     moka order_pages [group]

    Examples:
     moka order_pages
       launch a CLI utility to display and edit the order of pages in group 'root'

     moka order_pages mygroup
       launch a CLI utility to display and edit the order of pages in group 'mygroup'

          EOT
          exit
        end
      end

      def load_manifest
        @manifest = YAML.load_file(File.expand_path("manifest.yml", MOKA_ROOT))
        @site = SiteNode.new("site", @manifest["site"])
      end

      def verify_group_existence
        @group = @site.find_group(group_name)
        if @group.nil?
          say_status "ERROR:", "cannot find group '#{group_name}'", :red
          exit
        end
      end

      def ask_for_new_order
        counter = 0
        say ""
        say "The current page order in group '#{group_name}' is the following:\n"
        @group.pages.order_by(:order).each do |page|
          say "#{PageOrderGiver.counter_to_letters(counter)} - #{page.name}"
          counter += 1
        end
        say ""
        @input = ask "Specify a new ordering as a string of space-separated indices, or press enter to do nothing (example: to switch the second and the third items insert 'a c b'):\n"
      end

      def reorder
        input_array = @input.gsub(/[^a-z\s]/, "").split(/\s+/).map{|i| PageOrderGiver.letters_to_counter(i)}.uniq.delete_if{|i| i < 0 or i > @group.pages.size - 1}
        if input_array.size <= 0
          exit
        end
        counter = 0
        counter_two = 0
        @group.pages.order_by(:order).each do |page|
          unless input_array.index(counter).nil?
            @manifest["site"][@group.name][page.name]["order"] = input_array.index(counter) + 1
          else
            @manifest["site"][@group.name][page.name]["order"] = input_array.size + counter_two + 1
            counter_two += 1
          end
          counter += 1
        end
      end

      def dump_manifest
        f = File.open( File.expand_path('manifest.yml', MOKA_ROOT), 'w' ) do |out|
          YAML.dump( @manifest, out )
        end
        say_status "update", "manifest.yml", :green
      end

      def notify_new_order
        say ""
        say "The new page order in group '#{group_name}' is the following:\n"
        counter = 0
        @site = SiteNode.new("", @manifest["site"])
        @group = @site.find_group(group_name)
        @group.pages.each do |page|
          say "#{PageOrderGiver.counter_to_letters(counter)} - #{page.name}"
          counter += 1
        end
        say ""
      end

      def self.counter_to_letters(c)
        letters = %w(a b c d e f g h i j k l m n o p q r s t u v w x y z)
        if c < letters.size
          return letters[c]
        else
          return PageOrderGiver.counter_to_letters(c/letters.size - 1) + letters[c%letters.size]
        end
      end

      def self.letters_to_counter(l)
        letters = %w(a b c d e f g h i j k l m n o p q r s t u v w x y z)
        l.gsub(/[^a-z]/, "")
        if l.size == 0
          return -1
        end
        unless letters.index(l).nil?
          return letters.index(l)
        else
          return letters.index(l[-1]) + letters.size*(PageOrderGiver.letters_to_counter(l[0..-2]))
        end
      end
    end
  end
end

Moka::OrderGivers::PageOrderGiver.start