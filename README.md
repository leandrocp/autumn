# Autumn

<!-- MDOC -->

<div align="center">
  <img src="https://raw.githubusercontent.com/leandrocp/autumn/main/assets/images/autumn_logo.png" width="512" alt="Autumn logo">
</div>

<p align="center">
  Syntax highlighter powered by tree-sitter and Neovim themes.
</p>

<div align="center">
  <a href="https://hex.pm/packages/autumn">
    <img alt="Hex Version" src="https://img.shields.io/hexpm/v/autumn">
  </a>

  <a href="https://hexdocs.pm/autumn">
    <img alt="Hex Docs" src="http://img.shields.io/badge/hex.pm-docs-green.svg?style=flat">
  </a>

  <a href="https://opensource.org/licenses/MIT">
    <img alt="MIT" src="https://img.shields.io/hexpm/l/autumn">
  </a>
</div>

<div align="center">
  <img src="https://raw.githubusercontent.com/leandrocp/autumn/main/assets/images/sample.png" alt="Sample">
</div>

## Features

- 60+ languages
- 100+ Neovim themes

## Installation

```elixir
def deps do
  [
    {:autumn, "~> 0.3"}
  ]
end
```

## Usage

_Inline styles with default "One Dark" theme:_

```elixir
iex> Autumn.highlight!("Atom.to_string(:elixir)", language: "elixir")
~s|<pre class=\"athl\" style=\"background-color: #282c33ff; color: #dce0e5ff;\"><code class=\"language-elixir\" translate=\"no\"><span style=\"color: #6eb4bfff;\">Atom</span><span style=\"color: #6eb4bfff;\">.</span><span style=\"color: #73ade9ff;\">to_string</span><span style=\"color: #b2b9c6ff;\">(</span><span style=\"color: #bf956aff;\">:elixir</span><span style=\"color: #b2b9c6ff;\">)</span></code></pre>|
```

_Inline styles with custom theme:_

```elixir
iex> Autumn.highlight!("setTimeout(fun, 5000);", language: "js", theme: Autumn.Themes.github_light())
~s|<pre class=\"athl\" style=\"background-color: #ffffffff; color: #1f2328ff;\"><code class=\"language-javascript\" translate=\"no\"><span style=\"color: #8250dfff;\">setTimeout</span><span style=\"color: #1f2328ff;\">(</span><span style=\"color: #1f2328ff;\">fun</span><span style=\"color: #1f2328ff;\">,</span> <span style=\"color: #0550aeff;\">5000</span><span style=\"color: #1f2328ff;\">)</span><span style=\"color: #1f2328ff;\">;</span></code></pre>|
```

_Linked styles:_

```elixir
iex> Autumn.highlight!("setTimeout(fun, 5000);", language: "js", formatter: :html_linked)
~s|<pre class=\"athl\"><code class=\"language-javascript\" translate=\"no\"><span class=\"athl-function\">setTimeout</span><span class=\"athl-punctuation athl-punctuation-bracket\">(</span><span class=\"athl-variable\">fun</span><span class=\"athl-punctuation athl-punctuation-delimiter\">,</span> <span class=\"athl-number\">5000</span><span class=\"athl-punctuation athl-punctuation-bracket\">)</span><span class=\"athl-punctuation athl-punctuation-delimiter\">;</span></code></pre>|
```

## Formatters

There are 2 modes to syntax highlight source code, the default is embedding inline styles in each one of the tokens and the other mode is linking external stylesheets.

### Inline

Less flexible but easier to use, that's the default formatter and will generate token with inline styles:

```html
<span style="color: #6eb4bfff;">MyApp</span>
```

### Linked

More flexible but requires loading one of the CSS theme files. Use the `:html_linked` formatter to generate classes for each token:

```elixir
iex> Autumn.highlight!("Atom.to_string(:elixir)", language: "elixir", formatter: :html_linked)
~s|<pre class=\"athl\"><code class=\"language-elixir\" translate=\"no\"><span class=\"athl-type\">Atom</span><span class=\"athl-operator\">.</span><span class=\"athl-function\">to_string</span><span class=\"athl-punctuation athl-punctuation-bracket\">(</span><span class=\"athl-string athl-string-special athl-string-special-symbol\">:elixir</span><span class=\"athl-punctuation athl-punctuation-bracket\">)</span></code></pre>|
```

And then you need to serve any of of the [available CSS themes](https://github.com/leandrocp/autumn/tree/main/priv/static/css) in your app.

If you're using Phoenix you can add the following `Plug` into your app's `endpoint.ex` file:

```elixir
plug Plug.Static,
  at: "/themes",
  from: {:autumn, "priv/static/css/"},
  only: ["dracula.css"] # choose any theme you want
```

The style will be served at `/themes/dracula.css`, which in your local env should resolve to http://localhost:4000/themes/dracula.css

Finally add the stylesheet link into your template, usually in `root.html.heex`:

```html
<link phx-track-static rel="stylesheet" href={~p"/themes/dracula.css"} />
```

You can also copy the content of that theme file into a `<style>` tag in your template or serve that file from a CDN.

## Themes

See the [Theme](Autumn.Theme.html) module docs for more info.

## Samples

Visit https://autumn-30n.pages.dev to see all available samples.

## Looking for help with your Elixir project?

<img src="https://raw.githubusercontent.com/leandrocp/autumn/main/assets/images/dockyard_logo.png" width="256" alt="DockYard logo">

At DockYard we are [ready to help you build your next Elixir project](https://dockyard.com/phoenix-consulting).
We have a unique expertise in Elixir and Phoenix development that is unmatched and we love to [write about Elixir](https://dockyard.com/blog/categories/elixir).

Have a project in mind? [Get in touch](https://dockyard.com/contact/hire-us)!

## Acknowledgements

* [Logo](https://www.flaticon.com/free-icons/fall) created by by pongsakornRed - Flaticon
* [Logo font](https://fonts.google.com/specimen/Sacramento) designed by [Astigmatic](http://www.astigmatic.com)
* [Makeup](https://hex.pm/packages/makeup) for setting up the baseline and for the inspiration
* [Inkjet](https://crates.io/crates/inkjet) for the Rust implementation up to v0.2 and for the inspiration
