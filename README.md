# Autumn

<!-- MDOC -->

<p align="center">
  <img src="https://raw.githubusercontent.com/leandrocp/autumn/main/assets/images/autumn_logo.png" width="512" alt="Autumn logo">
</p>

<p align="center">
  Syntax highlighter for source code parsed with [Tree-Sitter](https://tree-sitter.github.io/tree-sitter/syntax-highlighting) and styled with [Helix Editor](https://helix-editor.com) themes.
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
#=> <pre style="background-color: #282C34; color: #ABB2BF;">
#=> <code class="autumn-hl language-elixir" translate="no">
#=> <span class="ahl-namespace" style="color: #61AFEF;">Atom</span><span class="ahl-operator" style="color: #C678DD;">.</span><span class="ahl-function" style="color: #61AFEF;">to_string</span><span class="ahl-foreground" style="color: #ABB2BF;">(</span><span class="ahl-string" style="color: #98C379;">:elixir</span><span class="ahl-foreground" style="color: #ABB2BF;">)</span>
#=> </code>
#=> </pre>

Autumn.highlight!("rb", "Math.sqrt(9)", theme: "dracula") |> IO.puts()
#=> <pre style="background-color: #282A36; color: #f8f8f2;">
#=> <code class="autumn-hl language-ruby" translate="no">
#=> <span class="ahl-constructor" style="color: #BD93F9;">Math</span><span class="ahl-punctuation-delimiter" style="color: #f8f8f2;">.</span><span class="ahl-function-method" style="color: #50fa7b;">sqrt</span><span class="ahl-punctuation-bracket" style="color: #f8f8f2;">(</span><span class="ahl-constant-numeric" style="color: #BD93F9;">9</span><span class="ahl-punctuation-bracket" style="color: #f8f8f2;">)</span>
#=> </code>
#=> </pre>
```

## Styles mode

To apply styles to code blocks, you can choose either to embed inline styles or serve static CSS.

By default it will generate tokens with an inline style like:

```html
<span class="ahl-namespace" style="color: #61AFEF;">Atom</span>
```

That's easy to get started but not efficient especially when you have multiple code blocks in the same page.

But you can opt out generating embed styles and leave only classes with the `:inline_style` option:

```elixir
Autumn.highlight!("elixir", "Atom.to_string(:elixir)", inline_style: false) |> IO.puts()
# rest ommited for brevity
#=> <span class="ahl-namespace">
```

And serve any of of the [available CSS themes](https://github.com/leandrocp/autumn/tree/main/priv/static/css) in your app,
if using Phoenix you can serve them from your app's Endpoint:

```elixir
plug Plug.Static,
  at: "/themes",
  from: {:autumn, "priv/static/css/"},
  only: ["dracula.css"]
```

Or copy the file and serve as needed.

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
