module JekyllThemeGuidesMbland
  def self.update_theme
    exec({ 'RUBYOPT' => nil }, 'bundle',
      *%w[update --source jekyll-theme-guides-mbland].freeze)
  end
end
