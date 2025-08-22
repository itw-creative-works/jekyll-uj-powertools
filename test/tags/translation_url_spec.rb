require_relative '../spec_helper'

RSpec.describe Jekyll::UJTranslationUrlTag do
  let(:site_config) do
    {
      'translation' => {
        'default' => 'en',
        'languages' => ['en', 'es', 'fr', 'de', 'it']
      }
    }
  end

  let(:site) { Jekyll::Site.new(Jekyll.configuration(site_config)) }
  let(:context) do
    ctx = Liquid::Context.new
    ctx.registers[:site] = site
    ctx['page'] = {
      'canonical' => {
        'path' => '/pricing'
      }
    }
    ctx
  end

  def render_tag(markup)
    template = Liquid::Template.parse("{% uj_translation_url #{markup} %}")
    template.render(context)
  end

  describe 'default language handling' do
    it 'returns root path for default language home page' do
      result = render_tag("'en', '/'")
      expect(result).to eq('/')
    end

    it 'returns path without language prefix for default language' do
      result = render_tag("'en', '/pricing'")
      expect(result).to eq('/pricing')
    end
  end

  describe 'non-default language handling' do
    it 'adds language prefix to home page' do
      result = render_tag("'es', '/'")
      expect(result).to eq('/es')
    end

    it 'adds language prefix to other pages' do
      result = render_tag("'es', '/pricing'")
      expect(result).to eq('/es/pricing')
    end

    it 'handles French language' do
      result = render_tag("'fr', '/about'")
      expect(result).to eq('/fr/about')
    end

    it 'handles German language' do
      result = render_tag("'de', '/contact'")
      expect(result).to eq('/de/contact')
    end

    it 'handles Italian language' do
      result = render_tag("'it', '/services'")
      expect(result).to eq('/it/services')
    end
  end

  describe 'variable resolution' do
    it 'resolves both language and path from variables' do
      context['language'] = 'es'
      context['page']['canonical']['path'] = '/pricing'
      
      result = render_tag('language, page.canonical.path')
      expect(result).to eq('/es/pricing')
    end

    it 'resolves language from variable with literal path' do
      context['current_lang'] = 'fr'
      
      result = render_tag("current_lang, '/about'")
      expect(result).to eq('/fr/about')
    end

    it 'resolves path from variable with literal language' do
      context['my_path'] = '/contact'
      
      result = render_tag("'es', my_path")
      expect(result).to eq('/es/contact')
    end

    it 'resolves both from separate variables' do
      context['lang'] = 'de'
      context['url'] = '/services'
      
      result = render_tag('lang, url')
      expect(result).to eq('/de/services')
    end

    it 'resolves nested variable access' do
      context['page'] = { 'lang' => 'it', 'url' => '/portfolio' }
      
      result = render_tag('page.lang, page.url')
      expect(result).to eq('/it/portfolio')
    end
  end

  describe 'path handling' do
    it 'handles path without leading slash' do
      result = render_tag("'de', 'contact'")
      expect(result).to eq('/de/contact')
    end

    it 'handles empty path' do
      result = render_tag("'it', ''")
      expect(result).to eq('/it')
    end

    it 'handles root path with trailing slash' do
      result = render_tag("'es', '/'")
      expect(result).to eq('/es')
    end
  end

  describe 'error handling' do
    it 'falls back to default language for invalid language' do
      result = render_tag("'zh', '/pricing'")
      expect(result).to eq('/pricing')
    end

    it 'handles nil language gracefully' do
      context['null_lang'] = nil
      result = render_tag("null_lang, '/about'")
      expect(result).to eq('/about')
    end

    it 'handles nil path gracefully' do
      context['null_path'] = nil
      result = render_tag("'es', null_path")
      expect(result).to eq('/es')
    end
  end

  describe 'mixed quotes and literals' do
    it 'handles single quotes' do
      result = render_tag("'es', '/pricing'")
      expect(result).to eq('/es/pricing')
    end

    it 'handles double quotes' do
      result = render_tag('"es", "/pricing"')
      expect(result).to eq('/es/pricing')
    end

    it 'handles mixed quotes' do
      result = render_tag(%q{'es', "/pricing"})
      expect(result).to eq('/es/pricing')
    end
  end
end