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

        path = resolve_path(context)

        # Return empty if path couldn't be resolved
        return "" if path.nil? || path.to_s.empty?

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

      private

      # Resolve the path argument from context.
      # Quoted strings are literals. Bare tokens are looked up as variables;
      # if the root segment isn't defined in context, fall back to the literal markup.
      def resolve_path(context)
        return nil if @path.nil? || @path.empty?

        # Quoted string literal
        if @path.match(/^["'](.*)["']$/)
          return $1
        end

        root = @path.split('.').first
        resolved = resolve_variable(context, @path)
        return resolved unless resolved.nil?

        # Variable resolved to nil — fall back to literal only if root is also nil/undefined
        context[root].nil? ? @path : nil
      end
    end
  end
end

Liquid::Template.register_tag('iffile', Jekyll::UJPowertools::IfFileTag)
