require "jekyll"

module Jekyll
  module UJPowertools
    def strip_ads(input)
      input.gsub(/\s*<ad-unit>[\s\S]*?<\/ad-unit>\s*/m, '')
    end

    def json_escape(value)
      value.gsub('\\', '\\\\').gsub('"', '\"')
    end
  end
end

Liquid::Template.register_filter(Jekyll::UJPowertools)
