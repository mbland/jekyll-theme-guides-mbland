# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'guides_style_mbland/version'

Gem::Specification.new do |s|
  s.name          = 'guides_style_mbland'
  s.version       = GuidesStyleMbland::VERSION
  s.authors       = ['Mike Bland']
  s.email         = ['mbland@acm.org']
  s.summary       = 'Guides style elements for Jekyll'
  s.description   = (
    'Provides consistent style elements for Guides generated using Jekyll. ' \
    'Originally based on DOCter (https://github.com/cfpb/docter/) ' \
    'from CFPB (http://cfpb.github.io/).'
  )
  s.homepage      = 'https://github.com/mbland/guides-style-mbland'
  s.license       = 'ISC'

  s.files         = `git ls-files -z assets _* *.md`.split("\x0")
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename f }

  s.add_runtime_dependency 'jekyll', '>=3.2.0'
  s.add_runtime_dependency 'jekyll_pages_api'
  s.add_runtime_dependency 'jekyll_pages_api_search'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'codeclimate-test-reporter'
  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rubocop'
end
