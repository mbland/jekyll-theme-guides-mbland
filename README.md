## [`guides_style_mbland`](https://rubygems.org/gems/guides_style_mbland): Guides style gem for Jekyll

[![Build Status](https://travis-ci.org/mbland/guides-style-mbland.svg?branch=master)](https://travis-ci.org/mbland/guides-style-mbland)

Provides consistent style elements for Guides generated using [Jekyll][]. Originally based on [DOCter][] from [CFPB][].

[Jekyll]: https://jekyllrb.com/
[DOCter]: https://github.com/cfpb/docter/
[CFPB]:   https://cfpb.github.io/

### Usage

In your [`Gemfile`][gemfile], include the following:

[gemfile]: http://bundler.io/gemfile.html

```ruby
group :jekyll_plugins do
  gem 'guides_style_mbland'
end
```

Add an `assets/css/styles.scss` file that contains at least the following:

```scss
---
---

@import "guides_style_mbland";
```

Then in your [`_config.yml` file](https://jekyllrb.com/docs/configuration/),
add the following (you may need to remove any `layout:`
[front matter](https://jekyllrb.com/docs/frontmatter/) from existing pages for
this to take effect):

```yaml
theme: guides_style_mbland

defaults:
  -
    scope:
      path: ""
    values:
      layout: "default"
```

Build the site per usual, and observe the results.

### Additional features

Here are some other features that can be enabled via `_config.yml`:

```yaml
# This adds the "back to" breadcrumb link under the page title:
back_link:
  url: "https://guides.example.com/"
  text: Read more Guides

# If you use Analytics, add your code here:
google_analytics_ua: UA-????????-??

# If you want all of the navigation bar entries expanded by default, add this
# property and it to true:
expand_nav: true
```

### Additional scripts and styles

If you'd like to add additional scripts or styles to every page on the site,
you can add `styles:` and `scripts:` lists to `_config.yml`. To add them to a
particular page, add these lists to the page's front matter.

### Alternate navigation bar titles

If you want a page to have a different title in the navigation bar than that
of the page itself, add a `navtitle:` property to the page's front matter:

```md
---
title: Since brevity is the soul of wit, I'll be brief.
navtitle: Polonius's advice
---
```

### Selectively expanding navigation bar items

If you wish to expand or contract specific navigation bar items, add the
`expand_nav:` property to those items in the `navigation:` list in
`_config.yml`. For example, the `Update the config file` entry will expand
since the default `expand_nav` property is `true`, but `Add a new page` will
remain collapsed:

```yaml
expand_nav: true

navigation:
- text: Introduction
  internal: true
- text: Add a new page
  url: add-a-new-page/
  internal: true
  expand_nav: false
  children:
  - text: Make a child page
    url: make-a-child-page/
    internal: true
- text: Update the config file
  url: update-the-config-file/
  internal: true
  children:
  - text: Understanding the `baseurl:` property
    url: understanding-baseurl/
    internal: true
```

### Development

First, choose a Jekyll site you'd like to use to view the impact of your
updates and clone its repository; then clone this repository into the same
parent directory. For example, to use the Guides Template:

```shell
$ git clone git@github.com:mbland/guides-template-mbland.git
$ git clone git@github.com:mbland/guides-style-mbland.git
```

In the `Gemfile` of the Jekyll site's repository, include the following:

```ruby
group :jekyll_plugins do
  gem 'guides_style_mbland', :path => '../guides-style-mbland'
end
```

You can find the different style assets and templates within subdirectories of
the `assets` and `lib/guides_style_mbland` directories of this repository. Edit
those, then rebuild the Jekyll site as usual to see the results.

### Open Source License

This software is made available as [Open Source software][oss-def] under the
[ISC License][].  For the text of the license, see the [LICENSE](LICENSE.md)
file.

[oss-def]:     https://opensource.org/osd-annotated
[isc license]: https://www.isc.org/downloads/software-support-policy/isc-license/

### Prior work

This was adapted from my previous [18F/guides-style][style-old] implementation.

[style-old]: https://github.com/18F/guides-style
