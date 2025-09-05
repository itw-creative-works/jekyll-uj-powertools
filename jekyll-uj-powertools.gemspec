# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  # Gem info
  spec.name = "jekyll-uj-powertools"
  spec.version = "1.6.7"

  # Author info
  spec.authors = ["ITW Creative Works"]
  spec.email = ["hello@itwcreativeworks.com"]

  # Gem details
  spec.summary = "A powerful set of utilities for Jekyll"
  spec.description = "jekyll-uj-powertools provides a powerful set of utilities for Jekyll, including functions to remove ads from strings and escape JSON characters."
  spec.homepage = "https://github.com/itw-creative-works/jekyll-uj-powertools"
  spec.license = "MIT"

  # Files
  spec.files = Dir["CODE_OF_CONDUCT.md", "README*.md", "LICENSE", "Rakefile", "*.gemspec", "Gemfile", "lib/**/*", "spec/**/*"]
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  # Gem requires Jekyll to work
  spec.add_runtime_dependency "jekyll", ">= 3.0", "< 5.0"

  # Development requires more
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"

  # Translation and HTML manipulation requires Nokogiri
  spec.add_runtime_dependency 'nokogiri', '>= 1.17'

  # Ruby version
  spec.required_ruby_version = ">= 2.0.0"
end
