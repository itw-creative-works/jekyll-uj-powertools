# Libraries
require "jekyll"

module Jekyll
  # Load Filters
  require_relative "filters/main"

  # Load Generators
  require_relative "generators/inject-properties"

  # Load Hooks
  require_relative "hooks/inject-properties"
  require_relative "hooks/markdown-images"

  # Load Tags
  require_relative "tags/external"
  require_relative "tags/fake_comments"
  require_relative "tags/icon"
  require_relative "tags/iffalsy"
  require_relative "tags/iffile"
  require_relative "tags/iftruthy"
  require_relative "tags/image"
  require_relative "tags/language"
  require_relative "tags/logo"
  require_relative "tags/member"
  require_relative "tags/post"
  require_relative "tags/readtime"
  require_relative "tags/social"
  require_relative "tags/translation_url"
  require_relative "tags/urlmatches"
  require_relative "tags/video"
end
