require_relative '../spec_helper'

RSpec.describe Jekyll::UJLogoTag do
  let(:site) { Jekyll::Site.new(Jekyll.configuration({})) }
  let(:context) { Liquid::Context.new({}, {}, { site: site }) }

  def render_tag(markup)
    template = Liquid::Template.parse("{% uj_logo #{markup} %}")
    template.render(context)
  end

  before do
    # Clear logo cache between tests
    Jekyll::UJLogoTag.class_variable_set(:@@logo_cache, {})

    # Mock file system for logo files
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:read).and_call_original

    # Mock jira brandmark in original color
    jira_brandmark_original_path = File.join(Dir.pwd, 'node_modules', 'ultimate-jekyll-manager', 'assets', 'logos', 'brandmarks', 'original', 'jira.svg')
    allow(File).to receive(:exist?).with(jira_brandmark_original_path).and_return(true)
    allow(File).to receive(:read).with(jira_brandmark_original_path).and_return('<svg>JIRA_BRANDMARK_ORIGINAL</svg>')

    # Mock fitbit combomark in original color
    fitbit_combomark_original_path = File.join(Dir.pwd, 'node_modules', 'ultimate-jekyll-manager', 'assets', 'logos', 'combomarks', 'original', 'fitbit.svg')
    allow(File).to receive(:exist?).with(fitbit_combomark_original_path).and_return(true)
    allow(File).to receive(:read).with(fitbit_combomark_original_path).and_return('<svg>FITBIT_COMBOMARK_ORIGINAL</svg>')

    # Mock slack brandmark in white color
    slack_brandmark_white_path = File.join(Dir.pwd, 'node_modules', 'ultimate-jekyll-manager', 'assets', 'logos', 'brandmarks', 'white', 'slack.svg')
    allow(File).to receive(:exist?).with(slack_brandmark_white_path).and_return(true)
    allow(File).to receive(:read).with(slack_brandmark_white_path).and_return('<svg>SLACK_BRANDMARK_WHITE</svg>')

    # Mock github combomark in black color
    github_combomark_black_path = File.join(Dir.pwd, 'node_modules', 'ultimate-jekyll-manager', 'assets', 'logos', 'combomarks', 'black', 'github.svg')
    allow(File).to receive(:exist?).with(github_combomark_black_path).and_return(true)
    allow(File).to receive(:read).with(github_combomark_black_path).and_return('<svg>GITHUB_COMBOMARK_BLACK</svg>')

    # Mock nonexistent logo
    nonexistent_path = File.join(Dir.pwd, 'node_modules', 'ultimate-jekyll-manager', 'assets', 'logos', 'brandmarks', 'original', 'nonexistent.svg')
    allow(File).to receive(:exist?).with(nonexistent_path).and_return(false)
  end

  describe 'basic logo rendering' do
    it 'renders a logo with default type and color' do
      result = render_tag('jira')
      expect(result).to eq('<svg>JIRA_BRANDMARK_ORIGINAL</svg>')
    end

    it 'renders a combomark logo' do
      result = render_tag('fitbit, combomarks')
      expect(result).to eq('<svg>FITBIT_COMBOMARK_ORIGINAL</svg>')
    end

    it 'renders a logo with custom color' do
      result = render_tag('slack, brandmarks, white')
      expect(result).to eq('<svg>SLACK_BRANDMARK_WHITE</svg>')
    end

    it 'renders a combomark with custom color' do
      result = render_tag('github, combomarks, black')
      expect(result).to eq('<svg>GITHUB_COMBOMARK_BLACK</svg>')
    end

    it 'renders default logo when logo does not exist' do
      result = render_tag('nonexistent')
      expect(result).to include('Font Awesome Free v7.0.0')
    end

    it 'returns empty string when no logo name is provided' do
      result = render_tag('')
      expect(result).to eq('')
    end
  end

  describe 'parameter variations' do
    it 'handles quoted logo names' do
      result = render_tag('"jira"')
      expect(result).to eq('<svg>JIRA_BRANDMARK_ORIGINAL</svg>')
    end

    it 'handles single-quoted logo names' do
      result = render_tag("'jira'")
      expect(result).to eq('<svg>JIRA_BRANDMARK_ORIGINAL</svg>')
    end

    it 'handles quoted type parameter' do
      result = render_tag('fitbit, "combomarks"')
      expect(result).to eq('<svg>FITBIT_COMBOMARK_ORIGINAL</svg>')
    end

    it 'handles quoted color parameter' do
      result = render_tag('slack, brandmarks, "white"')
      expect(result).to eq('<svg>SLACK_BRANDMARK_WHITE</svg>')
    end

    it 'handles all parameters quoted' do
      result = render_tag('"github", "combomarks", "black"')
      expect(result).to eq('<svg>GITHUB_COMBOMARK_BLACK</svg>')
    end

    it 'handles mixed quoted and unquoted parameters' do
      result = render_tag('"slack", brandmarks, "white"')
      expect(result).to eq('<svg>SLACK_BRANDMARK_WHITE</svg>')
    end
  end

  describe 'variable resolution' do
    it 'resolves logo name from context variable' do
      context['myLogo'] = 'jira'
      template = Liquid::Template.parse("{% uj_logo myLogo %}")
      result = template.render(context)
      expect(result).to eq('<svg>JIRA_BRANDMARK_ORIGINAL</svg>')
    end

    it 'resolves type from context variable' do
      context['logoType'] = 'combomarks'
      template = Liquid::Template.parse("{% uj_logo fitbit, logoType %}")
      result = template.render(context)
      expect(result).to eq('<svg>FITBIT_COMBOMARK_ORIGINAL</svg>')
    end

    it 'resolves color from context variable' do
      context['logoColor'] = 'white'
      template = Liquid::Template.parse("{% uj_logo slack, brandmarks, logoColor %}")
      result = template.render(context)
      expect(result).to eq('<svg>SLACK_BRANDMARK_WHITE</svg>')
    end

    it 'resolves all parameters from variables' do
      context['logo'] = 'github'
      context['type'] = 'combomarks'
      context['color'] = 'black'
      template = Liquid::Template.parse("{% uj_logo logo, type, color %}")
      result = template.render(context)
      expect(result).to eq('<svg>GITHUB_COMBOMARK_BLACK</svg>')
    end

    it 'handles nested variable access for logo name' do
      context['site'] = { 'logo' => { 'name' => 'jira' } }
      template = Liquid::Template.parse("{% uj_logo site.logo.name %}")
      result = template.render(context)
      expect(result).to eq('<svg>JIRA_BRANDMARK_ORIGINAL</svg>')
    end

    it 'handles nested variable access for all parameters' do
      context['config'] = { 
        'logo' => 'github',
        'style' => 'combomarks',
        'theme' => 'black'
      }
      template = Liquid::Template.parse("{% uj_logo config.logo, config.style, config.theme %}")
      result = template.render(context)
      expect(result).to eq('<svg>GITHUB_COMBOMARK_BLACK</svg>')
    end

    it 'treats quoted strings as literals even if variable exists' do
      context['jira'] = 'something-else'
      template = Liquid::Template.parse("{% uj_logo 'jira' %}")
      result = template.render(context)
      expect(result).to eq('<svg>JIRA_BRANDMARK_ORIGINAL</svg>')
    end

    it 'falls back to literal when variable not found' do
      # Ensure variable doesn't exist
      context['jira'] = nil
      template = Liquid::Template.parse("{% uj_logo jira %}")
      result = template.render(context)
      expect(result).to eq('<svg>JIRA_BRANDMARK_ORIGINAL</svg>')
    end

    it 'handles complex nested paths' do
      context['page'] = { 
        'company' => { 
          'branding' => {
            'logo' => 'slack',
            'type' => 'brandmarks',
            'color' => 'white'
          }
        }
      }
      template = Liquid::Template.parse("{% uj_logo page.company.branding.logo, page.company.branding.type, page.company.branding.color %}")
      result = template.render(context)
      expect(result).to eq('<svg>SLACK_BRANDMARK_WHITE</svg>')
    end

    it 'strips quotes from resolved variable values' do
      context['logo'] = '"jira"'
      template = Liquid::Template.parse("{% uj_logo logo %}")
      result = template.render(context)
      expect(result).to eq('<svg>JIRA_BRANDMARK_ORIGINAL</svg>')
    end
  end

  describe 'edge cases' do
    it 'handles extra spaces in markup' do
      result = render_tag('jira ,  brandmarks ,  original')
      expect(result).to eq('<svg>JIRA_BRANDMARK_ORIGINAL</svg>')
    end

    it 'handles trailing commas' do
      result = render_tag('jira,')
      expect(result).to eq('<svg>JIRA_BRANDMARK_ORIGINAL</svg>')
    end

    it 'handles empty type parameter' do
      result = render_tag('jira, ')
      expect(result).to eq('<svg>JIRA_BRANDMARK_ORIGINAL</svg>')
    end

    it 'handles empty color parameter' do
      result = render_tag('jira, brandmarks, ')
      expect(result).to eq('<svg>JIRA_BRANDMARK_ORIGINAL</svg>')
    end

    it 'uses default values when parameters are empty strings' do
      result = render_tag('jira, "", ""')
      expect(result).to eq('<svg>JIRA_BRANDMARK_ORIGINAL</svg>')
    end
  end

  describe 'caching behavior' do
    it 'caches loaded logos' do
      # First call should read from file
      expect(File).to receive(:read).once.and_return('<svg>CACHED_LOGO</svg>')
      
      # Mock the file existence
      path = File.join(Dir.pwd, 'node_modules', 'ultimate-jekyll-manager', 'assets', 'logos', 'brandmarks', 'original', 'test.svg')
      allow(File).to receive(:exist?).with(path).and_return(true)

      # Render twice, should only read once
      result1 = render_tag('test')
      result2 = render_tag('test')
      
      expect(result1).to eq('<svg>CACHED_LOGO</svg>')
      expect(result2).to eq('<svg>CACHED_LOGO</svg>')
    end

    it 'uses different cache keys for different variations' do
      # Should make two separate reads for different variations
      result1 = render_tag('jira')
      result2 = render_tag('jira, brandmarks, white')
      
      expect(result1).to eq('<svg>JIRA_BRANDMARK_ORIGINAL</svg>')
      # This will return default since we didn't mock the white version
      expect(result2).to include('Font Awesome Free v7.0.0')
    end
  end

  describe 'default logo fallback' do
    it 'returns default logo for non-existent brandmark' do
      result = render_tag('nonexistent')
      expect(result).to include('Font Awesome Free v7.0.0')
      expect(result).to include('<path d="M320 64C334.7')
    end

    it 'returns default logo for non-existent combomark' do
      nonexistent_combo_path = File.join(Dir.pwd, 'node_modules', 'ultimate-jekyll-manager', 'assets', 'logos', 'combomarks', 'original', 'nonexistent.svg')
      allow(File).to receive(:exist?).with(nonexistent_combo_path).and_return(false)
      
      result = render_tag('nonexistent, combomarks')
      expect(result).to include('Font Awesome Free v7.0.0')
    end

    it 'returns default logo for non-existent color variation' do
      nonexistent_color_path = File.join(Dir.pwd, 'node_modules', 'ultimate-jekyll-manager', 'assets', 'logos', 'brandmarks', 'rainbow', 'jira.svg')
      allow(File).to receive(:exist?).with(nonexistent_color_path).and_return(false)
      
      result = render_tag('jira, brandmarks, rainbow')
      expect(result).to include('Font Awesome Free v7.0.0')
    end
  end
end