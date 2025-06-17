# Libraries
# ...

module Jekyll
  class InjectData < Generator
    safe true
    priority :low

    def generate(site)
      # Define a global variable accessible in templates
      # site.config['cache_breaker'] = Time.now.to_i.to_s

      # Process pages
      site.pages.each do |page|
        inject_data(page, site)
      end

      # Process documents in all collections
      site.collections.each do |_, collection|
        collection.docs.each do |document|
          inject_data(document, site)
        end
      end
    end

    private

    def inject_data(item, site)
      # Inject a random number into the item's data
      item.data['random_id'] = rand(100) # Random number between 0 and 99

      return unless item.data['layout'] # Skip items without layouts

      # Find the layout file by its name
      layout_name = item.data['layout']
      layout = site.layouts[layout_name]

      if layout && layout.data
        # Merge layout front matter into item's "layout_data"
        item.data['layout_data'] = layout.data
      end
    end
  end
end
