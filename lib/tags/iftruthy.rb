# Libraries
require_relative '../helpers/variable_resolver'

# Tag
module Jekyll
  module UJPowertools
    class IfTruthyTag < Liquid::Block
      include VariableResolver
      def initialize(tag_name, markup, tokens)
        super
        @variable = markup.strip
      end

      def render(context)
        # Use the helper to resolve input (handles both literals and variables)
        # Don't use prefer_literal for iftruthy - we want to check variables
        value = resolve_input(context, @variable, false)

        # Check if the value is truthy (not nil, not false, not empty string, not 0)
        if value && value != false && value != "" && value != 0
          super
        else
          ""
        end
      end
    end
  end
end

Liquid::Template.register_tag('iftruthy', Jekyll::UJPowertools::IfTruthyTag)
