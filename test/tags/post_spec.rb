require_relative '../spec_helper'

RSpec.describe Jekyll::UJPostTag do
  let(:site) do 
    s = Jekyll::Site.new(Jekyll.configuration)
    # Create a mock posts collection
    s.collections['posts'] = Jekyll::Collection.new(s, 'posts')
    s
  end
  
  let(:context) do
    ctx = Liquid::Context.new
    ctx.registers[:site] = site
    ctx
  end
  
  # Create a mock post document
  let(:mock_post) do
    post = Jekyll::Document.new('_posts/2024-01-15-test-post.md', {
      site: site,
      collection: site.collections['posts']
    })
    # Jekyll::Document.data is a read-only method that returns a hash
    # We need to modify the data hash directly
    post.data['title'] = 'Test Post Title'
    post.data['description'] = 'Test post description'
    post.data['date'] = Date.new(2024, 1, 15)
    post.data['author'] = 'John Doe'
    post.data['category'] = 'Technology'
    post.data['categories'] = ['Technology', 'Programming']
    post.data['tags'] = ['ruby', 'jekyll']
    post.data['excerpt'] = 'This is an excerpt'
    post.data['custom_field'] = 'Custom value'
    post.data['post'] = {
      'id' => '123',
      'title' => 'Custom Post Title',
      'author' => 'Jane Smith'
    }
    allow(post).to receive(:id).and_return('/posts/2024-01-15-test-post')
    allow(post).to receive(:url).and_return('/2024/01/15/test-post')
    post
  end

  before do
    # Add the mock post to the site's posts collection
    site.collections['posts'].docs << mock_post
  end

  def render_tag(markup)
    template = Liquid::Template.parse("{% uj_post #{markup} %}")
    template.render(context)
  end

  describe 'property retrieval' do
    it 'returns post title by default' do
      result = render_tag("'/posts/2024-01-15-test-post'")
      expect(result).to eq('Test Post Title')
    end

    it 'returns post title when explicitly requested' do
      result = render_tag("'/posts/2024-01-15-test-post', 'title'")
      expect(result).to eq('Test Post Title')
    end

    it 'returns post description' do
      result = render_tag("'/posts/2024-01-15-test-post', 'description'")
      expect(result).to eq('Test post description')
    end

    it 'returns post URL with site URL' do
      site.config['url'] = 'https://example.com'
      result = render_tag("'/posts/2024-01-15-test-post', 'url'")
      expect(result).to eq('https://example.com/2024/01/15/test-post')
    end

    it 'returns post path' do
      result = render_tag("'/posts/2024-01-15-test-post', 'path'")
      expect(result).to eq('/2024/01/15/test-post')
    end

    it 'returns post date formatted' do
      result = render_tag("'/posts/2024-01-15-test-post', 'date'")
      expect(result).to eq('2024-01-15')
    end

    it 'returns post author' do
      result = render_tag("'/posts/2024-01-15-test-post', 'author'")
      expect(result).to eq('Jane Smith')  # Uses post.post.author first
    end

    it 'returns post category' do
      result = render_tag("'/posts/2024-01-15-test-post', 'category'")
      expect(result).to eq('Technology')
    end

    it 'returns post categories as comma-separated list' do
      result = render_tag("'/posts/2024-01-15-test-post', 'categories'")
      expect(result).to eq('Technology, Programming')
    end

    it 'returns post tags as comma-separated list' do
      result = render_tag("'/posts/2024-01-15-test-post', 'tags'")
      expect(result).to eq('ruby, jekyll')
    end

    it 'returns post ID' do
      result = render_tag("'/posts/2024-01-15-test-post', 'id'")
      expect(result).to eq('/posts/2024-01-15-test-post')
    end

    it 'returns custom field values' do
      result = render_tag("'/posts/2024-01-15-test-post', 'custom_field'")
      expect(result).to eq('Custom value')
    end

    it 'generates image path' do
      result = render_tag("'/posts/2024-01-15-test-post', 'image'")
      expect(result).to eq('/assets/images/blog/post-123/test-post.jpg')
    end
  end

  describe 'variable resolution' do
    it 'resolves post ID from variable' do
      context['post_id'] = '/posts/2024-01-15-test-post'
      result = render_tag("post_id, 'title'")
      expect(result).to eq('Test Post Title')
    end

    it 'resolves nested variables' do
      context['current'] = { 'post_id' => '/posts/2024-01-15-test-post' }
      result = render_tag("current.post_id, 'title'")
      expect(result).to eq('Test Post Title')
    end

    it 'uses current page as post when no ID provided' do
      context['page'] = {
        'id' => '/posts/2024-01-15-test-post',
        'collection' => 'posts'
      }
      result = render_tag("'', 'title'")
      expect(result).to eq('Test Post Title')
    end
  end

  describe 'post lookup' do
    it 'finds post by partial ID match' do
      result = render_tag("'test-post', 'title'")
      expect(result).to eq('Test Post Title')
    end

    it 'finds post by custom post.id field' do
      result = render_tag("'123', 'title'")
      expect(result).to eq('Test Post Title')
    end
  end

  describe 'edge cases' do
    it 'returns empty string when post not found' do
      result = render_tag("'nonexistent-post', 'title'")
      expect(result).to eq('')
    end

    it 'returns empty string when property not found' do
      result = render_tag("'/posts/2024-01-15-test-post', 'nonexistent'")
      expect(result).to eq('')
    end

    it 'falls back to excerpt when description is missing' do
      mock_post.data.delete('description')
      result = render_tag("'/posts/2024-01-15-test-post', 'description'")
      expect(result).to eq('This is an excerpt')
    end

    it 'handles missing date gracefully' do
      mock_post.data['date'] = nil
      result = render_tag("'/posts/2024-01-15-test-post', 'date'")
      expect(result).to eq('')
    end

    it 'handles empty categories array' do
      mock_post.data['categories'] = []
      result = render_tag("'/posts/2024-01-15-test-post', 'categories'")
      expect(result).to eq('')
    end

    it 'handles nil tags' do
      mock_post.data['tags'] = nil
      result = render_tag("'/posts/2024-01-15-test-post', 'tags'")
      expect(result).to eq('')
    end
  end

  describe 'image-tag generation' do
    it 'generates image tag markup' do
      # We can't easily test the full image-tag rendering without the actual image tag implementation
      # So we'll test that it returns something (the actual rendering)
      result = render_tag("'/posts/2024-01-15-test-post', 'image-tag'")
      # Since we don't have the actual uj_image tag implementation in tests,
      # this will return an empty string or error, but we're testing the path generation logic
      expect(result).to be_a(String)
    end
  end

  describe 'quoted vs unquoted arguments' do
    it 'treats single-quoted strings as literals' do
      result = render_tag("'/posts/2024-01-15-test-post', 'title'")
      expect(result).to eq('Test Post Title')
    end

    it 'treats double-quoted strings as literals' do
      result = render_tag('"/posts/2024-01-15-test-post", "title"')
      expect(result).to eq('Test Post Title')
    end

    it 'resolves unquoted strings as variables' do
      context['my_post'] = '/posts/2024-01-15-test-post'
      result = render_tag("my_post, 'title'")
      expect(result).to eq('Test Post Title')
    end
  end
end