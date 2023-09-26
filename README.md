# Autumn

[![Documentation](http://img.shields.io/badge/hex.pm-docs-green.svg?style=flat)](https://hexdocs.pm/autumn)
[![Package](https://img.shields.io/hexpm/v/autumn.svg)](https://hex.pm/packages/autumn)

<!-- MDOC -->

Syntax highlighter for source code parsed with Tree-Sitter and styled with Helix Editor themes.

Support [multiple languages](https://github.com/leandrocp/autumn/blob/06767957a26bf1217aab7c082645eda0635d711c/native/inkjet_nif/Cargo.toml#L21) and [100+ themes](https://github.com/leandrocp/autumn/tree/main/priv/generated/themes).

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
#=> <pre class="autumn highlight background" style="background-color: #282C34; ">
#=> <code class="language-elixir">
#=> <span class="namespace" style="color: #61AFEF; ">Atom</span>
#=> <span class="operator" style="color: #C678DD; ">.</span>
#=> <span class="function" style="color: #61AFEF; ">to_string</span>
#=> <span class="text" style="color: #ABB2BF; ">(</span>
#=> <span class="string" style="color: #98C379; ">:elixir</span>
#=> <span class="text" style="color: #ABB2BF; ">)</span>
#=> </code></pre>

Autumn.highlight!("rb", "Math.sqrt(9)", theme: "dracula") |> IO.puts()
#=> <pre class="autumn highlight background" style="background-color: #282A36; ">
#=> <code class="language-rb">
#=> <span class="constructor" style="color: #BD93F9; ">Math</span>
#=> <span class="punctuation delimiter" style="color: #f8f8f2; ">.</span>
#=> <span class="function method" style="color: #50fa7b; ">sqrt</span>
#=> <span class="punctuation bracket" style="color: #f8f8f2; ">(</span>
#=> <span class="constant numeric" style="color: #BD93F9; ">9</span>
#=> <span class="punctuation bracket" style="color: #f8f8f2; ">)</span>
#=> </code></pre>
```

## Samples

A set of samples is available at [priv/generated/samples](https://github.com/leandrocp/autumn/tree/main/priv/generated/samples) as the ones belows:

![elixir_onedark](https://raw.github.com/leandrocp/autumn/main/assets/elixir_onedark.png)
![elixir_github_light](https://raw.github.com/leandrocp/autumn/main/assets/elixir_github_light.png)

## Acknowledgements

[Inkjet](https://crates.io/crates/inkjet) for providing the underlying lib to load language grammars.
