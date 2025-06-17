# Libraries
require 'json'
require 'net/http'
require 'fileutils'
require 'nokogiri'
require 'digest'

# Hook
Jekyll::Hooks.register :site, :post_write do |site|
  # Variables
  # Translation path
  CACHE_DIR = '.temp/translations'
  # Re-translate pages older than this many days
  RECHECK_DAYS = 30

  # Get target languages from site config
  target_langs = site.config.dig('translation', 'languages') || []

  # Log
  puts "🔁 Starting translation process for supported languages (#{target_langs.length}): #{target_langs.join(', ')}"
  puts "🔍 UJ_ environment variables:"
  ENV.select { |k, _| k.start_with?('UJ_') }.each { |k, v| puts "   #{k}=#{v}" }

  # Skip if site config translation is disabled
  unless site.config.dig('translation', 'enabled')
    puts "🚫 Translation is disabled in _config.yml (translation.enabled: false)"
    next
  end

  # Quit if UJ_BUILD_MODE is false
  if ENV['UJ_BUILD_MODE'] == 'false' && ENV['UJ_TRANSLATION_FORCE'] != 'true'
    puts "🚫 UJ_BUILD_MODE is set to 'false' (set UJ_TRANSLATION_FORCE=true). Exiting translation process."
    next
  end

  # Ensure OpenAI API key is set
  unless ENV['OPENAI_API_KEY'] && !ENV['OPENAI_API_KEY'].strip.empty?
    puts "❌ OPENAI_API_KEY not found in environment. Exiting translation process."
    next
  end

  # Quit if no languages are configured
  if target_langs.empty?
    puts "🚫 No target languages configured in _config.yml (translation.languages). Exiting translation process."
    next
  end

  # Keep track of skipped files
  skipped_files = []

  # Loop through all pages in the site
  site.pages.clone.each do |page|
    # Quit if its not an HTML page
    next unless page.output_ext == '.html'

    # Get original content
    original_content = page.output

    # Extract body content
    doc = Nokogiri::HTML(original_content)
    original_content_body = doc.at('body')&.inner_html.to_s

    # Compute original hash
    original_hash = Digest::SHA256.hexdigest(original_content_body)

    # Get page path and URL
    page_path = page.path.sub(/^_?site\//, '')
    page_url = page.url

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

    # Loop through target languages
    target_langs.each do |lang|
      page_new_url = "/#{lang}#{page.url}"
      page_new_path = File.join(CACHE_DIR, lang, page_new_url)
      page_new_meta_path = "#{page_new_path}.meta.json"

      # See if we only want to test a specific page
      uj_translation_only = ENV['UJ_TRANSLATION_ONLY']
      if uj_translation_only && page_path != uj_translation_only
        skipped_files << "#{page_path} (UJ_TRANSLATION_ONLY is set)"
        next
      end

      # Log
      puts "🌐 Processing page '#{page_url}' for language '#{lang}'"

      # LOG new_page.data
      # Log permalink
      puts "🔗 New permalink: #{page_new_url}"

      # Either read cached translation or generate a new one
      translated = read_or_translate(original_content_body, original_hash, lang, page_new_path, page_new_meta_path)

      # Fallback if translation failed
      if translated.nil?
        puts "⚠️ Translation failed for #{page_url}, using original content and marking for retry"

        # Force a retry next time by setting bad hash + old timestamp
        FileUtils.mkdir_p(File.dirname(page_new_meta_path))
        File.write(page_new_meta_path, {
          timestamp: 0,
          hash: '__fail__'
        }.to_json)

        translated = original_content_body
      end

      # Rewrite internal links
      translated_html = rewrite_links(translated, lang)

      # Inject translated content into original HTML structure
      translated_doc = Nokogiri::HTML(original_content)
      translated_doc.at('body').inner_html = translated_html
      final_html = translated_doc.to_html

      # Determine output path
      output_dir = site.config['destination']
      translated_output_path = File.join(output_dir, lang, page.url)
      translated_output_path = File.join(translated_output_path, 'index.html') if translated_output_path.end_with?('/')

      # Write translated page to disk
      FileUtils.mkdir_p(File.dirname(translated_output_path))
      File.write(translated_output_path, final_html)
      puts "✅ Wrote translated file: #{translated_output_path}"
    end
  end

  # Log skipped files at the end
  if skipped_files.any?
    puts "\n🚫 Skipped files:"
    skipped_files.each { |f| puts " - #{f}" }
  end

  # Log
  puts "🎉 Translation process complete."
end

def read_or_translate(content, hash, lang, path, page_new_meta_path)
  if File.exist?(path) && File.exist?(page_new_meta_path)
    meta = JSON.parse(File.read(page_new_meta_path)) rescue {}
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

  # Log before/after content
  puts "\n--- BEFORE CONTENT (#{lang}) ---\n#{content[0..500]}..."

  # Translate the content using OpenAI API
  begin
    result = translate_with_api(content, lang)
  rescue => e
    puts "❌ Skipping translation for '#{lang}' due to error: #{e.message}"
    return nil
  end

  # Log the first 500 characters of the result
  puts "\n--- AFTER TRANSLATION (#{lang}) ---\n#{result[0..500]}..."

  # Save the translation and metadata
  FileUtils.mkdir_p(File.dirname(path))
  File.write(path, result)
  File.write(page_new_meta_path, {
    timestamp: Time.now.to_i,
    hash: hash
  }.to_json)

  puts "📝 Cached translation and metadata written to: #{path}"

  result
end

def translate_with_api(content, lang)
  system_prompt = "You are a professional translator. Translate the provided HTML content, preserving all original formatting, HTML structure, metadata, and links. Do not explain anything — just return the translated HTML. Translate to #{lang}."
  user_message = content

  uri = URI('https://api.openai.com/v1/chat/completions')

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.read_timeout = 30  # seconds
  http.open_timeout = 10  # seconds

  request = Net::HTTP::Post.new(uri.path, {
    'Authorization' => "Bearer #{ENV['OPENAI_API_KEY']}",
    'Content-Type' => 'application/json'
  })

  request.body = {
    model: 'gpt-4o',
    messages: [
      { role: 'system', content: system_prompt },
      { role: 'user', content: user_message }
    ],
    temperature: 0.3,
    max_tokens: 4096
  }.to_json

  response = http.request(request)

  if response.code.to_i != 200
    raise "HTTP #{response.code}: #{response.body}"
  end

  json = JSON.parse(response.body)
  puts "🔍 API response: #{json.inspect}"
  result = json.dig('choices', 0, 'message', 'content')

  if result.nil? || result.strip.empty?
    raise "Translation returned empty or invalid content"
  end

  puts "🔤 Translation complete."
  result
end

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
