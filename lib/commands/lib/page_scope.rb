module Moka
  class PageScope
    require File.expand_path('string_inflectors', File.dirname(__FILE__))
    require File.expand_path('helpers', File.dirname(__FILE__))
    require File.expand_path('partials_inclusion', File.dirname(__FILE__))
    require File.expand_path('lipsum_helpers', File.dirname(__FILE__))
    require File.expand_path('site_tree', File.dirname(__FILE__))

    include Moka::SiteTree
    include Moka::Helpers
    include Moka::LipsumHelpers
    include Moka::PartialsInclusion

    $:.unshift(File.expand_path('project/lib', MOKA_ROOT))
    require 'helpers'

    def initialize(manifest, current_group_name, current_page_name)
      @site = SiteNode.new("site", manifest["site"])
      @current_group = @site.find_group(current_group_name)
      @current_page = @current_group.find_page(current_page_name)
    end

    # returns a binding to the object
    def get_binding
      binding
    end

  end
end