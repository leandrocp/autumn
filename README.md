# Autumn

<!-- MDOC -->

<p align="center">
  <img src="https://raw.githubusercontent.com/leandrocp/autumn/main/assets/images/autumn_logo.png" width="512" alt="Autumn logo">
</p>

<p align="center">
  Syntax highlighter for source code parsed with Tree-Sitter and styled with Helix Editor themes.
</p>

<p align="center">
  <a href="https://hex.pm/packages/autumn">
    <img alt="Hex Version" src="https://img.shields.io/hexpm/v/autumn">
  </a>

  <a href="https://hexdocs.pm/autumn">
    <img alt="Hex Docs" src="http://img.shields.io/badge/hex.pm-docs-green.svg?style=flat">
  </a>

  <a href="https://opensource.org/licenses/MIT">
    <img alt="MIT" src="https://img.shields.io/hexpm/l/autumn">
  </a>
</p>

## Features

- Support [multiple languages](https://github.com/leandrocp/autumn/blob/main/native/inkjet_nif/Cargo.toml#L16) and [100+ themes](https://github.com/leandrocp/autumn/tree/main/priv/themes). Check out some samples at https://autumn-30n.pages.dev
- Used by [MDEx](https://github.com/leandrocp/mdex) - a fast 100% CommonMark-compatible GitHub Flavored Markdown parser and formatter for Elixir
- Use Rust's [inkjet crate](https://crates.io/crates/inkjet) under the hood

## Installation

Add `:autumn` dependency:

```elixir
def deps do
  [
    {:autumn, "~> 0.1"}
  ]
end
```

## Usage

```elixir
Autumn.highlight!("elixir", "Atom.to_string(:elixir)") |> IO.puts()
#=> <pre class="autumn-hl" style="background-color: #282C34; color: #ABB2BF;">
#=>   <code class="language-elixir" translate="no">
#=>     <span class="ahl-namespace" style="color: #61AFEF;">Atom</span><span class="ahl-operator" style="color: #C678DD;">.</span><span class="ahl-function" style="color: #61AFEF;">to_string</span><span class="ahl-punctuation ahl-bracket" style="color: #ABB2BF;">(</span><span class="ahl-string ahl-special ahl-symbol" style="color: #98C379;">:elixir</span><span class="ahl-punctuation ahl-bracket" style="color: #ABB2BF;">)</span>
#=>   </code>
#=> </pre>
```

## Styles mode

There are 2 modes to syntax highlight source code, the default is embedding inline styles in each one of the generated tokens, and the other more effective is relying on CSS classes to style the tokens.

### Inline

Inlining styles will look like:

```html
<span class="ahl-operator" style="color: #C678DD;">Atom</span>
```

That mode is easy and works fine for simple cases but in pages with multiple code blocks you might want to use CSS instead.

### Linked

First you need to disable inline styles by passing `false` to the `:inline_style` option:

```elixir
Autumn.highlight!("elixir", "Atom.to_string(:elixir)", inline_style: false) |> IO.puts()
# rest ommited for brevity
# `style` is no longer generated
#=> <span class="ahl-operator">
```

And then you need to serve any of of the [available CSS themes](https://github.com/leandrocp/autumn/tree/main/priv/static/css) in your app.

If you're using Phoenix you can serve them from your app, just add the following `Plug` into your app's `endpoint.ex` file:

```elixir
plug Plug.Static,
  at: "/themes",
  from: {:autumn, "priv/static/css/"},
  only: ["dracula.css"] # choose any theme you want
```

The style will be served at `/themes/dracula.css`. In your local environemnt that resolves to http://localhost:4000/themes/dracula.css so finally add to your template:

```html
<link phx-track-static rel="stylesheet" href={~p"/themes/dracula.css"} />
```

You can also copy the content of that theme file into a `<style>` tag in your template or serve that file from a CDN.

## Samples

Visit https://autumn-30n.pages.dev to see all [available samples](https://github.com/leandrocp/autumn/tree/main/priv/generated/samples) like the ones below:

<img src="https://raw.githubusercontent.com/leandrocp/autumn/main/assets/images/elixir_onedark.png" alt="Elixir source code in onedark theme">
<img src="https://raw.githubusercontent.com/leandrocp/autumn/main/assets/images/elixir_github_light.png" alt="Elixir source code in github_light theme">

## Looking for help with your Elixir project?

<img src="https://raw.githubusercontent.com/leandrocp/autumn/main/assets/images/dockyard_logo.png" width="256" alt="DockYard logo">

At DockYard we are [ready to help you build your next Elixir project](https://dockyard.com/phoenix-consulting).
We have a unique expertise in Elixir and Phoenix development that is unmatched and we love to [write about Elixir](https://dockyard.com/blog/categories/elixir).

Have a project in mind? [Get in touch](https://dockyard.com/contact/hire-us)!

## Acknowledgements

* [Logo](https://www.flaticon.com/free-icons/fall) created by by pongsakornRed - Flaticon
* [Logo font](https://fonts.google.com/specimen/Sacramento) designed by [Astigmatic](http://www.astigmatic.com)
