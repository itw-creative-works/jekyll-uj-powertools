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

      # Get post ID for @post/ prefix resolution
      post_id = doc.data['post'] && doc.data['post']['id'] ? doc.data['post']['id'] : nil

      # Shared transformer: convert ![alt](src) → rendered <img> HTML
      render_image = lambda do |alt_text, image_path|
        # Resolve @post/ prefix to full blog image path
        if image_path.start_with?('@post/')
          if post_id
            filename = image_path.sub('@post/', '')
            image_path = "/assets/images/blog/post-#{post_id}/#{filename}"
          else
            Jekyll.logger.warn "markdown-images", "@post/ used but no post.id found in #{doc.relative_path}"
          end
        end

        if image_class
          liquid_tag = "{% uj_image \"#{image_path}\", alt=\"#{alt_text}\", class=\"#{image_class}\" %}"
        else
          liquid_tag = "{% uj_image \"#{image_path}\", alt=\"#{alt_text}\" %}"
        end

        template = Liquid::Template.parse(liquid_tag)
        context = doc.site.site_payload.merge({'page' => doc.to_liquid})
        template.render(Liquid::Context.new(context))
      end

      # First pass: linked images [![alt](src)](href) → <a href><img></a>
      # Must run BEFORE the bare-image pass so the outer [](href) wrapper is preserved.
      # Kramdown otherwise promotes the inner ![](src) to a block and discards the wrapping link.
      # display:block on the anchor — otherwise an inline <a> has a 20px-tall hit
      # box, and clicks on the (taller) image overflow miss the link entirely.
      doc.content = doc.content.gsub(/\[!\[([^\]]*)\]\(([^)]+)\)\]\(([^)]+)\)/) do
        alt_text = $1
        image_path = $2
        href = $3
        img_html = render_image.call(alt_text, image_path)
        "\n\n<a href=\"#{href}\" style=\"display:block\">#{img_html}</a>\n\n"
      end

      # Second pass: bare markdown images ![alt](src)
      doc.content = doc.content.gsub(/!\[([^\]]*)\]\(([^)]+)\)/) do
        result = render_image.call($1, $2)
        "\n\n#{result}\n\n"
      end
    end
  end
end
