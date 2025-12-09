# Blog Taxonomy Generator
# Generates category and tag pages for blog posts
# Reads from post.categories and post.tags (nested under 'post' frontmatter)

module Jekyll
  class CategoryPage < Page
    def initialize(site, base, category_name, category_slug)
      @site = site
      @base = base
      @dir = "blog/categories/#{category_slug}"
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'blueprint/blog/categories/category.html')

      # Set page data
      self.data['category'] = {
        'name' => category_name,
        'slug' => category_slug
      }
      self.data['title'] = "#{category_name} - Blog Categories"
      self.data['meta'] ||= {}
      self.data['meta']['title'] = "#{category_name} - Blog Categories - #{site.config['brand']['name'] || site.config['title']}"
      self.data['meta']['description'] = "Browse all blog posts in the #{category_name} category."
      self.data['meta']['breadcrumb'] = category_name
    end
  end

  class TagPage < Page
    def initialize(site, base, tag_name, tag_slug)
      @site = site
      @base = base
      @dir = "blog/tags/#{tag_slug}"
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'blueprint/blog/tags/tag.html')

      # Set page data
      self.data['tag'] = {
        'name' => tag_name,
        'slug' => tag_slug
      }
      self.data['title'] = "#{tag_name} - Blog Tags"
      self.data['meta'] ||= {}
      self.data['meta']['title'] = "#{tag_name} - Blog Tags - #{site.config['brand']['name'] || site.config['title']}"
      self.data['meta']['description'] = "Browse all blog posts tagged with #{tag_name}."
      self.data['meta']['breadcrumb'] = tag_name
    end
  end

  class BlogTaxonomyGenerator < Generator
    safe true
    priority :normal

    def generate(site)
      # Collect unique categories and tags from posts
      categories = {}
      tags = {}

      site.posts.docs.each do |post|
        # Get categories from post.categories (nested under 'post' frontmatter)
        post_data = post.data['post']
        next unless post_data

        # Process categories
        if post_data['categories'].is_a?(Array)
          post_data['categories'].each do |category|
            next if category.nil? || category.to_s.strip.empty?
            category_name = titleize(category.to_s.strip)
            category_slug = slugify(category.to_s.strip)
            categories[category_slug] = category_name
          end
        end

        # Process tags
        if post_data['tags'].is_a?(Array)
          post_data['tags'].each do |tag|
            next if tag.nil? || tag.to_s.strip.empty?
            tag_name = titleize(tag.to_s.strip)
            tag_slug = slugify(tag.to_s.strip)
            tags[tag_slug] = tag_name
          end
        end
      end

      # Generate category pages
      categories.each do |slug, name|
        site.pages << CategoryPage.new(site, site.source, name, slug)
      end

      # Generate tag pages
      tags.each do |slug, name|
        site.pages << TagPage.new(site, site.source, name, slug)
      end

      # Log generation info
      Jekyll.logger.info "BlogTaxonomy:", "Generated #{categories.size} category pages and #{tags.size} tag pages"
    end

    private

    def slugify(text)
      text.downcase.gsub(/[^a-z0-9\s-]/, '').gsub(/\s+/, '-').gsub(/-+/, '-').strip
    end

    def titleize(text)
      text.split(/[\s_-]/).map(&:capitalize).join(' ')
    end
  end
end
