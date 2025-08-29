require 'jekyll'
require 'rspec/mocks/standalone'
require_relative '../lib/jekyll-uj-powertools'

# Create a test site
site = Jekyll::Site.new(Jekyll.configuration)

# Create a mock static file
static_file = double('StaticFile')
allow(static_file).to receive(:relative_path).and_return('assets/styles.css')
site.static_files << static_file

# Create context
context = Liquid::Context.new({}, {}, { site: site })

# Add debug info
puts "Static files count: #{site.static_files.length}"
site.static_files.each do |f|
  puts "  - #{f.relative_path}"
end

# Test the tag directly
template = Liquid::Template.parse("{% iffile assets/styles.css %}FILE EXISTS{% endiffile %}")
result = template.render(context)

puts "Result: '#{result}'"
puts "Expected: 'FILE EXISTS'"
puts "Match: #{result == 'FILE EXISTS'}"

# Also test with leading slash
template2 = Liquid::Template.parse("{% iffile /assets/styles.css %}FILE EXISTS{% endiffile %}")
result2 = template2.render(context)
puts "\nWith leading slash:"
puts "Result: '#{result2}'"