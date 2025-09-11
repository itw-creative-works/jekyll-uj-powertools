# Libraries
# ...

# Hook
Jekyll::Hooks.register :site, :pre_render do |site|
  # Ensure uj config exists
  site.config['uj'] ||= {}

  # Set cache breaker
  site.config['uj']['cache_breaker'] = Jekyll::UJPowertools.cache_timestamp

  # Add date properties
  site.config['uj']['date'] ||= {}
  now = Time.now
  site.config['uj']['date']['year'] = now.year
  site.config['uj']['date']['month'] = now.month
  site.config['uj']['date']['day'] = now.day

  # Add placeholder
  site.config['uj']['placeholder'] ||= {}
  site.config['uj']['placeholder']['src'] = "data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw=="
end
