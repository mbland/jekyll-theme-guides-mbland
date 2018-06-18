require_relative '../lib/jekyll-theme-guides-mbland/generator'
require_relative '../lib/jekyll-theme-guides-mbland/tags'
require_relative './test_site_helper'

require 'jekyll'
require 'minitest/autorun'
require 'nokogiri'
require 'safe_yaml'

module JekyllThemeGuidesMbland
  # rubocop:disable ClassLength
  # rubocop:disable MethodLength
  class GeneratedSiteTest < ::Minitest::Test
    include TestSiteHelper

    DEFAULTS_CONFIG = [
      'defaults:',
      '- scope:',
      '    path: ""',
      '  values:',
      '    layout: "default"',
    ].join("\n")

    def generate_site(nav_data: NAV_YAML, extra_config: '')
      write_config([DEFAULTS_CONFIG, nav_data, extra_config, ''].join("\n"))
      copy_pages(ALL_PAGES)
      config = SafeYAML.load(File.read(config_path))
      config['source'] = testdir
      config['destination'] = site_dir
      config['theme'] = 'jekyll-theme-guides-mbland'
      site = Jekyll::Site.new(Jekyll::Configuration.from(config))
      orig_verbosity = $VERBOSE
      $VERBOSE = nil
      site.process
      $VERBOSE = orig_verbosity
    end

    def generated_files
      Dir.glob(File.join(site_dir, '**', '*'))
         .select { |f| f.match?(%r{/index\.html$}) }
         .map { |f| f.sub(%r{^#{site_dir}/}, '').sub(%r{/index\.html$}, '') }
         .sort
    end

    def parse_page(page_name)
      Nokogiri::HTML(File.read(File.join(site_dir, page_name, 'index.html')))
    end

    def breadcrumbs(page)
      page.xpath('//div[@class = "breadcrumbs"]//li')
    end

    def breadcrumbs_text(page)
      breadcrumbs(page).map(&:text)
    end

    def breadcrumbs_hrefs(page)
      breadcrumbs(page).xpath('.//a').map { |bc| bc['href'] }
    end

    def nav_hrefs(page)
      page.xpath('//nav//a').map { |a| a['href'] }.sort
    end

    DEFAULT_SITE_PATHS = %w[
      add-a-new-page
      add-a-new-page/make-a-child-page
      add-images
      github-setup
      index.html
      post-your-guide
      update-the-config-file
      update-the-config-file/understanding-baseurl
    ].sort.freeze

    DEFAULT_SITE_URLS = %w[
      /
      /add-a-new-page/
      /add-a-new-page/make-a-child-page/
      /add-images/
      /github-setup/
      /post-your-guide/
      /update-the-config-file/
      /update-the-config-file/understanding-baseurl/
    ].sort.freeze

    def test_generated_site
      generate_site
      assert_equal(DEFAULT_SITE_PATHS, generated_files)
      page = parse_page(File.join('add-a-new-page', 'make-a-child-page'))
      assert_equal(['Add a new page', 'Make a child page'],
        breadcrumbs_text(page))
      assert_equal(['/add-a-new-page/'], breadcrumbs_hrefs(page))
      assert_equal(DEFAULT_SITE_URLS, nav_hrefs(page))
    end

    FLAT_SITE_PATHS = %w[
      add-a-new-page
      make-a-child-page
      add-images
      github-setup
      index.html
      post-your-guide
      update-the-config-file
      understanding-baseurl
    ].sort.freeze

    FLAT_SITE_URLS = %w[
      /
      /add-a-new-page/
      /make-a-child-page/
      /add-images/
      /github-setup/
      /post-your-guide/
      /update-the-config-file/
      /understanding-baseurl/
    ].sort.freeze

    def test_generated_site_with_flat_namespace_enabled
      generate_site(extra_config: 'flat_namespace: true')
      assert_equal(FLAT_SITE_PATHS, generated_files)
      page = parse_page('make-a-child-page')
      assert_equal(['Add a new page', 'Make a child page'],
        breadcrumbs_text(page))
      assert_equal(['/add-a-new-page/'], breadcrumbs_hrefs(page))
      assert_equal(FLAT_SITE_URLS, nav_hrefs(page))
    end

    NAV_CONFIG_WITH_EXTERNAL_SIBLING = [
      'navigation:',
      '- text: Parent',
      '  url: parent/',
      '  internal: true',
      '  children:',
      '  - text: External',
      '    url: https://external.example.org/foo',
      '    internal: false',
      '  - text: Child',
      '    url: child/',
      '    internal: true',
    ].freeze

    EXPECTED_CONFIG_WITH_EXTERNAL_SIBLING_NAV_URLS = [
      '/parent/',
      '/parent/child/',
      'https://external.example.org/foo',
    ].freeze

    # Regression test for #13.
    def test_internal_child_does_not_inherit_siblings_external_url
      generate_site(nav_data: NAV_CONFIG_WITH_EXTERNAL_SIBLING)
      page = parse_page('')
      assert_equal(EXPECTED_CONFIG_WITH_EXTERNAL_SIBLING_NAV_URLS,
        nav_hrefs(page))
    end
    # rubocop:enable MethodLength
    # rubocop:enable ClassLength
  end
end
