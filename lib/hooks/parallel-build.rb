# Parallel Build Generator
# Speeds up Jekyll builds by rendering pages and documents in parallel
#
# This runs as a Generator with :lowest priority to ensure it processes
# all pages AFTER other generators (like DynamicPages) have created them.
#
# Configuration in _config.yml:
#
#   parallel_build:
#     enabled: true          # Enable/disable parallel builds (default: true)
#     threads: 8             # Number of threads (default: number of CPU cores)
#     min_items: 1           # Minimum items before parallelizing (default: 1)
#
# Note: Parallel builds work best with CPU-bound rendering.
# Some Liquid tags may not be thread-safe - if you encounter issues,
# disable with `parallel_build: false` or `parallel_build.enabled: false`

require 'parallel'

module Jekyll
  class ParallelBuildGenerator < Generator
    safe true
    priority :lowest  # Run AFTER all other generators

    def generate(site)
      config = site.config['parallel_build']

      # Handle both `parallel_build: false` and `parallel_build.enabled: false`
      if config == false
        Jekyll.logger.info "ParallelBuild:", "Disabled via config"
        return
      end

      config = {} if config.nil? || config == true
      return unless config.fetch('enabled', true)

      threads = config.fetch('threads', Parallel.processor_count)
      min_items = config.fetch('min_items', 1)

      # Render documents in parallel (posts, collections)
      render_documents_parallel(site, threads, min_items)

      # Render pages in parallel
      render_pages_parallel(site, threads, min_items)
    end

    private

    def render_documents_parallel(site, threads, min_items)
      # Collect all documents that need rendering
      documents = site.collections.flat_map do |_name, collection|
        collection.docs.select { |doc| doc.respond_to?(:render) && !doc.data['rendered_parallel'] }
      end

      return if documents.size < min_items

      Jekyll.logger.info "ParallelBuild:", "Rendering #{documents.size} documents with #{threads} threads..."

      start_time = Time.now

      # Pre-render: prepare payload and info for each document
      # We need to do the actual Liquid rendering in parallel
      Parallel.each(documents, in_threads: threads) do |doc|
        begin
          # Mark as rendered to avoid double-rendering
          doc.data['rendered_parallel'] = true

          # Render content through Liquid
          if doc.content && !doc.content.empty?
            payload = site.site_payload
            info = {
              filters: [Jekyll::Filters],
              registers: {
                site: site,
                page: doc.to_liquid
              }
            }

            # Parse and render Liquid template
            template = site.liquid_renderer.file(doc.path).parse(doc.content)
            doc.content = template.render!(payload, info)
          end
        rescue => e
          Jekyll.logger.warn "ParallelBuild:", "Error rendering #{doc.relative_path}: #{e.message}"
        end
      end

      elapsed = Time.now - start_time
      Jekyll.logger.info "ParallelBuild:", "Documents rendered in #{elapsed.round(2)}s"
    end

    def render_pages_parallel(site, threads, min_items)
      # Get all pages (including dynamically generated ones without content)
      pages = site.pages.reject { |page| page.data['rendered_parallel'] }

      return if pages.size < min_items

      Jekyll.logger.info "ParallelBuild:", "Rendering #{pages.size} pages with #{threads} threads..."

      start_time = Time.now

      Parallel.each(pages, in_threads: threads) do |page|
        begin
          page.data['rendered_parallel'] = true

          # Only render if there's content to process
          if page.content && !page.content.empty?
            payload = site.site_payload
            info = {
              filters: [Jekyll::Filters],
              registers: {
                site: site,
                page: page.to_liquid
              }
            }

            template = site.liquid_renderer.file(page.path).parse(page.content)
            page.content = template.render!(payload, info)
          end
        rescue => e
          Jekyll.logger.warn "ParallelBuild:", "Error rendering #{page.name}: #{e.message}"
        end
      end

      elapsed = Time.now - start_time
      Jekyll.logger.info "ParallelBuild:", "Pages rendered in #{elapsed.round(2)}s"
    end
  end
end
