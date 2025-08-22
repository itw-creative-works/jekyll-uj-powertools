# Libraries
require "jekyll"

module Jekyll
  class UJIconTag < Liquid::Tag
    # Default icon to show when requested icon is not found
    DEFAULT_ICON = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640"><!--!Font Awesome Free v7.0.0 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free Copyright 2025 Fonticons, Inc.--><path d="M320 64C334.7 64 348.2 72.1 355.2 85L571.2 485C577.9 497.4 577.6 512.4 570.4 524.5C563.2 536.6 550.1 544 536 544L104 544C89.9 544 76.9 536.6 69.6 524.5C62.3 512.4 62.1 497.4 68.8 485L284.8 85C291.8 72.1 305.3 64 320 64zM320 232C306.7 232 296 242.7 296 256L296 368C296 381.3 306.7 392 320 392C333.3 392 344 381.3 344 368L344 256C344 242.7 333.3 232 320 232zM346.7 448C347.3 438.1 342.4 428.7 333.9 423.5C325.4 418.4 314.7 418.4 306.2 423.5C297.7 428.7 292.8 438.1 293.4 448C292.8 457.9 297.7 467.3 306.2 472.5C314.7 477.6 325.4 477.6 333.9 472.5C342.4 467.3 347.3 457.9 346.7 448z"/></svg>'

    # Language code to country code mapping for flags
    LANGUAGE_TO_COUNTRY = {
      'en' => 'us',    # English -> United States (could also be 'gb' for Great Britain)
      'es' => 'es',    # Spanish -> Spain
      'fr' => 'fr',    # French -> France
      'de' => 'de',    # German -> Germany
      'it' => 'it',    # Italian -> Italy
      'pt' => 'pt',    # Portuguese -> Portugal
      'ru' => 'ru',    # Russian -> Russia
      'ja' => 'jp',    # Japanese -> Japan
      'ko' => 'kr',    # Korean -> South Korea
      'zh' => 'cn',    # Chinese -> China
      'ar' => 'sa',    # Arabic -> Saudi Arabia
      'hi' => 'in',    # Hindi -> India
      'tr' => 'tr',    # Turkish -> Turkey
      'pl' => 'pl',    # Polish -> Poland
      'nl' => 'nl',    # Dutch -> Netherlands
      'sv' => 'se',    # Swedish -> Sweden
      'no' => 'no',    # Norwegian -> Norway
      'da' => 'dk',    # Danish -> Denmark
      'fi' => 'fi',    # Finnish -> Finland
      'he' => 'il',    # Hebrew -> Israel
      'th' => 'th',    # Thai -> Thailand
      'vi' => 'vn',    # Vietnamese -> Vietnam
      'uk' => 'ua',    # Ukrainian -> Ukraine
      'cs' => 'cz',    # Czech -> Czech Republic
      'hu' => 'hu',    # Hungarian -> Hungary
      'ro' => 'ro',    # Romanian -> Romania
      'bg' => 'bg',    # Bulgarian -> Bulgaria
      'hr' => 'hr',    # Croatian -> Croatia
      'sk' => 'sk',    # Slovak -> Slovakia
      'sl' => 'si',    # Slovenian -> Slovenia
      'et' => 'ee',    # Estonian -> Estonia
      'lv' => 'lv',    # Latvian -> Latvia
      'lt' => 'lt',    # Lithuanian -> Lithuania
      'mt' => 'mt',    # Maltese -> Malta
      'ga' => 'ie',    # Irish -> Ireland
      'cy' => 'gb',    # Welsh -> Great Britain
      'ca' => 'es',    # Catalan -> Spain (could also be ad for Andorra)
      'eu' => 'es',    # Basque -> Spain
      'gl' => 'es',    # Galician -> Spain
    }

    # Font Awesome size mappings - commented out for now
    # FA_SIZES = {
    #   'fa-2xs' => '0.625em',
    #   'fa-xs'  => '0.75em',
    #   'fa-sm'  => '0.875em',
    #   'fa-md'  => '1em',
    #   'fa-lg'  => '1.25em',
    #   'fa-xl'  => '1.5em',
    #   'fa-2xl' => '2em'
    # }

    # Cache for loaded icons to improve performance
    @@icon_cache = {}

    def initialize(tag_name, markup, tokens)
      super
      @markup = markup.strip
    end

    def render(context)
      # Parse arguments that can be quoted or unquoted
      parts = parse_arguments(@markup)
      icon_name_input = parts[0]
      css_classes = parts[1]

      # Check if the input was originally quoted (literal string)
      is_quoted = @markup.strip.match(/^['"]/)

      # If quoted, use as literal. Otherwise, try to resolve as variable
      if is_quoted
        icon_name = icon_name_input
      else
        # Try to resolve as a variable
        icon_name = resolve_variable(context, icon_name_input)
        # If it didn't resolve to a string, use the input as literal
        icon_name = icon_name_input if icon_name.nil? || !icon_name.is_a?(String)
      end

      # Strip quotes from resolved icon name if present
      if icon_name.is_a?(String) && icon_name.match(/^['"].*['"]$/)
        icon_name = icon_name[1..-2]
      end

      # Get site from context
      site = context.registers[:site]
      return '' unless site

      # Load the icon SVG from file
      icon_svg = load_icon_from_file(site, icon_name.to_s)
      return '' unless icon_svg

      # Process SVG to inject required attributes
      processed_svg = inject_svg_attributes(icon_svg)

      # Determine CSS classes
      # font_size = '1em' # default
      # if size_input && !size_input.empty?
      #   # Check if it's a Font Awesome preset size
      #   font_size = FA_SIZES[size_input] || size_input
      # end

      # Wrap in i tag with CSS classes (always include 'fa' class)
      if css_classes && !css_classes.empty?
        "<i class=\"fa #{css_classes}\">#{processed_svg}</i>"
      else
        "<i class=\"fa\">#{processed_svg}</i>"
      end
    end

    private

    def inject_svg_attributes(svg_content)
      # Inject width, height, and fill attributes into the SVG tag
      if svg_content.include?('<svg')
        # Replace the opening SVG tag to include our required attributes
        svg_content.sub(/<svg([^>]*)>/) do |match|
          existing_attrs = $1
          # Only add attributes if they don't already exist
          attrs_to_add = []
          attrs_to_add << 'width="1em"' unless existing_attrs.include?('width=')
          attrs_to_add << 'height="1em"' unless existing_attrs.include?('height=')
          attrs_to_add << 'fill="currentColor"' unless existing_attrs.include?('fill=')

          if attrs_to_add.any?
            "<svg#{existing_attrs} #{attrs_to_add.join(' ')}>"
          else
            match
          end
        end
      else
        svg_content
      end
    end

    def load_icon_from_file(site, icon_name)
      # Get the style from site config
      style = site.config.dig('icons', 'style') || 'solid'

      # Create cache key
      cache_key = "#{style}/#{icon_name}"

      # Return cached version if available
      return @@icon_cache[cache_key] if @@icon_cache.key?(cache_key)

      # Try to load icon from multiple sources in order
      icon_svg = try_load_fontawesome_icon(icon_name, style) ||
                 try_load_flag_icon(icon_name) ||
                 DEFAULT_ICON

      # Cache the result
      @@icon_cache[cache_key] = icon_svg
      return icon_svg
    end

    def try_load_fontawesome_icon(icon_name, style)
      # Build file path for the configured style
      icon_path = File.join(Dir.pwd, 'node_modules', 'ultimate-jekyll-manager', 'assets', 'icons', 'font-awesome', style, "#{icon_name}.svg")

      # Read file if it exists in the configured style
      if File.exist?(icon_path)
        return File.read(icon_path)
      end

      # If not found and style is not 'brands', try brands style as fallback
      if style != 'brands'
        brands_path = File.join(Dir.pwd, 'node_modules', 'ultimate-jekyll-manager', 'assets', 'icons', 'font-awesome', 'brands', "#{icon_name}.svg")

        if File.exist?(brands_path)
          return File.read(brands_path)
        end
      end

      nil
    end

    def try_load_flag_icon(icon_name)
      # First try direct country code (e.g., 'us', 'gb')
      flag_path = File.join(Dir.pwd, 'node_modules', 'ultimate-jekyll-manager', 'assets', 'icons', 'flags', 'modern-square', "#{icon_name}.svg")

      if File.exist?(flag_path)
        return File.read(flag_path)
      end

      # If not found, try language code to country code mapping (e.g., 'en' -> 'us')
      country_code = LANGUAGE_TO_COUNTRY[icon_name.downcase]
      if country_code
        mapped_flag_path = File.join(Dir.pwd, 'node_modules', 'ultimate-jekyll-manager', 'assets', 'icons', 'flags', 'modern-square', "#{country_code}.svg")

        if File.exist?(mapped_flag_path)
          return File.read(mapped_flag_path)
        end
      end

      nil
    end

    def parse_arguments(markup)
      # Parse arguments that can be quoted or unquoted
      # Examples: award, fa-md  OR  'award', 'fa-md'  OR  myVar, "2em"
      args = []
      current_arg = ''
      in_quotes = false
      quote_char = nil

      markup.each_char.with_index do |char, i|
        if !in_quotes && (char == '"' || char == "'")
          # Start of quoted string
          in_quotes = true
          quote_char = char
        elsif in_quotes && char == quote_char
          # End of quoted string
          in_quotes = false
          quote_char = nil
        elsif !in_quotes && char == ','
          # Argument separator
          args << current_arg.strip
          current_arg = ''
        else
          # Regular character
          current_arg += char
        end
      end

      # Add the last argument
      args << current_arg.strip if current_arg.strip.length > 0

      args
    end

    def resolve_variable(context, variable_name)
      # Handle nested variable access like page.icon
      parts = variable_name.split('.')
      current = context

      parts.each do |part|
        if current.respond_to?(:[])
          current = current[part]
        elsif current.respond_to?(:key?) && current.key?(part)
          current = current[part]
        else
          return nil
        end
        return nil if current.nil?
      end

      current
    end
  end
end

Liquid::Template.register_tag('uj_icon', Jekyll::UJIconTag)
