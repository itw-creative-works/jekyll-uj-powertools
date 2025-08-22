require_relative '../spec_helper'

RSpec.describe Jekyll::UJLanguageTag do
  let(:site) { Jekyll::Site.new(Jekyll.configuration()) }
  let(:context) { Liquid::Context.new({}, {}, { site: site }) }

  def render_tag(markup)
    template = Liquid::Template.parse("{% uj_language #{markup} %}")
    template.render(context)
  end

  describe 'basic language conversion' do
    it 'converts ISO code to English language name' do
      result = render_tag('de')
      expect(result).to eq('German')
    end

    it 'converts ISO code to English language name with explicit english parameter' do
      result = render_tag('de, english')
      expect(result).to eq('German')
    end

    it 'converts ISO code to native language name' do
      result = render_tag('de, native')
      expect(result).to eq('Deutsch')
    end

    it 'handles multiple language codes correctly' do
      expect(render_tag('fr')).to eq('French')
      expect(render_tag('fr, native')).to eq('français')
      expect(render_tag('es')).to eq('Spanish')
      expect(render_tag('es, native')).to eq('español')
      expect(render_tag('ja')).to eq('Japanese')
      expect(render_tag('ja, native')).to eq('日本語')
    end
  end

  describe 'quoted parameters' do
    it 'handles quoted ISO codes' do
      result = render_tag('"de"')
      expect(result).to eq('German')
    end

    it 'handles quoted ISO codes with quoted output type' do
      result = render_tag('"de", "native"')
      expect(result).to eq('Deutsch')
    end

    it 'handles single-quoted parameters' do
      result = render_tag("'fr', 'native'")
      expect(result).to eq('français')
    end

    it 'handles mixed quoted and unquoted parameters' do
      result = render_tag('"es", native')
      expect(result).to eq('español')
    end
  end

  describe 'variable resolution' do
    it 'resolves ISO code from context variable' do
      context['myLang'] = 'fr'
      template = Liquid::Template.parse("{% uj_language myLang %}")
      result = template.render(context)
      expect(result).to eq('French')
    end

    it 'resolves ISO code from context variable with output type' do
      context['myLang'] = 'ja'
      template = Liquid::Template.parse("{% uj_language myLang, native %}")
      result = template.render(context)
      expect(result).to eq('日本語')
    end

    it 'resolves nested variable access' do
      context['page'] = { 'language' => 'es' }
      template = Liquid::Template.parse("{% uj_language page.language, native %}")
      result = template.render(context)
      expect(result).to eq('español')
    end

    it 'treats quoted strings as literals even if variable exists' do
      context['de'] = 'fr'  # Variable that would conflict
      template = Liquid::Template.parse("{% uj_language 'de' %}")
      result = template.render(context)
      expect(result).to eq('German')  # Should use 'de' literal, not variable value 'fr'
    end

    it 'resolves unquoted names as variables when they exist' do
      context['langCode'] = 'it'
      template = Liquid::Template.parse("{% uj_language langCode %}")
      result = template.render(context)
      expect(result).to eq('Italian')
    end

    it 'falls back to literal string when variable not found' do
      template = Liquid::Template.parse("{% uj_language de %}")
      result = template.render(context)
      expect(result).to eq('German')  # Should treat 'de' as literal
    end

    it 'treats non-string resolved values as literal' do
      context['de'] = { 'country' => 'Germany' }  # Non-string value
      template = Liquid::Template.parse("{% uj_language de %}")
      result = template.render(context)
      expect(result).to eq('German')  # Should fall back to literal 'de'
    end
  end

  describe 'case insensitive handling' do
    it 'handles uppercase ISO codes' do
      result = render_tag('DE')
      expect(result).to eq('German')
    end

    it 'handles mixed case ISO codes' do
      result = render_tag('De, Native')
      expect(result).to eq('Deutsch')
    end

    it 'handles uppercase output type' do
      result = render_tag('fr, NATIVE')
      expect(result).to eq('français')
    end
  end

  describe 'edge cases' do
    it 'returns original code when ISO code not found' do
      result = render_tag('xx')
      expect(result).to eq('xx')
    end

    it 'handles extra spaces in markup' do
      result = render_tag('de ,  native')
      expect(result).to eq('Deutsch')
    end

    it 'handles empty output type parameter' do
      result = render_tag('de,')
      expect(result).to eq('German')  # Should default to english
    end

    it 'handles only ISO code parameter' do
      result = render_tag('fr')
      expect(result).to eq('French')  # Should default to english
    end

    it 'strips quotes from variable values containing quoted strings' do
      context['lang'] = "'de'"
      template = Liquid::Template.parse("{% uj_language lang, native %}")
      result = template.render(context)
      expect(result).to eq('Deutsch')
    end

    it 'strips double quotes from variable values' do
      context['lang'] = '"es"'
      template = Liquid::Template.parse("{% uj_language lang %}")
      result = template.render(context)
      expect(result).to eq('Spanish')
    end
  end

  describe 'comprehensive language support' do
    it 'supports common European languages' do
      expect(render_tag('en')).to eq('English')
      expect(render_tag('en, native')).to eq('English')
      expect(render_tag('it')).to eq('Italian')
      expect(render_tag('it, native')).to eq('italiano')
      expect(render_tag('pt')).to eq('Portuguese')
      expect(render_tag('pt, native')).to eq('português')
      expect(render_tag('ru')).to eq('Russian')
      expect(render_tag('ru, native')).to eq('русский')
    end

    it 'supports Asian languages' do
      expect(render_tag('zh')).to eq('Chinese')
      expect(render_tag('zh, native')).to eq('中文')
      expect(render_tag('ko')).to eq('Korean')
      expect(render_tag('ko, native')).to eq('한국어')
      expect(render_tag('hi')).to eq('Hindi')
      expect(render_tag('hi, native')).to eq('हिन्दी')
    end

    it 'supports African and Middle Eastern languages' do
      expect(render_tag('ar')).to eq('Arabic')
      expect(render_tag('ar, native')).to eq('العربية')
      expect(render_tag('sw')).to eq('Swahili')
      expect(render_tag('sw, native')).to eq('Kiswahili')
      expect(render_tag('he')).to eq('Hebrew')
      expect(render_tag('he, native')).to eq('עברית')
    end

    it 'supports Nordic languages' do
      expect(render_tag('da')).to eq('Danish')
      expect(render_tag('da, native')).to eq('dansk')
      expect(render_tag('sv')).to eq('Swedish')
      expect(render_tag('sv, native')).to eq('svenska')
      expect(render_tag('no')).to eq('Norwegian')
      expect(render_tag('no, native')).to eq('Norsk')
    end
  end

  describe 'argument parsing' do
    it 'parses arguments with commas inside quotes correctly' do
      # This shouldn't be a common case for language codes, but test parsing robustness
      result = render_tag('"de", "english"')
      expect(result).to eq('German')
    end

    it 'handles arguments without spaces around comma' do
      result = render_tag('fr,native')
      expect(result).to eq('français')
    end

    it 'handles arguments with multiple spaces' do
      result = render_tag('es  ,   native')
      expect(result).to eq('español')
    end
  end
end