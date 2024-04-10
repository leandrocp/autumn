defmodule AutumnTest do
  use ExUnit.Case

  defp assert_output(source_code, expected, opts \\ []) do
    result = Autumn.highlight!(source_code, opts)
    # IO.puts(result)
    assert String.trim(result) == String.trim(expected)
  end

  describe "deprecated still works" do
    test "highlight" do
      assert {:ok, hl} = Autumn.highlight("elixir", ":elixir")
      assert hl =~ "symbol"

      assert {:ok, hl} = Autumn.highlight("elixir", ":elixir", theme: "dracula")
      assert hl =~ "symbol"
    end

    test "highlight!" do
      assert Autumn.highlight!("elixir", ":elixir") =~ "symbol"
      assert Autumn.highlight!("elixir", ":elixir", theme: "dracula") =~ "symbol"
    end
  end

  describe "highlight" do
    test "elixir with default opts" do
      assert_output(
        ":elixir",
        ~s"""
        <pre class=\"autumn-hl\" style=\"background-color: #282C34; color: #ABB2BF;\"><code class=\"language-elixir\" translate=\"no\"><span class=\"ahl-string ahl-special ahl-symbol\" style=\"color: #98C379;\">:elixir</span></code></pre>
        """,
        language: "elixir"
      )
    end

    test "ruby with default opts" do
      assert_output(
        ~s|puts "autumn season"|,
        ~s"""
        <pre class=\"autumn-hl\" style=\"background-color: #282C34; color: #ABB2BF;\"><code class=\"language-ruby\" translate=\"no\"><span class=\"ahl-function ahl-method\" style=\"color: #61AFEF;\">puts</span> <span class=\"ahl-string\" style=\"color: #98C379;\">&quot;autumn season&quot;</span></code></pre>
        """,
        language: "script.rb"
      )
    end

    test "fallback to plaintext on invalid lang" do
      expected = ~s"""
      <pre class="autumn-hl" style="background-color: #282C34; color: #ABB2BF;"><code class="language-plaintext" translate="no">code</code></pre>
      """

      assert_output("code", expected, language: "invalid")
      assert_output("code", expected, language: nil)
    end
  end

  describe "theming" do
    test "invalid theme" do
      assert Autumn.highlight(":elixir", language: "elixir", theme: "invalid") ==
               {:error, "unknown theme: invalid"}
    end

    test "change theme" do
      assert_output(
        ":elixir",
        ~s"""
        <pre class=\"autumn-hl\" style=\"background-color: #282A36; color: #f8f8f2;\"><code class=\"language-elixir\" translate=\"no\"><span class=\"ahl-string ahl-special ahl-symbol\" style=\"color: #ffb86c;\">:elixir</span></code></pre>
        """,
        language: "elixir",
        theme: "dracula"
      )
    end
  end

  test "inject pre class" do
    assert_output(
      ":elixir",
      ~s"""
      <pre class=\"autumn-hl pre-class\" style=\"background-color: #282C34; color: #ABB2BF;\"><code class=\"language-elixir\" translate=\"no\"><span class=\"ahl-string ahl-special ahl-symbol\" style=\"color: #98C379;\">:elixir</span></code></pre>
      """,
      language: "elixir",
      pre_class: "pre-class"
    )
  end

  describe "languages" do
    test "load all languages" do
      assert {:ok, _} = Autumn.highlight("foo", language: "bash")
      assert {:ok, _} = Autumn.highlight("foo", language: "c")
      assert {:ok, _} = Autumn.highlight("foo", language: "clojure")
      assert {:ok, _} = Autumn.highlight("foo", language: "c-sharp")
      assert {:ok, _} = Autumn.highlight("foo", language: "commonlisp")
      assert {:ok, _} = Autumn.highlight("foo", language: "cpp")
      assert {:ok, _} = Autumn.highlight("foo", language: "css")
      assert {:ok, _} = Autumn.highlight("foo", language: "diff")
      assert {:ok, _} = Autumn.highlight("foo", language: "dockerfile")
      assert {:ok, _} = Autumn.highlight("foo", language: "elisp")
      assert {:ok, _} = Autumn.highlight("foo", language: "elixir")
      assert {:ok, _} = Autumn.highlight("foo", language: "erlang")
      assert {:ok, _} = Autumn.highlight("foo", language: "gleam")
      assert {:ok, _} = Autumn.highlight("foo", language: "go")
      assert {:ok, _} = Autumn.highlight("foo", language: "haskell")
      assert {:ok, _} = Autumn.highlight("foo", language: "hcl")
      assert {:ok, _} = Autumn.highlight("foo", language: "heex")
      assert {:ok, _} = Autumn.highlight("foo", language: "html")
      assert {:ok, _} = Autumn.highlight("foo", language: "java")
      assert {:ok, _} = Autumn.highlight("foo", language: "javascript")
      assert {:ok, _} = Autumn.highlight("foo", language: "json")
      assert {:ok, _} = Autumn.highlight("foo", language: "kotlin")
      assert {:ok, _} = Autumn.highlight("foo", language: "latex")
      assert {:ok, _} = Autumn.highlight("foo", language: "llvm")
      assert {:ok, _} = Autumn.highlight("foo", language: "lua")
      assert {:ok, _} = Autumn.highlight("foo", language: "make")
      assert {:ok, _} = Autumn.highlight("foo", language: "php")
      assert {:ok, _} = Autumn.highlight("foo", language: "proto")
      assert {:ok, _} = Autumn.highlight("foo", language: "python")
      assert {:ok, _} = Autumn.highlight("foo", language: "r")
      assert {:ok, _} = Autumn.highlight("foo", language: "regex")
      assert {:ok, _} = Autumn.highlight("foo", language: "ruby")
      assert {:ok, _} = Autumn.highlight("foo", language: "rust")
      assert {:ok, _} = Autumn.highlight("foo", language: "scala")
      assert {:ok, _} = Autumn.highlight("foo", language: "scss")
      assert {:ok, _} = Autumn.highlight("foo", language: "sql")
      assert {:ok, _} = Autumn.highlight("foo", language: "swift")
      assert {:ok, _} = Autumn.highlight("foo", language: "toml")
      assert {:ok, _} = Autumn.highlight("foo", language: "typescript")
      assert {:ok, _} = Autumn.highlight("foo", language: "yaml")
      assert {:ok, _} = Autumn.highlight("foo", language: "zig")
    end

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
