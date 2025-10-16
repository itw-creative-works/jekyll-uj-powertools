require_relative '../spec_helper'

RSpec.describe Jekyll::UJVideoTag do
  let(:site_config) { {} }
  let(:site) { Jekyll::Site.new(Jekyll.configuration(site_config)) }
  let(:context) { Liquid::Context.new({}, {}, { site: site }) }

  def render_tag(markup)
    template = Liquid::Template.parse("{% uj_video #{markup} %}")
    template.render(context)
  end

  describe 'local video rendering' do
    it 'renders a video element for local videos' do
      result = render_tag('"/assets/videos/test.mp4", class="video-fluid"')
      expect(result).to include('<video')
      expect(result).to include('</video>')
      expect(result).to include('<source')
      expect(result).to include('class="video-fluid"')
    end

    it 'includes controls by default' do
      result = render_tag('"/assets/videos/test.mp4"')
      expect(result).to include('controls')
    end

    it 'respects max_width option for local videos' do
      result = render_tag('"/assets/videos/test.mp4", max_width="640"')
      expect(result).to include('-320px.mp4')
      expect(result).to include('-640px.mp4')
      expect(result).not_to include('-1024px.mp4')
    end

    it 'generates responsive sources for different breakpoints' do
      result = render_tag('"/assets/videos/test.mp4"')
      expect(result).to include('-320px.mp4')
      expect(result).to include('-640px.mp4')
      expect(result).to include('-1024px.mp4')
      expect(result).to include('media="(max-width: 320px)"')
      expect(result).to include('media="(max-width: 640px)"')
      expect(result).to include('media="(max-width: 1024px)"')
      expect(result).to include('media="(min-width: 1025px)"')
    end

    it 'includes data-lazy attributes for lazy loading' do
      result = render_tag('"/assets/videos/test.mp4"')
      expect(result).to include('data-lazy="@src')
    end

    it 'includes fallback text' do
      result = render_tag('"/assets/videos/test.mp4"')
      expect(result).to include('Your browser does not support the video tag.')
    end
  end

  describe 'video attributes' do
    it 'adds autoplay attribute when specified' do
      result = render_tag('"/assets/videos/test.mp4", autoplay="true"')
      expect(result).to include('autoplay')
    end

    it 'adds loop attribute when specified' do
      result = render_tag('"/assets/videos/test.mp4", loop="true"')
      expect(result).to include('loop')
    end

    it 'adds muted attribute when specified' do
      result = render_tag('"/assets/videos/test.mp4", muted="true"')
      expect(result).to include('muted')
    end

    it 'adds playsinline attribute when specified' do
      result = render_tag('"/assets/videos/test.mp4", playsinline="true"')
      expect(result).to include('playsinline')
    end

    it 'removes controls when set to false' do
      result = render_tag('"/assets/videos/test.mp4", controls="false"')
      expect(result).not_to include('controls')
    end

    it 'adds poster attribute when specified' do
      result = render_tag('"/assets/videos/test.mp4", poster="/assets/images/poster.jpg"')
      expect(result).to include('poster="/assets/images/poster.jpg"')
    end

    it 'adds preload attribute with metadata as default' do
      result = render_tag('"/assets/videos/test.mp4"')
      expect(result).to include('preload="metadata"')
    end

    it 'allows custom preload value' do
      result = render_tag('"/assets/videos/test.mp4", preload="auto"')
      expect(result).to include('preload="auto"')
    end

    it 'adds width and height when specified' do
      result = render_tag('"/assets/videos/test.mp4", width="800", height="600"')
      expect(result).to include('width="800"')
      expect(result).to include('height="600"')
    end

    it 'adds style attribute when specified' do
      result = render_tag('"/assets/videos/test.mp4", style="border-radius: 8px;"')
      expect(result).to include('style="border-radius: 8px;"')
    end

    it 'handles multiple attributes together' do
      result = render_tag('"/assets/videos/test.mp4", autoplay="true", loop="true", muted="true", playsinline="true", class="bg-video"')
      expect(result).to include('autoplay')
      expect(result).to include('loop')
      expect(result).to include('muted')
      expect(result).to include('playsinline')
      expect(result).to include('class="bg-video"')
    end

    it 'does not add boolean attributes when set to false' do
      result = render_tag('"/assets/videos/test.mp4", autoplay="false", loop="false", muted="false"')
      expect(result).not_to include('autoplay')
      expect(result).not_to include('loop')
      expect(result).not_to include('muted')
    end
  end

  describe 'MIME type detection' do
    it 'correctly identifies MP4 videos' do
      result = render_tag('"/assets/videos/test.mp4"')
      expect(result).to include('type="video/mp4"')
    end

    it 'correctly identifies WebM videos' do
      result = render_tag('"/assets/videos/test.webm"')
      expect(result).to include('type="video/webm"')
    end

    it 'correctly identifies OGG videos' do
      result = render_tag('"/assets/videos/test.ogg"')
      expect(result).to include('type="video/ogg"')
    end

    it 'correctly identifies MOV videos' do
      result = render_tag('"/assets/videos/test.mov"')
      expect(result).to include('type="video/quicktime"')
    end

    it 'correctly identifies AVI videos' do
      result = render_tag('"/assets/videos/test.avi"')
      expect(result).to include('type="video/x-msvideo"')
    end

    it 'defaults to MP4 for unknown extensions' do
      result = render_tag('"/assets/videos/test.unknown"')
      expect(result).to include('type="video/mp4"')
    end

    it 'handles uppercase extensions' do
      result = render_tag('"/assets/videos/test.MP4"')
      expect(result).to include('type="video/mp4"')
    end
  end

  describe 'external URL rendering' do
    it 'renders a single video tag for external URLs' do
      result = render_tag('"https://example.com/video.mp4", class="video-fluid"')

      # Should contain video element
      expect(result).to include('<video')
      expect(result).to include('</video>')
      expect(result).to include('class="video-fluid"')

      # Should have source with data-lazy
      expect(result).to include('<source')
      expect(result).to include('data-lazy="@src https://example.com/video.mp4"')
    end

    it 'handles external URLs with query parameters' do
      result = render_tag('"https://example.com/video.mp4?quality=high&start=10"')
      expect(result).to include('data-lazy="@src https://example.com/video.mp4?quality=high&start=10"')
    end

    it 'includes controls by default for external videos' do
      result = render_tag('"https://example.com/video.mp4"')
      expect(result).to include('controls')
    end

    it 'handles all optional attributes for external URLs' do
      result = render_tag('"https://example.com/video.mp4", autoplay="true", loop="true", muted="true", class="my-video", style="width: 100%;", width="800", height="600"')
      expect(result).to include('autoplay')
      expect(result).to include('loop')
      expect(result).to include('muted')
      expect(result).to include('class="my-video"')
      expect(result).to include('style="width: 100%;"')
      expect(result).to include('width="800"')
      expect(result).to include('height="600"')
    end

    it 'includes correct MIME type for external videos' do
      result = render_tag('"https://example.com/video.webm"')
      expect(result).to include('type="video/webm"')
    end

    it 'includes fallback text for external videos' do
      result = render_tag('"https://example.com/video.mp4"')
      expect(result).to include('Your browser does not support the video tag.')
    end
  end

  describe 'URL detection' do
    it 'correctly identifies HTTP URLs as external' do
      result = render_tag('"http://example.com/video.mp4"')
      expect(result).to include('data-lazy="@src http://example.com/video.mp4"')
    end

    it 'correctly identifies HTTPS URLs as external' do
      result = render_tag('"https://example.com/video.mp4"')
      expect(result).to include('data-lazy="@src https://example.com/video.mp4"')
    end

    it 'treats relative paths as local' do
      result = render_tag('"/assets/videos/local.mp4"')
      expect(result).to include('-320px.mp4')
      expect(result).to include('-640px.mp4')
    end

    it 'treats absolute paths without protocol as local' do
      result = render_tag('"/var/www/videos/local.mp4"')
      expect(result).to include('-320px.mp4')
      expect(result).to include('-640px.mp4')
    end
  end

  describe 'variable resolution' do
    it 'resolves variables for video source' do
      context['myVideo'] = '/assets/videos/dynamic.mp4'
      template = Liquid::Template.parse("{% uj_video myVideo, class='dynamic-video' %}")
      result = template.render(context)
      expect(result).to include('data-lazy="@src /assets/videos/dynamic.mp4')
    end

    it 'resolves nested variables' do
      context['page'] = { 'hero' => { 'video' => 'https://example.com/hero.mp4' } }
      template = Liquid::Template.parse("{% uj_video page.hero.video, autoplay='true' %}")
      result = template.render(context)
      expect(result).to include('data-lazy="@src https://example.com/hero.mp4"')
    end
  end

  describe 'argument parsing' do
    it 'handles arguments with commas in values' do
      result = render_tag('"/assets/test.mp4", style="width: 100%; height: auto;"')
      expect(result).to include('style="width: 100%; height: auto;"')
    end

    it 'handles single quotes' do
      result = render_tag("'/assets/test.mp4', class='single-quotes'")
      expect(result).to include('class="single-quotes"')
    end

    it 'handles mixed quotes' do
      result = render_tag(%q{"/assets/test.mp4", class='mixed-quotes', style="border: 1px solid;"})
      expect(result).to include('class="mixed-quotes"')
      expect(result).to include('style="border: 1px solid;"')
    end
  end

  describe 'max_width breakpoint handling' do
    it 'generates only 320px source when max_width is 320' do
      result = render_tag('"/assets/videos/test.mp4", max_width="320"')
      expect(result).to include('-320px.mp4')
      expect(result).not_to include('-640px.mp4')
      expect(result).not_to include('-1024px.mp4')
    end

    it 'generates 320px and 640px sources when max_width is 640' do
      result = render_tag('"/assets/videos/test.mp4", max_width="640"')
      expect(result).to include('-320px.mp4')
      expect(result).to include('-640px.mp4')
      expect(result).not_to include('-1024px.mp4')
    end

    it 'generates 320px, 640px, and 1024px sources when max_width is 1024' do
      result = render_tag('"/assets/videos/test.mp4", max_width="1024"')
      expect(result).to include('-320px.mp4')
      expect(result).to include('-640px.mp4')
      expect(result).to include('-1024px.mp4')
      expect(result).not_to include('media="(min-width: 1025px)"')
    end

    it 'generates all sources when no max_width is specified' do
      result = render_tag('"/assets/videos/test.mp4"')
      expect(result).to include('-320px.mp4')
      expect(result).to include('-640px.mp4')
      expect(result).to include('-1024px.mp4')
      expect(result).to include('media="(min-width: 1025px)"')
    end
  end

  describe 'common use cases' do
    it 'renders background video with autoplay, loop, muted, and no controls' do
      result = render_tag('"/assets/videos/background.mp4", autoplay="true", loop="true", muted="true", playsinline="true", controls="false", class="bg-video"')
      expect(result).to include('autoplay')
      expect(result).to include('loop')
      expect(result).to include('muted')
      expect(result).to include('playsinline')
      expect(result).not_to include('controls')
      expect(result).to include('class="bg-video"')
    end

    it 'renders promotional video with poster and custom dimensions' do
      result = render_tag('"/assets/videos/promo.mp4", poster="/assets/images/promo-poster.jpg", width="1280", height="720", class="promo-video"')
      expect(result).to include('poster="/assets/images/promo-poster.jpg"')
      expect(result).to include('width="1280"')
      expect(result).to include('height="720"')
      expect(result).to include('class="promo-video"')
    end

    it 'renders mobile-optimized video with smaller max_width' do
      result = render_tag('"/assets/videos/mobile.mp4", max_width="640", playsinline="true"')
      expect(result).to include('playsinline')
      expect(result).to include('-320px.mp4')
      expect(result).to include('-640px.mp4')
      expect(result).not_to include('-1024px.mp4')
    end
  end
end
