defmodule Autumn.AutumnTest do
  use ExUnit.Case, async: true
  doctest Autumn

  defp assert_output(source_code, expected, opts) do
    result = Autumn.highlight!(source_code, opts)
    # IO.puts(result)
    assert String.trim(result) == String.trim(expected)
  end

  describe "deprecated still works" do
    test "highlight" do
      assert {:ok, hl} = Autumn.highlight("elixir", ":test")
      assert hl =~ "background-color: #282c33ff; color: #dce0e5ff"

      assert {:ok, hl} = Autumn.highlight("elixir", ":test", theme: "dracula")
      assert hl =~ "background-color: #282a36ff; color: #f8f8f2ff;"
    end

    test "highlight!" do
      assert Autumn.highlight!("elixir", ":test") =~ "background-color: #282c33ff; color: #dce0e5ff"
      assert Autumn.highlight!("elixir", ":test", theme: "dracula") =~ "background-color: #282a36ff; color: #f8f8f2ff;"
    end

    test "inline_mode" do
      assert {:ok,
              "<pre class=\"athl\" style=\"background-color: #282c33ff; color: #dce0e5ff;\"><code class=\"language-elixir\" translate=\"no\"><span style=\"color: #bf956aff;\">:test</span></code></pre>"} =
               Autumn.highlight(":test", language: "elixir", inline_style: true)
    end
  end

  test "available_languages" do
    assert Autumn.available_languages() == [
             "bash",
             "c",
             "clojure",
             "cpp",
             "csharp",
             "css",
             "diff",
             "dockerfile",
             "eex",
             "elisp",
             "elixir",
             "elm",
             "ember",
             "erlang",
             "gleam",
             "go",
             "haskell",
             "heex",
             "html",
             "iex",
             "java",
             "javascript",
             "jsdoc",
             "json",
             "jsx",
             "kotlin",
             "llvm",
             "lua",
             "make",
             "markdown",
             "markdown_inline",
             "objc",
             "php",
             "plaintext",
             "proto",
             "python",
             "r",
             "regex",
             "ruby",
             "rust",
             "scala",
             "sql",
             "svelte",
             "swift",
             "terraform",
             "toml",
             "typescript",
             "vimscript",
             "yaml",
             "zig"
           ]
  end

  test "available_themes" do
    assert length(Autumn.available_themes()) == 613
  end

  describe "formatter: inline" do
    test "with default opts" do
      assert_output(
        "defmodule Test do\n  @lang :elixir\nend",
        ~s"""
        <pre class="athl" style="background-color: #282c33ff; color: #dce0e5ff;"><code class="language-elixir" translate="no"><span style="color: #b477cfff;">defmodule</span> <span style="color: #6eb4bfff;">Test</span> <span style="color: #b477cfff;">do</span>
          <span style="color: #6eb4bfff;">@</span><span style="color: #73ade9ff;">lang</span> <span style="color: #bf956aff;">:elixir</span>
        <span style="color: #b477cfff;">end</span></code></pre>
        """,
        language: "elixir"
      )
    end

    test "with named theme" do
      assert_output(
        "defmodule Test do\n  @lang :elixir\nend",
        ~s"""
        <pre class="athl" style="background-color: #282a36ff; color: #f8f8f2ff;"><code class="language-elixir" translate="no"><span style="color: #ff79c6ff;">defmodule</span> <span style="color: #8be9fdff;">Test</span> <span style="color: #ff79c6ff;">do</span>
          <span style="color: #ff79c6ff;">@</span><span style="color: #50fa7bff;">lang</span> <span style="color: #bd93f9ff;">:elixir</span>
        <span style="color: #ff79c6ff;">end</span></code></pre>
        """,
        language: "elixir",
        theme: "Dracula"
      )
    end

    test "with struct theme" do
      assert_output(
        "defmodule Test do\n  @lang :elixir\nend",
        ~s"""
        <pre class="athl" style="background-color: #282a36ff; color: #f8f8f2ff;"><code class="language-elixir" translate="no"><span style="color: #ff79c6ff;">defmodule</span> <span style="color: #8be9fdff;">Test</span> <span style="color: #ff79c6ff;">do</span>
          <span style="color: #ff79c6ff;">@</span><span style="color: #50fa7bff;">lang</span> <span style="color: #bd93f9ff;">:elixir</span>
        <span style="color: #ff79c6ff;">end</span></code></pre>
        """,
        language: "elixir",
        theme: Autumn.Themes.dracula()
      )
    end

    test "with pre_class" do
      assert_output(
        "defmodule Test do\n  @lang :elixir\nend",
        ~s"""
        <pre class="athl test-pre-class" style="background-color: #282c33ff; color: #dce0e5ff;"><code class="language-elixir" translate="no"><span style="color: #b477cfff;">defmodule</span> <span style="color: #6eb4bfff;">Test</span> <span style="color: #b477cfff;">do</span>
          <span style="color: #6eb4bfff;">@</span><span style="color: #73ade9ff;">lang</span> <span style="color: #bf956aff;">:elixir</span>
        <span style="color: #b477cfff;">end</span></code></pre>
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
        TODO
        """,
        language: "elixir"
      )
    end

    test "enable debug" do
      assert_output(
        "defmodule Test do\n  @lang :elixir\nend",
        ~s"""
        <pre class="athl" style="background-color: #282c33ff; color: #dce0e5ff;"><code class="language-elixir" translate="no"><span data-athl-hl="keyword" style="color: #b477cfff;">defmodule</span> <span data-athl-hl="type" style="color: #6eb4bfff;">Test</span> <span data-athl-hl="keyword" style="color: #b477cfff;">do</span>
          <span data-athl-hl="operator" style="color: #6eb4bfff;">@</span><span data-athl-hl="function" style="color: #73ade9ff;">lang</span> <span data-athl-hl="string.special.symbol" style="color: #bf956aff;">:elixir</span>
        <span data-athl-hl="keyword" style="color: #b477cfff;">end</span></code></pre>
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
        <pre class="athl"><code class="language-elixir" translate="no"><span class="athl-keyword">defmodule</span> <span class="athl-type">Test</span> <span class="athl-keyword">do</span>
          <span class="athl-operator">@</span><span class="athl-function">lang</span> <span class="athl-string athl-string-special athl-string-special-symbol">:elixir</span>
        <span class="athl-keyword">end</span></code></pre>
        """,
        language: "elixir",
        formatter: :html_linked
      )
    end
  end

  describe "formatter: terminal" do
    test "with default opts" do
      assert_output(
        "defmodule Test do\n  @lang :elixir\nend",
        "\e[0m\e[38;2;180;119;207mdefmodule\e[0m \e[0m\e[38;2;110;180;191mTest\e[0m \e[0m\e[38;2;180;119;207mdo\e[0m\n  \e[0m\e[38;2;110;180;191m@\e[0m\e[0m\e[38;2;115;173;233mlang\e[0m \e[0m\e[38;2;191;149;106m:elixir\e[0m\n\e[0m\e[38;2;180;119;207mend\e[0m",
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
      assert Autumn.language("ex") == "elixir"
      assert Autumn.language(".ex") == "elixir"
    end

    test "by file name" do
      assert Autumn.language("file.rb") == "ruby"
      assert Autumn.language("/path/to/file.rb") == "ruby"
      assert Autumn.language("../file.rb") == "ruby"
    end
  end
end
