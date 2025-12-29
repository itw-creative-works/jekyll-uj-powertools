# Dynamic Pages Generator
# Automatically generates pages from collection data based on config
#
# Usage in _config.yml:
#
#   generators:
#     collection_categories:
#       # Example 1: Extract category from frontmatter field
#       - collection: recipes
#         field: recipe.cuisine       # Dot notation for nested fields
#         layout: recipe-category
#         permalink: /recipes/:slug
#         title: ":name Recipes"
#         description: "Browse our collection of :name recipes."
#
#       # Example 2: Simple frontmatter field
#       - collection: products
#         field: category
#         layout: product-category
#         permalink: /products/:slug
#         title: ":name Products"
#         description: "Shop our :name products."
#
#       # Example 3: Minimal config (uses defaults)
#       - collection: articles
#         field: category
#         layout: article-category
#
# Template variables for title/description/permalink:
#   :name - The formatted category name (e.g., "Asian Cuisine")
#   :slug - The URL-safe slug (e.g., "asian-cuisine")
#
# Defaults:
#   permalink: /:collection/:slug (e.g., /recipes/asian)
#   title: :name
#   description: "Browse our collection of :name."

module Jekyll
  class DynamicPagesGenerator < Generator
    safe true
    priority :normal  # Run before InjectProperties (:low) so dynamic pages get resolved data

    def generate(site)
      config = site.config.dig('generators', 'collection_categories')
      return unless config.is_a?(Array)

      config.each do |category_config|
        generate_category_pages(site, category_config)
      end
    end

    private

    def generate_category_pages(site, config)
      collection_name = config['collection']
      field = config['field']
      return unless collection_name && field

      collection = site.collections[collection_name]
      return unless collection

      # Configuration with defaults
      layout = config['layout']
      permalink_template = config['permalink'] || "/#{collection_name}/:slug"
      title_template = config['title'] || ':name'
      description_template = config['description'] || 'Browse our collection of :name.'

      # Extract unique categories from documents
      categories = {}

      collection.docs.each do |doc|
        category_value = dig_value(doc.data, field)
        next unless category_value && !category_value.empty?

        category_slug = slugify(category_value)
        next if categories.key?(category_slug)

        # Format category name: titleize
        category_name = titleize(category_value)

        # Apply templates
        permalink = apply_template(permalink_template, category_name, category_slug)
        title = apply_template(title_template, category_name, category_slug)
        description = apply_template(description_template, category_name, category_slug)

        categories[category_slug] = {
          'slug' => category_slug,
          'name' => category_name,
          'title' => title,
          'description' => description,
          'permalink' => permalink
        }
      end

      # Generate a page for each category
      categories.each do |slug, data|
        page = DynamicCategoryPage.new(site, layout, data, collection_name)
        site.pages << page
      end

      Jekyll.logger.info "DynamicPages:", "Generated #{categories.size} category pages for '#{collection_name}'"
    end

    # Dig into nested hash using dot notation (e.g., "recipe.cuisine")
    def dig_value(hash, field)
      keys = field.split('.')
      value = hash
      keys.each do |key|
        return nil unless value.is_a?(Hash)
        value = value[key]
      end
      value.is_a?(String) ? value : nil
    end

    def slugify(str)
      str.to_s.downcase.strip.gsub(/[^\w\s-]/, '').gsub(/[\s_]+/, '-')
    end

    def titleize(str)
      str.to_s.split(/[\s_-]+/).map(&:capitalize).join(' ')
    end

    def apply_template(template, name, slug)
      template.gsub(':name', name).gsub(':slug', slug)
    end
  end

  # Custom page class for dynamically generated category pages
  class DynamicCategoryPage < Page
    def initialize(site, layout, data, collection_name)
      @site = site
      @base = site.source
      @dir = ''
      @name = "#{data['slug']}.html"

      self.process(@name)
      self.data = {
        'layout' => layout,
        'title' => data['title'],
        'description' => data['description'],
        'category_slug' => data['slug'],
        'category_name' => data['name'],
        'collection_name' => collection_name,
        'permalink' => data['permalink'],
        'meta' => {
          'title' => "#{data['title']} - #{site.config.dig('brand', 'name') || site.config['title']}",
          'description' => data['description']
        }
      }
    end
  end
end
