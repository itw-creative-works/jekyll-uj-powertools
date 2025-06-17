# Libraries
require "jekyll"

# Module
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

    # Accessor for the consistent timestamp
    def self.cache_timestamp
      @cache_timestamp
    end
  end

  # Load Generators
  require_relative "generators/inject-properties"

  # Load Hooks
  require_relative "hooks/inject-properties"
  # require_relative "hooks/translate-pages"
end

# Register the filter
Liquid::Template.register_filter(Jekyll::UJPowertools)
