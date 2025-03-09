# Autumn

<!-- MDOC -->

<div align="center">
  <img src="https://raw.githubusercontent.com/leandrocp/autumn/main/assets/images/autumn_logo.png" width="512" alt="Autumn logo">
</div>

<p align="center">
  Syntax highlighter powered by tree-sitter and Neovim themes.
</p>

<p align="center">
  <a href="https://autumnus.dev">https://autumnus.dev</a>
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

_Inline styles with default `"onedark"` theme:_

```elixir
iex> Autumn.highlight!("Atom.to_string(:elixir)", language: "elixir")
~s|<pre class="athl" style="color: #abb2bf; background-color: #282c34;"><code class="language-elixir" translate="no" tabindex="0"><span class="line" data-line="1"><span style="color: #e5c07b;">Atom</span><span style="color: #56b6c2;">.</span><span style="color: #61afef;">to_string</span><span style="color: #c678dd;">(</span><span style="color: #e06c75;">:elixir</span><span style="color: #c678dd;">)</span>
</span></code></pre>|
```

_Inline styles with custom theme:_

```elixir
iex> Autumn.highlight!("setTimeout(fun, 5000);", language: "js", theme: "github_light")
~s|<pre class="athl" style="color: #1f2328; background-color: #ffffff;"><code class="language-javascript" translate="no" tabindex="0"><span class="line" data-line="1"><span style="color: #6639ba;">setTimeout</span><span style="color: #1f2328;">(</span><span style="color: #1f2328;">fun</span><span style="color: #1f2328;">,</span> <span style="color: #0550ae;">5000</span><span style="color: #1f2328;">)</span><span style="color: #1f2328;">;</span>
</span></code></pre>|
```

_Linked styles:_

```elixir
iex> Autumn.highlight!("setTimeout(fun, 5000);", language: "js", formatter: :html_linked)
~s|<pre class="athl"><code class="language-javascript" translate="no" tabindex="0"><span class="line" data-line="1"><span class="function-call">setTimeout</span><span class="punctuation-bracket">(</span><span class="variable">fun</span><span class="punctuation-delimiter">,</span> <span class="number">5000</span><span class="punctuation-bracket">)</span><span class="punctuation-delimiter">;</span>
</span></code></pre>|
```

_Terminal_:
```
"\e[0m\e[38;2;97;175;239msetTimeout\e[0m\e[0m\e[38;2;198;120;221m(\e[0m\e[0m\e[38;2;224;108;117mfun\e[0m\e[0m\e[38;2;171;178;191m,\e[0m \e[0m\e[38;2;209;154;102m5000\e[0m\e[0m\e[38;2;198;120;221m)\e[0m\e[0m\e[38;2;171;178;191m;\e[0m"
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
