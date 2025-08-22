# Libraries
require "jekyll"

module Jekyll
  # Hook into the pre_render phase to transform markdown images before conversion
  Jekyll::Hooks.register [:posts, :pages, :documents], :pre_render do |doc|
    # Only process markdown files
    if doc.extname == ".md"
      # Get image class from resolved data if available
      image_class = nil
      if doc.data['resolved'] && doc.data['resolved']['theme']
        theme = doc.data['resolved']['theme']
        if theme['post'] && theme['post']['image'] && theme['post']['image']['class']
          image_class = theme['post']['image']['class']
        end
      end

      # Transform markdown images by parsing and rendering Liquid template
      doc.content = doc.content.gsub(/!\[([^\]]*)\]\(([^)]+)\)/) do
        alt_text = $1
        image_path = $2

        # Build the Liquid tag string
        if image_class
          liquid_tag = "{% uj_image \"#{image_path}\", alt=\"#{alt_text}\", class=\"#{image_class}\" %}"
        else
          liquid_tag = "{% uj_image \"#{image_path}\", alt=\"#{alt_text}\" %}"
        end

        # Parse and render the Liquid template immediately
        template = Liquid::Template.parse(liquid_tag)
        context = doc.site.site_payload.merge({'page' => doc.to_liquid})
        result = template.render(Liquid::Context.new(context))

        # Return the HTML with blank lines to ensure markdown treats it as raw HTML
        "\n\n#{result}\n\n"
      end
    end
  end
end
