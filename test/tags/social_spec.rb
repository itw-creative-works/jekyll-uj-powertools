require_relative '../spec_helper'

RSpec.describe Jekyll::UJSocialTag do
  let(:page_data) do
    {
      'resolved' => {
        'socials' => {
          'twitter' => 'myusername',
          'github' => 'octocat',
          'linkedin' => 'john-doe-123',
          'youtube' => 'channelname',
          'instagram' => 'my_insta',
          'tumblr' => 'myblog',
          'tiktok' => 'user123',
          'facebook' => 'john.doe.5',
          'dev' => 'johndoe',
          'discord' => 'xyz123',
          'slack' => 'myworkspace',
          'twitch' => 'gamer123',
          'soundcloud' => 'artist',
          'spotify' => '12345',
          'mixcloud' => 'djname'
        }
      }
    }
  end
  
  let(:site) { Jekyll::Site.new(Jekyll.configuration) }
  let(:context) { Liquid::Context.new({ 'page' => page_data }, {}, { site: site }) }

  def render_tag(markup)
    template = Liquid::Template.parse("{% uj_social #{markup} %}")
    template.render(context)
  end

  describe 'basic social link generation' do
    it 'generates Twitter link' do
      result = render_tag('twitter')
      expect(result).to eq('https://twitter.com/myusername')
    end

    it 'generates GitHub link' do
      result = render_tag('github')
      expect(result).to eq('https://github.com/octocat')
    end

    it 'generates LinkedIn link' do
      result = render_tag('linkedin')
      expect(result).to eq('https://linkedin.com/in/john-doe-123')
    end

    it 'generates YouTube link with @ prefix' do
      result = render_tag('youtube')
      expect(result).to eq('https://youtube.com/@channelname')
    end

    it 'generates Instagram link' do
      result = render_tag('instagram')
      expect(result).to eq('https://instagram.com/my_insta')
    end

    it 'generates Tumblr subdomain link' do
      result = render_tag('tumblr')
      expect(result).to eq('https://myblog.tumblr.com')
    end

    it 'generates TikTok link with @ prefix' do
      result = render_tag('tiktok')
      expect(result).to eq('https://tiktok.com/@user123')
    end

    it 'generates Facebook link' do
      result = render_tag('facebook')
      expect(result).to eq('https://facebook.com/john.doe.5')
    end

    it 'generates Dev.to link' do
      result = render_tag('dev')
      expect(result).to eq('https://dev.to/johndoe')
    end

    it 'generates Discord invite link' do
      result = render_tag('discord')
      expect(result).to eq('https://discord.gg/xyz123')
    end

    it 'generates Slack workspace link' do
      result = render_tag('slack')
      expect(result).to eq('https://myworkspace.slack.com')
    end

    it 'generates Twitch link' do
      result = render_tag('twitch')
      expect(result).to eq('https://twitch.tv/gamer123')
    end

    it 'generates SoundCloud link' do
      result = render_tag('soundcloud')
      expect(result).to eq('https://soundcloud.com/artist')
    end

    it 'generates Spotify user link' do
      result = render_tag('spotify')
      expect(result).to eq('https://open.spotify.com/user/12345')
    end

    it 'generates Mixcloud link' do
      result = render_tag('mixcloud')
      expect(result).to eq('https://mixcloud.com/djname')
    end
  end

  describe 'quoted arguments' do
    it 'handles single-quoted platform names' do
      result = render_tag("'twitter'")
      expect(result).to eq('https://twitter.com/myusername')
    end

    it 'handles double-quoted platform names' do
      result = render_tag('"github"')
      expect(result).to eq('https://github.com/octocat')
    end
  end

  describe 'edge cases' do
    it 'returns empty string when platform not found' do
      result = render_tag('unknown')
      expect(result).to eq('')
    end

    it 'returns empty string when social handle is nil' do
      page_data['resolved']['socials']['twitter'] = nil
      result = render_tag('twitter')
      expect(result).to eq('')
    end

    it 'returns empty string when social handle is empty' do
      page_data['resolved']['socials']['twitter'] = ''
      result = render_tag('twitter')
      expect(result).to eq('')
    end

    it 'returns empty string when page has no resolved data' do
      context_without_resolved = Liquid::Context.new({ 'page' => {} }, {}, { site: site })
      template = Liquid::Template.parse("{% uj_social twitter %}")
      result = template.render(context_without_resolved)
      expect(result).to eq('')
    end

    it 'returns empty string when page is nil' do
      context_without_page = Liquid::Context.new({}, {}, { site: site })
      template = Liquid::Template.parse("{% uj_social twitter %}")
      result = template.render(context_without_page)
      expect(result).to eq('')
    end

    it 'handles spaces around platform name' do
      result = render_tag('  twitter  ')
      expect(result).to eq('https://twitter.com/myusername')
    end
  end

  describe 'special URL patterns' do
    it 'adds @ prefix for YouTube' do
      page_data['resolved']['socials']['youtube'] = 'nochannel'
      result = render_tag('youtube')
      expect(result).to eq('https://youtube.com/@nochannel')
    end

    it 'adds @ prefix for TikTok' do
      page_data['resolved']['socials']['tiktok'] = 'noprofile'
      result = render_tag('tiktok')
      expect(result).to eq('https://tiktok.com/@noprofile')
    end

    it 'creates subdomain for Tumblr' do
      page_data['resolved']['socials']['tumblr'] = 'coolblog'
      result = render_tag('tumblr')
      expect(result).to eq('https://coolblog.tumblr.com')
    end

    it 'creates subdomain for Slack' do
      page_data['resolved']['socials']['slack'] = 'workspace'
      result = render_tag('slack')
      expect(result).to eq('https://workspace.slack.com')
    end
  end

  describe 'variable resolution' do
    it 'resolves platform name from context variable' do
      context['social'] = 'twitter'
      template = Liquid::Template.parse("{% uj_social social %}")
      result = template.render(context)
      expect(result).to eq('https://twitter.com/myusername')
    end

    it 'resolves different platforms from variables' do
      context['platform'] = 'github'
      template = Liquid::Template.parse("{% uj_social platform %}")
      result = template.render(context)
      expect(result).to eq('https://github.com/octocat')
    end

    it 'handles nested variable access' do
      context['site'] = { 'current_social' => 'linkedin' }
      template = Liquid::Template.parse("{% uj_social site.current_social %}")
      result = template.render(context)
      expect(result).to eq('https://linkedin.com/in/john-doe-123')
    end

    it 'falls back to literal string when variable not found' do
      # Clear any existing variables
      context['twitter'] = nil
      template = Liquid::Template.parse("{% uj_social twitter %}")
      result = template.render(context)
      expect(result).to eq('https://twitter.com/myusername')
    end

    it 'returns empty string when variable resolves to invalid platform' do
      context['social'] = 'invalid_platform'
      template = Liquid::Template.parse("{% uj_social social %}")
      result = template.render(context)
      expect(result).to eq('')
    end
  end
end