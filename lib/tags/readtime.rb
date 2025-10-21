# Libraries
require "jekyll"
require_relative '../helpers/variable_resolver'

module Jekyll
  class UJReadtimeTag < Liquid::Tag
    include UJPowertools::VariableResolver

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

      # Calculate readtime (269 words per minute, minimum 1 minute)
      readtime = (words / 269.0).ceil
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
        # Use the helper to resolve input (handles both literals and variables)
        resolve_input(context, @markup)
      end
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
