require_relative '../spec_helper'

RSpec.describe Jekyll::UJReadtimeTag do
  let(:site) { Jekyll::Site.new(Jekyll.configuration) }
  let(:context) do
    ctx = Liquid::Context.new
    ctx.registers[:site] = site
    ctx
  end

  def render_tag(markup = '')
    template = Liquid::Template.parse("{% uj_readtime #{markup} %}")
    template.render(context)
  end

  describe 'readtime calculation' do
    it 'calculates 1 minute for content under 200 words' do
      context['page'] = { 'content' => 'word ' * 100 }
      result = render_tag
      expect(result).to eq('1')
    end

    it 'calculates 1 minute for exactly 269 words' do
      context['page'] = { 'content' => 'word ' * 269 }
      result = render_tag
      expect(result).to eq('1')
    end

    it 'calculates 2 minutes for 270 words' do
      context['page'] = { 'content' => 'word ' * 270 }
      result = render_tag
      expect(result).to eq('2')
    end

    it 'calculates correct readtime for large content' do
      context['page'] = { 'content' => 'word ' * 1345 }
      result = render_tag
      # 1345 / 269 = 5
      expect(result).to eq('5')
    end

    it 'rounds up partial minutes' do
      context['page'] = { 'content' => 'word ' * 300 }
      result = render_tag
      # 300 / 269 ≈ 1.12, rounds up to 2
      expect(result).to eq('2')
    end
  end

  describe 'HTML stripping' do
    it 'strips HTML tags before calculating readtime' do
      html_content = '<p>' + ('word ' * 100) + '</p><div>' + ('test ' * 100) + '</div>'
      context['page'] = { 'content' => html_content }
      result = render_tag
      # 200 words total, should be 1 minute
      expect(result).to eq('1')
    end

    it 'removes script tags completely' do
      context['page'] = { 'content' => ('word ' * 100) + '<script>alert("test")</script>' + ('word ' * 100) }
      result = render_tag
      # 200 words (script content ignored), should be 1 minute
      expect(result).to eq('1')
    end

    it 'removes style tags completely' do
      context['page'] = { 'content' => ('word ' * 100) + '<style>body { color: red; }</style>' + ('word ' * 100) }
      result = render_tag
      # 200 words (style content ignored), should be 1 minute
      expect(result).to eq('1')
    end
  end

  describe 'variable resolution' do
    it 'uses custom variable when provided' do
      context['article_content'] = 'word ' * 300
      result = render_tag('article_content')
      # 300 / 200 = 1.5, rounds up to 2
      expect(result).to eq('2')
    end

    it 'resolves nested variables' do
      context['post'] = { 'body' => 'word ' * 400 }
      result = render_tag('post.body')
      # 400 / 200 = 2
      expect(result).to eq('2')
    end

    it 'uses page content when no argument provided' do
      context['page'] = { 'content' => 'word ' * 600 }
      result = render_tag
      # 600 / 200 = 3
      expect(result).to eq('3')
    end
  end

  describe 'edge cases' do
    it 'returns 1 when page has no content' do
      context['page'] = {}
      result = render_tag
      expect(result).to eq('1')
    end

    it 'returns 1 when page is nil' do
      context['page'] = nil
      result = render_tag
      expect(result).to eq('1')
    end

    it 'returns 1 when variable not found' do
      result = render_tag('nonexistent')
      expect(result).to eq('1')
    end

    it 'returns 1 for empty content' do
      context['page'] = { 'content' => '' }
      result = render_tag
      expect(result).to eq('1')
    end

    it 'returns 1 for whitespace-only content' do
      context['page'] = { 'content' => '   \n\t   ' }
      result = render_tag
      expect(result).to eq('1')
    end

    it 'handles single word' do
      context['page'] = { 'content' => 'Hello' }
      result = render_tag
      expect(result).to eq('1')
    end
  end

  describe 'content normalization' do
    it 'normalizes multiple spaces' do
      context['page'] = { 'content' => 'Word    with     multiple      spaces    ' + ('test ' * 266) }
      result = render_tag
      # Should normalize to 270 words total (4 + 266)
      expect(result).to eq('2')
    end

    it 'handles mixed whitespace characters' do
      content = "Word\twith\ttabs\nand\nnewlines\r\nand\rcarriage\rreturns " + ('test ' * 262)
      context['page'] = { 'content' => content }
      result = render_tag
      # Should normalize to 270 words (8 + 262)
      expect(result).to eq('2')
    end
  end
end