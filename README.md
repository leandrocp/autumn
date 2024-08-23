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

- Support [50+ languages](https://github.com/leandrocp/autumn/blob/main/native/autumn/Cargo.toml) and [100+ themes](https://github.com/leandrocp/autumn/tree/main/priv/themes). Check out some samples at https://autumn-30n.pages.dev
- Used by [MDEx](https://github.com/leandrocp/mdex) - a fast and extensible Markdown parser and formatter
- Use Rust's [inkjet crate](https://crates.io/crates/inkjet) under the hood

## Installation

Add `:autumn` dependency:

```elixir
def deps do
  [
    {:autumn, "~> 0.2"}
  ]
end
```

## Usage

```elixir
Autumn.highlight!("Atom.to_string(:elixir)", language: "elixir") |> IO.puts()
#=> <pre class="athl" style="background-color: #282C34;">
#=>   <code class="language-elixir" translate="no">
#=>     <span data-hl-name="namespace" style="color: #61AFEF;">Atom</span><span data-hl-name="operator" style="color: #C678DD;">.</span><span data-hl-name="function" style="color: #61AFEF;">to_string</span><span data-hl-name="punctuation.bracket" style="color: #ABB2BF;">(</span><span data-hl-name="string.special.symbol" style="color: #98C379;">:elixir</span><span data-hl-name="punctuation.bracket" style="color: #ABB2BF;">)</span>
#=>   </code>
#=> </pre>
```

## Style modes

There are 2 modes to syntax highlight source code, the default is embedding inline styles in each one of the generated tokens and the other is through a linked stylesheet.

### Inline

The default mode so no additional option is required. Less flexible but easier to use, it generates each token with the [highlight name](https://tree-sitter.github.io/tree-sitter/syntax-highlighting#theme) and the matching theme style:

```html
<span data-hl-name="namespace" style="color: #61AFEF;">Atom</span>
```

### Linked

More flexible but requires loading one of the CSS theme files.

First you need to disable inline styles by passing `false` to the `:inline_style` option:

```elixir
Autumn.highlight!("Atom.to_string(:elixir)", language: "elixir", inline_style: false) |> IO.puts()
# ... rest ommited for brevity
# `data-hl-name` and `style` are no longer generated, now only class is used to match styles
#=> <span class="athl-namespace">Atom</span>
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

Finally add the stylesheet link into your template, normally `root.html.heex`:

```html
<link phx-track-static rel="stylesheet" href={~p"/themes/dracula.css"} />
```

You can also copy the content of that theme file into a `<style>` tag in your template or serve it file from a CDN.

## Override colors

_To properly override colors you should use the linked mode that is more flexible, although you can still override colors in inline mode._

You can override colors on 2 levels: either change the color var or the highlight class styles.

A CSS theme usually looks like the above example. Note that the `green` color is applied to both `string` and `type` highlights:

```css
:root {
  /* palette */
  --athl-green: #98C379;
}
/* highlight names */
.athl-string {
  color: var(--athl-green);
}
.athl-type {
  color: var(--athl-green);
}
```

Then you can manipulate the theme file in your app by changing either the `green` color var:

```css
body > pre.athl {
  /* string and type will be lightgreen now */
  --athl-green: lightgreen;
}
```

Or you can only change specific tokens:

```css
pre.athl .athl-string {
  /* only `strings` will be lightgreen, keep `type` with the original color */
  color: lightgreen;
}
```

And it's also possible to override only specific languages:

```css
/* override colors for Elixir code */
body > pre.athl code.language-elixir

/* override tokens for Elixir code */
pre.athl code.language-elixir .athl-string
```

Some themes may not match the highlight names exactly, causing colors to look wrong. For example the "dracula" theme on Elixir code lacks some colors
that you can fix with the following CSS:

```css
pre.athl .athl-namespace { color: var(--athl-cyan); }
pre.athl .athl-operator { color: var(--athl-pink); }
pre.athl .athl-variable-other-member { color: var(--athl-green); }
```

## Autumn or Makeup?

Makeup is a well-established syntax highlighter that works well, particularly for Elixir code, but it's not without trade-offs.

Creating and maintaining languages for Makeup requires writing custom lexers that output a list of tokes in a format only accepted by that lib.
This inevitably increases the effort necessary to add support for new languages and maintain the lexer in sync with upstream changes,
not to mention it doesn't have the concept of injections to parse more than one language used in the same source code, for example, the `~H` sigil in Elixir modules.

Themes (styles) can be converted from Pygments and it's relatively straightforward to keep them in sync but the list of styles is not extensive
so you might not find the theme you're looking for, although that's a minor issue.

Autumn on the other hand is based on tree-sitter, a library that has been widely adopted officially by many communities, including Elixir,
and modern editors are using it to syntax highlight source code, making it a more future-proof and viable solution.
So we can offer support for many languages and themes out of the box, wit a low maintenance cost.

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
* [Makeup](https://hex.pm/packages/makeup) for setting up the baseline and for the inspiration
* [Inkjet](https://crates.io/crates/inkjet) for providing the tree-sitter bindings and language configs