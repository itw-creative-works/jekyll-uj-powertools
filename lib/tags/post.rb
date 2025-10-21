# Libraries
require "jekyll"
require_relative '../helpers/variable_resolver'

module Jekyll
  class UJPostTag < Liquid::Tag
    include UJPowertools::VariableResolver
    def initialize(tag_name, markup, tokens)
      super
      @markup = markup.strip
    end

    def render(context)
      # Parse arguments
      args = parse_arguments_with_quotes(@markup)
      post_input = args[0]
      property_input = args[1] || "'title'"  # Default to title if no property specified

      # Strip quotes from property if present
      property = property_input.gsub(/^['"]|['"]$/, '')

      # Resolve post ID
      post_id = is_quoted?(post_input) ?
                post_input.gsub(/^['"]|['"]$/, '') :
                resolve_post_id(context, post_input)
      return '' unless post_id

      # Find post in site collections
      site = context.registers[:site]
      post = find_post(site, post_id)
      return '' unless post

      # Return the requested property
      case property
      when 'title'
        post.data['title'] || ''
      when 'description'
        post.data['description'] || post.data['excerpt'] || ''
      when 'url'
        site_url = site.config['url'] || ''
        site_url + post.url
      when 'path'
        post.url
      when 'date'
        post.data['date'] ? post.data['date'].strftime('%Y-%m-%d') : ''
      when 'author'
        (post.data['post'] && post.data['post']['author']) || post.data['author'] || ''
      when 'category'
        post.data['category'] || post.data['categories']&.first || ''
      when 'categories'
        Array(post.data['categories']).join(', ')
      when 'tags'
        Array(post.data['tags']).join(', ')
      when 'id'
        post.id
      when 'image'
        # Use the custom post.post.id if available, otherwise fall back to extracting from post.id
        custom_id = (post.data['post'] && post.data['post']['id']) || post.id.gsub(/^\/(\w+)\//, '')
        # Extract the slug from the Jekyll post ID
        post_id_clean = post.id.gsub(/^\/(\w+)\//, '')
        slug = post_id_clean.gsub(/^\d{4}-\d{2}-\d{2}-/, '')
        "/assets/images/blog/posts/post-#{custom_id}/#{slug}.jpg"
      when 'image-tag'
        # Generate image path
        # Use the custom post.post.id if available, otherwise fall back to extracting from post.id
        custom_id = (post.data['post'] && post.data['post']['id']) || post.id.gsub(/^\/(\w+)\//, '')
        # Extract the slug from the Jekyll post ID
        post_id_clean = post.id.gsub(/^\/(\w+)\//, '')
        slug = post_id_clean.gsub(/^\d{4}-\d{2}-\d{2}-/, '')
        image_path = "/assets/images/blog/posts/post-#{custom_id}/#{slug}.jpg"

        # Parse additional options for the image tag
        image_options = parse_image_options(args[2..-1], context)

        # Set default alt text if not provided
        if !image_options['alt']
          # Try to get the title from post.post.title first, then fall back to post.title
          default_alt = (post.data['post'] && post.data['post']['title']) || post.data['title']
          image_options['alt'] = default_alt if default_alt
        end

        # Build the markup string for uj_image tag
        image_markup = build_image_markup(image_path, image_options)

        # Parse and render the uj_image tag using Liquid template
        template_content = "{% uj_image #{image_markup} %}"
        template = Liquid::Template.parse(template_content)
        template.render!(context)
      else
        # Try to access any other property dynamically
        (post.data['post'] && post.data['post'][property]) || post.data[property] || ''
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

    def resolve_post_id(context, post_input)
      if post_input.nil? || post_input.empty?
        # No input, use current page if it's a post
        page = context['page']
        return nil unless page

        # Check if current page is a post
        if page['post'] || page['collection'] == 'posts'
          page['id']
        else
          nil
        end
      else
        # Resolve the variable
        resolve_variable(context, post_input)
      end
    end

    # resolve_variable method is now provided by VariableResolver module

    def find_post(site, post_id)
      post_id_clean = post_id.to_s.strip

      # Search in posts collection first
      if site.collections['posts']
        post = site.collections['posts'].docs.find do |doc|
          # Check standard ID match
          doc.id == post_id_clean ||
          doc.id.include?(post_id_clean) ||
          # Also check if the post has a custom post.id field that matches (convert to string for comparison)
          (doc.data['post'] && doc.data['post']['id'].to_s == post_id_clean)
        end
        return post if post
      end

      # Search in other collections that might contain posts
      site.collections.each do |name, collection|
        next if name == 'posts'  # Already checked

        post = collection.docs.find do |doc|
          (doc.id == post_id_clean ||
           doc.id.include?(post_id_clean) ||
           # Check custom post.id field (convert to string for comparison)
           (doc.data['post'] && doc.data['post']['id'].to_s == post_id_clean)) &&
          doc.data['post']
        end
        return post if post
      end

      nil
    end

    def parse_image_options(option_args, context)
      options = {}

      option_args.each do |arg|
        if arg.include?('=')
          key, value = arg.split('=', 2)
          key = key.strip

          # Check if the value is quoted (literal) or unquoted (variable)
          if value.strip.match(/^['"].*['"]$/)
            # It's a literal string, strip quotes
            value = value.strip.gsub(/^['"]|['"]$/, '')
          else
            # It's a variable, resolve it
            resolved_value = resolve_variable(context, value.strip)
            value = resolved_value || value.strip
          end

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

Liquid::Template.register_tag('uj_post', Jekyll::UJPostTag)
