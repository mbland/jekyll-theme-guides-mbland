require_relative '../lib/jekyll-theme-guides-mbland/navigation'
require_relative './test_site_helper'

require 'fileutils'
require 'minitest/autorun'
require 'safe_yaml'
require 'stringio'

module JekyllThemeGuidesMbland
  # rubocop:disable ClassLength
  class NavigationTest < ::Minitest::Test
    include TestSiteHelper

    def test_empty_config_no_pages
      write_config('', with_collections: false)
      JekyllThemeGuidesMbland.update_navigation_configuration(testdir)
      assert_equal('', read_config)
    end

    def test_empty_config_no_nav_data_no_pages
      write_config('', with_collections: false)
      JekyllThemeGuidesMbland.update_navigation_configuration(testdir)
      assert_equal('', read_config)
    end

    def test_config_with_nav_data_but_no_pages
      write_config(NAV_YAML)
      JekyllThemeGuidesMbland.update_navigation_configuration(testdir)
      assert_equal(nav_config, read_config)
    end

    def test_all_pages_with_existing_data
      write_config(NAV_YAML)
      copy_pages(ALL_PAGES)
      JekyllThemeGuidesMbland.update_navigation_configuration(testdir)
      assert_equal("#{COLLECTIONS_CONFIG}\n#{NAV_YAML}", read_config)
    end

    def test_add_all_pages_from_scratch
      write_config(nav_config)
      copy_pages(ALL_PAGES)
      JekyllThemeGuidesMbland.update_navigation_configuration(testdir)
      assert_result_matches_expected_config(sorted_nav_data(NAV_DATA))
    end

    def add_a_grandchild_page(nav_data, parent_text, child_text,
      grandchild_text, grandchild_url)
      parent = nav_data.detect { |nav| nav['text'] == parent_text }
      child = parent['children'].detect { |nav| nav['text'] == child_text }
      (child['children'] ||= []) << {
        'text' => grandchild_text, 'url' => grandchild_url, 'internal' => true
      }
    end

    def test_remove_stale_config_entries
      nav_data = SafeYAML.load(NAV_YAML, safe: true)
      add_a_grandchild_page(nav_data['navigation'], 'Add a new page',
        'Make a child page', 'Make a grandchild page', 'grandchild-page/')

      # We have to slice off the leading `---\n` of the YAML, and the trailing
      # newline.
      write_config([
        LEADING_COMMENT, nav_data.to_yaml[4..-2], TRAILING_COMMENT
      ].join("\n"))
      copy_pages(ALL_PAGES)
      JekyllThemeGuidesMbland.update_navigation_configuration(testdir)
      assert_equal("#{COLLECTIONS_CONFIG}\n#{NAV_YAML}", read_config)
    end

    def write_config_without_collection
      # Use the `pages/` dir instead of `_pages`. Set the default permalink
      # for all the pages so we don't need to manually update every page.
      @pages_dir = File.join(testdir, 'pages')
      FileUtils.mkdir_p(pages_dir)
      config = [
        'permalink: /:path/',
        LEADING_COMMENT,
        'navigation:',
        TRAILING_COMMENT,
      ].join("\n")
      write_config(config, with_collections: false)
    end

    def move_home_page_and_create_external_page
      # Pull the home page to the root to make sure it's included, and make a
      # new page outside of the `pages/` directory to make sure it isn't
      # included.
      copy_pages(ALL_PAGES)
      FileUtils.mv(File.join(pages_dir, 'index.md'), testdir)
      File.write(File.join(testdir, 'excluded.md'), [
        '---',
        'title: This page shouldn\'t appear in the navigation menu',
        '---',
      ].join("\n"))
    end

    def add_permalinks(pages)
      pages.each do |page|
        next if page == 'index.md'
        path = File.join(pages_dir, page)
        front_matter = SafeYAML.load_file(path, safe: true)
        front_matter['permalink'] = "/#{page.sub(/\.md$/, '')}/"
        File.write(path, "#{front_matter.to_yaml}\n---")
      end
    end

    def test_add_all_pages_from_scratch_without_collection
      write_config_without_collection
      move_home_page_and_create_external_page
      add_permalinks(ALL_PAGES)
      JekyllThemeGuidesMbland.update_navigation_configuration(testdir)
      assert_result_matches_expected_config(sorted_nav_data(NAV_DATA))
    end

    CONFIG_WITH_EXTERNAL_PAGE = [
      '- text: Link to the mbland/guides-style-mbland repo',
      '  url: https://github.com/mbland/guides-style-mbland',
    ].freeze

    def test_do_not_remove_external_page_entries
      write_config(nav_config(CONFIG_WITH_EXTERNAL_PAGE))
      copy_pages(ALL_PAGES)
      JekyllThemeGuidesMbland.update_navigation_configuration(testdir)
      expected_data = sorted_nav_data(NAV_DATA)
      expected_data['navigation'].unshift(
        'text' => 'Link to the mbland/guides-style-mbland repo',
        'url' => 'https://github.com/mbland/guides-style-mbland'
      )
      assert_result_matches_expected_config(expected_data)
    end

    CONFIG_WITH_MISSING_PAGES = [
      '- text: Introduction',
      '  internal: true',
      '- text: Add a new page',
      '  url: add-a-new-page/',
      '  internal: true',
      '  children:',
      '  - text: Make a child page',
      '    url: make-a-child-page/',
      '    internal: true',
    ].freeze

    def test_add_missing_pages
      write_config(nav_config(CONFIG_WITH_MISSING_PAGES))
      copy_pages(ALL_PAGES)
      JekyllThemeGuidesMbland.update_navigation_configuration(testdir)
      assert_result_matches_expected_config(NAV_DATA)
    end

    CONFIG_MISSING_CHILD_PAGES = [
      '- text: Introduction',
      '  internal: true',
      '- text: Add a new page',
      '  url: add-a-new-page/',
      '  internal: true',
      '- text: Add images',
      '  url: add-images/',
      '  internal: true',
      '- text: Update the config file',
      '  url: update-the-config-file/',
      '  internal: true',
      '- text: GitHub setup',
      '  url: github-setup/',
      '  internal: true',
      '- text: Post your guide',
      '  url: post-your-guide/',
      '  internal: true',
    ].freeze

    def test_add_missing_child_pages
      write_config(nav_config(CONFIG_MISSING_CHILD_PAGES))
      copy_pages(ALL_PAGES)
      JekyllThemeGuidesMbland.update_navigation_configuration(testdir)
      assert_result_matches_expected_config(NAV_DATA)
    end

    CONFIG_MISSING_PARENT_PAGE = [
      '- text: Introduction',
      '  internal: true',
      '- text: Add images',
      '  url: add-images/',
      '  internal: true',
      '- text: Make a child page',
      '  url: make-a-child-page/',
      '  internal: true',
      '- text: Update the config file',
      '  url: update-the-config-file/',
      '  internal: true',
      '- text: GitHub setup',
      '  url: github-setup/',
      '  internal: true',
      '- text: Post your guide',
      '  url: post-your-guide/',
      '  internal: true',
    ].freeze

    # An entry for the child already exists, and we want to move it under a
    # parent page, under the presumption that the parent relationship was just
    # added.
    def test_add_missing_parent_page
      write_config(nav_config(CONFIG_MISSING_PARENT_PAGE))
      copy_pages(ALL_PAGES)
      JekyllThemeGuidesMbland.update_navigation_configuration(testdir)
      assert_result_matches_expected_config(NAV_DATA)
    end

    def test_should_raise_if_parent_page_does_not_exist
      write_config(nav_config(CONFIG_MISSING_PARENT_PAGE))
      copy_pages(ALL_PAGES.reject { |page| page == 'add-a-new-page.md' })
      exception = assert_raises(StandardError) do
        JekyllThemeGuidesMbland.update_navigation_configuration(testdir)
      end
      expected = "Parent pages missing for the following:\n  " \
        '/add-a-new-page/make-a-child-page/'
      assert_equal expected, exception.message
    end

    CONFIG_CONTAINING_ONLY_INTRODUCTION = [
      '- text: Introduction',
      '  internal: true',
    ].freeze

    def test_all_pages_starting_with_empty_data
      write_config(nav_config(CONFIG_CONTAINING_ONLY_INTRODUCTION))
      copy_pages(ALL_PAGES)
      JekyllThemeGuidesMbland.update_navigation_configuration(testdir)
      assert_result_matches_expected_config(NAV_DATA)
    end

    NO_LEADING_SLASH = <<NO_LEADING_SLASH.freeze
