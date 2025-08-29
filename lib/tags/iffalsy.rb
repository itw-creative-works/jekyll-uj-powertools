# Libraries
require_relative '../helpers/variable_resolver'

# Tag
module Jekyll
  module UJPowertools
    class IfFalsyTag < Liquid::Block
      include VariableResolver
      
      def initialize(tag_name, markup, tokens)
        super
        @variable = markup.strip
      end

      def render(context)
        # Use the helper to resolve input (handles both literals and variables)
        value = resolve_input(context, @variable)

        # Check if the value is falsy (nil, false, empty string, or 0)
        if value.nil? || value == false || value == "" || value == 0
          super
        else
          ""
        end
      end
    end
  end
end

Liquid::Template.register_tag('iffalsy', Jekyll::UJPowertools::IfFalsyTag)