# Libraries
# ...

# Tag
module Jekyll
  module UJPowertools
    class IfFalsyTag < Liquid::Block
      def initialize(tag_name, markup, tokens)
        super
        @variable = markup.strip
      end

      def render(context)
        # Use Liquid's variable lookup to handle nested properties
        value = context.scopes.last[@variable] || context[@variable]

        # For nested properties like page.my.variable
        if @variable.include?('.')
          parts = @variable.split('.')
          value = context[parts.first]
          parts[1..-1].each do |part|
            value = value.is_a?(Hash) ? value[part] : nil
            break if value.nil?
          end
        end

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