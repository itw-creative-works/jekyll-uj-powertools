require_relative '../spec_helper'

RSpec.describe Jekyll::UJCommentsTag do
  let(:site) { Jekyll::Site.new(Jekyll.configuration) }
  let(:context) do
    ctx = Liquid::Context.new
    ctx.registers[:site] = site
    ctx
  end

  def render_tag(markup = '')
    template = Liquid::Template.parse("{% uj_fake_comments #{markup} %}")
    template.render(context)
  end

  describe 'basic comment generation' do
    it 'generates comments based on word count modulo 13' do
      context['page'] = { 'content' => 'This is a test content with exactly thirteen words here in this text.' }
      result = render_tag
      # 13 words % 13 = 0
      expect(result).to eq('0')
    end

    it 'handles different word counts' do
      context['page'] = { 'content' => 'One two three four five six seven eight nine ten eleven twelve thirteen fourteen' }
      result = render_tag
      # 14 words % 13 = 1
      expect(result).to eq('1')
    end

    it 'handles large word counts' do
      context['page'] = { 'content' => 'word ' * 100 }
      result = render_tag
      # 100 % 13 = 9
      expect(result).to eq('9')
    end
  end

  describe 'HTML stripping' do
    it 'strips HTML tags before counting words' do
      context['page'] = { 'content' => '<p>Hello <strong>world</strong></p> <div>test</div>' }
      result = render_tag
      # "Hello world test" = 3 words, 3 % 13 = 3
      expect(result).to eq('3')
    end

    it 'removes script tags completely' do
      context['page'] = { 'content' => 'Hello <script>alert("test")</script> world' }
      result = render_tag
      # "Hello world" = 2 words, 2 % 13 = 2
      expect(result).to eq('2')
    end

    it 'removes style tags completely' do
      context['page'] = { 'content' => 'Hello <style>body { color: red; }</style> world' }
      result = render_tag
      # "Hello world" = 2 words, 2 % 13 = 2
      expect(result).to eq('2')
    end

    it 'handles nested HTML tags' do
      context['page'] = { 'content' => '<div><p>Hello <span>beautiful</span> world</p></div>' }
      result = render_tag
      # "Hello beautiful world" = 3 words, 3 % 13 = 3
      expect(result).to eq('3')
    end
  end

  describe 'variable resolution' do
    it 'resolves content from custom variable' do
      context['custom_content'] = 'One two three four five'
      result = render_tag('custom_content')
      # 5 words % 13 = 5
      expect(result).to eq('5')
    end

    it 'resolves nested variables' do
      context['article'] = { 'body' => 'Word count test content here' }
      result = render_tag('article.body')
      # 5 words % 13 = 5
      expect(result).to eq('5')
    end

    it 'uses page content when no argument provided' do
      context['page'] = { 'content' => 'Default page content here' }
      result = render_tag
      # 4 words % 13 = 4
      expect(result).to eq('4')
    end
  end

  describe 'edge cases' do
    it 'returns 0 when page has no content' do
      context['page'] = {}
      result = render_tag
      expect(result).to eq('0')
    end

    it 'returns 0 when page is nil' do
      context['page'] = nil
      result = render_tag
      expect(result).to eq('0')
    end

    it 'returns 0 when variable not found' do
      result = render_tag('nonexistent')
      expect(result).to eq('0')
    end

    it 'handles empty content' do
      context['page'] = { 'content' => '' }
      result = render_tag
      expect(result).to eq('0')
    end

    it 'handles whitespace-only content' do
      context['page'] = { 'content' => '   \n\t   ' }
      result = render_tag
      # Whitespace-only content becomes empty string after strip, 
      # but "".split(/\s+/) returns [""] which has length 1
      # 1 % 13 = 1
      expect(result).to eq('1')
    end

    it 'handles content with multiple spaces' do
      context['page'] = { 'content' => 'Word    with     multiple      spaces' }
      result = render_tag
      # Should normalize to 4 words
      expect(result).to eq('4')
    end
  end

  describe 'special characters and encoding' do
    it 'handles content with special characters' do
      context['page'] = { 'content' => 'Hello, world! How are you?' }
      result = render_tag
      # 5 words % 13 = 5
      expect(result).to eq('5')
    end

    it 'handles content with HTML entities' do
      context['page'] = { 'content' => 'Hello &amp; world &lt;test&gt;' }
      result = render_tag
      # 4 words % 13 = 4
      expect(result).to eq('4')
    end
  end
end