---
title: No leading slash
permalink: no-leading-slash/
---
NO_LEADING_SLASH

    NO_TRAILING_SLASH = <<NO_TRAILING_SLASH.freeze
---
title: No trailing slash
permalink: /no-trailing-slash
---
NO_TRAILING_SLASH

    FILES_WITH_ERRORS = {
      'missing-front-matter.md' => 'no front matter brosef',
      'no-leading-slash.md' => NO_LEADING_SLASH,
      'no-trailing-slash.md' => NO_TRAILING_SLASH,
    }.freeze

    EXPECTED_ERRORS = <<EXPECTED_ERRORS.freeze
The following files have errors in their front matter:
  _pages/missing-front-matter.md:
    no front matter defined
  _pages/no-leading-slash.md:
    `permalink:` does not begin with '/'
  _pages/no-trailing-slash.md:
    `permalink:` does not end with '/'
EXPECTED_ERRORS

    def test_detect_front_matter_errors
      write_config(NAV_YAML)
      FILES_WITH_ERRORS.each { |file, content| write_page(file, content) }
      errors = \
        JekyllThemeGuidesMbland::FrontMatter.validate_with_message_upon_error(
          JekyllThemeGuidesMbland::FrontMatter.load(testdir)
        )
      assert_equal EXPECTED_ERRORS, errors + "\n"
    end

    def test_ignore_static_files
      write_config(NAV_YAML)
      write_page('image.png', '')
      errors = \
        JekyllThemeGuidesMbland::FrontMatter.validate_with_message_upon_error(
          JekyllThemeGuidesMbland::FrontMatter.load(testdir)
        )
      assert_nil(errors)
    end

    WITH_NAVTITLE = <<WITH_NAVTITLE.freeze
---
title: Some egregiously, pretentiously, criminally long title
navtitle: Hello!
---
WITH_NAVTITLE

    def test_use_navtitle_if_present
      write_config(NAV_YAML)
      write_page('navtitle.md', WITH_NAVTITLE)
      JekyllThemeGuidesMbland.update_navigation_configuration(testdir)
      expected = [{
        'text' => 'Hello!', 'url' => 'navtitle/', 'internal' => true
      }]
      result = SafeYAML.load(read_config, safe: true)
      assert_equal(expected, result['navigation'])
    end

    def test_show_error_message_and_exit_if_pages_front_matter_is_malformed
      capture_stderr do
        write_config("#{COLLECTIONS_CONFIG}\nnavigation:")
        FILES_WITH_ERRORS.each { |file, content| write_page(file, content) }
        exception = assert_raises(SystemExit) do
          JekyllThemeGuidesMbland.update_navigation_configuration(testdir)
        end
        assert_equal(1, exception.status)
        assert($stderr.string.include?(EXPECTED_ERRORS +
          "_config.yml not updated\n"))
      end
    end
  end
  # rubocop:enable ClassLength
end
