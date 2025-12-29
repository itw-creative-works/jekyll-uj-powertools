<p align="center">
  <a href="https://cdn.itwcreativeworks.com/assets/itw-creative-works/images/logo/itw-creative-works-brandmark-black-x.svg">
    <img src="https://cdn.itwcreativeworks.com/assets/itw-creative-works/images/logo/itw-creative-works-brandmark-black-x.svg" width="100px">
  </a>
</p>

<p align="center">
  <img src="https://img.shields.io/gem/v/jekyll-uj-powertools">
  <br>
  <!-- <img src="https://img.shields.io/librariesio/release/npm/jekyll-uj-powertools.svg"> -->
  <img src="https://img.shields.io/github/repo-size/itw-creative-works/jekyll-uj-powertools">
  <img src="https://img.shields.io/codeclimate/maintainability-percentage/itw-creative-works/jekyll-uj-powertools.svg">
  <img src="https://img.shields.io/gem/dt/jekyll-uj-powertools">
  <!-- <img src="https://img.shields.io/node/v/jekyll-uj-powertools.svg"> -->
  <img src="https://img.shields.io/website/https/itwcreativeworks.com.svg">
  <img src="https://img.shields.io/github/license/itw-creative-works/jekyll-uj-powertools.svg">
  <img src="https://img.shields.io/github/contributors/itw-creative-works/jekyll-uj-powertools.svg">
  <img src="https://img.shields.io/github/last-commit/itw-creative-works/jekyll-uj-powertools.svg">
  <br>
  <br>
  <a href="https://itwcreativeworks.com">Site</a> | <a href="https://rubygems.org/gems/jekyll-uj-powertools">Gem Page</a> | <a href="https://github.com/itw-creative-works/jekyll-uj-powertools">GitHub Repo</a>
  <br>
  <br>
  Meet <strong>jekyll-uj-powertools</strong>, your new best friend for developing with <a href="https://github.com/itw-creative-works/ultimate-jekyll">Ultimate jekyll</a>
</p>

## 🦄 Features
* Powerful utility for Jekyll sites
* `uj_strip_ads` filter to remove ads from a string
* `uj_json_escape` filter to escape JSON characters

# 🌐 Jekyll::uj-powertools
Meet `jekyll-uj-powertools`, the powerful set of utilities for Jekyll users.

It includes functions to remove ads from strings and escape JSON characters, making your Jekyll site cleaner and more efficient.

## 📦 Installation
Install the gem and add to the application's Gemfile by executing:
```shell
bundle add jekyll-uj-powertools
```

If bundler is not being used to manage dependencies, install the gem by executing:
```shell
gem install jekyll-uj-powertools
```

## ⚡️ Usage
Now you can use all the custom filters and variables provided by `jekyll-uj-powertools` in your Jekyll site.

## Filters
### `uj_strip_ads` Filter
Remove ads from a string, such as a blog post or article.

```liquid
{{ post.content | uj_strip_ads }}
```

### `uj_json_escape` Filter
Escape JSON characters in a string making it safe to use in a JSON object.

```liquid
{{ post.content | uj_json_escape }}
```

### `uj_title_case` Filter
Convert a string to title case.

```liquid
{{ "hello world" | uj_title_case }}
```

### `uj_pluralize` Filter
Return the singular or plural form of a word based on a count.

```liquid
{{ 1 | uj_pluralize: 'post', 'posts' }}
<!-- Output: post -->

{{ 5 | uj_pluralize: 'post', 'posts' }}
<!-- Output: posts -->

{{ 0 | uj_pluralize: 'item', 'items' }}
<!-- Output: items -->

<!-- Plural is optional - defaults to singular + 's' -->
{{ 3 | uj_pluralize: 'comment' }}
<!-- Output: comments -->

<!-- Works with irregular plurals -->
{{ 2 | uj_pluralize: 'child', 'children' }}
<!-- Output: children -->
```

### `uj_commaify` Filter
Format numbers with commas for better readability (e.g., 10000 becomes 10,000).

```liquid
{{ 10000 | uj_commaify }}
<!-- Output: 10,000 -->

{{ 1234567890 | uj_commaify }}
<!-- Output: 1,234,567,890 -->

{{ 1234.56 | uj_commaify }}
<!-- Output: 1,234.56 -->
```

### `uj_content_format` Filter
Process content with Liquid templating and Markdown conversion, automatically transforming markdown and liquid into HTML intelligently based on the file type.

```liquid
{{ post.content | uj_content_format }}
```

This filter:
- Transforms markdown images `![alt](url)` to `{% uj_image "url", alt="alt", class="..." %}`
- Automatically pulls image class from `page.resolved.theme.blog.image.class`
- Processes Liquid tags in the content
- Converts Markdown to HTML (for .md files)

