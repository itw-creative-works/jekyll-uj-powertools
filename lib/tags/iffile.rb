# Libraries
# ...

# Tag
module Jekyll
  module UJPowertools
    class IfFileTag < Liquid::Block
      def initialize(tag_name, markup, tokens)
        super
        @path = markup.strip
      end

      def render(context)
        # Get the site object
        site = context.registers[:site]

        # Resolve the path variable if it's a variable name
        path = context[@path] || @path

        # Handle nested variables like page.css_path
        if @path.include?('.')
          parts = @path.split('.')
          path = context[parts.first]
          parts[1..-1].each do |part|
            path = path.is_a?(Hash) ? path[part] : nil
            break if path.nil?
          end
        end

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
