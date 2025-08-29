# Libraries
require "jekyll"
require_relative '../helpers/variable_resolver'

module Jekyll
  class UJCommentsTag < Liquid::Tag
    include UJPowertools::VariableResolver
    def initialize(tag_name, markup, tokens)
      super
      @markup = markup.strip
    end

    def render(context)
      # Get the content to analyze
      content = resolve_content(context)
      return '0' unless content
      
      # Strip HTML tags
      stripped_content = strip_html(content)
      
      # Count words
      words = count_words(stripped_content)
      
      # Generate comment count based on word count modulo 13
      comments = words % 13
      
      comments.to_s
    end
    
    private
    
    def resolve_content(context)
      if @markup.empty?
        # No argument, use page content
        page = context['page']
        return nil unless page
        page['content']
      else
        # Use the helper to resolve input (handles both literals and variables)
        resolve_input(context, @markup)
      end
    end
    
    # resolve_variable method is now provided by VariableResolver module
    
    def strip_html(content)
      # Remove HTML tags
      content = content.to_s.gsub(/<script.*?<\/script>/m, '')
      content = content.gsub(/<style.*?<\/style>/m, '')
      content = content.gsub(/<[^>]+>/, ' ')
      content = content.gsub(/\s+/, ' ')
      content.strip
    end
    
    def count_words(text)
      # Count words (split by whitespace)
      text.split(/\s+/).length
    end
  end
end

Liquid::Template.register_tag('uj_fake_comments', Jekyll::UJCommentsTag)