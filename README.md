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
Now you can use the `uj_strip_ads` and `uj_json_escape` filters in your Jekyll site:

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

These examples show how you can use the features of `jekyll-uj-powertools` in your Jekyll site.

## 🔧 Development
After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## ⚠️ Testing
Run the tests
```shell
bundle install
bundle exec rspec
```

## 💎 Build + Publish the Gem
```shell
# Build the gem
gem build jekyll-uj-powertools.gemspec

# Publish the gem where X.X.X is the version number
gem push jekyll-uj-powertools-X.X.X.gem
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
