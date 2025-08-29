# Libraries
require "jekyll"
require_relative '../helpers/variable_resolver'

module Jekyll
  module UJPowertools
    class ExternalTag < Liquid::Tag
      include VariableResolver
      
      def initialize(tag_name, markup, tokens)
        super
        @markup = markup.strip
      end

      def render(context)
        # Resolve input path (handles both literals and variables)
        path = resolve_input(context, @markup)
        return '' if path.nil? || path.empty?
        
        # Check if path already has a protocol (http:// or https://)
        if path =~ /^https?:\/\//
          # Already has protocol, return as-is
          path
        elsif path =~ /^\/\//
          # Protocol-relative URL, return as-is
          path
        else
          # Get site URL from context
          site = context.registers[:site]
          site_url = site.config['url'] || ''
          
          # Remove trailing slash from site_url if present
          site_url = site_url.chomp('/')
          
          # Ensure path starts with /
          path = "/#{path}" unless path.start_with?('/')
          
          # Combine site URL with path
          "#{site_url}#{path}"
        end
      end
    end
  end
end

Liquid::Template.register_tag('uj_external', Jekyll::UJPowertools::ExternalTag)