#!/usr/bin/env ruby

require "rubygems"
require "thor"
require "thor/group"

module Moka
  module OrderGivers
    class GroupOrderGiver < Thor::Group
      require "yaml"
      require File.expand_path('lib/utilities', File.dirname(__FILE__))
      require File.expand_path('lib/site_tree', File.dirname(__FILE__))
      
      include Thor::Actions
      include Moka::SiteTree

      class_option :help, :type => :boolean, :aliases => "-h"

      def provide_help_if_needed
        if options[:help]
          say <<-EOT

    Usage:

     moka order_groups

    Examples:
     moka order_groups
       launch a CLI utility to display and edit the order groups

          EOT
          exit
        end
      end

      def load_manifest
        @manifest = YAML.load_file(File.expand_path("manifest.yml", MOKA_ROOT))
        @site = SiteNode.new("site", @manifest["site"])
      end

      def ask_for_new_order
        counter = 0
        say ""
        say "The current group order is the following:\n"
        @site.groups.each do |group|
          say "#{GroupOrderGiver.counter_to_letters(counter)} - #{group.name}"
          counter += 1
        end
        say ""
        @input = ask "Specify a new ordering as a string of space-separated indices, or press enter to do nothing (example: to switch the second and the third items insert 'a c b'):\n"
      end

      def reorder
        input_array = @input.gsub(/[^a-z\s]/, "").split(/\s+/).map{|i| GroupOrderGiver.letters_to_counter(i)}.uniq.delete_if{|i| i < 0 or i > @site.groups.size - 1}
        if input_array.size <= 0
          exit
        end
        counter = 0
        counter_two = 0
        @site.groups.each do |group|
          unless input_array.index(counter).nil?
            @manifest["site"][group.name]["order"] = input_array.index(counter) + 1
          else
            @manifest["site"][group.name]["order"] = input_array.size + counter_two + 1
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
        say "The new group order is the following:\n"
        counter = 0
        @site = SiteNode.new("", @manifest["site"])
        @site.groups.each do |group|
          say "#{GroupOrderGiver.counter_to_letters(counter)} - #{group.name}"
          counter += 1
        end
        say ""
      end

      def self.counter_to_letters(c)
        letters = %w(a b c d e f g h i j k l m n o p q r s t u v w x y z)
        if c < letters.size
          return letters[c]
        else
          return GroupOrderGiver.counter_to_letters(c/letters.size - 1) + letters[c%letters.size]
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
          return letters.index(l[-1]) + letters.size*(GroupOrderGiver.letters_to_counter(l[0..-2]))
        end
      end
    end
  end
end

Moka::OrderGivers::GroupOrderGiver.start