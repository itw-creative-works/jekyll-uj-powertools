# Libraries
require "jekyll"
require_relative '../helpers/variable_resolver'

module Jekyll
  class UJVideoTag < Liquid::Tag
    include UJPowertools::VariableResolver

    PLACEHOLDER = "data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw=="

    def initialize(tag_name, markup, tokens)
      super
      @markup = markup.strip
    end

    def render(context)
      # Parse arguments
      args = parse_arguments(@markup)
      src_input = args[0]

      # Parse options and resolve their values
      options = parse_options(args[1..-1], context)

      # Resolve source path (treat unquoted strings as literals)
      src = resolve_input(context, src_input, true)
      return '' unless src

      # Check if this is an external URL
      is_external = !!(src =~ /^https?:\/\//)

      if is_external
        # For external URLs, just create a simple responsive video tag
        build_external_video(src, options)
      else
        # Extract file extension
        extension = File.extname(src)
        src_path = src.chomp(extension)

        # Determine max width
        max_width = options['max_width'] || options['max-width'] || false
        max_width = max_width.to_s if max_width

        # Build video element for local videos
        build_video_element(src, src_path, extension, max_width, options)
      end
    end

    private

    # parse_arguments and parse_options methods are now provided by VariableResolver module

    def build_video_element(src, src_path, extension, max_width, options)
      html = "<video\n"

      # Add common video attributes
      css_class = options['class'] || ''
      style = options['style'] || ''
      width = options['width'] || ''
      height = options['height'] || ''
      autoplay = options['autoplay'] || ''
      loop = options['loop'] || ''
      muted = options['muted'] || ''
      controls = options['controls'] || 'true'
      playsinline = options['playsinline'] || ''
      preload = options['preload'] || 'metadata'
      poster = options['poster'] || ''

      html += "class=\"#{css_class}\"\n" unless css_class.empty?
      html += "style=\"#{style}\"\n" unless style.empty?
      html += "width=\"#{width}\"\n" unless width.empty?
      html += "height=\"#{height}\"\n" unless height.empty?
      html += "autoplay\n" unless autoplay.empty? || autoplay == 'false'
      html += "loop\n" unless loop.empty? || loop == 'false'
      html += "muted\n" unless muted.empty? || muted == 'false'
      html += "controls\n" unless controls == 'false'
      html += "playsinline\n" unless playsinline.empty? || playsinline == 'false'
      html += "preload=\"#{preload}\"\n"
      html += "poster=\"#{poster}\"\n" unless poster.empty?
      html += ">\n"

      # Add sources based on max_width
      html += build_video_sources(src_path, extension, max_width, src)

      # Fallback text
      html += "Your browser does not support the video tag.\n"
      html += "</video>"

      html
    end

    def build_video_sources(src_path, extension, max_width, src)
      html = ""

      case max_width
      when "320"
        html += "<source data-lazy=\"@src #{src_path}-320px#{extension}\" type=\"video/#{get_mime_type(extension)}\">\n"
      when "640"
        html += "<source data-lazy=\"@src #{src_path}-320px#{extension}\" media=\"(max-width: 320px)\" type=\"video/#{get_mime_type(extension)}\">\n"
        html += "<source data-lazy=\"@src #{src_path}-640px#{extension}\" type=\"video/#{get_mime_type(extension)}\">\n"
      when "1024"
        html += "<source data-lazy=\"@src #{src_path}-320px#{extension}\" media=\"(max-width: 320px)\" type=\"video/#{get_mime_type(extension)}\">\n"
        html += "<source data-lazy=\"@src #{src_path}-640px#{extension}\" media=\"(max-width: 640px)\" type=\"video/#{get_mime_type(extension)}\">\n"
        html += "<source data-lazy=\"@src #{src_path}-1024px#{extension}\" type=\"video/#{get_mime_type(extension)}\">\n"
      else
        html += "<source data-lazy=\"@src #{src_path}-320px#{extension}\" media=\"(max-width: 320px)\" type=\"video/#{get_mime_type(extension)}\">\n"
        html += "<source data-lazy=\"@src #{src_path}-640px#{extension}\" media=\"(max-width: 640px)\" type=\"video/#{get_mime_type(extension)}\">\n"
        html += "<source data-lazy=\"@src #{src_path}-1024px#{extension}\" media=\"(max-width: 1024px)\" type=\"video/#{get_mime_type(extension)}\">\n"
        html += "<source data-lazy=\"@src #{src}\" media=\"(min-width: 1025px)\" type=\"video/#{get_mime_type(extension)}\">\n"
      end

      html
    end

    def build_external_video(src, options)
      # Build responsive video tag for external URLs
      css_class = options['class'] || ''
      style = options['style'] || ''
      width = options['width'] || ''
      height = options['height'] || ''
      autoplay = options['autoplay'] || ''
      loop = options['loop'] || ''
      muted = options['muted'] || ''
      controls = options['controls'] || 'true'
      playsinline = options['playsinline'] || ''
      preload = options['preload'] || 'metadata'
      poster = options['poster'] || ''

      # Build video tag on a single line to prevent markdown parsing issues
      html = "<video"
      html += " class=\"#{css_class}\"" unless css_class.empty?
      html += " style=\"#{style}\"" unless style.empty?
      html += " width=\"#{width}\"" unless width.empty?
      html += " height=\"#{height}\"" unless height.empty?
      html += " autoplay" unless autoplay.empty? || autoplay == 'false'
      html += " loop" unless loop.empty? || loop == 'false'
      html += " muted" unless muted.empty? || muted == 'false'
      html += " controls" unless controls == 'false'
      html += " playsinline" unless playsinline.empty? || playsinline == 'false'
      html += " preload=\"#{preload}\""
      html += " poster=\"#{poster}\"" unless poster.empty?
      html += ">"

      # Determine MIME type from file extension
      extension = File.extname(src)
      mime_type = get_mime_type(extension)

      html += "<source data-lazy=\"@src #{src}\" type=\"video/#{mime_type}\">"
      html += "Your browser does not support the video tag."
      html += "</video>"

      html
    end

    def get_mime_type(extension)
      case extension.downcase
      when '.mp4'
        'mp4'
      when '.webm'
        'webm'
      when '.ogg', '.ogv'
        'ogg'
      when '.mov'
        'quicktime'
      when '.avi'
        'x-msvideo'
      else
        'mp4'  # Default to mp4
      end
    end
  end
end

Liquid::Template.register_tag('uj_video', Jekyll::UJVideoTag)
