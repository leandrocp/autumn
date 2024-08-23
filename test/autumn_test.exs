defmodule AutumnTest do
  use ExUnit.Case, async: true

  defp assert_output(source_code, expected, opts \\ []) do
    result = Autumn.highlight!(source_code, opts)
    IO.puts(result)
    assert String.trim(result) == String.trim(expected)
  end

  # FIXME: update deprecated tests
  describe "deprecated still works" do
    test "highlight" do
      assert {:ok, hl} = Autumn.highlight("elixir", ":test")
      assert hl =~ "#e06c75"

      assert {:ok, hl} = Autumn.highlight("elixir", ":test", theme: "dracula")
      assert hl =~ "#bd93f9"
    end

    test "highlight!" do
      assert Autumn.highlight!("elixir", ":test") =~ "#e06c75"
      assert Autumn.highlight!("elixir", ":test", theme: "dracula") =~ "#bd93f9"
    end

    test "inline_mode" do
      assert {:ok, hl} = Autumn.highlight(":test", language: "elixir", inline_style: true)
      assert hl =~ "#e06c75"
    end
  end

  test "available_languages" do
    assert Autumn.available_languages() ==
             ["bash", "diff", "elixir", "plain", "text"]
  end

  test "available_themes" do
    assert Autumn.available_themes() ==
             [
               {"Andromeda", &Autumn.Themes.andromeda/0},
               {"Atelier Cave Dark", &Autumn.Themes.atelier_cave_dark/0},
               {"Atelier Cave Light", &Autumn.Themes.atelier_cave_light/0},
               {"Atelier Dune Dark", &Autumn.Themes.atelier_dune_dark/0},
               {"Atelier Dune Light", &Autumn.Themes.atelier_dune_light/0},
               {"Atelier Estuary Dark", &Autumn.Themes.atelier_estuary_dark/0},
               {"Atelier Estuary Light", &Autumn.Themes.atelier_estuary_light/0},
               {"Atelier Forest Dark", &Autumn.Themes.atelier_forest_dark/0},
               {"Atelier Forest Light", &Autumn.Themes.atelier_forest_light/0},
               {"Atelier Heath Dark", &Autumn.Themes.atelier_heath_dark/0},
               {"Atelier Heath Light", &Autumn.Themes.atelier_heath_light/0},
               {"Atelier Lakeside Dark", &Autumn.Themes.atelier_lakeside_dark/0},
               {"Atelier Lakeside Light", &Autumn.Themes.atelier_lakeside_light/0},
               {"Atelier Plateau Dark", &Autumn.Themes.atelier_plateau_dark/0},
               {"Atelier Plateau Light", &Autumn.Themes.atelier_plateau_light/0},
               {"Atelier Savanna Dark", &Autumn.Themes.atelier_savanna_dark/0},
               {"Atelier Savanna Light", &Autumn.Themes.atelier_savanna_light/0},
               {"Atelier Seaside Dark", &Autumn.Themes.atelier_seaside_dark/0},
               {"Atelier Seaside Light", &Autumn.Themes.atelier_seaside_light/0},
               {"Atelier Sulphurpool Dark", &Autumn.Themes.atelier_sulphurpool_dark/0},
               {"Atelier Sulphurpool Light", &Autumn.Themes.atelier_sulphurpool_light/0},
               {"Ayu Dark", &Autumn.Themes.ayu_dark/0},
               {"Ayu Light", &Autumn.Themes.ayu_light/0},
               {"Ayu Mirage", &Autumn.Themes.ayu_mirage/0},
               {"Catppuccin Frappé", &Autumn.Themes.catppuccin_frappe/0},
               {"Catppuccin Frappé - No Italics", &Autumn.Themes.catppuccin_frappe_no_italics/0},
               {"Catppuccin Latte", &Autumn.Themes.catppuccin_latte/0},
               {"Catppuccin Latte - No Italics", &Autumn.Themes.catppuccin_latte_no_italics/0},
               {"Catppuccin Macchiato", &Autumn.Themes.catppuccin_macchiato/0},
               {"Catppuccin Macchiato - No Italics", &Autumn.Themes.catppuccin_macchiato_no_italics/0},
               {"Catppuccin Mocha", &Autumn.Themes.catppuccin_mocha/0},
               {"Catppuccin Mocha - No Italics", &Autumn.Themes.catppuccin_mocha_no_italics/0},
               {"Dracula", &Autumn.Themes.dracula/0},
               {"Github Dark", &Autumn.Themes.github_dark/0},
               {"Github Dark Colorblind", &Autumn.Themes.github_dark_colorblind/0},
               {"Github Dark Dimmed", &Autumn.Themes.github_dark_dimmed/0},
               {"Github Dark High Contrast", &Autumn.Themes.github_dark_high_contrast/0},
               {"Github Dark Tritanopia", &Autumn.Themes.github_dark_tritanopia/0},
               {"Github Light", &Autumn.Themes.github_light/0},
               {"Github Light Colorblind", &Autumn.Themes.github_light_colorblind/0},
               {"Github Light High Contrast", &Autumn.Themes.github_light_high_contrast/0},
               {"Github Light Tritanopia", &Autumn.Themes.github_light_tritanopia/0},
               {"Gruvbox Dark", &Autumn.Themes.gruvbox_dark/0},
               {"Gruvbox Dark Hard", &Autumn.Themes.gruvbox_dark_hard/0},
               {"Gruvbox Dark Soft", &Autumn.Themes.gruvbox_dark_soft/0},
               {"Gruvbox Light", &Autumn.Themes.gruvbox_light/0},
               {"Gruvbox Light Hard", &Autumn.Themes.gruvbox_light_hard/0},
               {"Gruvbox Light Soft", &Autumn.Themes.gruvbox_light_soft/0},
               {"One Dark", &Autumn.Themes.one_dark/0},
               {"One Light", &Autumn.Themes.one_light/0},
               {"Rosé Pine", &Autumn.Themes.rose_pine/0},
               {"Rosé Pine Dawn", &Autumn.Themes.rose_pine_dawn/0},
               {"Rosé Pine Moon", &Autumn.Themes.rose_pine_moon/0},
               {"Sandcastle", &Autumn.Themes.sandcastle/0},
               {"Solarized Dark", &Autumn.Themes.solarized_dark/0},
               {"Solarized Light", &Autumn.Themes.solarized_light/0},
               {"Summercamp", &Autumn.Themes.summercamp/0}
             ]
  end

  describe "formatter: inline" do
    test "with default opts" do
      assert_output(
        "defmodule Test do\n  @lang :elixir\nend",
        ~s"""
        <pre class="athl" style="background-color: hsl(220 13% 27%); color: hsl(220 12% 81%);"><code class="language-elixir" translate="no"><span style="color: hsl(282 48% 64%);">defmodule</span> <span style="color: hsl(188 39% 59%);">Test</span> <span style="color: hsl(282 48% 64%);">do</span>
          <span style="color: hsl(188 39% 59%);">@</span><span style="color: hsl(211 73% 68%);">lang</span> <span style="color: hsl(30 40% 58%);">:elixir</span>
        <span style="color: hsl(282 48% 64%);">end</span></code></pre>
        """,
        language: "elixir"
      )
    end

    test "with theme" do
      assert_output(
        "defmodule Test do\n  @lang :elixir\nend",
        ~s"""
        <pre class="athl" style="background-color: hsl(231 15% 18%); color: hsl(60 30% 96%);"><code class="language-elixir" translate="no"><span style="color: hsl(326 100% 74%);">defmodule</span> <span style="color: hsl(191 97% 77%);">Test</span> <span style="color: hsl(326 100% 74%);">do</span>
          <span style="color: hsl(326 100% 74%);">@</span><span style="color: hsl(135 94% 65%);">lang</span> <span style="color: hsl(265 89% 78%);">:elixir</span>
        <span style="color: hsl(326 100% 74%);">end</span></code></pre>
        """,
        language: "elixir",
        theme: "Dracula"
      )
    end

    test "with pre_class" do
      assert_output(
        "defmodule Test do\n  @lang :elixir\nend",
        ~s"""
        <pre class="athl test-pre-class" style="background-color: hsl(220 13% 27%); color: hsl(220 12% 81%);"><code class="language-elixir" translate="no"><span style="color: hsl(282 48% 64%);">defmodule</span> <span style="color: hsl(188 39% 59%);">Test</span> <span style="color: hsl(282 48% 64%);">do</span>
          <span style="color: hsl(188 39% 59%);">@</span><span style="color: hsl(211 73% 68%);">lang</span> <span style="color: hsl(30 40% 58%);">:elixir</span>
        <span style="color: hsl(282 48% 64%);">end</span></code></pre>
        """,
        language: "elixir",
        pre_class: "test-pre-class"
      )
    end

    @tag :skip
    test "with line number" do
      assert_output(
        "defmodule Test do\n  @lang :elixir\nend",
        ~s"""
        <pre class="athl" style="color: #abb2bf; background-color: #282c34;"><code class="language-elixir" translate="no">
          <span><span style="color: #c678dd;">defmodule</span> <span style="color: #e5c07b;">Test</span> <span style="color: #c678dd;">do</span></span>
          <span>  <span style="color: #c678dd;">@</span><span style="color: #c678dd;">lang</span> <span style="color: #e06c75;">:elixir</span></span>
          <span><span style="color: #c678dd;">end</span></span>
        </code></pre>
        """,
        language: "elixir",
        line_number: false
      )
    end

    test "enable debug" do
      assert_output(
        "defmodule Test do\n  @lang :elixir\nend",
        ~s"""
        <pre class="athl" style="background-color: hsl(220 13% 27%); color: hsl(220 12% 81%);"><code class="language-elixir" translate="no"><span data-athl-hl="keyword" style="color: hsl(282 48% 64%);"/>defmodule</span> <span data-athl-hl="type" style="color: hsl(188 39% 59%);"/>Test</span> <span data-athl-hl="keyword" style="color: hsl(282 48% 64%);"/>do</span>
          <span data-athl-hl="operator" style="color: hsl(188 39% 59%);"/>@</span><span data-athl-hl="function" style="color: hsl(211 73% 68%);"/>lang</span> <span data-athl-hl="string.special.symbol" style="color: hsl(30 40% 58%);"/>:elixir</span>
        <span data-athl-hl="keyword" style="color: hsl(282 48% 64%);"/>end</span></code></pre>
        """,
        language: "elixir",
        debug: true
      )
    end
  end

  describe "linked" do
    test "with default opts" do
      assert_output(
        "defmodule Test do\n  @lang :elixir\nend",
        ~s"""
        <pre class="athl"><code class="language-elixir" translate="no">
          <span data-athl-line="1"><span class="athl-keyword">defmodule</span> <span class="athl-module">Test</span> <span class="athl-keyword">do</span></span>
          <span data-athl-line="2">  <span class="athl-attribute">@</span><span class="athl-attribute">lang</span> <span class="athl-string-special-symbol">:elixir</span></span>
          <span data-athl-line="3"><span class="athl-keyword">end</span></span>
        </code></pre>
        """,
        language: "elixir",
        mode: :linked
      )
    end
  end

  describe "formatter: terminal" do
    test "with default opts" do
      assert_output(
        "defmodule Test do\n  @lang :elixir\nend",
        ~s"""
        """,
        language: "elixir",
        formatter: :terminal
      )
    end
  end

  describe "languages" do
    test "by name" do
      assert Autumn.language("elixir") == "elixir"
      assert Autumn.language("Elixir") == "elixir"
      assert Autumn.language("ELIXIR") == "elixir"
    end

    test "by extension" do
      assert Autumn.language("ex") == "ex"
      assert Autumn.language(".ex") == "ex"
    end

    test "by file name" do
      assert Autumn.language("file.rb") == "rb"
      assert Autumn.language("/path/to/file.rb") == "rb"
      assert Autumn.language("../file.rb") == "rb"
    end
  end
end
