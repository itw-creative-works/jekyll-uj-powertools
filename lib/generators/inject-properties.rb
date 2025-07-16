# Libraries
# ...

# Module
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

    def deep_merge(hash1, hash2)
      merger = proc { |_, old_val, new_val|
        if old_val.is_a?(Hash) && new_val.is_a?(Hash)
          old_val.merge(new_val, &merger)
        else
          new_val
        end
      }
      hash1.merge(hash2, &merger)
    end

    def inject_data(item, site)
      # Inject a random number into the item's data
      item.data['random_id'] = rand(100) # Random number between 0 and 99

      # Inject the file extension into the item's data
      if item.respond_to?(:path)
        item.data['extension'] = File.extname(item.path)
      end

      # Set resolved data for site, layout, and page
      # Create a deep merge of site -> layout -> page data
      # Priority: page (highest) -> layout -> site (lowest)
      resolved = {}

      # Start with site data
      if site.config
        resolved = deep_merge(resolved, site.config)
      end

      # Merge layout data if available
      if item.data['layout']
        layout_name = item.data['layout']
        layout = site.layouts[layout_name]
        if layout && layout.data
          resolved = deep_merge(resolved, layout.data)
          # Also add layout_data for backward compatibility
          item.data['layout_data'] = layout.data
        end
      end

      # Finally merge page data (highest priority)
      resolved = deep_merge(resolved, item.data)

      # Add the resolved data to the item
      item.data['resolved'] = resolved
    end
  end
end
