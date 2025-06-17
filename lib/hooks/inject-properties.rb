# Libraries
# ...

# Hook
Jekyll::Hooks.register :site, :pre_render do |site|
  site.config['uj'] ||= {}
  site.config['uj']['cache_breaker'] = Jekyll::UJPowertools.cache_timestamp
end
