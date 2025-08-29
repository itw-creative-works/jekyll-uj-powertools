require_relative '../spec_helper'

RSpec.describe Jekyll::UJPowertools::IfFileTag do
  let(:site) { Jekyll::Site.new(Jekyll.configuration) }
  let(:context) { Liquid::Context.new({}, {}, { site: site }) }

  # Helper to create mock static files
  def add_static_file(path)
    # Remove leading slash for relative_path
    relative_path = path.start_with?('/') ? path[1..-1] : path
    
    static_file = double('StaticFile')
    allow(static_file).to receive(:relative_path).and_return(relative_path)
    site.static_files << static_file
    
    # Debug output
    puts "[TEST] Added static file: #{relative_path}"
    puts "[TEST] Total static files: #{site.static_files.length}"
  end

  def render_tag(path, content)
    template = Liquid::Template.parse("{% iffile #{path} %}#{content}{% endiffile %}")
    template.render(context)
  end

  before(:each) do
    # Clear static files before each test
    site.static_files.clear
  end

  describe 'basic file existence checks' do
    it 'renders content when file exists' do
      add_static_file('assets/styles.css')
      expect(render_tag('assets/styles.css', 'FILE EXISTS')).to eq('FILE EXISTS')
    end

    it 'renders content when file exists with leading slash' do
      add_static_file('assets/styles.css')
      expect(render_tag('/assets/styles.css', 'FILE EXISTS')).to eq('FILE EXISTS')
    end

    it 'does not render content when file does not exist' do
      add_static_file('assets/styles.css')
      expect(render_tag('assets/nonexistent.css', 'FILE EXISTS')).to eq('')
    end

    it 'handles empty path' do
      expect(render_tag('', 'FILE EXISTS')).to eq('')
    end

    it 'handles whitespace in markup' do
      add_static_file('assets/styles.css')
      expect(render_tag('  assets/styles.css  ', 'FILE EXISTS')).to eq('FILE EXISTS')
    end
  end

  describe 'variable resolution' do
    it 'resolves simple variables' do
      context['css_file'] = 'assets/main.css'
      add_static_file('assets/main.css')
      expect(render_tag('css_file', 'FILE EXISTS')).to eq('FILE EXISTS')
    end

    it 'uses literal path when variable is undefined' do
      add_static_file('undefined_var')
      expect(render_tag('undefined_var', 'FILE EXISTS')).to eq('FILE EXISTS')
    end

    it 'handles nil variable values' do
      context['css_file'] = nil
      expect(render_tag('css_file', 'FILE EXISTS')).to eq('')
    end

    it 'handles variable with leading slash' do
      context['css_file'] = '/assets/main.css'
      add_static_file('assets/main.css')
      expect(render_tag('css_file', 'FILE EXISTS')).to eq('FILE EXISTS')
    end

    it 'handles variable without leading slash' do
      context['css_file'] = 'assets/main.css'
      add_static_file('assets/main.css')
      expect(render_tag('css_file', 'FILE EXISTS')).to eq('FILE EXISTS')
    end
  end

  describe 'nested variable access' do
    it 'resolves page.css_path style variables' do
      context['page'] = { 'css_path' => 'assets/custom.css' }
      add_static_file('assets/custom.css')
      expect(render_tag('page.css_path', 'FILE EXISTS')).to eq('FILE EXISTS')
    end

    it 'resolves deeply nested variables' do
      context['site'] = { 'assets' => { 'css' => { 'main' => 'styles/main.css' } } }
      add_static_file('styles/main.css')
      expect(render_tag('site.assets.css.main', 'FILE EXISTS')).to eq('FILE EXISTS')
    end

    it 'handles undefined nested properties' do
      context['page'] = { 'title' => 'Test' }
      expect(render_tag('page.css_path', 'FILE EXISTS')).to eq('')
    end

    it 'handles partially defined nested properties' do
      context['page'] = { 'assets' => {} }
      expect(render_tag('page.assets.css', 'FILE EXISTS')).to eq('')
    end

    it 'falls back to literal path when nested lookup fails' do
      context['page'] = nil
      add_static_file('page.css_path')
      expect(render_tag('page.css_path', 'FILE EXISTS')).to eq('FILE EXISTS')
    end

    it 'handles non-hash intermediate values' do
      context['page'] = { 'title' => 'Test Page' }
      # Trying to access title.something should fail gracefully
      expect(render_tag('page.title.something', 'FILE EXISTS')).to eq('')
    end
  end

  describe 'path normalization' do
    it 'adds leading slash to paths without one' do
      add_static_file('assets/styles.css')
      expect(render_tag('assets/styles.css', 'FILE EXISTS')).to eq('FILE EXISTS')
    end

    it 'preserves leading slash in paths' do
      add_static_file('assets/styles.css')
      expect(render_tag('/assets/styles.css', 'FILE EXISTS')).to eq('FILE EXISTS')
    end

    it 'handles paths with multiple leading slashes' do
      add_static_file('assets/styles.css')
      expect(render_tag('//assets/styles.css', 'FILE EXISTS')).to eq('')
    end

    it 'handles paths with trailing slashes' do
      add_static_file('assets/folder/')
      expect(render_tag('assets/folder/', 'FILE EXISTS')).to eq('FILE EXISTS')
    end

    it 'handles relative paths with dots' do
      add_static_file('./assets/styles.css')
      expect(render_tag('./assets/styles.css', 'FILE EXISTS')).to eq('FILE EXISTS')
    end
  end

  describe 'multiple files' do
    before do
      add_static_file('assets/style1.css')
      add_static_file('assets/style2.css')
      add_static_file('js/app.js')
      add_static_file('images/logo.png')
    end

    it 'finds the correct file among many' do
      expect(render_tag('assets/style1.css', 'FOUND')).to eq('FOUND')
      expect(render_tag('assets/style2.css', 'FOUND')).to eq('FOUND')
      expect(render_tag('js/app.js', 'FOUND')).to eq('FOUND')
      expect(render_tag('images/logo.png', 'FOUND')).to eq('FOUND')
    end

    it 'does not find non-existent files' do
      expect(render_tag('assets/style3.css', 'FOUND')).to eq('')
      expect(render_tag('js/vendor.js', 'FOUND')).to eq('')
    end
  end

  describe 'complex content handling' do
    before do
      add_static_file('assets/app.css')
    end

    it 'renders multi-line content' do
      content = "<link rel=\"stylesheet\" href=\"/assets/app.css\">\n<style>body { margin: 0; }</style>"
      expect(render_tag('assets/app.css', content)).to eq(content)
    end

    it 'handles nested Liquid tags' do
      context['file_exists'] = 'assets/app.css'
      context['css_url'] = '/assets/app.css'
      template = Liquid::Template.parse(
        "{% iffile file_exists %}<link href=\"{{ css_url }}\">{% endiffile %}"
      )
      expect(template.render(context)).to eq('<link href="/assets/app.css">')
    end

    it 'handles HTML with special characters' do
      content = '<link rel="stylesheet" href="/css/main.css" data-test=\'value\'>'
      expect(render_tag('assets/app.css', content)).to eq(content)
    end
  end

  describe 'edge cases' do
    it 'handles empty static files array' do
      # Ensure static_files is empty
      expect(site.static_files).to be_empty
      expect(render_tag('any/file.css', 'FOUND')).to eq('')
    end

    it 'handles special characters in filenames' do
      add_static_file('assets/my-file_v2.0.css')
      expect(render_tag('assets/my-file_v2.0.css', 'FOUND')).to eq('FOUND')
    end

    it 'handles spaces in filenames' do
      add_static_file('assets/my file.css')
      expect(render_tag('assets/my file.css', 'FOUND')).to eq('FOUND')
    end

    it 'distinguishes between similar filenames' do
      add_static_file('assets/style.css')
      add_static_file('assets/styles.css')
      
      expect(render_tag('assets/style.css', 'STYLE')).to eq('STYLE')
      expect(render_tag('assets/styles.css', 'STYLES')).to eq('STYLES')
      expect(render_tag('assets/styl.css', 'STYL')).to eq('')
    end

    it 'handles unicode characters in paths' do
      add_static_file('assets/文件.css')
      expect(render_tag('assets/文件.css', 'FOUND')).to eq('FOUND')
    end
  end

  describe 'common use cases' do
    it 'checks for CSS files in typical locations' do
      add_static_file('assets/css/main.css')
      add_static_file('css/styles.css')
      add_static_file('_site/assets/application.css')
      
      expect(render_tag('/assets/css/main.css', 'FOUND')).to eq('FOUND')
      expect(render_tag('css/styles.css', 'FOUND')).to eq('FOUND')
      expect(render_tag('_site/assets/application.css', 'FOUND')).to eq('FOUND')
    end

    it 'works with Jekyll page variables' do
      context['page'] = {
        'custom_css' => 'assets/custom-theme.css',
        'js_bundle' => '/js/app.bundle.js'
      }
      
      add_static_file('assets/custom-theme.css')
      add_static_file('js/app.bundle.js')
      
      template = Liquid::Template.parse(
        "{% iffile page.custom_css %}<link rel=\"stylesheet\" href=\"/{{ page.custom_css }}\">{% endiffile %}"
      )
      expect(template.render(context)).to include('custom-theme.css')
      
      template = Liquid::Template.parse(
        "{% iffile page.js_bundle %}<script src=\"{{ page.js_bundle }}\"></script>{% endiffile %}"
      )
      expect(template.render(context)).to include('app.bundle.js')
    end

    it 'provides fallback for missing files' do
      context['primary_css'] = 'assets/custom.css'
      context['fallback_css'] = 'assets/default.css'
      
      # Only fallback exists
      add_static_file('assets/default.css')
      
      template = Liquid::Template.parse(
        "{% iffile primary_css %}" +
        "<link href=\"/{{ primary_css }}\">" +
        "{% endiffile %}" +
        "{% iffile fallback_css %}" +
        "<link href=\"/{{ fallback_css }}\">" +
        "{% endiffile %}"
      )
      
      result = template.render(context)
      expect(result).not_to include('custom.css')
      expect(result).to include('default.css')
    end
  end
end