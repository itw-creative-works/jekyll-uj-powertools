require_relative '../spec_helper'

RSpec.describe Jekyll::UJPowertools::UrlMatchesTag do
  let(:site) { Jekyll::Site.new(Jekyll.configuration) }
  let(:context) { Liquid::Context.new({}, {}, { site: site }) }

  def render_tag(url_to_check, output = nil, current_page_url = '/about/')
    # Set up the page context with current URL
    context['page'] = { 'url' => current_page_url }
    
    # Build the tag markup with comma separation
    markup = output ? "\"#{url_to_check}\", \"#{output}\"" : "\"#{url_to_check}\""
    
    # Parse and render the template
    template = Liquid::Template.parse("{% urlmatches #{markup} %}")
    template.render(context)
  end

  describe 'basic URL matching' do
    it 'returns output when URLs match exactly' do
      expect(render_tag('/about/', 'active', '/about/')).to eq('active')
    end

    it 'returns empty string when URLs do not match' do
      expect(render_tag('/contact/', 'active', '/about/')).to eq('')
    end

    it 'uses default "active" output when not specified' do
      expect(render_tag('/about/', nil, '/about/')).to eq('active')
    end
  end

  describe 'URL normalization' do
    it 'handles index.html in page URL' do
      expect(render_tag('/about/', 'active', '/about/index.html')).to eq('active')
    end

    it 'handles index.html in checked URL' do
      context['page'] = { 'url' => '/about/' }
      template = Liquid::Template.parse('{% urlmatches "/about/index.html", "active" %}')
      expect(template.render(context)).to eq('active')
    end

    it 'adds trailing slash to non-root paths' do
      expect(render_tag('/about', 'active', '/about/')).to eq('active')
      expect(render_tag('/about/', 'active', '/about')).to eq('active')
    end

    it 'handles root URL correctly' do
      expect(render_tag('/', 'active', '/')).to eq('active')
      expect(render_tag('/', 'active', '/index.html')).to eq('active')
    end

    it 'handles root index.html' do
      context['page'] = { 'url' => '/index.html' }
      template = Liquid::Template.parse('{% urlmatches "/", "active" %}')
      expect(template.render(context)).to eq('active')
    end
  end

  describe 'variable resolution' do
    it 'resolves URL from variable' do
      context['my_url'] = '/about/'
      context['page'] = { 'url' => '/about/' }
      template = Liquid::Template.parse('{% urlmatches my_url, "active" %}')
      expect(template.render(context)).to eq('active')
    end

    it 'resolves output from variable' do
      context['my_output'] = 'current-page'
      context['page'] = { 'url' => '/about/' }
      template = Liquid::Template.parse('{% urlmatches "/about/", my_output %}')
      expect(template.render(context)).to eq('current-page')
    end

    it 'handles nested variable access for URL' do
      context['nav'] = { 'url' => '/services/' }
      context['page'] = { 'url' => '/services/' }
      template = Liquid::Template.parse('{% urlmatches nav.url, "active" %}')
      expect(template.render(context)).to eq('active')
    end

    it 'handles nested variable access for output' do
      context['styles'] = { 'active_class' => 'is-current' }
      context['page'] = { 'url' => '/about/' }
      template = Liquid::Template.parse('{% urlmatches "/about/", styles.active_class %}')
      expect(template.render(context)).to eq('is-current')
    end
  end

  describe 'edge cases' do
    it 'handles nil URL gracefully' do
      context['page'] = { 'url' => nil }
      template = Liquid::Template.parse('{% urlmatches "/about/", "active" %}')
      expect(template.render(context)).to eq('')
    end

    it 'handles undefined page URL' do
      context['page'] = {}
      template = Liquid::Template.parse('{% urlmatches "/about/", "active" %}')
      expect(template.render(context)).to eq('')
    end

    it 'handles empty string URLs' do
      expect(render_tag('', 'active', '')).to eq('active')
    end

    it 'handles URLs with query parameters' do
      expect(render_tag('/about/?param=value', 'active', '/about/?param=value')).to eq('active')
      expect(render_tag('/about/', 'active', '/about/?param=value')).to eq('')
    end

    it 'handles URLs with anchors' do
      expect(render_tag('/about/#section', 'active', '/about/#section')).to eq('active')
      expect(render_tag('/about/', 'active', '/about/#section')).to eq('')
    end

    it 'handles complex paths' do
      expect(render_tag('/blog/2024/01/post/', 'active', '/blog/2024/01/post/')).to eq('active')
      expect(render_tag('/blog/2024/01/post', 'active', '/blog/2024/01/post/')).to eq('active')
    end

    it 'handles paths with extensions other than .html' do
      expect(render_tag('/file.pdf', 'active', '/file.pdf')).to eq('active')
      # Both normalize to '/file.pdf/' so they match
      expect(render_tag('/file.pdf', 'active', '/file.pdf/')).to eq('active')
      # Different files don't match
      expect(render_tag('/file.pdf', 'active', '/other.pdf')).to eq('')
    end

    it 'handles whitespace in tag parameters' do
      context['page'] = { 'url' => '/about/' }
      template = Liquid::Template.parse('{% urlmatches   "/about/",   "active"   %}')
      expect(template.render(context)).to eq('active')
    end
  end

  describe 'output variations' do
    it 'returns custom HTML output when matching' do
      html_output = '<span class="active">Current</span>'
      expect(render_tag('/about/', html_output, '/about/')).to eq(html_output)
    end

    it 'returns custom CSS classes when matching' do
      css_classes = 'nav-active current-page highlighted'
      expect(render_tag('/about/', css_classes, '/about/')).to eq(css_classes)
    end

    it 'returns numbers as strings when matching' do
      expect(render_tag('/about/', '1', '/about/')).to eq('1')
    end

    it 'handles special characters in output' do
      special_output = 'active-menu__item--current'
      expect(render_tag('/about/', special_output, '/about/')).to eq(special_output)
    end
  end

  describe 'practical use cases' do
    it 'works for navigation menu highlighting' do
      # Simulating a navigation menu scenario
      pages = [
        { 'url' => '/', 'title' => 'Home' },
        { 'url' => '/about/', 'title' => 'About' },
        { 'url' => '/services/', 'title' => 'Services' },
        { 'url' => '/contact/', 'title' => 'Contact' }
      ]

      context['page'] = { 'url' => '/about/' }
      
      pages.each do |nav_page|
        context['nav_url'] = nav_page['url']
        template = Liquid::Template.parse('{% urlmatches nav_url, "active" %}')
        result = template.render(context)
        
        if nav_page['url'] == '/about/'
          expect(result).to eq('active')
        else
          expect(result).to eq('')
        end
      end
    end

    it 'works with Jekyll site navigation' do
      # Simulating Jekyll's site.pages structure
      context['site'] = {
        'pages' => [
          { 'url' => '/about/', 'title' => 'About Us' },
          { 'url' => '/blog/', 'title' => 'Blog' }
        ]
      }
      context['page'] = { 'url' => '/blog/index.html' }
      
      # Check each page in navigation
      context['check_url'] = '/blog/'
      template = Liquid::Template.parse('{% urlmatches check_url, "current" %}')
      expect(template.render(context)).to eq('current')
    end
  end

  describe 'comparison with manual implementation' do
    it 'provides same result as manual URL comparison' do
      test_cases = [
        ['/about/', '/about/', true],
        ['/about', '/about/', true],
        ['/about/', '/about', true],
        ['/about/index.html', '/about/', true],
        ['/about/', '/about/index.html', true],
        ['/', '/', true],
        ['/', '/index.html', true],
        ['/contact/', '/about/', false],
        ['/blog/', '/blog/post/', false]
      ]

      test_cases.each do |page_url, check_url, should_match|
        context['page'] = { 'url' => page_url }
        context['check_url'] = check_url
        
        # Using urlmatches tag
        urlmatches_template = Liquid::Template.parse('{% urlmatches check_url, "MATCH" %}')
        urlmatches_result = urlmatches_template.render(context)
        
        if should_match
          expect(urlmatches_result).to eq('MATCH'), 
            "Expected match for page_url: #{page_url}, check_url: #{check_url}"
        else
          expect(urlmatches_result).to eq(''),
            "Expected no match for page_url: #{page_url}, check_url: #{check_url}"
        end
      end
    end
  end
end