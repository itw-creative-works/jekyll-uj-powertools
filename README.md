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