If no class is specified in frontmatter, the `uj_image` tag will be rendered without a class attribute.

#### Frontmatter Configuration Example
```yaml
---
theme:
  blog:
    image:
      class: "img-fluid rounded-3 shadow"
---
```

With this frontmatter, all markdown images in the post will automatically use the specified class.

## Global Variables
### `site.uj.cache_breaker` Variable
Use the `site.uj.cache_breaker` variable to append a cache-busting query parameter to your assets.

```liquid
<link rel="stylesheet" href="{{ "/assets/css/style.css" | prepend: site.baseurl }}?v={{ site.uj.cache_breaker }}">
```

## Page Variables
### `page.random_id` Variable
Generate a random ID for each page, useful for sorting randomly or for unique identifiers.

```liquid
<!-- Sort pages in a random order -->
{% assign sorted_pages = site.pages | sort: "random_id" %}
{% for page in sorted_pages %}
  <h2>{{ page.title }}</h2>
  <p>Random ID: {{ page.random_id }}</p>
  <p>{{ page.content }}</p>
{% endfor %}
```

### `page.extension` Variable
Get the file extension of the current page, useful for determining how to process or display the page.

```liquid
<!-- Check the extension of a page -->
{% if page.extension == "html" %}
  <p>This is an HTML page.</p>
{% elsif page.extension == "md" %}
  <p>This is a Markdown page.</p>
{% endif %}
```

### `page.layout_data` Variable
Access the layout data of the page object, which can be useful for accessing layout-specific variables when looping through pages.

```liquid
<!-- Loop through pages and access the layout data of each page -->
{% for page in site.pages %}
  <h2>{{ page.title }}</h2>
  <p>{{ page.layout_data.description }}</p>
{% endfor %}
```

### `page.resolved` Variable
Resolves the site, layout, and page data into a single object, which can be useful for accessing all the information about the current page in one place.

```liquid
<!-- New Way -->
{{ page.resolved.my.variable }}

<!-- Old Way -->
{{ page.my.variable | default: layout.my.variable | default: site.my.variable }}
```

## Tags
### `iftruthy` Tag
A custom Liquid tag that checks if a variable is truthy (not nil, not false, not empty string, not 0) and renders the content inside the tag if it is truthy.
```liquid
{% iftruthy my_variable %}
  <p>This content will only be rendered if my_variable is truthy.</p>
{% endiftruthy %}
```

### `iffalsy` Tag
A custom Liquid tag that checks if a variable is falsy (nil, false, empty string, or 0) and renders the content inside the tag if it is falsy.
```liquid
{% iffalsy my_variable %}
  <p>This content will only be rendered if my_variable is falsy.</p>
{% endifalsy %}
```

### `uj_icon` Tag
A custom Liquid tag that renders a Font Awesome icon with the specified style and name. It supports `name` and `class` parameters.
```liquid
{% uj_icon "rocket", "fa-lg me-2" %}
```

### `uj_logo` Tag
A custom Liquid tag that renders company logos from the Ultimate Jekyll Manager assets. It supports brandmarks and combomarks in various colors.

Parameters:
- `name` (required): The logo name (e.g., "jira", "fitbit", "github")
- `type` (optional): "brandmarks" (default) or "combomarks"
- `color` (optional): "original" (default) or any other color variant (e.g., "white", "black")

```liquid
{% uj_logo "jira" %}
{% uj_logo "fitbit", "combomarks" %}
{% uj_logo "slack", "brandmarks", "white" %}
{% uj_logo site.company.logo, "combomarks", "black" %}
```

The tag supports dynamic variables and will resolve them from the context:
```liquid
{% uj_logo page.sponsor.logo %}
{% uj_logo site.partner.name, site.partner.type, site.partner.color %}
```

### `uj_fake_comments` Tag
Generates a fake comment count based on content word count for demonstration purposes.
```liquid
{% uj_fake_comments %}
{% uj_fake_comments page.content %}
```

### `uj_image` Tag
Renders responsive images with WebP support and lazy loading.
```liquid
{% uj_image "/assets/images/hero.jpg", max_width="1024", alt="Hero image" %}
{% uj_image page.featured_image, class="img-fluid", webp="false" %}
```

### `uj_language` Tag
Converts ISO language codes to language names in English or native format.
```liquid
{% uj_language "es" %}
{% uj_language page.language, "native" %}
```

### `uj_member` Tag
Retrieves member information from site team collection.
```liquid
{% uj_member "john-doe", "name" %}
{% uj_member page.author, "url" %}
{% uj_member member_id, "image" %}
{% uj_member "john-doe", "image-tag", max_width="640", class="team-photo" %}
```

