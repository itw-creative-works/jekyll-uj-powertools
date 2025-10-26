# Libraries
require "jekyll"
require "json"

# Filters
module Jekyll
  module UJPowertools
    # Initialize a timestamp that will remain consistent across calls (with milliseconds)
    @cache_timestamp = (Time.now.to_f * 1000).to_i.to_s

    # Strip ads from the input
    def uj_strip_ads(input)
      input
        # Remove HTML <ad-units>
        .gsub(/\s*<ad-unit>[\s\S]*?<\/ad-unit>\s*/m, '')
        # Remove includes starting with "/master/modules/adunits/"
        .gsub(/\s*\{% include \/master\/modules\/adunits\/.*? %\}\s*/m, '')
    end

    # Escape a string for use in JSON
    # def uj_json_escape(value)
    #   value
    #     .gsub('\\', '\\\\')  # Escape backslashes
    #     .gsub('"', '\"')     # Escape double quotes
    #     .gsub("\b", '\\b')   # Escape backspace
    #     .gsub("\f", '\\f')   # Escape formfeed
    #     .gsub("\n", '\\n')   # Escape newline
    #     .gsub("\r", '\\r')   # Escape carriage return
    #     .gsub("\t", '\\t')   # Escape tab
    # end
    def uj_json_escape(value)
      value.to_json[1..-2]  # Convert to JSON and remove the surrounding quotes
    end

    # Increment a global counter that can be accessed from any page then return the new value
    # def uj_increment_return(input)
    #   @context.registers[:uj_incremental_return] ||= 0
    #   @context.registers[:uj_incremental_return]
    #   @context.registers[:uj_incremental_return] += input
    # end
    def uj_increment_return(input)
      @context ||= { registers: {} }
      @context[:registers][:uj_incremental_return] ||= 0
      @context[:registers][:uj_incremental_return] += input
    end

    # Return a random number between 0 and the input
    def uj_random(input)
      rand(input)
    end

    # Title case
    def uj_title_case(input)
      input.split(' ').map(&:capitalize).join(' ')
    end

    # Check if a value is truthy (not nil, empty string, or 'null')
    # def uj_istruthy(input)
    #   return false if input.nil?
    #   return false if input.respond_to?(:empty?) && input.empty?
    #   return false if input.to_s.downcase == 'null'
    #   return false if input == false
    #   true
    # end

    # Accessor for the consistent timestamp
    def self.cache_timestamp
      @cache_timestamp
    end

    # Check if a string ends with a specific suffix
    # def uj_ends_with(input, suffix)
    #   input.end_with?(suffix)
    # end

    # Format content based on file extension - apply liquify and markdownify for .md files
    def uj_content_format(input)
      # Return empty string if input is nil
      return '' unless input

      # Get the current page from context
      page = @context.registers[:page] if @context.respond_to?(:registers)
      page ||= @context[:registers][:page] if @context.is_a?(Hash)

      # Get site from context
      site = @context.registers[:site] if @context.respond_to?(:registers)
      site ||= @context[:registers][:site] if @context.is_a?(Hash)

      # Apply recursive liquify (markdown images are already converted to uj_image tags by the hook)
      liquified = uj_liquify(input)

      # Check if the page extension is .md
      if page && page['extension'] == '.md' && site
        # Apply markdownify for markdown files
        converter = site.find_converter_instance(Jekyll::Converters::Markdown)
        converter.convert(liquified)
      else
        # Return just liquified content for non-markdown files
        liquified
      end
    end

    # # Process Liquid template syntax within a string
    # def liquify(input)
    #   return '' unless input

    #   if @context.respond_to?(:registers)
    #     Liquid::Template.parse(input).render(@context)
    #   else
    #     Liquid::Template.parse(input).render(@context[:registers] || {})
    #   end
    # end

    # Process Liquid template syntax within a string, recursively handling nested Liquid variables
    def uj_liquify(input, max_depth = 10)
      return '' unless input

      depth = 0
      result = input.to_s

      # Keep processing while we detect Liquid syntax and haven't exceeded max depth
      while (result.include?('{{') || result.include?('{%')) && depth < max_depth
        new_result = if @context.respond_to?(:registers)
          Liquid::Template.parse(result).render(@context)
        else
          Liquid::Template.parse(result).render(@context[:registers] || {})
        end

        # If nothing changed, we're done (prevents infinite loops)
        break if new_result == result

        result = new_result
        depth += 1
      end

      result
    end

    # Pretty print JSON with configurable indentation (default 2 spaces)
    def uj_jsonify(input, indent_size = 2)
      indent_string = ' ' * indent_size.to_i
      JSON.pretty_generate(input, indent: indent_string)
    end

    private

    # Helper method to safely dig through nested hashes
    def dig_value(hash, *keys)
      return nil unless hash

      value = hash
      keys.each do |key|
        return nil unless value.is_a?(Hash)
        value = value[key]
        return nil if value.nil?
      end

      value
    end
  end
end

# Register the filter
Liquid::Template.register_filter(Jekyll::UJPowertools)
