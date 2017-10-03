require_relative './breadcrumbs'
require_relative './generated_pages'
require_relative './namespace_flattener'

require 'jekyll'

module JekyllThemeGuidesMbland
  class Generator < ::Jekyll::Generator
    def generate(site)
      GeneratedPages.generate_pages_from_navigation_data(site)
      pages = site.collections['pages']
      docs = (pages.nil? ? [] : pages.docs) + site.pages
      docs.each { |doc| Generator.generate_working_url(doc) }
      Breadcrumbs.generate(site, docs)
      NamespaceFlattener.flatten_url_namespace(site, docs)
    end

    # Calling the `url` method on a Jekyll::Page or Jekyll::Document will render
    # the returned value immutable from that point. Here we generate a separate
    # URL object that we use to calculate `data['permalink']` prior to the first
    # call to `url`. This enables `NamespaceFlattener.flatten_url_namespace` to
    # update the URL as a final step, after `Breadcrumbs.generate` has finished
    # its processing.
    def self.generate_working_url(doc)
      t = doc.respond_to?(:url_template) ? doc.url_template : doc.template
      doc.data[:working_url] = Jekyll::URL.new(
        template:     t,
        placeholders: doc.url_placeholders,
        permalink:    doc.permalink
      ).to_s
    end
  end
end
