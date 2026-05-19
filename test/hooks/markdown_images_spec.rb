require_relative '../spec_helper'

RSpec.describe 'Jekyll Hooks - Markdown Images' do
  let(:site) do
    Jekyll::Site.new(Jekyll.configuration({}))
  end

  let(:site_payload) do
    site.site_payload
  end

  before do
    # Reload the hook to ensure it's registered
    load File.expand_path('../../lib/hooks/markdown-images.rb', __dir__)
  end

  # Helper to create a mock document
  def create_doc(content:, extname: '.md', data: {})
    doc = double('doc')
    allow(doc).to receive(:extname).and_return(extname)
    allow(doc).to receive(:data).and_return(data)
    allow(doc).to receive(:content).and_return(content)
    allow(doc).to receive(:content=) { |val| allow(doc).to receive(:content).and_return(val) }
    allow(doc).to receive(:site).and_return(site)
    allow(doc).to receive(:to_liquid).and_return(data)
    allow(doc).to receive(:relative_path).and_return('test.md')
    doc
  end

  describe '@post/ prefix resolution' do
    it 'resolves @post/ to full blog image path when post.id exists' do
      doc = create_doc(
        content: '![Alt text](@post/my-image.jpg)',
        data: { 'post' => { 'id' => 42 } },
      )

      Jekyll::Hooks.trigger(:posts, :pre_render, doc)

      # The hook should have resolved @post/ and generated HTML via uj_image
      expect(doc.content).to include('/assets/images/blog/post-42/my-image.jpg')
      expect(doc.content).to include('<picture>')
      expect(doc.content).to include('alt="Alt text"')
    end

    it 'resolves @post/ with string post ID' do
      doc = create_doc(
        content: '![Photo](@post/hero.jpg)',
        data: { 'post' => { 'id' => '1234567890' } },
      )

      Jekyll::Hooks.trigger(:posts, :pre_render, doc)

      expect(doc.content).to include('/assets/images/blog/post-1234567890/hero.jpg')
    end

    it 'preserves @post/ path when post.id is missing and logs warning' do
      doc = create_doc(
        content: '![Alt](@post/orphan.jpg)',
        data: {},
      )

      expect(Jekyll.logger).to receive(:warn).with('markdown-images', a_string_including('@post/'))

      Jekyll::Hooks.trigger(:posts, :pre_render, doc)

      # Should still produce HTML but with unresolved @post/ path
      expect(doc.content).to include('@post/orphan.jpg')
    end

    it 'handles multiple @post/ images in one document' do
      doc = create_doc(
        content: "![First](@post/one.jpg)\n\nSome text\n\n![Second](@post/two.jpg)",
        data: { 'post' => { 'id' => 99 } },
      )

      Jekyll::Hooks.trigger(:posts, :pre_render, doc)

      expect(doc.content).to include('/assets/images/blog/post-99/one.jpg')
      expect(doc.content).to include('/assets/images/blog/post-99/two.jpg')
    end

    it 'handles @post/ with .png extension' do
      doc = create_doc(
        content: '![Diagram](@post/chart.png)',
        data: { 'post' => { 'id' => 5 } },
      )

      Jekyll::Hooks.trigger(:posts, :pre_render, doc)

      expect(doc.content).to include('/assets/images/blog/post-5/chart.png')
    end
  end

  describe 'non-@post/ images' do
    it 'passes absolute paths through unchanged' do
      doc = create_doc(
        content: '![Logo](/assets/images/logo.jpg)',
        data: { 'post' => { 'id' => 1 } },
      )

      Jekyll::Hooks.trigger(:posts, :pre_render, doc)

      expect(doc.content).to include('/assets/images/logo.jpg')
      expect(doc.content).not_to include('@post/')
    end

    it 'passes external URLs through unchanged' do
      doc = create_doc(
        content: '![External](https://images.unsplash.com/photo-123.jpg)',
        data: { 'post' => { 'id' => 1 } },
      )

      Jekyll::Hooks.trigger(:posts, :pre_render, doc)

      expect(doc.content).to include('https://images.unsplash.com/photo-123.jpg')
    end
  end

  describe 'non-markdown files' do
    it 'skips HTML files entirely' do
      original_content = '![Test](@post/should-not-change.jpg)'
      doc = create_doc(
        content: original_content,
        extname: '.html',
        data: { 'post' => { 'id' => 1 } },
      )

      Jekyll::Hooks.trigger(:posts, :pre_render, doc)

      expect(doc.content).to eq(original_content)
    end
  end

  describe 'image class from theme config' do
    it 'applies image class from resolved theme config' do
      doc = create_doc(
        content: '![Styled](@post/styled.jpg)',
        data: {
          'post' => { 'id' => 10 },
          'resolved' => { 'theme' => { 'post' => { 'image' => { 'class' => 'img-fluid rounded-3' } } } },
        },
      )

      Jekyll::Hooks.trigger(:posts, :pre_render, doc)

      expect(doc.content).to include('class="img-fluid rounded-3"')
    end
  end

  describe 'linked images [![alt](src)](href)' do
    # Kramdown promotes a lone block-level `![](src)` to its own paragraph, which
    # shreds the outer `[...](href)` wrapper into orphan literal brackets. The hook
    # must detect the linked-image pattern first and emit explicit <a><img></a> HTML.
    it 'wraps the rendered image in an <a> tag pointing to the outer URL' do
      doc = create_doc(
        content: '[![Caption](https://i.example.com/pic.png)](https://example.com/landing)',
        data: { 'post' => { 'id' => 1 } },
      )

      Jekyll::Hooks.trigger(:posts, :pre_render, doc)

      expect(doc.content).to include('<a href="https://example.com/landing"')
      expect(doc.content).to include('</a>')
      expect(doc.content).to include('https://i.example.com/pic.png')
      expect(doc.content).to include('alt="Caption"')
      # The literal markdown brackets must NOT survive
      expect(doc.content).not_to include('[!')
      expect(doc.content).not_to include('](https://example.com/landing)')
    end

    it 'sets the anchor to display:block so the entire image is clickable' do
      # Without display:block, an inline <a> has a one-line-tall hit box and clicks
      # on the (taller) image's overflow miss the link, falling through to the <p>.
      doc = create_doc(
        content: '[![Pic](https://i.example.com/p.png)](https://example.com/x)',
        data: { 'post' => { 'id' => 1 } },
      )

      Jekyll::Hooks.trigger(:posts, :pre_render, doc)

      expect(doc.content).to match(/<a href="https:\/\/example\.com\/x"\s+style="display:block">/)
    end

    it 'resolves @post/ inside the linked image' do
      doc = create_doc(
        content: '[![Diagram](@post/chart.png)](https://example.com/full-size)',
        data: { 'post' => { 'id' => 42 } },
      )

      Jekyll::Hooks.trigger(:posts, :pre_render, doc)

      expect(doc.content).to include('<a href="https://example.com/full-size"')
      expect(doc.content).to include('/assets/images/blog/post-42/chart.png')
      expect(doc.content).not_to include('@post/')
    end

    it 'handles multiple linked images in one document' do
      doc = create_doc(
        content: "[![One](https://i.example.com/1.png)](https://example.com/a)\n\n[![Two](https://i.example.com/2.png)](https://example.com/b)",
        data: { 'post' => { 'id' => 1 } },
      )

      Jekyll::Hooks.trigger(:posts, :pre_render, doc)

      expect(doc.content).to include('<a href="https://example.com/a"')
      expect(doc.content).to include('<a href="https://example.com/b"')
      expect(doc.content).to include('https://i.example.com/1.png')
      expect(doc.content).to include('https://i.example.com/2.png')
    end

    it 'still processes bare ![](src) images when both patterns exist' do
      doc = create_doc(
        content: "[![Linked](https://i.example.com/linked.png)](https://example.com/page)\n\n![Bare](https://i.example.com/bare.png)",
        data: { 'post' => { 'id' => 1 } },
      )

      Jekyll::Hooks.trigger(:posts, :pre_render, doc)

      expect(doc.content).to include('<a href="https://example.com/page"')
      expect(doc.content).to include('https://i.example.com/linked.png')
      expect(doc.content).to include('https://i.example.com/bare.png')
      # The bare image must NOT have been double-wrapped in <a>
      bare_index = doc.content.index('bare.png')
      surrounding = doc.content[[bare_index - 200, 0].max...bare_index]
      expect(surrounding).not_to match(/<a href[^>]*>\s*[^<]*$/)
    end

    it 'surrounds the linked image with blank lines so kramdown treats it as a block' do
      doc = create_doc(
        content: "### Heading\n[![Pic](https://i.example.com/x.png)](https://example.com/y)\nBody text follows.",
        data: { 'post' => { 'id' => 1 } },
      )

      Jekyll::Hooks.trigger(:posts, :pre_render, doc)

      # The rendered <a>...</a> block should have newlines around it
      expect(doc.content).to match(/\n\n<a href="https:\/\/example\.com\/y"/)
      expect(doc.content).to match(/<\/a>\n\n/)
    end

    it 'applies image class from theme config to the inner <img>' do
      doc = create_doc(
        content: '[![Styled](https://i.example.com/s.png)](https://example.com/landing)',
        data: {
          'post' => { 'id' => 1 },
          'resolved' => { 'theme' => { 'post' => { 'image' => { 'class' => 'img-fluid rounded-3' } } } },
        },
      )

      Jekyll::Hooks.trigger(:posts, :pre_render, doc)

      expect(doc.content).to include('<a href="https://example.com/landing"')
      expect(doc.content).to include('class="img-fluid rounded-3"')
    end
  end

  describe 'mixed content' do
    it 'handles @post/ images mixed with external and absolute images' do
      doc = create_doc(
        content: "![Local](@post/local.jpg)\n\n![Abs](/assets/images/abs.jpg)\n\n![Ext](https://example.com/ext.jpg)",
        data: { 'post' => { 'id' => 7 } },
      )

      Jekyll::Hooks.trigger(:posts, :pre_render, doc)

      expect(doc.content).to include('/assets/images/blog/post-7/local.jpg')
      expect(doc.content).to include('/assets/images/abs.jpg')
      expect(doc.content).to include('https://example.com/ext.jpg')
    end
  end
end
