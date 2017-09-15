require 'jekyll/tags/include'
require 'liquid'

module GuidesStyleMbland
  class ShouldExpandNavTag < ::Liquid::Tag
    NAME = 'guides_style_mbland_should_expand_nav'.freeze
    ::Liquid::Template.register_tag(NAME, self)

    attr_reader :parent_reference, :url_reference

    def initialize(_tag_name, markup, _)
      references = markup.split(',').map(&:strip)
      @parent_reference = references.shift
      @url_reference = references.shift
    end

    def render(context)
      scope = context.scopes.detect { |s| s.member?(url_reference) }
      parent_url = scope[url_reference]
      page_url = context['page']['url']
      page_url == parent_url || page_url.start_with?(parent_url) ||
        expand_nav_default(scope, context)
    end

    private

    def expand_nav_default(scope, context)
      default = scope[parent_reference]['expand_nav']
      default = context['site']['expand_nav'] if default.nil?
      default.nil? ? false : default
    end
  end

  class PopLastUrlComponent < ::Liquid::Tag
    NAME = 'guides_style_mbland_pop_last_url_component'.freeze
    ::Liquid::Template.register_tag(NAME, self)

    attr_reader :reference

    def initialize(_tag_name, markup, _)
      @reference = markup.strip
    end

    def render(context)
      scope = context.scopes.detect { |s| s.member?(reference) }
      parent_url = scope[reference]
      result = File.dirname(parent_url)
      result == '/' ? result : "#{result}/"
    end
  end
end
