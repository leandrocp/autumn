# Autumn

[![Documentation](http://img.shields.io/badge/hex.pm-docs-green.svg?style=flat)](https://hexdocs.pm/autumn)
[![Package](https://img.shields.io/hexpm/v/live_monaco_editor.svg)](https://hex.pm/packages/autumn)

Syntax highlighter for source code using Tree-Sitter parsing and Helix Editor themes.

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
Autumn.highlight("elixir", ":elixir")
#=> <pre class="highlight"><code class="language-elixir">
#=> <span style="color: #ff79c6">:elixir</span>
#=> </code></pre>

Autumn.highlight("elixir", ":elixir", theme: "Dracula")
#=> TODO
```
## Roadmap
- [ ] Change theme
- [ ] Load themes and langs with https://crates.io/crates/lazy_static
- [ ] Option to disable italic
- [ ] Option to disable bold
- [ ] Option to disable underline
