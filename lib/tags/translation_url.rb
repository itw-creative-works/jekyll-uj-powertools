# Libraries
require "jekyll"

module Jekyll
  class UJTranslationUrlTag < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      super
      @markup = markup.strip
    end

    def render(context)
      # Parse arguments that can be quoted or unquoted
      parts = parse_arguments(@markup)
      
      # Return root if no arguments
      return '/' if parts.empty? || parts[0].nil?
      
      language_code_input = parts[0]
      url_path_input = parts[1] || '/'

      # Resolve language code (literal or variable)
      language_code = resolve_argument_value(context, language_code_input)
      # Resolve URL path (literal or variable)  
      url_path = resolve_argument_value(context, url_path_input)

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

    def parse_arguments(markup)
      # Parse arguments that can be quoted or unquoted
      # Examples: 'es', '/pricing'  OR  language, page.canonical.path  OR  'es', page.url
      args = []
      current_arg = ''
      in_quotes = false
      quote_char = nil

      markup.each_char.with_index do |char, i|
        if !in_quotes && (char == '"' || char == "'")
          # Start of quoted string - include the quote in the arg
          in_quotes = true
          quote_char = char
          current_arg += char
        elsif in_quotes && char == quote_char
          # End of quoted string - include the quote in the arg
          current_arg += char
          in_quotes = false
          quote_char = nil
        elsif !in_quotes && char == ','
          # Argument separator
          args << current_arg.strip
          current_arg = ''
        else
          # Regular character
          current_arg += char
        end
      end

      # Add the last argument
      args << current_arg.strip if current_arg.strip.length > 0

      args
    end

    def resolve_argument_value(context, argument_input)
      return '' if argument_input.nil? || argument_input.empty?

      # Check if the argument was originally quoted (literal string)
      is_quoted = argument_input.match(/^['"].*['"]$/)

      # If quoted, remove quotes and use as literal. Otherwise, try to resolve as variable
      if is_quoted
        # Remove quotes from literal string
        resolved_value = argument_input[1..-2]
      else
        # Try to resolve as a variable
        resolved_value = resolve_variable(context, argument_input)
        # If variable resolved to nil, return empty string
        return '' if resolved_value.nil?
        # If it didn't resolve to a string, use the resolved value
        resolved_value = resolved_value.to_s if resolved_value
      end

      resolved_value.to_s
    end

    def resolve_variable(context, variable_name)
      parts = variable_name.split('.')
      current = context

      parts.each do |part|
        if current.respond_to?(:[])
          current = current[part]
        elsif current.respond_to?(:key?) && current.key?(part)
          current = current[part]
        else
          return nil
        end
        return nil if current.nil?
      end

      current
    end

    def normalize_path(path)
      return '' if path.nil? || path.empty?
      
      # Remove leading slash for processing
      clean_path = path.start_with?('/') ? path[1..-1] : path
      
      # Handle empty path (home page)
      return '' if clean_path.empty?
      
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