The `image-tag` property renders a responsive image using the `uj_image` tag with all its features (WebP, lazy loading, responsive sizes). You can pass any `uj_image` options as additional parameters.

### `uj_post` Tag
Fetches post data from site collections.
```liquid
{% uj_post "my-post-slug", "title" %}
{% uj_post post.id, "description" %}
{% uj_post current_post, "image-url" %}
```

### `uj_readtime` Tag
Calculates estimated reading time based on content (200 words per minute).
```liquid
{% uj_readtime %}
{% uj_readtime page.content %}
```

### `uj_social` Tag
Generates social media URLs from platform handles.
```liquid
{% uj_social "twitter" %}
{% uj_social "github" %}
```

### `uj_translation_url` Tag
Creates language-specific URLs for multilingual sites.
```liquid
{% uj_translation_url "es", page.url %}
{% uj_translation_url target_lang, "/pricing" %}
```

## Generators

### Dynamic Pages Generator
Automatically generate pages from collection data based on frontmatter fields. This is useful for creating category, tag, or any taxonomy pages dynamically without manually creating each page.

#### Configuration
Add to your `_config.yml`:

```yaml
generators:
  collection_categories:
    # Example 1: Extract category from nested frontmatter field
    - collection: recipes
      field: recipe.cuisine       # Dot notation for nested fields
      layout: recipe-category
      permalink: /recipes/:slug
      title: ":name Recipes"
      description: "Browse our collection of :name recipes."

    # Example 2: Simple frontmatter field
    - collection: products
      field: category
      layout: product-category
      permalink: /products/:slug
      title: ":name Products"
      description: "Shop our :name products."

    # Example 3: Minimal config (uses defaults)
    - collection: articles
      field: category
      layout: article-category
```

#### Template Variables
Use these placeholders in `title`, `description`, and `permalink`:
- `:name` - The formatted category name (e.g., "Asian Cuisine")
- `:slug` - The URL-safe slug (e.g., "asian-cuisine")

#### Defaults
- `permalink`: `/:collection/:slug` (e.g., `/recipes/asian`)
- `title`: `:name`
- `description`: `Browse our collection of :name.`

#### Generated Page Data
Each generated page includes the following data accessible in the layout:
- `page.title` - The formatted title
- `page.description` - The formatted description
- `page.category_slug` - URL-safe slug (e.g., "asian-cuisine")
- `page.category_name` - Human-readable name (e.g., "Asian Cuisine")
- `page.collection_name` - Source collection name (e.g., "recipes")
- `page.meta.title` - SEO title with site name appended
- `page.meta.description` - SEO description

#### Example Layout
Create a layout file (e.g., `_layouts/recipe-category.html`) to display the category page:

```liquid
---
layout: default
---
<h1>{{ page.category_name }}</h1>
<p>{{ page.description }}</p>

{% assign items = site.recipes | where_exp: "item", "item.recipe.cuisine == page.category_name" %}
{% for item in items %}
  <article>
    <h2><a href="{{ item.url }}">{{ item.title }}</a></h2>
  </article>
{% endfor %}
```

## Development Config (`_config.dev.yml`)
Speed up dev builds by limiting collections. Create `_config.dev.yml` in your Jekyll source:

```yaml
limit_collections:
  recipes: 50
  products: 20
```

Run with: `bundle exec jekyll serve --config _config.yml,_config.dev.yml`

UJ auto-loads this file in dev mode.

## Final notes
These examples show how you can use the features of `jekyll-uj-powertools` in your Jekyll site.

## 🔧 Development
After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## ⚠️ Testing
Run the tests
```shell
bundle install && bundle exec rspec
```

Test in your [Ultimate Jekyll Site](http://github.com/itw-creative-works/ultimate-jekyll)
```shell
npm start -- --ujPluginDevMode=true
```

## 💎 Build + Publish the Gem
To release a new version, update the version number in the `.gemspec` and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

```shell
# Release
bundle exec rake release

# Clear the files in the pkg folder
rm -rf pkg/*
```

## 🗨️ Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/itw-creative-works/jekyll-uj-powertools.

## 📚 Projects Using this Library
* [ITW Creative Works](https://itwcreativeworks.com)
* [Somiibo](https://somiibo.com)
* [Slapform](https://slapform.com)
* [StudyMonkey](https://studymonkey.ai)
* [DashQR](https://dashqr.com)
* [Replyify](https://replyify.app)
* [SoundGrail](https://soundgrail.com)
* [Trusteroo](https://trusteroo.com)

Ask us to have your project listed! :)
