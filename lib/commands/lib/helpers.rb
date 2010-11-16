module Moka
  module Helpers

    require File.expand_path('utilities', File.dirname(__FILE__))

    # Returns true if the page passed as an argument is the page currently being compiled (a.k.a. the @current_page), else returns false. The argument can be a PageNode object, or a string in the form 'groupname:pagename' (if group isn't specified, 'root' is assumed).
    #
    # ==== Examples:
    #
    # <ul>
    #   <% @current_group.pages.each do |page| %>
    #     <li>
    #       <% if current_page? page %>
    #         <%= page.name.titleize %>
    #       <% else %>
    #         <%= link_to page.name.titleize, page %>
    #       <% end %>
    #     </li>
    #   <% end %>
    # </ul>
    #
    def current_page?(page)
      unless page.respond_to? :path
        page_name, group_name = Moka::Utilities.parse_grouppage(page)
        return @current_page.path == @site.find_group(group_name).find_page(page_name).path
      else
        return @current_page.path == page.path
      end
    end

    # Returns an <img> tag for the file path passed as a parameter. If the file path is relative and does not start with "/", then the path is assumed to be relative to the compiled/images directory, else it is assumed to be relative to the root (compiled) directory or absolute.
    def image_tag(*args)
      html_options = args.extract_options!
      tag_options = ""
      html_options.each do |opt, val|
        tag_options << " #{opt.to_s}=\"#{val}\""
      end
      tag_string = ""
      img = args.first
      if img.index(/\A(http:\/\/|https:\/\/)/i).nil?
        img = adapt_path((img[0] == ?/) ? img : "images/" + img)
      end
      tag_string << "<img src=\"#{img}\"#{tag_options} />\n"
      return tag_string
    end

    # Returns one or more <script> tags to include each Javascript file path (absolute or relative) passed as a parameter. If a file has no extension, ".js" is assumed. If a relative file path does not start with "/", then the path is assumed to be relative to the compiled/javascripts directory, else it is assumed to be relative to the root (compiled) directory. If the first parameter is :all, then a script tag for every file in the compiled/javascripts directory is returned.
    def javascript_include_tag(*sources)
      html_options = sources.extract_options!
      tag_options = ""
      html_options.each do |opt, val|
        tag_options << " #{opt.to_s}=\"#{val}\""
      end
      tag_string = ""
      if sources.first.to_s == "all"
        sources = Dir.glob(File.expand_path("compiled/javascripts/*.js", MOKA_ROOT)).collect{|f| File.basename(f)}
      end
      sources.each do |s|
        if s.index(/\A(http:\/\/|https:\/\/)/i).nil?
          s = (File.extname(s) == "") ? s + ".js" : s
          s = adapt_path((s[0] == ?/) ? s : "javascripts/" + s)
        end
        tag_string << "<script type=\"text/javascript\" src=\"#{s}\"#{tag_options}></script>\n"
      end
      return tag_string
    end

    # Returns an html link tag (<a ...>...</a>) for the PageNode or path passed as the second argument. Syntax is link_to(anchor_text, [page or path], [html_options]). If a relative path is passed, it must be relative to the root directory (the function takes care of making it relative to the @current_page).
    def link_to(*args)
      name         = args[0]
      page         = args[1] || name
      html_options = args[2]

      url = path_to(page)

      if html_options
        tag_options = ""
        html_options.each do |opt, val|
          tag_options << " #{opt.to_s}=\"#{val}\""
        end
        href = html_options['href']
      else
        tag_options = nil
      end

      href_attr = "href=\"#{url}\"" unless href
      "<a #{href_attr}#{tag_options}>#{name.respond_to?(:name) ? name.name : name}</a>"
    end

    # If the argument is a PageNode object, returns the path to that page relative to the @current_page. If the argument is a relative path, it is assumed to be relative to the root, changed and made relative to the @current_page and returned. If the argument is an absolute path, it is returned unchanged.
    def path_to(page)
      pre = back_to_root(@current_page.path)
      if page.is_a? Moka::SiteTree::PageNode
        # page is a PageNode object
        return adapt_path(page.path)
      else
        # page is a path
        return adapt_path(page.to_s)
      end
    end

    # Returns one or more <link> tags to include each stylesheet file path passed as a parameter. If a file path has no extension, ".css" is assumed. The path can be absolute or relative. If a relative file path does not start with "/", then the path is assumed to be relative to the compiled/stylesheets directory, else it is assumed to be relative to the root (compiled) directory. If the first parameter is :all, then a link tag for every file in the compiled/stylesheets directory (or that will be compiled in compiled/stylesheets) is returned.
    def stylesheet_link_tag(*sources)
      html_options = sources.extract_options!
      tag_options = ""
      html_options.each do |opt, val|
        tag_options << " #{opt.to_s}=\"#{val}\""
      end
      tag_string = ""
      if sources.first.to_s == "all"
        sources = Dir.glob(File.expand_path("compiled/stylesheets/*.css", MOKA_ROOT)).collect{|f| File.basename(f)}
        sources += Dir.glob(File.expand_path("project/styles/*.sass", MOKA_ROOT)).collect{|f| File.basename(f, ".sass") + ".css"}
        sources.uniq!
      end
      sources.each do |s|
        if s.index(/\A(http:\/\/|https:\/\/)/i).nil?
          s = (File.extname(s) == "") ? s + ".css" : s
          s = adapt_path((s[0] == ?/) ? s : "stylesheets/" + s)
        end
        tag_string << "<link rel=\"stylesheet\" href=\"#{s}\" type=\"text/css\"#{tag_options} />\n"
      end
      return tag_string
    end

    private

    # Takes a path relative to the root and makes it relative to the @current_page. If the path is absolute, returns the path unchanged.
    def adapt_path(path) 
      if path.index(/^[\w]{0,6}:\/\//).nil?
        # page is a relative path
        path.sub!("/", "") if path[0] == ?/
        return back_to_root(@current_page.path) << path
      else
        # page is an absolute path
        return path
      end
    end

    def back_to_root(path_from_root)
      d = File.dirname(path_from_root)
      pre = ""
      while d != "." do
        pre << "../"
        d = File.dirname(d)
      end
      return pre
    end

  end
end

class Array
  def extract_options!
    last.is_a?(::Hash) ? pop : {}
  end
end
