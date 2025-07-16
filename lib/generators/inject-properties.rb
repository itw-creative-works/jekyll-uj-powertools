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

    def filter_site_config(config)
      # Get exclusion list from config or use defaults
      exclusions = config['powertools_resolved_exclude'] || default_exclusions

      # Always exclude the config key itself
      exclusions_with_config_key = exclusions + ['powertools_resolved_exclude']

      # Create filtered copy
      filtered = {}
      config.each do |key, value|
        next if exclusions_with_config_key.include?(key)
        filtered[key] = value
      end

      filtered
    end

    def default_exclusions
      # Exclude Jekyll internal keys and potentially large data
      [
        # Unnecessary Jekyll keys
        'plugins', 'gems', 'whitelist', 'plugins_dir',
        'layouts_dir', 'data_dir', 'includes_dir',
        'collections', 'jekyll-archives', 'scholar',
        'assets', 'webpack', 'sass', 'keep_files',
        'include', 'exclude', 'markdown_ext',

        # Custom exclusions
        'escapes', 'icons',

        # Use this to customize exclusions in the Jekyll site
        'powertools_resolved_exclude',
      ]
    end

    def get_layout_chain(layout_name, site)
      chain = []
      current_layout_name = layout_name
      
      # Traverse up the layout hierarchy
      while current_layout_name
        layout = site.layouts[current_layout_name]
        break unless layout
        
        chain.unshift(layout)  # Add to beginning to maintain parent->child order
        current_layout_name = layout.data['layout']
      end
      
      chain
    end

    def filter_front_matter(data)
      # Jekyll internal properties that shouldn't be in resolved data
      jekyll_internals = [
        'layout', 'permalink', 'published', 'date', 'categories', 'tags',
        'path', 'relative_path', 'collection', 'type', 'id', 'url',
        'next', 'previous', 'draft', 'ext', 'excerpt', 'output'
      ]
      
      filtered = {}
      data.each do |key, value|
        next if jekyll_internals.include?(key)
        filtered[key] = value
      end
      
      filtered
    end

    def inject_data(item, site)
      # Inject a random number into the item's data
      item.data['random_id'] = rand(100) # Random number between 0 and 99

      # Inject the file extension into the item's data
      if item.respond_to?(:path)
        item.data['extension'] = File.extname(item.path)
      end

      # Set resolved data for site, layout, and page
      # Create a deep merge of site -> child layouts -> parent layouts -> page data
      # Priority: page (highest) -> parent layouts -> child layouts -> site (lowest)
      resolved = {}

      # Start with site data
      if site.config
        # Filter site config to exclude large/unnecessary keys
        filtered_config = filter_site_config(site.config)
        resolved = deep_merge(resolved, filtered_config)
      end

      # Merge layout data if available (traverse the entire layout chain)
      if item.data['layout']
        layout_chain = get_layout_chain(item.data['layout'], site)

        # Merge each layout in reverse order (child to parent)
        # This gives parent layouts (base layouts) higher priority
        layout_chain.reverse.each do |layout|
          if layout && layout.data
            # Filter out Jekyll internal layout properties
            layout_data = filter_front_matter(layout.data)
            resolved = deep_merge(resolved, layout_data)
          end
        end

        # Also add layout_data for backward compatibility (immediate layout only)
        immediate_layout = site.layouts[item.data['layout']]
        if immediate_layout && immediate_layout.data
          item.data['layout_data'] = immediate_layout.data
        end
      end

      # Finally merge page data (highest priority)
      # Filter out Jekyll internal properties
      page_data = filter_front_matter(item.data)
      resolved = deep_merge(resolved, page_data)

      # Add the resolved data to the item
      item.data['resolved'] = resolved
    end
  end
end
