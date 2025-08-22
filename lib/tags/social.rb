# Libraries
require "jekyll"

module Jekyll
  class UJSocialTag < Liquid::Tag
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
      # Parse the platform name (can be quoted or unquoted)
      platform_input = parse_argument(@markup)
      
      # Resolve the platform name (could be a variable or literal string)
      platform = resolve_variable(context, platform_input)
      
      # If it didn't resolve to anything, use the input as a literal string
      platform = platform_input if platform.nil? || platform.empty?
      
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
    
    def parse_argument(markup)
      # Remove quotes if present
      cleaned = markup.strip
      if (cleaned.start_with?('"') && cleaned.end_with?('"')) ||
         (cleaned.start_with?("'") && cleaned.end_with?("'"))
        cleaned[1..-2]
      else
        cleaned
      end
    end
    
    def resolve_variable(context, variable_name)
      # Handle nested variable access like page.social
      parts = variable_name.split('.')
      current = context
      
      parts.each do |part|
        return nil unless current.respond_to?(:[]) || current.is_a?(Hash)
        current = current[part]
        return nil if current.nil?
      end
      
      current
    end
  end
end

Liquid::Template.register_tag('uj_social', Jekyll::UJSocialTag)