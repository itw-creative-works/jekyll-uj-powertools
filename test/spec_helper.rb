require 'simplecov'

SimpleCov.start do
  add_filter '/test/'
  add_filter '/spec/'
  
  add_group 'Filters', 'lib/filters'
  add_group 'Generators', 'lib/generators'
  add_group 'Hooks', 'lib/hooks'
  add_group 'Tags', 'lib/tags'
  
  minimum_coverage 100
  
  track_files 'lib/**/*.rb'
end

require 'jekyll-uj-powertools'