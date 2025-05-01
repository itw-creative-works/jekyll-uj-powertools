require "jekyll"

module Jekyll
  module UJPowertools
    # Initialize a timestamp that will remain consistent across calls
    @cache_timestamp = Time.now.to_i.to_s

    # Strip ads from the input
    def uj_strip_ads(input)
      input
        # Remove HTML <ad-units>
        .gsub(/\s*<ad-unit>[\s\S]*?<\/ad-unit>\s*/m, '')
        # Remove includes starting with "/master/modules/adunits/"
        .gsub(/\s*\{% include \/master\/modules\/adunits\/.*? %\}\s*/m, '')
    end

    # Escape a string for use in JSON
    # def uj_json_escape(value)
    #   value
    #     .gsub('\\', '\\\\')  # Escape backslashes
    #     .gsub('"', '\"')     # Escape double quotes
    #     .gsub("\b", '\\b')   # Escape backspace
    #     .gsub("\f", '\\f')   # Escape formfeed
    #     .gsub("\n", '\\n')   # Escape newline
    #     .gsub("\r", '\\r')   # Escape carriage return
    #     .gsub("\t", '\\t')   # Escape tab
    # end
    def uj_json_escape(value)
      value.to_json[1..-2]  # Convert to JSON and remove the surrounding quotes
    end

    # Increment a global counter that can be accessed from any page then return the new value
    # def uj_increment_return(input)
    #   @context.registers[:uj_incremental_return] ||= 0
    #   @context.registers[:uj_incremental_return]
    #   @context.registers[:uj_incremental_return] += input
    # end
    def uj_increment_return(input)
      @context ||= { registers: {} }
      @context[:registers][:uj_incremental_return] ||= 0
      @context[:registers][:uj_incremental_return] += input
    end

    # Return a random number between 0 and the input
    def uj_random(input)
      rand(input)
    end

    # Return the current year
    def uj_year(input)
      Time.now.year
    end

    # Title case
    def uj_title_case(input)
      input.split(' ').map(&:capitalize).join(' ')
    end

    # Accessor for the consistent timestamp
    def self.cache_timestamp
      @cache_timestamp
    end
  end

  # Set a global cache buster timestamp
  # class CacheBreakerGenerator < Jekyll::Generator
  #   safe true
  #   priority :highest

  #   def generate(site)
  #     # Define a global variable accessible in templates
  #     site.config['cache_breaker2'] = Time.now.to_i.to_s
  #   end
  # end

  # Inject data into pages and documents
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

# Register the filter
Liquid::Template.register_filter(Jekyll::UJPowertools)

# Register hook
Jekyll::Hooks.register :site, :pre_render do |site|
  site.config['uj'] ||= {}
  site.config['uj']['cacheBreaker'] = Jekyll::UJPowertools.cache_timestamp
  site.config['uj']['cache_breaker'] = Jekyll::UJPowertools.cache_timestamp
end
