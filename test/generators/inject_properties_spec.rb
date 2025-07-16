require 'jekyll-uj-powertools'

RSpec.describe Jekyll::InjectData do
  let(:site) do
    double('site', 
      pages: [page], 
      collections: { 'posts' => collection },
      layouts: { 'default' => layout },
      config: {
        'title' => 'Site Title',
        'description' => 'Site Description',
        'value' => { 'check' => 'site_value' },
        'nested' => { 'foo' => 'site_foo', 'bar' => 'site_bar' },
        'plugins' => ['jekyll-feed', 'jekyll-seo'],  # Should be excluded
        'collections' => { 'posts' => {} }  # Should be excluded
      }
    )
  end

  let(:page) do
    double('page', 
      data: {},
      path: '/path/to/page.html'
    )
  end

  let(:document) do
    double('document',
      data: { 'layout' => 'default' },
      path: '/path/to/post.md'
    )
  end

  let(:collection) do
    double('collection', docs: [document])
  end

  let(:layout) do
    double('layout', data: { 
      'title' => 'Default Layout', 
      'description' => 'A default layout',
      'value' => { 'check' => 'layout_value' },
      'nested' => { 'foo' => 'layout_foo', 'baz' => 'layout_baz' }
    })
  end

  let(:generator) { Jekyll::InjectData.new }

  before do
    # Reset random seed for consistent testing
    srand(1)
  end

  describe '#generate' do
    it 'processes all pages and documents' do
      expect(generator).to receive(:inject_data).with(page, site)
      expect(generator).to receive(:inject_data).with(document, site)
      
      generator.generate(site)
    end
  end

  describe '#inject_data' do
    context 'for a page without layout' do
      before do
        page.data.clear
        generator.send(:inject_data, page, site)
      end

      it 'injects random_id' do
        expect(page.data['random_id']).to be_between(0, 99)
      end

      it 'injects file extension' do
        expect(page.data['extension']).to eq('.html')
      end

      it 'does not inject layout_data when no layout is specified' do
        expect(page.data['layout_data']).to be_nil
      end
    end

    context 'for a document with layout' do
      before do
        document.data.clear
        document.data['layout'] = 'default'
        generator.send(:inject_data, document, site)
      end

      it 'injects random_id' do
        expect(document.data['random_id']).to be_between(0, 99)
      end

      it 'injects file extension' do
        expect(document.data['extension']).to eq('.md')
      end

      it 'injects layout_data from the specified layout' do
        expect(document.data['layout_data']).to eq({
          'title' => 'Default Layout',
          'description' => 'A default layout',
          'value' => { 'check' => 'layout_value' },
          'nested' => { 'foo' => 'layout_foo', 'baz' => 'layout_baz' }
        })
      end
    end

    context 'when layout does not exist' do
      let(:site_no_layout) do
        double('site', 
          pages: [],
          collections: {},
          layouts: {},
          config: {}
        )
      end

      before do
        document.data.clear
        document.data['layout'] = 'nonexistent'
        generator.send(:inject_data, document, site_no_layout)
      end

      it 'does not inject layout_data when layout is not found' do
        expect(document.data['layout_data']).to be_nil
      end
    end

    context 'when item does not respond to path' do
      let(:item_without_path) do
        double('item', data: {})
      end

      before do
        generator.send(:inject_data, item_without_path, site)
      end

      it 'still injects random_id' do
        expect(item_without_path.data['random_id']).to be_between(0, 99)
      end

      it 'does not inject extension when path is not available' do
        expect(item_without_path.data['extension']).to be_nil
      end
    end

    context 'resolved data merging' do
      let(:page_with_data) do
        double('page',
          data: {
            'layout' => 'default',
            'title' => 'Page Title',
            'value' => { 'check' => 'page_value' },
            'nested' => { 'foo' => 'page_foo' }
          },
          path: '/path/to/page.html'
        )
      end

      before do
        generator.send(:inject_data, page_with_data, site)
      end

      it 'creates resolved data with all three levels merged' do
        expect(page_with_data.data['resolved']).to be_a(Hash)
      end

      it 'prioritizes page data over layout and site data' do
        expect(page_with_data.data['resolved']['title']).to eq('Page Title')
        expect(page_with_data.data['resolved']['value']['check']).to eq('page_value')
      end

      it 'falls back to layout data when page data is missing' do
        expect(page_with_data.data['resolved']['description']).to eq('A default layout')
      end

      it 'deep merges nested hashes correctly' do
        resolved_nested = page_with_data.data['resolved']['nested']
        expect(resolved_nested['foo']).to eq('page_foo')  # Page value wins
        expect(resolved_nested['bar']).to eq('site_bar')  # Site value (no override)
        expect(resolved_nested['baz']).to eq('layout_baz')  # Layout value (no override)
      end

      it 'includes all site config in resolved data' do
        # Site-only values should be present
        expect(page_with_data.data['resolved']['title']).to eq('Page Title')  # Overridden
        expect(page_with_data.data['resolved']['description']).to eq('A default layout')  # From layout
      end

      it 'filters out Jekyll internal properties' do
        # Layout and other Jekyll internals should not be in resolved
        expect(page_with_data.data['resolved']['layout']).to be_nil
        expect(page_with_data.data['resolved']['path']).to be_nil
      end
    end

    context 'resolved data without layout' do
      let(:page_no_layout) do
        double('page',
          data: {
            'title' => 'Page Without Layout',
            'custom' => 'page_custom'
          },
          path: '/path/to/page.html'
        )
      end

      before do
        generator.send(:inject_data, page_no_layout, site)
      end

      it 'creates resolved data even without layout' do
        expect(page_no_layout.data['resolved']).to be_a(Hash)
      end

      it 'merges site and page data without layout data' do
        expect(page_no_layout.data['resolved']['title']).to eq('Page Without Layout')
        expect(page_no_layout.data['resolved']['custom']).to eq('page_custom')
        expect(page_no_layout.data['resolved']['description']).to eq('Site Description')  # From site
      end
    end

    context 'site config filtering' do
      let(:page_for_filtering) do
        double('page',
          data: { 'layout' => 'default' },
          path: '/path/to/page.html'
        )
      end

      before do
        generator.send(:inject_data, page_for_filtering, site)
      end

      it 'excludes Jekyll internal keys from resolved data' do
        expect(page_for_filtering.data['resolved']['plugins']).to be_nil
        expect(page_for_filtering.data['resolved']['collections']).to be_nil
      end

      it 'includes non-excluded site config keys' do
        # Title comes from layout which overrides site
        expect(page_for_filtering.data['resolved']['title']).to eq('Default Layout')
        # Value comes from layout which overrides site
        expect(page_for_filtering.data['resolved']['value']['check']).to eq('layout_value')
        # This comes from site config (not in layout)
        expect(page_for_filtering.data['resolved']['nested']['bar']).to eq('site_bar')
      end
    end

    context 'custom exclusions' do
      let(:site_with_exclusions) do
        double('site',
          pages: [],
          collections: {},
          layouts: {},
          config: {
            'title' => 'Site Title',
            'custom_data' => 'Should be excluded',
            'keep_this' => 'Should be kept',
            'powertools_resolved_exclude' => ['custom_data', 'plugins']
          }
        )
      end

      let(:page_with_exclusions) do
        double('page',
          data: {},
          path: '/path/to/page.html'
        )
      end

      before do
        generator.send(:inject_data, page_with_exclusions, site_with_exclusions)
      end

      it 'uses custom exclusion list from config' do
        expect(page_with_exclusions.data['resolved']['custom_data']).to be_nil
        expect(page_with_exclusions.data['resolved']['keep_this']).to eq('Should be kept')
        expect(page_with_exclusions.data['resolved']['powertools_resolved_exclude']).to be_nil
      end
    end

    context 'layout chain traversal' do
      let(:base_layout) do
        double('base_layout', data: {
          'title' => 'Base Layout',
          'theme' => { 'nav' => { 'enabled' => true } }
        })
      end

      let(:middle_layout) do
        double('middle_layout', data: {
          'layout' => 'base',
          'title' => 'Middle Layout',
          'theme' => { 'main' => { 'class' => 'container' } }
        })
      end

      let(:site_with_chain) do
        double('site',
          pages: [],
          collections: {},
          layouts: { 
            'base' => base_layout,
            'middle' => middle_layout,
            'default' => layout
          },
          config: { 'title' => 'Site Title' }
        )
      end

      let(:page_with_chain) do
        double('page',
          data: {
            'layout' => 'middle',
            'title' => 'Page with Chain',
            'theme' => { 'test' => 'test_value' }
          },
          path: '/path/to/page.html'
        )
      end

      before do
        # Update middle layout to have proper chain
        allow(site_with_chain.layouts['middle']).to receive(:data).and_return({
          'layout' => 'base',
          'title' => 'Middle Layout',
          'theme' => { 'main' => { 'class' => 'container' } }
        })
        
        generator.send(:inject_data, page_with_chain, site_with_chain)
      end

      it 'traverses the entire layout chain' do
        resolved_theme = page_with_chain.data['resolved']['theme']
        
        # From base layout
        expect(resolved_theme['nav']['enabled']).to eq(true)
        
        # From middle layout
        expect(resolved_theme['main']['class']).to eq('container')
        
        # From page
        expect(resolved_theme['test']).to eq('test_value')
      end

      it 'respects precedence in layout chain' do
        # Page title should override all layouts
        expect(page_with_chain.data['resolved']['title']).to eq('Page with Chain')
      end

      it 'gives parent layouts priority over child layouts' do
        # When a child and parent layout define the same key,
        # the parent (base) layout should win
        # In this test, both middle and base have 'title', 
        # but base should win (if page didn't override)
        page_no_override = double('page',
          data: {
            'layout' => 'middle',
            'theme' => { 'test' => 'test_value' }
          },
          path: '/path/to/page.html'
        )
        
        generator.send(:inject_data, page_no_override, site_with_chain)
        
        # Base layout's title should win over middle layout's title
        expect(page_no_override.data['resolved']['title']).to eq('Base Layout')
      end
    end
  end

  describe 'generator configuration' do
    it 'is marked as safe' do
      expect(Jekyll::InjectData.safe).to be true
    end

    it 'has low priority' do
      expect(Jekyll::InjectData.priority).to eq(:low)
    end
  end
end