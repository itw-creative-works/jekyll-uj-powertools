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
        
        puts "[iffile] Input markup: #{@path}"
        
        # Resolve the path variable if it's a variable name
        path = context[@path] || @path
        puts "[iffile] After context lookup: #{path}"
        
        # Handle nested variables like page.css_path
        if @path.include?('.')
          parts = @path.split('.')
          path = context[parts.first]
          parts[1..-1].each do |part|
            path = path.is_a?(Hash) ? path[part] : nil
            break if path.nil?
          end
          puts "[iffile] After nested lookup: #{path}"
        end
        
        # Ensure path starts with /
        path = "/#{path}" unless path.to_s.start_with?('/')
        puts "[iffile] Final path to check: #{path}"
        
        # Check if file exists in static_files
        puts "[iffile] Path to check: #{path}"
        
        # Debug: show first few static files
        puts "[iffile] Sample static files (first 5 CSS files):"
        site.static_files.select { |f| f.relative_path.end_with?('.css') }.first(5).each do |file|
          puts "  - #{file.relative_path}"
        end
        
        file_exists = site.static_files.any? { |file| 
          # Compare both with and without leading slash
          matches = file.relative_path == path || 
                   file.relative_path == path[1..-1] ||
                   "/#{file.relative_path}" == path
          if matches
            puts "[iffile] FOUND MATCH: #{file.relative_path}"
          end
          matches
        }
        
        puts "[iffile] File exists: #{file_exists}"
        
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