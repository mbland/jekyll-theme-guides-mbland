module JekyllThemeGuidesMbland
  class DummyPage < ::Jekyll::Page
    attr_accessor :data

    def initialize(site, permalink)
      @site = site
      @data = {}
      @dir = nil
      data['permalink'] = permalink
    end

    def html?
      true
    end
  end
end
