# Libraries
require "jekyll"
require_relative '../helpers/variable_resolver'

module Jekyll
  class UJMemberTag < Liquid::Tag
    include UJPowertools::VariableResolver
    def initialize(tag_name, markup, tokens)
      super
      @markup = markup.strip
    end

    def render(context)
      # Parse arguments preserving quotes
      args = parse_arguments_with_quotes(@markup)
      member_input = args[0]
      property_input = args[1] || "'name'"  # Default to name if no property specified

      # Strip quotes from property if present
      property = property_input.gsub(/^['"]|['"]$/, '')

      # Resolve member ID
      member_id = is_quoted?(member_input) ?
                  member_input.gsub(/^['"]|['"]$/, '') :
                  resolve_member_id(context, member_input)
      return '' unless member_id

      # Find member in site.team collection
      site = context.registers[:site]
      member = find_member(site, member_id)
      return '' unless member

      # Return the requested property
      case property
      when 'name'
        (member.data['member'] && member.data['member']['name']) || ''
      when 'url'
        site_url = site.config['url'] || ''
        site_url + member.url
      when 'path'
        member.url
      when 'image'
        member_id_clean = member.id.gsub('/team/', '')
        "/assets/images/team/#{member_id_clean}/profile.jpg"
      when 'image-tag'
        # Generate image path
        member_id_clean = member.id.gsub('/team/', '')
        image_path = "/assets/images/team/#{member_id_clean}/profile.jpg"
        
        # Parse additional options for the image tag
        image_options = parse_image_options(args[2..-1])
        
        # Set default alt text if not provided
        if !image_options['alt'] && member.data['member'] && member.data['member']['name']
          image_options['alt'] = member.data['member']['name']
        end
        
        # Build the markup string for uj_image tag
        image_markup = build_image_markup(image_path, image_options)
        
        # Parse and render the uj_image tag using Liquid template
        template_content = "{% uj_image #{image_markup} %}"
        template = Liquid::Template.parse(template_content)
        template.render!(context)
      else
        # Try to access any other property dynamically
        (member.data['member'] && member.data['member'][property]) || member.data[property] || ''
      end
    end

    private

    def parse_arguments_with_quotes(markup)
      # Parse arguments preserving quotes for detection
      args = []
      current_arg = ''
      in_quotes = false
      quote_char = nil
      
      markup.each_char.with_index do |char, i|
        if !in_quotes && (char == '"' || char == "'")
          in_quotes = true
          quote_char = char
          current_arg += char
        elsif in_quotes && char == quote_char
          in_quotes = false
          current_arg += char
          quote_char = nil
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
    
    def parse_arguments(markup)
      # Parse arguments that can be quoted or unquoted
      args = []
      current_arg = ''
      in_quotes = false
      quote_char = nil

      markup.each_char.with_index do |char, i|
        if !in_quotes && (char == '"' || char == "'")
          in_quotes = true
          quote_char = char
        elsif in_quotes && char == quote_char
          in_quotes = false
          quote_char = nil
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

    def resolve_member_id(context, member_input)
      if member_input.nil? || member_input.empty?
        # No input, try default sources
        page = context['page']
        return nil unless page

        if page['post'] && page['post']['member']
          page['post']['member']
        elsif page['member'] && page['member']['name']
          page['id']
        else
          nil
        end
      else
        # Resolve the variable
        resolve_variable(context, member_input)
      end
    end

    def resolve_variable(context, variable_name)
      # Handle nested variable access
      parts = variable_name.split('.')
      current = context

      parts.each do |part|
        return nil unless current.respond_to?(:[]) || current.is_a?(Hash)
        current = current[part]
        return nil if current.nil?
      end

      current
    end

    def find_member(site, member_id)
      return nil unless site.collections['team']

      site.collections['team'].docs.find do |member|
        member.id.include?(member_id.to_s)
      end
    end
    
    def parse_image_options(option_args)
      options = {}
      
      option_args.each do |arg|
        # Strip quotes if present
        arg_clean = arg.gsub(/^['"]|['"]$/, '')
        
        if arg_clean.include?('=')
          key, value = arg_clean.split('=', 2)
          key = key.strip
          value = value.strip.gsub(/^['"]|['"]$/, '')
          options[key] = value
        end
      end
      
      options
    end
    
    def build_image_markup(image_path, options)
      # Build markup string in the format expected by uj_image tag
      markup_parts = ["\"#{image_path}\""]
      
      options.each do |key, value|
        markup_parts << "#{key}=\"#{value}\""
      end
      
      markup_parts.join(', ')
    end
  end
end

Liquid::Template.register_tag('uj_member', Jekyll::UJMemberTag)
