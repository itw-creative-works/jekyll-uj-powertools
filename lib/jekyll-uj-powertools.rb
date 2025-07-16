# Libraries
require "jekyll"

module Jekyll
  # Load Filters
  require_relative "filters/main"

  # Load Generators
  require_relative "generators/inject-properties"

  # Load Hooks
  require_relative "hooks/inject-properties"

  # Load Tags
  # require_relative "tags/ifistruthy"
end
