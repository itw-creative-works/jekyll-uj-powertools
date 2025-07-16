require 'jekyll-uj-powertools'

RSpec.describe Jekyll::InjectData do
  let(:site) do
    double('site', 
      pages: [page], 
      collections: { 'posts' => collection },
      layouts: { 'default' => layout }
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
    double('layout', data: { 'title' => 'Default Layout', 'description' => 'A default layout' })
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
          'description' => 'A default layout'
        })
      end
    end

    context 'when layout does not exist' do
      let(:site_no_layout) do
        double('site', 
          pages: [],
          collections: {},
          layouts: {}
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