require 'sass'

module GuidesStyleMbland
  class Sass
    DIR = File.join File.dirname(__FILE__), 'sass'
    GUIDES_STYLES_FILE = File.join DIR, 'guides_style_mbland.scss'
  end
end

Sass.load_paths << ::GuidesStyleMbland::Sass::DIR
