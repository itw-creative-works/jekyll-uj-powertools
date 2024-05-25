require "jekyll"

module Jekyll
  module UJPowertools
    def strip_ads(input)
      # input.gsub(/\{% include \/master\/modules\/adunits[^%]*%\}/, '')
      input.gsub(/<!--\s*ADUNIT_TRIGGER_START\s*-->.*?<!--\s*ADUNIT_TRIGGER_END\s*-->/m, '')
    end

    def json_escape(value)
      value.gsub('\\', '\\\\').gsub('"', '\"')
    end
  end
end

Liquid::Template.register_filter(Jekyll::UJPowertools)
