# Libraries
require_relative '../helpers/variable_resolver'

# Tag
module Jekyll
  module UJPowertools
    class IfFileTag < Liquid::Block
      include VariableResolver
      
      def initialize(tag_name, markup, tokens)
        super
        @path = markup.strip
      end

      def render(context)
        # Get the site object
        site = context.registers[:site]

        # Use the helper to resolve input (handles both literals and variables)
        path = resolve_input(context, @path)
        
        # Return empty if path couldn't be resolved
        return "" unless path

        # Ensure path starts with /
        path = "/#{path}" unless path.to_s.start_with?('/')

        # Check if file exists in static_files
        file_exists = site.static_files.any? { |file|
          # Compare both with and without leading slash
          file.relative_path == path ||
          file.relative_path == path[1..-1] ||
          "/#{file.relative_path}" == path
        }

        if file_exists
          super
        else
          ""
        end
      end
    end
  end
end

Liquid::Template.register_tag('iffile', Jekyll::UJPowertools::IfFileTag)
