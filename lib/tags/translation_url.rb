# Libraries
require "jekyll"
require_relative '../helpers/variable_resolver'

module Jekyll
  class UJTranslationUrlTag < Liquid::Tag
    include UJPowertools::VariableResolver
    def initialize(tag_name, markup, tokens)
      super
      @markup = markup.strip
    end

    def render(context)
      # Parse arguments using helper
      parts = parse_arguments(@markup)
      
      # Return root if no arguments
      return '/' if parts.empty? || parts[0].nil?
      
      # Resolve both arguments using helper (handles literals and variables)
      language_code = resolve_input(context, parts[0])
      url_path = resolve_input(context, parts[1]) || '/'

      # Get site and translation config from context
      site = context.registers[:site]
      return '/' unless site

      translation_config = site.config['translation'] || {}
      default_language = translation_config['default'] || 'en'
      available_languages = translation_config['languages'] || [default_language]
      
      # Validate that the requested language is available
      unless available_languages.include?(language_code)
        # Fall back to default language if requested language is not available
        language_code = default_language
      end
      
      # Normalize the URL path
      normalized_path = normalize_path(url_path)
      
      # Generate the language-specific URL
      generate_language_url(language_code, normalized_path, default_language)
    end

    private

    # parse_arguments and resolve_variable methods are now provided by VariableResolver module

    def normalize_path(path)
      return '' if path.nil? || path.empty?
      
      # Remove leading slash for processing
      clean_path = path.start_with?('/') ? path[1..-1] : path
      
      # Handle empty path (home page)
      return '' if clean_path.empty?
      
      # Special case: remove index.html from blog paths
      # This converts "blog/index.html" to "blog"
      clean_path = clean_path.sub(/^blog\/index\.html$/, 'blog')
      
      # Special case: remove .html from blog pagination paths
      # This converts "blog/page/2.html" to "blog/page/2"
      clean_path = clean_path.sub(/^blog\/page\/(\d+)\.html$/, 'blog/page/\1')
      
      clean_path
    end

    def generate_language_url(language_code, normalized_path, default_language)
      # If it's the default language, return the original path
      if language_code == default_language
        return normalized_path.empty? ? '/' : "/#{normalized_path}"
      end

      # For non-default languages, prefix with language code
      if normalized_path.empty?
        # Home page: /es
        "/#{language_code}"
      else
        # Other pages: /es/pricing
        "/#{language_code}/#{normalized_path}"
      end
    end
  end
end

Liquid::Template.register_tag('uj_translation_url', Jekyll::UJTranslationUrlTag)