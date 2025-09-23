# Libraries
require "jekyll"
require_relative '../helpers/variable_resolver'

module Jekyll
  class UJLogoTag < Liquid::Tag
    include UJPowertools::VariableResolver
    
    # Default logo to show when requested logo is not found
    DEFAULT_LOGO = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640"><!--!Font Awesome Free v7.0.0 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free Copyright 2025 Fonticons, Inc.--><path d="M320 64C334.7 64 348.2 72.1 355.2 85L571.2 485C577.9 497.4 577.6 512.4 570.4 524.5C563.2 536.6 550.1 544 536 544L104 544C89.9 544 76.9 536.6 69.6 524.5C62.3 512.4 62.1 497.4 68.8 485L284.8 85C291.8 72.1 305.3 64 320 64zM320 232C306.7 232 296 242.7 296 256L296 368C296 381.3 306.7 392 320 392C333.3 392 344 381.3 344 368L344 256C344 242.7 333.3 232 320 232zM346.7 448C347.3 438.1 342.4 428.7 333.9 423.5C325.4 418.4 314.7 418.4 306.2 423.5C297.7 428.7 292.8 438.1 293.4 448C292.8 457.9 297.7 467.3 306.2 472.5C314.7 477.6 325.4 477.6 333.9 472.5C342.4 467.3 347.3 457.9 346.7 448z"/></svg>'
    
    # Cache for loaded logos to improve performance
    @@logo_cache = {}
    
    def initialize(tag_name, markup, tokens)
      super
      @markup = markup.strip
    end
    
    def render(context)
      # Parse arguments using helper
      parts = parse_arguments(@markup)
      
      # Resolve logo name (required)
      logo_name = parts[0]
      if logo_name
        resolved = resolve_input(context, logo_name, true)
        # If resolved value is not a string, treat the input as literal
        if resolved.is_a?(String)
          # Strip any quotes from the resolved string value
          logo_name = resolved.gsub(/^['"]|['"]$/, '')
        else
          # Strip quotes if present and use as literal
          logo_name = logo_name.gsub(/^['"]|['"]$/, '')
        end
      end
      
      # Return empty if no logo name provided
      return '' unless logo_name
      
      # Resolve type (brandmarks or combomarks) - defaults to brandmarks
      type = 'brandmarks'
      if parts[1] && !parts[1].empty?
        resolved_type = resolve_input(context, parts[1], true)
        if resolved_type.is_a?(String) && !resolved_type.empty?
          type = resolved_type.gsub(/^['"]|['"]$/, '')
        elsif !parts[1].gsub(/^['"]|['"]$/, '').empty?
          type = parts[1].gsub(/^['"]|['"]$/, '')
        end
      end
      
      # Resolve color - defaults to original
      color = 'original'
      if parts[2] && !parts[2].empty?
        resolved_color = resolve_input(context, parts[2], true)
        if resolved_color.is_a?(String) && !resolved_color.empty?
          color = resolved_color.gsub(/^['"]|['"]$/, '')
        elsif !parts[2].gsub(/^['"]|['"]$/, '').empty?
          color = parts[2].gsub(/^['"]|['"]$/, '')
        end
      end
      
      # Get site from context
      site = context.registers[:site]
      return '' unless site
      
      # Load the logo SVG from file
      logo_svg = load_logo_from_file(logo_name.to_s, type, color)
      return '' unless logo_svg
      
      # Return the SVG directly
      logo_svg
    end
    
    private
    
    def load_logo_from_file(logo_name, type, color)
      # Create cache key
      cache_key = "#{type}/#{color}/#{logo_name}"
      
      # Return cached version if available
      return @@logo_cache[cache_key] if @@logo_cache.key?(cache_key)
      
      # Build file path
      logo_path = File.join(Dir.pwd, 'node_modules', 'ultimate-jekyll-manager', 'assets', 'logos', type, color, "#{logo_name}.svg")
      
      # Try to load the logo
      logo_svg = if File.exist?(logo_path)
                   File.read(logo_path)
                 else
                   DEFAULT_LOGO
                 end
      
      # Cache the result
      @@logo_cache[cache_key] = logo_svg
      return logo_svg
    end
  end
end

Liquid::Template.register_tag('uj_logo', Jekyll::UJLogoTag)