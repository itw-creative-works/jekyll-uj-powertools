require_relative '../spec_helper'

RSpec.describe Jekyll::UJPowertools::ExternalTag do
  let(:site) { Jekyll::Site.new(Jekyll::Configuration::DEFAULTS.merge('url' => 'https://example.com')) }
  let(:context) { Liquid::Context.new({}, {}, { site: site }) }
  
  def render_tag(markup)
    template = Liquid::Template.parse("{% uj_external #{markup} %}")
    template.render(context)
  end
  
  describe '#render' do
    context 'with relative path' do
      it 'adds site URL to relative path' do
        result = render_tag('"/assets/image.jpg"')
        expect(result).to eq('https://example.com/assets/image.jpg')
      end
      
      it 'adds site URL to path without leading slash' do
        result = render_tag('"assets/image.jpg"')
        expect(result).to eq('https://example.com/assets/image.jpg')
      end
    end
    
    context 'with absolute URL' do
      it 'returns https URL as-is' do
        result = render_tag('"https://cdn.example.com/image.jpg"')
        expect(result).to eq('https://cdn.example.com/image.jpg')
      end
      
      it 'returns http URL as-is' do
        result = render_tag('"http://cdn.example.com/image.jpg"')
        expect(result).to eq('http://cdn.example.com/image.jpg')
      end
    end
    
    context 'with protocol-relative URL' do
      it 'returns protocol-relative URL as-is' do
        result = render_tag('"//cdn.example.com/image.jpg"')
        expect(result).to eq('//cdn.example.com/image.jpg')
      end
    end
    
    context 'with variable input' do
      it 'resolves variable and adds site URL' do
        context['image_path'] = '/assets/photo.png'
        result = render_tag('image_path')
        expect(result).to eq('https://example.com/assets/photo.png')
      end
      
      it 'resolves nested variable' do
        context['page'] = { 'image' => '/uploads/banner.jpg' }
        result = render_tag('page.image')
        expect(result).to eq('https://example.com/uploads/banner.jpg')
      end
    end
    
    context 'with site URL variations' do
      it 'handles site URL with trailing slash' do
        site.config['url'] = 'https://example.com/'
        result = render_tag('"/assets/image.jpg"')
        expect(result).to eq('https://example.com/assets/image.jpg')
      end
      
      it 'handles missing site URL' do
        site.config['url'] = nil
        result = render_tag('"/assets/image.jpg"')
        expect(result).to eq('/assets/image.jpg')
      end
    end
    
    context 'with empty or nil input' do
      it 'returns empty string for empty input' do
        result = render_tag('""')
        expect(result).to eq('')
      end
      
      it 'returns empty string for nil variable' do
        context['undefined_var'] = nil
        result = render_tag('undefined_var')
        expect(result).to eq('')
      end
    end
  end
end