# Libraries
require "jekyll"
require_relative '../helpers/variable_resolver'

module Jekyll
  class UJSocialTag < Liquid::Tag
    include UJPowertools::VariableResolver
    # Social platform URL patterns
    SOCIAL_URLS = {
      'facebook' => 'https://facebook.com/%s',
      'twitter' => 'https://twitter.com/%s',
      'linkedin' => 'https://linkedin.com/in/%s',
      'youtube' => 'https://youtube.com/@%s',
      'instagram' => 'https://instagram.com/%s',
      'tumblr' => 'https://%s.tumblr.com',
      'slack' => 'https://%s.slack.com',
      'discord' => 'https://discord.gg/%s',
      'github' => 'https://github.com/%s',
      'dev' => 'https://dev.to/%s',
      'tiktok' => 'https://tiktok.com/@%s',
      'twitch' => 'https://twitch.tv/%s',
      'soundcloud' => 'https://soundcloud.com/%s',
      'spotify' => 'https://open.spotify.com/user/%s',
      'mixcloud' => 'https://mixcloud.com/%s'
    }
    
    def initialize(tag_name, markup, tokens)
      super
      @markup = markup.strip
    end

    def render(context)
      # Resolve the platform name (handles both literals and variables)
      platform = resolve_input(context, @markup) || @markup
      
      # Get the social handle from page.resolved.socials.{platform}
      page = context['page']
      return '' unless page
      
      social_handle = page['resolved'] && page['resolved']['socials'] && page['resolved']['socials'][platform]
      return '' unless social_handle && !social_handle.empty?
      
      # Get the URL pattern for this platform
      url_pattern = SOCIAL_URLS[platform]
      return '' unless url_pattern
      
      # Build the URL
      url_pattern % social_handle
    end
    
    private
    
    # parse_argument and resolve_variable methods are now provided by VariableResolver module
  end
end

Liquid::Template.register_tag('uj_social', Jekyll::UJSocialTag)