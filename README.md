# Autumn

<!-- MDOC -->

<div align="center">
  <img src="https://raw.githubusercontent.com/leandrocp/autumn/main/assets/images/autumn_logo.png" width="512" alt="Autumn logo">
</div>

<p align="center">
  Syntax highlighter powered by Tree-sitter and Neovim themes.
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

- 🌳 60+ languages with tree-sitter parsing
- 🎨 100+ Neovim themes
- 📝 HTML output with inline or linked styles
- 🖥️ Terminal output with ANSI colors
- 🔍 Language auto-detection
- 🎯 Customizable formatting options
- ✨ Line highlighting with custom styling
- 🎁 Custom HTML wrappers for code blocks

## Installation

```elixir
def deps do
  [
    {:autumn, "~> 0.3"}
  ]
end
```

## Usage

### Basic Usage (HTML Inline)

```elixir
iex> Autumn.highlight!("Atom.to_string(:elixir)", language: "elixir")
~s|<pre class="athl" style="color: #abb2bf; background-color: #282c34;"><code class="language-elixir" translate="no" tabindex="0"><span class="line" data-line="1"><span style="color: #e5c07b;">Atom</span><span style="color: #56b6c2;">.</span><span style="color: #61afef;">to_string</span><span style="color: #c678dd;">(</span><span style="color: #e06c75;">:elixir</span><span style="color: #c678dd;">)</span>
</span></code></pre>|
```

See the HTML Linked and Terminal formatters below for more options.

### Language Auto-detection

```elixir
iex> Autumn.highlight!("#!/usr/bin/env bash\nID=1")
~s|<pre class="athl" style="color: #abb2bf; background-color: #282c34;"><code class="language-bash" translate="no" tabindex="0"><span class="line" data-line="1"><span style="color: #c678dd;">#!/usr/bin/env bash</span>
</span><span class="line" data-line="2"><span style="color: #d19a66;">ID</span><span style="color: #56b6c2;">=</span><span style="color: #d19a66;">1</span>
</span></code></pre>|
```

### Themes

Themes are sourced from popular Neovim colorschemes.

Use `Autumn.available_themes/0` to list all available themes. You can specify a theme by name directly in the `:theme` option, or use `Autumn.Theme.get/1` to get a specific theme struct if you need to inspect or manipulate its styles.

```elixir
# Using theme name
iex> Autumn.highlight!("setTimeout(fun, 5000);", language: "js", theme: "github_light")
~s|<pre class="athl" style="color: #1f2328; background-color: #ffffff;"><code class="language-javascript" translate="no" tabindex="0"><span class="line" data-line="1"><span style="color: #6639ba;">setTimeout</span><span style="color: #1f2328;">(</span><span style="color: #1f2328;">fun</span><span style="color: #1f2328;">,</span> <span style="color: #0550ae;">5000</span><span style="color: #1f2328;">)</span><span style="color: #1f2328;">;</span>
</span></code></pre>|

# Using theme struct
iex> theme = Autumn.Theme.get("github_light")
iex> Autumn.highlight!("setTimeout(fun, 5000);", language: "js", theme: theme)
```

#### Bring Your Own Theme

You can also load custom themes from JSON files or strings:

```elixir
# Load from JSON file
{:ok, theme} = Autumn.Theme.from_file("/path/to/your/theme.json")
Autumn.highlight!("your code", theme: theme)

# Load from JSON string
theme_json = ~s({"name": "my_theme", "appearance": "dark", "highlights": {"comment": {"fg": "#808080"}}})
{:ok, theme} = Autumn.Theme.from_json(theme_json)
Autumn.highlight!("your code", theme: theme)
```

## Incomplete or Malformed code

It's also capable of handling incomplete or malformed code, useful for streaming like in a ChatGPT interface:

```elixir
iex> Autumn.highlight!("const header = document.getEl", language: "js")
~s|<pre class="athl" style="color: #abb2bf; background-color: #282c34;"><code class="language-javascript" translate="no" tabindex="0"><span class="line" data-line="1"><span style="color: #c678dd;">const</span> <span style="color: #abb2bf;">header</span> <span style="color: #abb2bf;">=</span> <span style="color: #e86671;">document</span><span style="color: #848b98;">.</span><span style="color: #56b6c2;">getEl</span>
</span></code></pre>|
```

## Formatters

Autumn supports three output formatters:

Both HTML formatters wrap each line in a `<span class="line">` element with a `data-line` attribute containing the line number, making it easy to add line numbers or implement line-based features in your application.

### HTML Inline (Default)

Generates HTML with inline styles for each token:

```elixir
iex> Autumn.highlight!("Atom.to_string(:elixir)", language: "elixir", formatter: :html_inline)
# or with options
iex> Autumn.highlight!("Atom.to_string(:elixir)", language: "elixir", formatter: {:html_inline, pre_class: "my-code", italic: true, include_highlights: true})
```

