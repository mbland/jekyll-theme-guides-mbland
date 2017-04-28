module GuidesStyleMbland
  def self.update_theme
    exec({ 'RUBYOPT' => nil }, 'bundle',
      *%w(update --source guides_style_mbland))
  end
end
