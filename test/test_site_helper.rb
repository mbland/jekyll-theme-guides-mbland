require 'fileutils'
require 'safe_yaml'
require 'stringio'

module JekyllThemeGuidesMbland
  module TestSiteHelper
    attr_reader :testdir, :config_path, :pages_dir, :site_dir

    TEST_DIR = File.dirname(__FILE__)
    TEST_PAGES_DIR = File.join(TEST_DIR, '_pages')

    NAV_DATA_PATH = File.join(TEST_DIR, 'navigation_test_data.yml')
    NAV_YAML = File.read(NAV_DATA_PATH)
    NAV_DATA = SafeYAML.load(NAV_YAML, safe: true)

    COLLECTIONS_CONFIG = [
      'collections:',
      '  pages:',
      '    output: true',
      '    permalink: /:path/',
      '',
    ].join("\n").freeze

    ALL_PAGES = %w[
      add-a-new-page/make-a-child-page.md
      add-a-new-page.md
      add-images.md
      github-setup.md
      index.md
      post-your-guide.md
      update-the-config-file/understanding-baseurl.md
      update-the-config-file.md
    ].freeze

    LEADING_COMMENT  = '# Comments before the navigation section ' +
      'should be preserved.'.freeze
    TRAILING_COMMENT = '# Comments after the navigation section ' +
      "should also be preserved.\n".freeze

    def setup
      @assertions = 0
      @testdir = Dir.glob(Dir.mktmpdir).first
      @config_path = File.join(testdir, '_config.yml')
      @pages_dir = File.join(testdir, '_pages')
      FileUtils.mkdir_p(pages_dir)
      @site_dir = File.join(testdir, '_site')
    end

    def teardown
      FileUtils.rm_rf(testdir, secure: true)
    end

    def write_config(config_data, with_collections: true)
      prefix = with_collections ? "#{COLLECTIONS_CONFIG}\n" : ''
      File.write(config_path, "#{prefix}#{config_data}")
    end

    def read_config
      File.read(config_path)
    end

    def write_page(filename, content)
      File.write(File.join(pages_dir, filename), content)
    end

    def copy_pages(pages)
      pages.each do |page|
        parent_dir = File.dirname(page)
        full_orig_path = File.join(TEST_PAGES_DIR, page)
        target_dir = File.join(pages_dir, parent_dir)
        FileUtils.mkdir_p(target_dir)
        FileUtils.cp(full_orig_path, target_dir)
      end
    end

    def nav_array_to_hash(nav)
      (nav['navigation'] || []).map { |i| [i['text'], i] }.to_h
    end

    def assert_result_matches_expected_config(nav_data)
      # We can't do a straight string comparison, since the items may not be
      # in order relative to the original.
      result = read_config
      result_data = SafeYAML.load(result, safe: true)
      refute_equal(-1, result.index(LEADING_COMMENT),
        'Comment before `navigation:` section is missing')
      refute_equal(-1, result.index(TRAILING_COMMENT),
        'Comment after `navigation:` section is missing')
      assert_equal(nav_array_to_hash(nav_data), nav_array_to_hash(result_data))
    end

    # We need to be careful not to modify the original NAV_DATA object when
    # sorting.
    def sorted_nav_data(nav_data)
      nav_data = {}.merge(nav_data)
      sorted = nav_data['navigation'].map { |i| i }.sort_by { |i| i['text'] }
      nav_data['navigation'] = sorted
      nav_data
    end

    def nav_config(*lines)
      [
        COLLECTIONS_CONFIG,
        LEADING_COMMENT,
        'navigation:',
        *lines,
        TRAILING_COMMENT,
      ].join("\n")
    end

    def capture_stderr
      orig_stderr = $stderr
      $stderr = StringIO.new
      yield
    ensure
      $stderr = orig_stderr
    end
  end
end
