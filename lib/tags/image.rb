# Libraries
require "jekyll"

module Jekyll
  class UJImageTag < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      super
      @markup = markup.strip
    end

    def render(context)
      # Parse arguments
      args = parse_arguments(@markup)
      src_input = args[0]
      options = parse_options(args[1..-1])

      # Resolve source path
      src = resolve_variable(context, src_input)
      return '' unless src

      # Check if this is an external URL
      is_external = !!(src =~ /^https?:\/\//)

      if is_external
        # For external URLs, just create a simple responsive img tag
        build_external_image(src, options)
      else
        # Extract file extension
        extension = File.extname(src)
        src_path = src.chomp(extension)

        # Determine max width
        max_width = options['max_width'] || options['max-width'] || false
        max_width = max_width.to_s if max_width

        # Build picture element for local images
        build_picture_element(src, src_path, extension, max_width, options)
      end
    end

    private

    def parse_arguments(markup)
      args = []
      current_arg = ''
      in_quotes = false
      quote_char = nil

      markup.each_char do |char|
        if !in_quotes && (char == '"' || char == "'")
          in_quotes = true
          quote_char = char
          current_arg += char
        elsif in_quotes && char == quote_char
          in_quotes = false
          quote_char = nil
          current_arg += char
        elsif !in_quotes && char == ','
          args << current_arg.strip
          current_arg = ''
        else
          current_arg += char
        end
      end

      args << current_arg.strip if current_arg.strip.length > 0
      args
    end

    def parse_options(option_args)
      options = {}

      option_args.each do |arg|
        if arg.include?('=')
          key, value = arg.split('=', 2)
          key = key.strip.gsub(/^['"]|['"]$/, '')
          value = value.strip.gsub(/^['"]|['"]$/, '')
          options[key] = value
        end
      end

      options
    end

    def resolve_variable(context, variable_input)
      # Strip quotes if present
      if variable_input.match(/^['"]/)
        variable_input.gsub(/^['"]|['"]$/, '')
      else
        # Resolve as variable
        parts = variable_input.split('.')
        current = context

        parts.each do |part|
          return nil unless current.respond_to?(:[]) || current.is_a?(Hash)
          current = current[part]
          return nil if current.nil?
        end

        current
      end
    end

    def build_picture_element(src, src_path, extension, max_width, options)
      html = "<picture>\n"

      # Add WebP sources unless disabled
      unless options['webp'] == 'false'
        html += build_webp_sources(src_path, max_width)
      end

      # Add original format sources
      html += build_original_sources(src_path, extension, max_width, src)

      # Build img tag
      alt = options['alt'] || ''
      css_class = options['class'] || ''
      style = options['style'] || ''
      width = options['width'] || ''
      height = options['height'] || ''

      html += "<img\n"
      html += "src=\"data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==\"\n"
      html += "data-lazy=\"@src #{src}\"\n"
      html += "class=\"#{css_class}\"\n" unless css_class.empty?
      html += "alt=\"#{alt}\"\n"
      html += "style=\"#{style}\"\n" unless style.empty?
      html += "width=\"#{width}\"\n" unless width.empty?
      html += "height=\"#{height}\"\n" unless height.empty?
      html += ">\n"
      html += "</picture>"

      html
    end

    def build_webp_sources(src_path, max_width)
      html = ""

      case max_width
      when "320"
        html += "<source data-lazy=\"@srcset #{src_path}-320px.webp\" type=\"image/webp\">\n"
      when "640"
        html += "<source data-lazy=\"@srcset #{src_path}-320px.webp\" media=\"(max-width: 320px)\" type=\"image/webp\">\n"
        html += "<source data-lazy=\"@srcset #{src_path}-640px.webp\" type=\"image/webp\">\n"
      when "1024"
        html += "<source data-lazy=\"@srcset #{src_path}-320px.webp\" media=\"(max-width: 320px)\" type=\"image/webp\">\n"
        html += "<source data-lazy=\"@srcset #{src_path}-640px.webp\" media=\"(max-width: 640px)\" type=\"image/webp\">\n"
        html += "<source data-lazy=\"@srcset #{src_path}-1024px.webp\" type=\"image/webp\">\n"
      else
        html += "<source data-lazy=\"@srcset #{src_path}-320px.webp\" media=\"(max-width: 320px)\" type=\"image/webp\">\n"
        html += "<source data-lazy=\"@srcset #{src_path}-640px.webp\" media=\"(max-width: 640px)\" type=\"image/webp\">\n"
        html += "<source data-lazy=\"@srcset #{src_path}-1024px.webp\" media=\"(max-width: 1024px)\" type=\"image/webp\">\n"
        html += "<source data-lazy=\"@srcset #{src_path}.webp\" type=\"image/webp\">\n"
      end

      html
    end

    def build_original_sources(src_path, extension, max_width, src)
      html = ""

      case max_width
      when "320"
        html += "<source data-lazy=\"@srcset #{src_path}-320px#{extension}\">\n"
      when "640"
        html += "<source data-lazy=\"@srcset #{src_path}-320px#{extension}\" media=\"(max-width: 320px)\">\n"
        html += "<source data-lazy=\"@srcset #{src_path}-640px#{extension}\">\n"
      when "1024"
        html += "<source data-lazy=\"@srcset #{src_path}-320px#{extension}\" media=\"(max-width: 320px)\">\n"
        html += "<source data-lazy=\"@srcset #{src_path}-640px#{extension}\" media=\"(max-width: 640px)\">\n"
        html += "<source data-lazy=\"@srcset #{src_path}-1024px#{extension}\">\n"
      else
        html += "<source data-lazy=\"@srcset #{src_path}-320px#{extension}\" media=\"(max-width: 320px)\">\n"
        html += "<source data-lazy=\"@srcset #{src_path}-640px#{extension}\" media=\"(max-width: 640px)\">\n"
        html += "<source data-lazy=\"@srcset #{src_path}-1024px#{extension}\" media=\"(max-width: 1024px)\">\n"
        html += "<source data-lazy=\"@srcset #{src}\" media=\"(min-width: 1025px)\">\n"
      end

      html
    end

    def build_external_image(src, options)
      # Build responsive img tag for external URLs
      alt = options['alt'] || ''
      css_class = options['class'] || ''
      style = options['style'] || ''
      width = options['width'] || ''
      height = options['height'] || ''
      loading = options['loading'] || 'lazy'

      # Build img tag on a single line to prevent markdown parsing issues
      html = "<img"
      html += " src=\"data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==\""
      html += " data-lazy=\"@src #{src}\""
      html += " class=\"#{css_class}\"" unless css_class.empty?
      html += " alt=\"#{alt}\""
      html += " style=\"#{style}\"" unless style.empty?
      html += " width=\"#{width}\"" unless width.empty?
      html += " height=\"#{height}\"" unless height.empty?
      html += " loading=\"#{loading}\""
      html += ">"

      html
    end
  end
end

Liquid::Template.register_tag('uj_image', Jekyll::UJImageTag)
