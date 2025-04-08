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

    test "inline_style option" do
      capture_io(:stderr, fn ->
        assert {:ok,
                "<pre class=\"athl\" style=\"color: #abb2bf; background-color: #282c34;\"><code class=\"language-elixir\" translate=\"no\" tabindex=\"0\"><span class=\"line\" data-line=\"1\"><span style=\"color: #56b6c2;\">:test</span>\n</span></code></pre>"} =
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
    assert available_languages |> Map.keys() |> length() == 68
    assert available_languages["elixir"] == {"Elixir", ["*.ex", "*.exs"]}
  end

  test "available_themes" do
    assert Autumn.available_themes() |> length() == 102
  end

  test "accept empty theme" do
    assert {:ok, result} = Autumn.highlight("#!/usr/bin/env bash\necho 'test'", theme: "noop")
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
        </span><span class="line" data-line="2">  <span style="color: #abb2bf;"><span style="color: #d19a66;">@<span style="color: #61afef;"><span style="color: #d19a66;">lang <span style="color: #56b6c2;">:elixir</span></span></span></span></span>
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
        theme: "dracula"
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
        theme: Autumn.Theme.get("dracula")
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
        <pre class="athl" style="color: #abb2bf; background-color: #282c34;"><code class="language-elixir" translate="no" tabindex="0"><span class="line" data-line="1"><span  data-highlight="keyword.function" style="color: #c678dd;">defmodule</span> <span  data-highlight="module" style="color: #e5c07b;">Test</span> <span  data-highlight="keyword" style="color: #c678dd;">do</span>
        </span><span class="line" data-line="2">  <span  data-highlight="operator" style="color: #abb2bf;"><span  data-highlight="constant" style="color: #d19a66;">@<span  data-highlight="function.call" style="color: #61afef;"><span  data-highlight="constant" style="color: #d19a66;">lang <span  data-highlight="string.special.symbol" style="color: #56b6c2;">:elixir</span></span></span></span></span>
        </span><span class="line" data-line="3"><span  data-highlight="keyword" style="color: #c678dd;">end</span>
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
        "\e[0m\e[38;2;198;120;221mdefmodule\e[0m \e[0m\e[38;2;229;192;123mTest\e[0m \e[0m\e[38;2;198;120;221mdo\e[0m\n  \e[0m\e[38;2;171;178;191m\e[0m\e[38;2;209;154;102m@\e[0m\e[38;2;97;175;239m\e[0m\e[38;2;209;154;102mlang \e[0m\e[38;2;86;182;194m:elixir\e[0m\e[0m\e[0m\e[0m\e[0m\n\e[0m\e[38;2;198;120;221mend\e[0m",
        language: "elixir",
        formatter: :terminal
      )
    end
  end
end
