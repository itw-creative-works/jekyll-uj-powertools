require_relative '../spec_helper'

RSpec.describe Jekyll::UJIconTag do
  let(:site_config) do
    {
      'icons' => {
        'style' => 'solid'
      }
    }
  end

  let(:site) { Jekyll::Site.new(Jekyll.configuration(site_config)) }
  let(:context) { Liquid::Context.new({}, {}, { site: site }) }

  def render_tag(markup)
    template = Liquid::Template.parse("{% uj_icon #{markup} %}")
    template.render(context)
  end

  before do
    # Clear icon cache between tests
    Jekyll::UJIconTag.class_variable_set(:@@icon_cache, {})

    # Mock file system for icon files
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:read).and_call_original

    # Mock award icon (without the attributes we'll inject)
    award_path = File.join(Dir.pwd, 'node_modules', 'ultimate-jekyll-manager', 'assets', 'icons', 'font-awesome', 'solid', 'award.svg')
    allow(File).to receive(:exist?).with(award_path).and_return(true)
    allow(File).to receive(:read).with(award_path).and_return('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 384 512">AWARD_SVG_DATA</svg>')

    # Mock star icon (without the attributes we'll inject)
    star_path = File.join(Dir.pwd, 'node_modules', 'ultimate-jekyll-manager', 'assets', 'icons', 'font-awesome', 'solid', 'star.svg')
    allow(File).to receive(:exist?).with(star_path).and_return(true)
    allow(File).to receive(:read).with(star_path).and_return('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 576 512">STAR_SVG_DATA</svg>')

    # Mock download icon for specific tests
    download_path = File.join(Dir.pwd, 'node_modules', 'ultimate-jekyll-manager', 'assets', 'icons', 'font-awesome', 'solid', 'download.svg')
    allow(File).to receive(:exist?).with(download_path).and_return(true)
    allow(File).to receive(:read).with(download_path).and_return('<svg>DOWNLOAD_ICON</svg>')

    # Mock nonexistent icon
    nonexistent_path = File.join(Dir.pwd, 'node_modules', 'ultimate-jekyll-manager', 'assets', 'icons', 'font-awesome', 'solid', 'nonexistent.svg')
    allow(File).to receive(:exist?).with(nonexistent_path).and_return(false)
    nonexistent_brands_path = File.join(Dir.pwd, 'node_modules', 'ultimate-jekyll-manager', 'assets', 'icons', 'font-awesome', 'brands', 'nonexistent.svg')
    allow(File).to receive(:exist?).with(nonexistent_brands_path).and_return(false)
    nonexistent_flag_path = File.join(Dir.pwd, 'node_modules', 'ultimate-jekyll-manager', 'assets', 'icons', 'flags', 'modern-square', 'nonexistent.svg')
    allow(File).to receive(:exist?).with(nonexistent_flag_path).and_return(false)

    # Mock brand icon that only exists in brands folder
    github_solid_path = File.join(Dir.pwd, 'node_modules', 'ultimate-jekyll-manager', 'assets', 'icons', 'font-awesome', 'solid', 'github.svg')
    allow(File).to receive(:exist?).with(github_solid_path).and_return(false)
    github_brands_path = File.join(Dir.pwd, 'node_modules', 'ultimate-jekyll-manager', 'assets', 'icons', 'font-awesome', 'brands', 'github.svg')
    allow(File).to receive(:exist?).with(github_brands_path).and_return(true)
    allow(File).to receive(:read).with(github_brands_path).and_return('<svg>GITHUB_BRAND_ICON</svg>')

    # Mock flag icons
    us_flag_path = File.join(Dir.pwd, 'node_modules', 'ultimate-jekyll-manager', 'assets', 'icons', 'flags', 'modern-square', 'us.svg')
    allow(File).to receive(:exist?).with(us_flag_path).and_return(true)
    allow(File).to receive(:read).with(us_flag_path).and_return('<svg>US_FLAG_ICON</svg>')

    gb_flag_path = File.join(Dir.pwd, 'node_modules', 'ultimate-jekyll-manager', 'assets', 'icons', 'flags', 'modern-square', 'gb.svg')
    allow(File).to receive(:exist?).with(gb_flag_path).and_return(true)
    allow(File).to receive(:read).with(gb_flag_path).and_return('<svg>GB_FLAG_ICON</svg>')

    # Mock some flags that don't exist directly but should be found via language mapping
    en_flag_path = File.join(Dir.pwd, 'node_modules', 'ultimate-jekyll-manager', 'assets', 'icons', 'flags', 'modern-square', 'en.svg')
    allow(File).to receive(:exist?).with(en_flag_path).and_return(false)

    es_flag_path = File.join(Dir.pwd, 'node_modules', 'ultimate-jekyll-manager', 'assets', 'icons', 'flags', 'modern-square', 'es.svg')
    allow(File).to receive(:exist?).with(es_flag_path).and_return(true)
    allow(File).to receive(:read).with(es_flag_path).and_return('<svg>ES_FLAG_ICON</svg>')
  end

  describe 'basic icon rendering' do
    it 'renders an icon without classes' do
      result = render_tag('award')
      expect(result).to include('<i class="fa">')
      expect(result).to include('</i>')
      expect(result).to include('<svg')
      expect(result).to include('width="1em"')
      expect(result).to include('height="1em"')
      expect(result).to include('AWARD_SVG_DATA')
    end

    it 'renders default icon when icon does not exist' do
      result = render_tag('nonexistent')
      expect(result).to include('Font Awesome Free v7.0.0')
    end

    it 'renders different icons correctly' do
      award_result = render_tag('award')
      star_result = render_tag('star')

      expect(award_result).to include('AWARD_SVG_DATA')
      expect(star_result).to include('STAR_SVG_DATA')
    end
  end

  describe 'CSS classes' do
    it 'renders with single CSS class' do
      result = render_tag('award, fa-md')
      expect(result).to include('<i class="fa fa-md">')
      expect(result).to include('AWARD_SVG_DATA')
    end

    it 'renders with multiple CSS classes' do
      result = render_tag('award, "fa-md me-2"')
      expect(result).to include('<i class="fa fa-md me-2">')
      expect(result).to include('AWARD_SVG_DATA')
    end

    it 'renders with multiple CSS classes including Bootstrap utilities' do
      result = render_tag("award, 'fa-lg text-primary ms-3'")
      expect(result).to include('<i class="fa fa-lg text-primary ms-3">')
      expect(result).to include('AWARD_SVG_DATA')
    end
  end

  describe 'edge cases' do
    it 'handles extra spaces in markup' do
      result = render_tag('award ,  "fa-lg me-2"')
      expect(result).to include('<i class="fa fa-lg me-2">')
    end

    it 'handles no CSS classes gracefully' do
      result = render_tag('award,')
      expect(result).to match(%r{^<i class="fa"><svg.*AWARD_SVG_DATA.*</svg></i>$})
    end

    it 'handles empty CSS classes' do
      result = render_tag('award, ')
      expect(result).to match(%r{^<i class="fa"><svg.*AWARD_SVG_DATA.*</svg></i>$})
    end

    it 'returns default icon when icon file does not exist' do
      # This test already covers the nonexistent icon case
      result = render_tag('nonexistent')
      expect(result).to include('Font Awesome Free v7.0.0')
    end
  end

  describe 'variable resolution' do
    it 'resolves icon name from context variable' do
      context['myVariable'] = 'award'
      template = Liquid::Template.parse("{% uj_icon myVariable %}")
      result = template.render(context)
      expect(result).to match(%r{^<i class="fa"><svg.*AWARD_SVG_DATA.*</svg></i>$})
    end

    it 'resolves icon name from context variable with CSS classes' do
      context['myVariable'] = 'star'
      template = Liquid::Template.parse("{% uj_icon myVariable, 'fa-2xl text-warning' %}")
      result = template.render(context)
      expect(result).to include('<i class="fa fa-2xl text-warning">')
      expect(result).to include('STAR_SVG_DATA')
    end

    it 'falls back to literal string when variable not found' do
      # Clear any existing variables
      context['award'] = nil
      template = Liquid::Template.parse("{% uj_icon award %}")
      result = template.render(context)
      expect(result).to match(%r{^<i class="fa"><svg.*AWARD_SVG_DATA.*</svg></i>$})
    end

    it 'handles nested variable access' do
      context['page'] = { 'icon' => 'star' }
      template = Liquid::Template.parse("{% uj_icon page.icon, 'fa-lg me-2' %}")
      result = template.render(context)
      expect(result).to include('<i class="fa fa-lg me-2">')
      expect(result).to include('STAR_SVG_DATA')
    end

    it 'treats quoted strings as literals even if variable exists' do
      # Create a context variable that would conflict
      context['download'] = { 'mac' => 'url1', 'windows' => 'url2' }

      # Using quotes should use 'download' as icon name, not the variable
      template = Liquid::Template.parse("{% uj_icon 'download', 'fa-lg' %}")

      result = template.render(context)
      expect(result).to include('<i class="fa fa-lg">')
      expect(result).to include('DOWNLOAD_ICON')
    end

    it 'resolves unquoted names as variables when they exist' do
      # Set up variable
      context['iconName'] = 'star'

      # Without quotes, should resolve variable
      template = Liquid::Template.parse("{% uj_icon iconName %}")
      result = template.render(context)
      expect(result).to include('STAR_SVG_DATA')
    end

    it 'treats non-string resolved values as literal icon names' do
      # Variable resolves to non-string
      context['download'] = { 'mac' => 'url1', 'windows' => 'url2' }

      # Without quotes, resolves to object, so should fall back to literal 'download'
      template = Liquid::Template.parse("{% uj_icon download %}")
      result = template.render(context)
      expect(result).to include('DOWNLOAD_ICON')
    end
  end

  describe 'SVG integrity' do
    it 'preserves all SVG attributes and injects required ones' do
      result = render_tag('award, "fa-lg"')
      expect(result).to include('xmlns="http://www.w3.org/2000/svg"')
      expect(result).to include('width="1em"')
      expect(result).to include('height="1em"')
      expect(result).to include('fill="currentColor"')
      expect(result).to include('viewBox="0 0 384 512"')
    end

    it 'maintains SVG content integrity' do
      result = render_tag('award')
      expect(result).to include('AWARD_SVG_DATA')
    end

    it 'injects attributes into SVG without existing width/height/fill' do
      result = render_tag('award')
      expect(result).to include('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 384 512" width="1em" height="1em" fill="currentColor">')
    end

    it 'does not duplicate attributes if they already exist' do
      # Mock an icon that already has the attributes
      test_path = File.join(Dir.pwd, 'node_modules', 'ultimate-jekyll-manager', 'assets', 'icons', 'font-awesome', 'solid', 'test.svg')
      allow(File).to receive(:exist?).with(test_path).and_return(true)
      allow(File).to receive(:read).with(test_path).and_return('<svg width="2em" height="2em" fill="red" viewBox="0 0 100 100">TEST_DATA</svg>')

      result = render_tag('test')
      # Should keep original attributes, not duplicate
      expect(result).to include('width="2em"')
      expect(result).to include('height="2em"')
      expect(result).to include('fill="red"')
      expect(result).not_to include('width="1em"')
      expect(result).not_to include('fill="currentColor"')
    end
  end

  describe 'HTML output structure' do
    it 'produces valid HTML structure' do
      result = render_tag('award, "fa-2xl me-3"')
      expect(result).to match(%r{^<i class="fa fa-2xl me-3"><svg.*</svg></i>$})
    end

    it 'escapes output properly' do
      # Test that the output doesn't break HTML structure
      result = render_tag('award, "fa-lg"')
      expect(result).not_to include('<<')
      expect(result).not_to include('>>')
      expect(result.scan('<i').length).to eq(1)
      expect(result.scan('</i>').length).to eq(1)
    end
  end

  describe 'brands fallback behavior' do
    it 'falls back to brands style when icon not found in configured style' do
      result = render_tag('github')
      expect(result).to include('GITHUB_BRAND_ICON')
    end

    it 'falls back to brands style with CSS classes' do
      result = render_tag('github, "fa-lg me-2"')
      expect(result).to include('<i class="fa fa-lg me-2">')
      expect(result).to include('GITHUB_BRAND_ICON')
    end

    it 'uses brands style directly when configured' do
      # Change site config to use brands style
      site.config['icons']['style'] = 'brands'

      # Mock a brand icon existing in brands folder
      twitter_brands_path = File.join(Dir.pwd, 'node_modules', 'ultimate-jekyll-manager', 'assets', 'icons', 'font-awesome', 'brands', 'twitter.svg')
      allow(File).to receive(:exist?).with(twitter_brands_path).and_return(true)
      allow(File).to receive(:read).with(twitter_brands_path).and_return('<svg>TWITTER_BRAND_ICON</svg>')

      result = render_tag('twitter')
      expect(result).to include('TWITTER_BRAND_ICON')
    end

    it 'does not check brands fallback when style is already brands' do
      # Change site config to use brands style
      site.config['icons']['style'] = 'brands'

      # This should return default icon, not check other styles
      result = render_tag('nonexistent')
      expect(result).to include('Font Awesome Free v7.0.0')
    end
  end

  describe 'quoted and unquoted arguments' do
    it 'handles unquoted arguments' do
      result = render_tag('award, fa-lg')
      expect(result).to include('<i class="fa fa-lg">')
      expect(result).to include('AWARD_SVG_DATA')
    end

    it 'handles single-quoted arguments' do
      result = render_tag("'award', 'fa-lg me-2'")
      expect(result).to include('<i class="fa fa-lg me-2">')
      expect(result).to include('AWARD_SVG_DATA')
    end

    it 'handles double-quoted arguments' do
      result = render_tag('"award", "fa-lg text-primary"')
      expect(result).to include('<i class="fa fa-lg text-primary">')
      expect(result).to include('AWARD_SVG_DATA')
    end

    it 'handles mixed quoted and unquoted arguments' do
      result = render_tag("'award', fa-lg")
      expect(result).to include('<i class="fa fa-lg">')
      expect(result).to include('AWARD_SVG_DATA')

      result2 = render_tag('award, "fa-sm me-1"')
      expect(result2).to include('<i class="fa fa-sm me-1">')
      expect(result2).to include('AWARD_SVG_DATA')
    end

    it 'handles variables with quoted CSS classes' do
      context['myIcon'] = 'star'
      template = Liquid::Template.parse("{% uj_icon myIcon, 'fa-xl text-warning me-2' %}")
      result = template.render(context)
      expect(result).to include('<i class="fa fa-xl text-warning me-2">')
      expect(result).to include('STAR_SVG_DATA')
    end

    it 'handles quoted variables with unquoted CSS classes' do
      context['action'] = { 'icon' => 'award' }
      template = Liquid::Template.parse("{% uj_icon action.icon, fa-md %}")
      result = template.render(context)
      expect(result).to include('<i class="fa fa-md">')
      expect(result).to include('AWARD_SVG_DATA')
    end

    it 'strips quotes from variable values containing quoted strings' do
      context['icon'] = "'rocket'"
      template = Liquid::Template.parse("{% uj_icon icon, 'fa-lg' %}")

      # Mock the rocket icon
      rocket_path = File.join(Dir.pwd, 'node_modules', 'ultimate-jekyll-manager', 'assets', 'icons', 'font-awesome', 'solid', 'rocket.svg')
      allow(File).to receive(:exist?).with(rocket_path).and_return(true)
      allow(File).to receive(:read).with(rocket_path).and_return('<svg>ROCKET_ICON</svg>')

      result = template.render(context)
      expect(result).to include('<i class="fa fa-lg">')
      expect(result).to include('ROCKET_ICON')
    end

    it 'strips double quotes from variable values' do
      context['icon'] = '"star"'
      template = Liquid::Template.parse("{% uj_icon icon %}")

      result = template.render(context)
      expect(result).to include('STAR_SVG_DATA')
    end

    it 'resolves nested page variables correctly' do
      # Set up nested variable structure like page.my.variable => 'rocket'
      context['page'] = { 'my' => { 'variable' => 'rocket' } }
      template = Liquid::Template.parse("{% uj_icon page.my.variable, 'fa-md me-2' %}")

      # Mock the rocket icon
      rocket_path = File.join(Dir.pwd, 'node_modules', 'ultimate-jekyll-manager', 'assets', 'icons', 'font-awesome', 'solid', 'rocket.svg')
      allow(File).to receive(:exist?).with(rocket_path).and_return(true)
      allow(File).to receive(:read).with(rocket_path).and_return('<svg>ROCKET_ICON</svg>')

      result = template.render(context)
      expect(result).to include('<i class="fa fa-md me-2">')
      expect(result).to include('ROCKET_ICON')
      # Make sure it doesn't try to use the literal variable name
      expect(result).not_to include('page.my.variable')
    end

    it 'fails gracefully when variable cannot be resolved and shows the issue' do
      # Set up a situation where variable resolution fails
      context['page'] = nil  # This will cause resolution to fail
      template = Liquid::Template.parse("{% uj_icon page.my.variable, 'fa-md me-2' %}")

      # Mock the literal path that would be created
      literal_path = File.join(Dir.pwd, 'node_modules', 'ultimate-jekyll-manager', 'assets', 'icons', 'font-awesome', 'solid', 'page.my.variable.svg')
      allow(File).to receive(:exist?).with(literal_path).and_return(false)
      literal_brands_path = File.join(Dir.pwd, 'node_modules', 'ultimate-jekyll-manager', 'assets', 'icons', 'font-awesome', 'brands', 'page.my.variable.svg')
      allow(File).to receive(:exist?).with(literal_brands_path).and_return(false)
      literal_flag_path = File.join(Dir.pwd, 'node_modules', 'ultimate-jekyll-manager', 'assets', 'icons', 'flags', 'modern-square', 'page.my.variable.svg')
      allow(File).to receive(:exist?).with(literal_flag_path).and_return(false)

      result = template.render(context)
      # This should return the default icon since the literal file doesn't exist
      expect(result).to include('Font Awesome Free v7.0.0')
    end
  end

  describe 'flags functionality' do
    it 'renders flag icons using country codes' do
      result = render_tag('us, "fa-lg me-2"')
      expect(result).to include('<i class="fa fa-lg me-2">')
      expect(result).to include('US_FLAG_ICON')
    end

    it 'renders flag icons using different country codes' do
      result = render_tag('gb')
      expect(result).to include('<i class="fa">')
      expect(result).to include('GB_FLAG_ICON')
    end

    it 'translates language codes to country codes for flags' do
      result = render_tag('en, "fa-md"')
      expect(result).to include('<i class="fa fa-md">')
      expect(result).to include('US_FLAG_ICON')  # 'en' maps to 'us'
    end

    it 'handles language codes that map to same country code' do
      result = render_tag('es')
      expect(result).to include('ES_FLAG_ICON')  # 'es' maps to 'es'
    end

    it 'prioritizes FontAwesome icons over flags when both exist' do
      # Mock a case where both FA icon and flag exist
      rocket_fa_path = File.join(Dir.pwd, 'node_modules', 'ultimate-jekyll-manager', 'assets', 'icons', 'font-awesome', 'solid', 'rocket.svg')
      allow(File).to receive(:exist?).with(rocket_fa_path).and_return(true)
      allow(File).to receive(:read).with(rocket_fa_path).and_return('<svg>ROCKET_FA_ICON</svg>')

      rocket_flag_path = File.join(Dir.pwd, 'node_modules', 'ultimate-jekyll-manager', 'assets', 'icons', 'flags', 'modern-square', 'rocket.svg')
      allow(File).to receive(:exist?).with(rocket_flag_path).and_return(true)
      allow(File).to receive(:read).with(rocket_flag_path).and_return('<svg>ROCKET_FLAG_ICON</svg>')

      result = render_tag('rocket')
      expect(result).to include('ROCKET_FA_ICON')
      expect(result).not_to include('ROCKET_FLAG_ICON')
    end

    it 'falls back to flags when FontAwesome icon does not exist' do
      # This test uses 'us' which doesn't exist as FA icon but exists as flag
      result = render_tag('us')
      expect(result).to include('US_FLAG_ICON')
    end

    it 'handles case insensitive language code mapping' do
      # Test with uppercase language code
      result = render_tag('EN')
      expect(result).to include('US_FLAG_ICON')  # 'EN' should map to 'us'
    end

    it 'returns default icon when neither FA nor flag exists' do
      # Mock paths for non-existent icon
      nonexistent_fa_path = File.join(Dir.pwd, 'node_modules', 'ultimate-jekyll-manager', 'assets', 'icons', 'font-awesome', 'solid', 'fakecountry.svg')
      allow(File).to receive(:exist?).with(nonexistent_fa_path).and_return(false)
      nonexistent_brands_path = File.join(Dir.pwd, 'node_modules', 'ultimate-jekyll-manager', 'assets', 'icons', 'font-awesome', 'brands', 'fakecountry.svg')
      allow(File).to receive(:exist?).with(nonexistent_brands_path).and_return(false)
      nonexistent_flag_path = File.join(Dir.pwd, 'node_modules', 'ultimate-jekyll-manager', 'assets', 'icons', 'flags', 'modern-square', 'fakecountry.svg')
      allow(File).to receive(:exist?).with(nonexistent_flag_path).and_return(false)

      result = render_tag('fakecountry')
      expect(result).to include('Font Awesome Free v7.0.0')  # Should contain the default icon
    end
  end
end
