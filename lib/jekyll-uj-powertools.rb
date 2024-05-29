require "jekyll"

module Jekyll
  module UJPowertools
    # Strip ads from the input
    def uj_strip_ads(input)
      input.gsub(/\s*<ad-unit>[\s\S]*?<\/ad-unit>\s*/m, '')
    end

    # Escape a string for use in JSON
    def uj_json_escape(value)
      value.gsub('\\', '\\\\').gsub('"', '\"')
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
  end
end

Liquid::Template.register_filter(Jekyll::UJPowertools)