Options:
- `:pre_class` - CSS class for the `<pre>` tag
- `:italic` - enable italic styles
- `:include_highlights` - include highlight scope names in `data-highlight` attributes
- `:highlight_lines` - highlight specific lines with custom styling
- `:header` - wrap the highlighted code with custom HTML elements

#### Line Highlighting

```elixir
# Default: theme-based highlighting using cursorline from current theme
highlight_lines = %{
  lines: [2..4, 6]  # Mix integers and ranges for flexible line specification
  # style defaults to :theme, which uses the cursorline highlight from theme
}

# Or with explicit theme styling  
theme_highlight_lines = %{
  lines: [1..2],
  style: :theme  # uses cursorline highlight from theme
}

# Or with custom CSS styling
custom_highlight_lines = %{
  lines: [2..4, 6],  # Multiple lines: 2..4, Single line: 6
  style: "background-color: #fff3cd; border-left: 3px solid #ffc107;"
}

Autumn.highlight!(code, language: "elixir", formatter: {:html_inline, highlight_lines: highlight_lines})
```

#### Custom HTML Wrapper

```elixir
# Wrap code with custom HTML elements
header = %{
  open_tag: "<div class='code-wrapper' data-language='elixir'>",
  close_tag: "</div>"
}

Autumn.highlight!(code, language: "elixir", formatter: {:html_inline, header: header})
```

### HTML Linked

Generates HTML with CSS classes for styling:

```elixir
iex> Autumn.highlight!("Atom.to_string(:elixir)", language: "elixir", formatter: :html_linked)
# or with options
iex> Autumn.highlight!("Atom.to_string(:elixir)", language: "elixir", formatter: {:html_linked, pre_class: "my-code"})
```

Options:
- `:pre_class` - CSS class for the `<pre>` tag
- `:highlight_lines` - highlight specific lines with custom CSS class
- `:header` - wrap the highlighted code with custom HTML elements

#### Line Highlighting with CSS Classes

```elixir
# Highlight lines with a CSS class
highlight_lines = %{
  lines: [1..3, 7..8],
  class: "highlighted-line"
}

Autumn.highlight!(code, language: "elixir", formatter: {:html_linked, highlight_lines: highlight_lines})
```

You'll need to style the CSS class in your stylesheet:

```css
.highlighted-line {
  background-color: #fff3cd;
  border-left: 3px solid #ffc107;
}
```

To use linked styles, you need to include one of the [available CSS themes](https://github.com/leandrocp/autumn/tree/main/priv/static/css) in your app.

For Phoenix apps, add this to your `endpoint.ex`:

```elixir
plug Plug.Static,
  at: "/themes",
  from: {:autumn, "priv/static/css/"},
  only: ["dracula.css"] # choose any theme you want
```

Then add the stylesheet to your template:

```html
<link phx-track-static rel="stylesheet" href={~p"/themes/dracula.css"} />
```

### Terminal

Generates ANSI escape codes for terminal output:

```elixir
iex> Autumn.highlight!("Atom.to_string(:elixir)", language: "elixir", formatter: :terminal)
# or with options
iex> Autumn.highlight!("Atom.to_string(:elixir)", language: "elixir", formatter: {:terminal, italic: true})
```

Options:
- `:italic` - enable italic styles (if supported by your terminal)

## Advanced Usage

### Combining Multiple Features

You can combine line highlighting, custom HTML wrappers, and themes for rich code presentation:

```elixir
# Create highlighted lines for errors or important sections
error_lines = %{
  lines: [3, 7..9],  # Single line 3, and lines 7-9
  style: "background-color: #f8d7da; border-left: 4px solid #dc3545;"
}

# Wrap with semantic HTML
code_wrapper = %{
  open_tag: "<article class='code-example' data-language='elixir' data-theme='dracula'>",
  close_tag: "</article>"
}

# Combine everything
Autumn.highlight!(code, 
  language: "elixir",
  formatter: {
    :html_inline, 
    theme: "dracula",
    highlight_lines: error_lines,
    header: code_wrapper,
    include_highlights: true
  }
)
```

## Samples

Visit https://autumnus.dev to check out some examples.

## Acknowledgements

* [Logo](https://www.flaticon.com/free-icons/fall) created by by pongsakornRed - Flaticon
* [Logo font](https://fonts.google.com/specimen/Sacramento) designed by [Astigmatic](http://www.astigmatic.com)
* [Makeup](https://hex.pm/packages/makeup) for setting up the baseline and for the inspiration
* [Inkjet](https://crates.io/crates/inkjet) for the Rust implementation up to v0.2 and for the inspiration
