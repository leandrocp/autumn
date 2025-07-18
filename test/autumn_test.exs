defmodule Autumn.AutumnTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

  defp assert_output(source_code, expected, opts) do
    result = Autumn.highlight!(source_code, opts)
    # IO.puts(result)
    assert String.trim(result) == String.trim(expected)
  end

  defp assert_contains(source_code, expected, opts) do
    result = Autumn.highlight!(source_code, opts)
    result = String.trim(result)
    assert String.contains?(result, expected)
  end

  describe "deprecated still works" do
    test "highlight" do
      capture_io(:stderr, fn ->
        assert {:ok, hl} = Autumn.highlight("elixir", ":test")

        assert hl =~
                 ~s|<pre class="athl" style="color: #abb2bf; background-color: #282c34;"><code class="language-elixir"|

        assert {:ok, hl} = Autumn.highlight("elixir", ":test", theme: "dracula")

        assert hl =~
                 ~s|<pre class="athl" style="color: #f8f8f2; background-color: #282a36;"><code class="language-elixir"|
      end)
    end

    test "highlight!" do
      capture_io(:stderr, fn ->
        assert Autumn.highlight!("elixir", ":test") =~
                 ~s|<pre class="athl" style="color: #abb2bf; background-color: #282c34;"><code class="language-elixir"|

        assert Autumn.highlight!("elixir", ":test", theme: "dracula") =~
                 ~s|<pre class="athl" style="color: #f8f8f2; background-color: #282a36;"><code class="language-elixir"|
      end)
    end

    test "theme option" do
      capture_io(:stderr, fn ->
        assert {:ok, highlighted} =
                 Autumn.highlight(":test", language: "elixir", theme: "github_light")

        assert highlighted =~
                 ~s|<pre class="athl" style="color: #1f2328; background-color: #ffffff;">|
      end)
    end

    test "inline_style option" do
      capture_io(:stderr, fn ->
        assert {:ok,
                "<pre class=\"athl\" style=\"color: #abb2bf; background-color: #282c34;\"><code class=\"language-elixir\" translate=\"no\" tabindex=\"0\"><span class=\"line\" data-line=\"1\"><span style=\"color: #e06c75;\">:test</span>\n</span></code></pre>"} =
                 Autumn.highlight(":test", language: "elixir", inline_style: true)
      end)
    end

    test "pre_class option" do
      capture_io(:stderr, fn ->
        assert {:ok, highlighted} =
                 Autumn.highlight(":test", language: "elixir", pre_class: "deprecated")

        assert highlighted =~ ~s|<pre class="athl deprecated"|
      end)
    end
  end

  test "available_languages" do
    available_languages = Autumn.available_languages()
    assert available_languages |> Map.keys() |> length() == 71
    assert available_languages["elixir"] == {"Elixir", ["*.ex", "*.exs"]}
  end

  test "available_themes" do
    assert Autumn.available_themes() |> length() == 119
  end

  describe "formatter_type: :html_inline" do
    test "default opts" do
      assert Autumn.formatter_type(:html_inline) ==
               {:ok,
                {:html_inline,
                 %{
                   italic: false,
                   theme: "onedark",
                   pre_class: nil,
                   include_highlights: false,
                   highlight_lines: nil,
                   header: nil
                 }}}
    end
  end

  describe "formatter_type: :html_linked" do
    test "default opts" do
      assert Autumn.formatter_type(:html_linked) ==
               {:ok, {:html_linked, %{pre_class: nil, highlight_lines: nil, header: nil}}}
    end
  end

  describe "formatter_type: :terminal" do
    test "default opts" do
      assert Autumn.formatter_type(:terminal) ==
               {:ok, {:terminal, %{theme: "onedark"}}}
    end
  end

  test "accept empty theme" do
    assert {:ok, result} =
             Autumn.highlight("#!/usr/bin/env bash\necho 'test'",
               formatter: {:html_inline, theme: "noop"}
             )

    assert result =~ ~s|class="language-bash"|
  end

  test "detects language from shebang" do
    assert {:ok, result} = Autumn.highlight("#!/usr/bin/env bash\necho 'test'")
    assert result =~ ~s|class="language-bash"|
  end

  test "handles code with unicode characters" do
    assert {:ok, result} = Autumn.highlight("def π() do\n  3.14\nend", language: "elixir")
    assert result =~ "π"
  end

  test "raises on invalid formatter options" do
    assert_raise NimbleOptions.ValidationError, fn ->
      Autumn.highlight!("test", formatter: :invalid)
    end

    assert_raise NimbleOptions.ValidationError, fn ->
      Autumn.highlight!("test", formatter: {:html_inline, :invalid})
    end
  end

  describe "formatter: inline" do
    test "with default opts" do
      assert_output(
        "defmodule Test do\n  @lang :elixir\nend",
        ~s"""
        <pre class="athl" style="color: #abb2bf; background-color: #282c34;"><code class="language-elixir" translate="no" tabindex="0"><span class="line" data-line="1"><span style="color: #c678dd;">defmodule</span> <span style="color: #e5c07b;">Test</span> <span style="color: #c678dd;">do</span>
        </span><span class="line" data-line="2">  <span style="color: #56b6c2;"><span style="color: #d19a66;">@<span style="color: #61afef;"><span style="color: #d19a66;">lang <span style="color: #e06c75;">:elixir</span></span></span></span></span>
        </span><span class="line" data-line="3"><span style="color: #c678dd;">end</span>
        </span></code></pre>
        """,
        language: "elixir"
      )
    end

    test "with named theme" do
      assert_output(
        "defmodule Test do\n  @lang :elixir\nend",
        ~s"""
        <pre class="athl" style="color: #f8f8f2; background-color: #282a36;"><code class="language-elixir" translate="no" tabindex="0"><span class="line" data-line="1"><span style="color: #8be9fd;">defmodule</span> <span style="color: #ffb86c;">Test</span> <span style="color: #ff79c6;">do</span>
        </span><span class="line" data-line="2">  <span style="color: #ff79c6;"><span style="color: #bd93f9;">@<span style="color: #50fa7b;"><span style="color: #bd93f9;">lang <span style="color: #bd93f9;">:elixir</span></span></span></span></span>
        </span><span class="line" data-line="3"><span style="color: #ff79c6;">end</span>
        </span></code></pre>
        """,
        language: "elixir",
        formatter: {:html_inline, theme: "dracula"}
      )
    end

    test "with struct theme" do
      assert_output(
        "defmodule Test do\n  @lang :elixir\nend",
        ~s"""
        <pre class="athl" style="color: #f8f8f2; background-color: #282a36;"><code class="language-elixir" translate="no" tabindex="0"><span class="line" data-line="1"><span style="color: #8be9fd;">defmodule</span> <span style="color: #ffb86c;">Test</span> <span style="color: #ff79c6;">do</span>
        </span><span class="line" data-line="2">  <span style="color: #ff79c6;"><span style="color: #bd93f9;">@<span style="color: #50fa7b;"><span style="color: #bd93f9;">lang <span style="color: #bd93f9;">:elixir</span></span></span></span></span>
        </span><span class="line" data-line="3"><span style="color: #ff79c6;">end</span>
        </span></code></pre>
        """,
        language: "elixir",
        formatter: {:html_inline, theme: Autumn.Theme.get("dracula")}
      )
    end

    test "with pre_class" do
      assert_contains(
        "defmodule Test do\n  @lang :elixir\nend",
        ~s|<pre class="athl test-pre-class"|,
        language: "elixir",
        formatter: {:html_inline, pre_class: "test-pre-class"}
      )
    end

    test "with include_highlights" do
      assert_output(
        "defmodule Test do\n  @lang :elixir\nend",
        ~s"""
        <pre class="athl" style="color: #abb2bf; background-color: #282c34;"><code class="language-elixir" translate="no" tabindex="0"><span class="line" data-line="1"><span data-highlight="keyword.function" style="color: #c678dd;">defmodule</span> <span data-highlight="module" style="color: #e5c07b;">Test</span> <span data-highlight="keyword" style="color: #c678dd;">do</span>
        </span><span class="line" data-line="2">  <span data-highlight="operator" style="color: #56b6c2;"><span data-highlight="constant" style="color: #d19a66;">@<span data-highlight="function.call" style="color: #61afef;"><span data-highlight="constant" style="color: #d19a66;">lang <span data-highlight="string.special.symbol" style="color: #e06c75;">:elixir</span></span></span></span></span>
        </span><span class="line" data-line="3"><span data-highlight="keyword" style="color: #c678dd;">end</span>
        </span></code></pre>
        """,
        language: "elixir",
        formatter: {:html_inline, include_highlights: true}
      )
    end
  end

  describe "formatter: linked" do
    test "with default opts" do
      assert_output(
        "defmodule Test do\n  @lang :elixir\nend",
        ~s"""
        <pre class="athl"><code class="language-elixir" translate="no" tabindex="0"><span class="line" data-line="1"><span class="keyword-function">defmodule</span> <span class="module">Test</span> <span class="keyword">do</span>
        </span><span class="line" data-line="2">  <span class="operator"><span class="constant">@<span class="function-call"><span class="constant">lang <span class="string-special-symbol">:elixir</span></span></span></span></span>
        </span><span class="line" data-line="3"><span class="keyword">end</span>
        </span></code></pre>
        """,
        language: "elixir",
        formatter: :html_linked
      )
    end

    test "with pre_class option" do
      assert {:ok, result} =
               Autumn.highlight("defmodule Test do\nend",
                 language: "elixir",
                 formatter: {:html_linked, pre_class: "custom-class"}
               )

      assert result =~ ~s|<pre class="athl custom-class"|
    end
  end

  describe "formatter: terminal" do
    test "with default opts" do
      assert_output(
        "defmodule Test do\n  @lang :elixir\nend",
        "\e[0m\e[38;2;198;120;221mdefmodule\e[0m \e[0m\e[38;2;229;192;123mTest\e[0m \e[0m\e[38;2;198;120;221mdo\e[0m\n  \e[0m\e[38;2;86;182;194m\e[0m\e[38;2;209;154;102m@\e[0m\e[38;2;97;175;239m\e[0m\e[38;2;209;154;102mlang \e[0m\e[38;2;224;108;117m:elixir\e[0m\e[0m\e[0m\e[0m\e[0m\n\e[0m\e[38;2;198;120;221mend\e[0m",
        language: "elixir",
        formatter: :terminal
      )
    end

    test "with theme" do
      assert_output(
        "defmodule Test do\n  @lang :elixir\nend",
        "\e[0m\e[38;2;207;34;46mdefmodule\e[0m \e[0m\e[38;2;207;34;46mTest\e[0m \e[0m\e[38;2;207;34;46mdo\e[0m\n  \e[0m\e[38;2;5;80;174m\e[0m\e[38;2;5;80;174m@\e[0m\e[38;2;102;57;186m\e[0m\e[38;2;5;80;174mlang \e[0m\e[38;2;5;80;174m:elixir\e[0m\e[0m\e[0m\e[0m\e[0m\n\e[0m\e[38;2;207;34;46mend\e[0m",
        language: "elixir",
        formatter: {:terminal, theme: "github_light"}
      )
    end
  end

  describe "formatter: highlight_lines" do
    test "html_inline with single line highlighting" do
      highlight_lines = %{
        lines: [2],
        style: "background-color: yellow;"
      }

      result =
        Autumn.highlight!(
          "def hello\n  puts 'world'\nend",
          language: "ruby",
          formatter: {:html_inline, highlight_lines: highlight_lines}
        )

      assert String.contains?(
               result,
               ~s|<span class="line" style="background-color: yellow;" data-line="2">|
             )
    end

    test "html_inline with multiple line ranges" do
      highlight_lines = %{
        lines: [1, 3],
        style: "background-color: yellow;"
      }

      result =
        Autumn.highlight!(
          "line 1\nline 2\nline 3",
          language: "text",
          formatter: {:html_inline, highlight_lines: highlight_lines}
        )

      assert String.contains?(
               result,
               ~s|<span class="line" style="background-color: yellow;" data-line="1">|
             )

      refute String.contains?(
               result,
               ~s|<span class="line" style="background-color: yellow;" data-line="2">|
             )

      assert String.contains?(
               result,
               ~s|<span class="line" style="background-color: yellow;" data-line="3">|
             )
    end

    test "html_inline with mixed integers and ranges" do
      highlight_lines = %{
        lines: [1, 3..5, 7],
        style: "background-color: yellow;"
      }

      result =
        Autumn.highlight!(
          "line 1\nline 2\nline 3\nline 4\nline 5\nline 6\nline 7\nline 8\nline 9",
          language: "text",
          formatter: {:html_inline, highlight_lines: highlight_lines}
        )

      assert String.contains?(
               result,
               ~s|<span class="line" style="background-color: yellow;" data-line="1">|
             )

      refute String.contains?(
               result,
               ~s|<span class="line" style="background-color: yellow;" data-line="2">|
             )

      assert String.contains?(
               result,
               ~s|<span class="line" style="background-color: yellow;" data-line="3">|
             )

      assert String.contains?(
               result,
               ~s|<span class="line" style="background-color: yellow;" data-line="4">|
             )

      assert String.contains?(
               result,
               ~s|<span class="line" style="background-color: yellow;" data-line="5">|
             )

      refute String.contains?(
               result,
               ~s|<span class="line" style="background-color: yellow;" data-line="6">|
             )

      assert String.contains?(
               result,
               ~s|<span class="line" style="background-color: yellow;" data-line="7">|
             )
    end

    test "html_inline with theme style" do
      highlight_lines = %{
        lines: [1],
        style: :theme
      }

      result =
        Autumn.highlight!(
          "def test\nend",
          language: "ruby",
          formatter: {:html_inline, theme: "dracula", highlight_lines: highlight_lines}
        )

      assert String.contains?(
               result,
               ~s|<span class="line" style="background-color: #3e4452;" data-line="1">|
             )
    end

    test "html_inline with default theme style (style field omitted)" do
      highlight_lines = %{
        lines: [1]
        # style field is omitted, should default to :theme
      }

      result =
        Autumn.highlight!(
          "def test\nend",
          language: "ruby",
          formatter: {:html_inline, theme: "dracula", highlight_lines: highlight_lines}
        )

      assert String.contains?(
               result,
               ~s|<span class="line" style="background-color: #3e4452;" data-line="1">|
             )
    end

    test "html_linked with single line and default theme" do
      highlight_lines = %{
        lines: [1]
      }

      result =
        Autumn.highlight!(
          "line 1\nline 2\nline 3\nline 4\nline 5\nline 6\nline 7\nline 8\nline 9",
          language: "text",
          formatter: {:html_linked, highlight_lines: highlight_lines}
        )

      assert String.contains?(result, ~s|<span class="line cursorline" data-line="1">|)
    end

    test "html_linked with multiple lines and default theme " do
      highlight_lines = %{
        lines: [1, 2]
      }

      result =
        Autumn.highlight!(
          "line 1\nline 2\nline 3\nline 4\nline 5\nline 6\nline 7\nline 8\nline 9",
          language: "text",
          formatter: {:html_linked, highlight_lines: highlight_lines}
        )

      assert String.contains?(result, ~s|<span class="line cursorline" data-line="1">|)
      assert String.contains?(result, ~s|<span class="line cursorline" data-line="2">|)
      refute String.contains?(result, ~s|<span class="line cursorline" data-line="3">|)
    end

    test "html_linked with mixes lines and ranges and default theme " do
      highlight_lines = %{
        lines: [1, 2, 2..4]
      }

      result =
        Autumn.highlight!(
          "line 1\nline 2\nline 3\nline 4\nline 5\nline 6\nline 7\nline 8\nline 9",
          language: "text",
          formatter: {:html_linked, highlight_lines: highlight_lines}
        )

      assert String.contains?(result, ~s|<span class="line cursorline" data-line="1">|)
      assert String.contains?(result, ~s|<span class="line cursorline" data-line="2">|)
      assert String.contains?(result, ~s|<span class="line cursorline" data-line="3">|)
      refute String.contains?(result, ~s|<span class="line cursorline" data-line="5">|)
    end

    test "html_linked with CSS class" do
      highlight_lines = %{
        lines: [1],
        class: "hl-test"
      }

      result =
        Autumn.highlight!(
          "def broken\n  raise 'error'\nend",
          language: "ruby",
          formatter: {:html_linked, highlight_lines: highlight_lines}
        )

      assert String.contains?(result, ~s|<span class="line hl-test" data-line="1">|)
    end

    test "invalid highlight_lines format raises error" do
      assert_raise NimbleOptions.ValidationError, fn ->
        Autumn.highlight!(
          "test",
          language: "text",
          formatter: {:html_inline, highlight_lines: "invalid"}
        )
      end
    end

    test "invalid lines format raises error" do
      highlight_lines = %{
        lines: ["invalid"],
        style: :theme
      }

      assert_raise NimbleOptions.ValidationError, ~r/invalid value for :highlight_lines/, fn ->
        Autumn.highlight!(
          "test",
          language: "text",
          formatter: {:html_inline, highlight_lines: highlight_lines}
        )
      end
    end

    test "invalid style format raises error" do
      highlight_lines = %{
        lines: [1],
        style: 123
      }

      assert_raise NimbleOptions.ValidationError, ~r/invalid value for :style option/, fn ->
        Autumn.highlight!(
          "test",
          language: "text",
          formatter: {:html_inline, highlight_lines: highlight_lines}
        )
      end
    end
  end

  describe "formatter: header" do
    test "html_inline with custom wrapper" do
      header = %{
        open_tag: ~s|<div class="wrapper">|,
        close_tag: "</div>"
      }

      result =
        Autumn.highlight!(
          "puts 'hello'",
          language: "ruby",
          formatter: {:html_inline, header: header}
        )

      assert String.starts_with?(result, ~s|<div class="wrapper"><pre class="athl"|)
      assert String.ends_with?(result, "</div>")
    end

    test "invalid header format raises error" do
      assert_raise NimbleOptions.ValidationError, fn ->
        Autumn.highlight!(
          "test",
          language: "text",
          formatter: {:html_inline, header: "invalid"}
        )
      end
    end

    test "invalid header keys raise error" do
      header = %{
        open_tag: "<div>"
        # missing close_tag
      }

      assert_raise NimbleOptions.ValidationError,
                   ~r/invalid value for :header option/,
                   fn ->
                     Autumn.highlight!(
                       "test",
                       language: "text",
                       formatter: {:html_inline, header: header}
                     )
                   end
    end

    test "non-string header values raise error" do
      header = %{
        open_tag: 123,
        close_tag: "</div>"
      }

      assert_raise NimbleOptions.ValidationError,
                   ~r/invalid value for :open_tag option/,
                   fn ->
                     Autumn.highlight!(
                       "test",
                       language: "text",
                       formatter: {:html_inline, header: header}
                     )
                   end
    end
  end

  describe "formatter: combined features" do
    test "highlight_lines and header together" do
      highlight_lines = %{
        lines: [1],
        style: "background-color: #f8d7da;"
      }

      header = %{
        open_tag: "<div class='code-block' data-highlighted='true'>",
        close_tag: "</div>"
      }

      result =
        Autumn.highlight!(
          "error_line\nnormal_line",
          language: "text",
          formatter: {:html_inline, highlight_lines: highlight_lines, header: header}
        )

      assert String.starts_with?(result, "<div class='code-block' data-highlighted='true'>")
      assert String.ends_with?(result, "</div>")
      assert String.contains?(result, "background-color: #f8d7da;")
      assert String.contains?(result, "data-line=\"1\"")
    end

    test "all options together" do
      highlight_lines = %{
        lines: [2],
        style: :theme
      }

      header = %{
        open_tag: "<section class='example'>",
        close_tag: "</section>"
      }

      result =
        Autumn.highlight!(
          "def example\n  # this line is highlighted\n  puts 'done'\nend",
          language: "ruby",
          formatter: {
            :html_inline,
            theme: "dracula",
            pre_class: "custom-code",
            italic: true,
            include_highlights: true,
            highlight_lines: highlight_lines,
            header: header
          }
        )

      assert String.starts_with?(result, "<section class='example'>")
      assert String.ends_with?(result, "</section>")
      assert String.contains?(result, "class=\"athl custom-code\"")
      assert String.contains?(result, "data-highlight=")
      assert String.contains?(result, "data-line=\"2\"")
      # Dracula theme colors
      assert String.contains?(result, "background-color: #282a36")
    end
  end
end
