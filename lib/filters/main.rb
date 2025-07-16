# Libraries
require "jekyll"

# Filters
module Jekyll
  module UJPowertools
    # Initialize a timestamp that will remain consistent across calls
    @cache_timestamp = Time.now.to_i.to_s

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

    # Return the current year
    def uj_year(input)
      Time.now.year
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
      # Get the current page from context
      page = @context.registers[:page] if @context.respond_to?(:registers)
      page ||= @context[:registers][:page] if @context.is_a?(Hash)

      # Apply liquify first
      liquified = if @context.respond_to?(:registers)
        Liquid::Template.parse(input).render(@context)
      else
        Liquid::Template.parse(input).render(@context[:registers] || {})
      end

      # Check if the page extension is .md
      if page && page['extension'] == '.md'
        # Apply markdownify for markdown files
        site = @context.registers[:site] if @context.respond_to?(:registers)
        site ||= @context[:registers][:site] if @context.is_a?(Hash)

        if site
          converter = site.find_converter_instance(Jekyll::Converters::Markdown)
          converter.convert(liquified)
        else
          liquified
        end
      else
        # Return just liquified content for non-markdown files
        liquified
      end
    end
  end
end

# Register the filter
Liquid::Template.register_filter(Jekyll::UJPowertools)
