require "jekyll"

module Jekyll
  module UJPowertools
    def remove_ads(input)
      input.gsub(/<[^>]*class="uj-vert-unit"[^>]*>.*?<\/[^>]*>/m, '')
    end

    def json_escape(value)
      value.gsub('\\', '\\\\').gsub('"', '\"')
    end
  end
end

Liquid::Template.register_filter(Jekyll::UJPowertools)
