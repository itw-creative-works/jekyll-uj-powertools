require_relative '../spec_helper'

RSpec.describe Jekyll::UJImageTag do
  let(:site_config) { {} }
  let(:site) { Jekyll::Site.new(Jekyll.configuration(site_config)) }
  let(:context) { Liquid::Context.new({}, {}, { site: site }) }

  def render_tag(markup)
    template = Liquid::Template.parse("{% uj_image #{markup} %}")
    template.render(context)
  end

  describe 'local image rendering' do
    it 'renders a picture element for local images' do
      result = render_tag('"/assets/images/test.jpg", alt="Test image", class="img-fluid"')
      expect(result).to include('<picture>')
      expect(result).to include('</picture>')
      expect(result).to include('<img')
      expect(result).to include('alt="Test image"')
      expect(result).to include('class="img-fluid"')
    end

    it 'includes WebP sources for local images by default' do
      result = render_tag('"/assets/images/test.jpg"')
      expect(result).to include('type="image/webp"')
      expect(result).to include('-320px.webp')
      expect(result).to include('-640px.webp')
      expect(result).to include('-1024px.webp')
    end

    it 'respects max_width option for local images' do
      result = render_tag('"/assets/images/test.jpg", max_width="640"')
      expect(result).to include('-320px.webp')
      expect(result).to include('-640px.webp')
      expect(result).not_to include('-1024px.webp')
    end

    it 'excludes WebP when disabled' do
      result = render_tag('"/assets/images/test.jpg", webp="false"')
      expect(result).not_to include('type="image/webp"')
      expect(result).to include('<picture>')
    end
  end

  describe 'external URL rendering' do
    it 'renders a single img tag for external URLs' do
      result = render_tag('"https://example.com/image.jpg", alt="External image", class="img-fluid rounded"')
      
      # Should be a single line
      expect(result.lines.count).to eq(1)
      
      # Should contain all necessary attributes
      expect(result).to include('<img')
      expect(result).to include('>')
      expect(result).to include('data-lazy="@src https://example.com/image.jpg"')
      expect(result).to include('alt="External image"')
      expect(result).to include('class="img-fluid rounded"')
      expect(result).to include('loading="lazy"')
      
      # Should NOT contain picture element
      expect(result).not_to include('<picture')
      expect(result).not_to include('</picture>')
    end

    it 'generates valid single-line HTML for external URLs' do
      result = render_tag('"https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800&q=80", alt="Unsplash photo", class="w-100"')
      
      # Verify it's a single line
      expect(result.lines.count).to eq(1)
      
      # Verify it starts with <img and ends with >
      expect(result).to match(/^<img.*>$/)
      
      # Should not have newlines within the tag
      expect(result).not_to include("\n")
    end

    it 'handles external URLs with query parameters' do
      result = render_tag('"https://example.com/image.jpg?w=1200&q=80", alt="Image with params"')
      expect(result).to include('data-lazy="@src https://example.com/image.jpg?w=1200&q=80"')
    end

    it 'includes placeholder src for lazy loading' do
      result = render_tag('"https://example.com/image.jpg"')
      expect(result).to include('src="data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw=="')
    end

    it 'handles all optional attributes for external URLs' do
      result = render_tag('"https://example.com/image.jpg", alt="Test", class="my-class", style="width: 100%;", width="800", height="600"')
      expect(result).to include('alt="Test"')
      expect(result).to include('class="my-class"')
      expect(result).to include('style="width: 100%;"')
      expect(result).to include('width="800"')
      expect(result).to include('height="600"')
    end

    it 'handles custom loading attribute' do
      result = render_tag('"https://example.com/image.jpg", loading="eager"')
      expect(result).to include('loading="eager"')
    end
  end

  describe 'URL detection' do
    it 'correctly identifies HTTP URLs as external' do
      result = render_tag('"http://example.com/image.jpg"')
      expect(result).not_to include('<picture')
      expect(result).to include('<img')
    end

    it 'correctly identifies HTTPS URLs as external' do
      result = render_tag('"https://example.com/image.jpg"')
      expect(result).not_to include('<picture')
      expect(result).to include('<img')
    end

    it 'treats relative paths as local' do
      result = render_tag('"/assets/images/local.jpg"')
      expect(result).to include('<picture>')
    end

    it 'treats absolute paths without protocol as local' do
      result = render_tag('"/var/www/images/local.jpg"')
      expect(result).to include('<picture>')
    end
  end

  describe 'variable resolution' do
    it 'resolves variables for image source' do
      context['myImage'] = '/assets/images/dynamic.jpg'
      template = Liquid::Template.parse("{% uj_image myImage, alt='Dynamic image' %}")
      result = template.render(context)
      expect(result).to include('data-lazy="@src /assets/images/dynamic.jpg"')
    end

    it 'resolves nested variables' do
      context['page'] = { 'hero' => { 'image' => 'https://example.com/hero.jpg' } }
      template = Liquid::Template.parse("{% uj_image page.hero.image, alt='Hero' %}")
      result = template.render(context)
      expect(result).to include('data-lazy="@src https://example.com/hero.jpg"')
    end
  end

  describe 'argument parsing' do
    it 'handles arguments with commas in values' do
      result = render_tag('"/assets/test.jpg", alt="Test, with comma", class="img-fluid"')
      expect(result).to include('alt="Test, with comma"')
    end

    it 'handles single quotes' do
      result = render_tag("'/assets/test.jpg', alt='Single quotes'")
      expect(result).to include('alt="Single quotes"')
    end

    it 'handles mixed quotes' do
      result = render_tag(%q{"/assets/test.jpg", alt='Mixed quotes', class="test-class"})
      expect(result).to include('alt="Mixed quotes"')
      expect(result).to include('class="test-class"')
    end
  end
end