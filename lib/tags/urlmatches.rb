# Libraries
require_relative '../helpers/variable_resolver'

# Tag
module Jekyll
  module UJPowertools
    class UrlMatchesTag < Liquid::Tag
      include VariableResolver

      def initialize(tag_name, markup, tokens)
        super
        # Parse arguments: url, output_if_active
        args = parse_arguments(markup)
        @url = args[0] || ''
        @output = args[1] || 'active'
      end

      def render(context)
        # Get the current page URL
        page_url = context['page']['url']

        # Resolve the URL to check (handles both literals and variables)
        check_url = resolve_input(context, @url, true)

        # Resolve the output (handles both literals and variables)
        output = resolve_input(context, @output, true)

        # Normalize URLs to handle index pages
        # /about/index.html becomes /about/
        # / stays as /
        normalized_page_url = normalize_url(page_url)
        normalized_check_url = normalize_url(check_url)

        # Return output if URLs match, empty string otherwise
        if normalized_page_url == normalized_check_url
          output
        else
          ""
        end
      end

      private

      def normalize_url(url)
        return nil if url.nil?

        # Remove index.html from the end
        normalized = url.sub(/index\.html?$/, '')

        # Ensure trailing slash for non-root paths
        if normalized != '/' && !normalized.end_with?('/')
          normalized += '/'
        end

        normalized
      end
    end
  end
end

Liquid::Template.register_tag('urlmatches', Jekyll::UJPowertools::UrlMatchesTag)
