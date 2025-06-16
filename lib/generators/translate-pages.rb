require 'json'
require 'net/http'
require 'fileutils'
require 'nokogiri'
require 'digest'

module Jekyll
  class TranslatePages < Generator
    safe true
    priority :low

    # Variables
    # Translation path
    CACHE_DIR = '.temp/translations'
    # Re-translate pages older than this many days
    RECHECK_DAYS = 30

    def generate(site)
      target_langs = site.config.dig('translation', 'languages') || []

      # Log
      puts "🔁 Starting translation process for supported languages: #{target_langs.join(', ')}"
      puts "📂 Cache directory: #{CACHE_DIR}"
      # puts "🔍 All environment variables:"
      # ENV.each { |k, v| puts "   #{k}=#{v}" }
      puts "🔍 UJ_ environment variables:"
      ENV.select { |k, _| k.start_with?('UJ_') }.each { |k, v| puts "   #{k}=#{v}" }

      # Skip if site config translation is disabled
      unless site.config.dig('translation', 'enabled')
        puts "🚫 Translation is disabled in _config.yml (translation.enabled: false)"
        return
      end

      # Ensure OpenAI API key is set
      unless ENV['OPENAI_API_KEY'] && !ENV['OPENAI_API_KEY'].strip.empty?
        puts "❌ OPENAI_API_KEY not found in environment. Exiting translation process."
        return
      end

      # Quit if no languages are configured
      if target_langs.empty?
        puts "🚫 No target languages configured in _config.yml (translation.languages). Exiting translation process."
        return
      end

      # Keep track of skipped files
      skipped_files = []

      # Loop through all pages in the site
      site.pages.clone.each do |page|
        next unless page.output_ext == '.html'
        original_content = page.content
        original_hash = Digest::SHA256.hexdigest(original_content)
        page_path = page.path.sub(/^_?site\//, '')

        # Skip if page.translation.enabled is false
        if page.data['translation'] && page.data['translation']['enabled'] == false
          skipped_files << "#{page_path} (translation disabled)"
          next
        end

        # Skip if page.redirect.url is set
        if page.data['redirect'] && page.data['redirect']['url']
          skipped_files << "#{page_path} (redirect set)"
          next
        end

        target_langs.each do |lang|
          translated_path = File.join(CACHE_DIR, lang, page_path)
          meta_path = "#{translated_path}.meta.json"

          # @TODO: Remove this
          # Unless its pages/legal/terms.md, QUIT
          if page_path != 'pages/legal/terms.md'
            skipped_files << "#{page_path} (only 'pages/legal/terms.md' is processed)"
            next
          end

          # Log
          puts "🌐 Processing page '#{page_path}' for language '#{lang}'"

          # Either read cached translation or generate a new one
          translated = read_or_translate(original_content, original_hash, lang, translated_path, meta_path)

          next unless translated # skip this lang if translation failed

          # Build new page with translated content
          new_page = page.dup
          new_page.data = page.data.dup
          new_page.data['lang'] = lang
          new_page.data['permalink'] = "/#{lang}#{page.url}"
          new_page.content = rewrite_links(translated, lang)

          site.pages << new_page
          puts "✅ Added translated page: /#{lang}#{page.url}"
        end
      end

      # Log skipped files at the end
      if skipped_files.any?
        puts "\n🚫 Skipped files:"
        skipped_files.each { |f| puts " - #{f}" }
      end

      puts "🎉 Translation process complete."
    end

    private

    # Return cached translation or generate new one via API
    def read_or_translate(content, hash, lang, path, meta_path)
      if File.exist?(path) && File.exist?(meta_path)
        meta = JSON.parse(File.read(meta_path)) rescue {}
        last_hash = meta['hash']
        last_time = Time.at(meta['timestamp'].to_i) rescue Time.at(0)

        age_days = ((Time.now - last_time) / (60 * 60 * 24)).round
        puts "📅 Cache age: #{age_days}/#{RECHECK_DAYS} days"

        # Determine whether we should re-check based on age
        recheck_due_to_age = RECHECK_DAYS && RECHECK_DAYS > 0 && age_days >= RECHECK_DAYS

        # Re-translate if hash changed or translation is too old (only if RECHECK_DAYS is truthy)
        if last_hash == hash && !recheck_due_to_age
          puts "📦 Using cached translation at: #{path}"
          return File.read(path)
        else
          puts "🔁 Cache stale or hash changed, regenerating translation..."
        end
      else
        puts "📭 No cache found, generating translation..."
      end

      begin
        result = translate_with_api(content, lang)
      rescue => e
        puts "❌ Skipping translation for '#{lang}' due to error: #{e.message}"
        return nil
      end

      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, result)
      File.write(meta_path, {
        timestamp: Time.now.to_i,
        hash: hash
      }.to_json)

      puts "📝 Cached translation and metadata written to: #{path}"

      # Log before/after content
      puts "\n--- BEFORE CONTENT (#{lang}) ---\n#{content[0..500]}..."
      puts "\n--- AFTER TRANSLATION (#{lang}) ---\n#{result[0..500]}..."

      result
    end

    # Perform translation via OpenAI API
    def translate_with_api(content, lang)
      system_prompt = "You are a professional translator. Translate the provided HTML content, preserving all original formatting, HTML structure, metadata, and links. Do not explain anything — just return the translated HTML. Translate to #{lang}."
      user_message = content

      uri = URI('https://api.openai.com/v1/chat/completions')

      res = Net::HTTP.post(
        uri,
        {
          model: 'gpt-4',
          messages: [
            { role: 'system', content: system_prompt },
            { role: 'user', content: user_message }
          ],
          temperature: 0.3
        }.to_json,
        {
          'Authorization' => "Bearer #{ENV['OPENAI_API_KEY']}",
          'Content-Type' => 'application/json'
        }
      )

      if res.code.to_i != 200
        raise "HTTP #{res.code}: #{res.body}"
      end

      json = JSON.parse(res.body)
      result = json.dig('choices', 0, 'message', 'content')

      if result.nil? || result.strip.empty?
        raise "Translation returned empty or invalid content"
      end

      puts "🔤 Translation complete."
      result
    end

    # Rewrite internal links to language-prefixed versions
    def rewrite_links(html, lang)
      doc = Nokogiri::HTML::DocumentFragment.parse(html)
      doc.css('a[href^="/"]').each do |a|
        href = a['href']
        next if href.start_with?("/#{lang}") || href.include?('.') || href.start_with?('//')
        new_href = "/#{lang}#{href}"
        puts "🔗 Rewriting link: #{href} -> #{new_href}"
        a['href'] = new_href
      end
      doc.to_html
    end
  end
end
