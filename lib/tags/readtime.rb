# Libraries
require "jekyll"

module Jekyll
  class UJReadtimeTag < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      super
      @markup = markup.strip
    end

    def render(context)
      # Get the content to analyze
      content = resolve_content(context)
      return '1' unless content
      
      # Strip HTML tags
      stripped_content = strip_html(content)
      
      # Count words
      words = count_words(stripped_content)
      
      # Calculate readtime (200 words per minute, minimum 1 minute)
      readtime = (words / 200.0).ceil
      readtime = 1 if readtime < 1
      
      readtime.to_s
    end
    
    private
    
    def resolve_content(context)
      if @markup.empty?
        # No argument, use page content
        page = context['page']
        return nil unless page
        page['content']
      else
        # Resolve the variable name
        resolve_variable(context, @markup)
      end
    end
    
    def resolve_variable(context, variable_name)
      # Handle nested variable access like page.content or include.content
      parts = variable_name.split('.')
      current = context
      
      parts.each do |part|
        return nil unless current.respond_to?(:[]) || current.is_a?(Hash)
        current = current[part]
        return nil if current.nil?
      end
      
      current
    end
    
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

Liquid::Template.register_tag('uj_readtime', Jekyll::UJReadtimeTag)