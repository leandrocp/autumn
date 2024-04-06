defmodule AutumnTest do
  use ExUnit.Case

  defp assert_output(lang, source_code, expected, opts \\ []) do
    result = Autumn.highlight!(lang, source_code, opts)
    # IO.puts(result)
    assert String.trim(result) == String.trim(expected)
  end

  describe "highlight" do
    test "elixir with default opts" do
      assert_output("elixir", ":elixir", ~s"""
      <pre class="autumn highlight" style="background-color: #282C34; color: #ABB2BF;"><code class="language-elixir" translate="no"><span class="string" style="color: #98C379;">:elixir</span></code></pre>
      """)
    end

    test "ruby with default opts" do
      assert_output("script.rb", ~s|puts "autumn season"|, ~s"""
      <pre class="autumn highlight" style="background-color: #282C34; color: #ABB2BF;"><code class="language-ruby" translate="no"><span class="function" style="color: #61AFEF;">puts</span> <span class="string" style="color: #98C379;">&quot;autumn season&quot;</span></code></pre>
      """)
    end

    test "fallback to plaintext on invalid lang" do
      expected = ~s"""
      <pre class="autumn highlight" style="background-color: #282C34; color: #ABB2BF;"><code class="language-plaintext" translate="no">code</code></pre>
      """

      assert_output("invalid", "code", expected)
      assert_output(nil, "code", expected)
    end
  end

  test "change theme" do
    assert_output(
      "elixir",
      ":elixir",
      ~s"""
      <pre class="autumn highlight" style="background-color: #282A36; color: #f8f8f2;"><code class="language-elixir" translate="no"><span class="string special" style="color: #ffb86c;">:elixir</span></code></pre>
      """,
      theme: "dracula"
    )
  end

  describe "languages" do
    test "load all languages" do
      assert {:ok, _} = Autumn.highlight("bash", "foo")
      assert {:ok, _} = Autumn.highlight("c", "foo")
      assert {:ok, _} = Autumn.highlight("clojure", "foo")
      assert {:ok, _} = Autumn.highlight("c-sharp", "foo")
      assert {:ok, _} = Autumn.highlight("commonlisp", "foo")
      assert {:ok, _} = Autumn.highlight("cpp", "foo")
      assert {:ok, _} = Autumn.highlight("css", "foo")
      assert {:ok, _} = Autumn.highlight("diff", "foo")
      assert {:ok, _} = Autumn.highlight("dockerfile", "foo")
      assert {:ok, _} = Autumn.highlight("elisp", "foo")
      assert {:ok, _} = Autumn.highlight("elixir", "foo")
      assert {:ok, _} = Autumn.highlight("erlang", "foo")
      assert {:ok, _} = Autumn.highlight("gleam", "foo")
      assert {:ok, _} = Autumn.highlight("go", "foo")
      assert {:ok, _} = Autumn.highlight("haskell", "foo")
      assert {:ok, _} = Autumn.highlight("hcl", "foo")
      assert {:ok, _} = Autumn.highlight("heex", "foo")
      assert {:ok, _} = Autumn.highlight("html", "foo")
      assert {:ok, _} = Autumn.highlight("java", "foo")
      assert {:ok, _} = Autumn.highlight("javascript", "foo")
      assert {:ok, _} = Autumn.highlight("json", "foo")
      assert {:ok, _} = Autumn.highlight("kotlin", "foo")
      assert {:ok, _} = Autumn.highlight("latex", "foo")
      assert {:ok, _} = Autumn.highlight("llvm", "foo")
      assert {:ok, _} = Autumn.highlight("lua", "foo")
      assert {:ok, _} = Autumn.highlight("make", "foo")
      assert {:ok, _} = Autumn.highlight("php", "foo")
      assert {:ok, _} = Autumn.highlight("proto", "foo")
      assert {:ok, _} = Autumn.highlight("python", "foo")
      assert {:ok, _} = Autumn.highlight("r", "foo")
      assert {:ok, _} = Autumn.highlight("regex", "foo")
      assert {:ok, _} = Autumn.highlight("ruby", "foo")
      assert {:ok, _} = Autumn.highlight("rust", "foo")
      assert {:ok, _} = Autumn.highlight("scala", "foo")
      assert {:ok, _} = Autumn.highlight("scss", "foo")
      assert {:ok, _} = Autumn.highlight("sql", "foo")
      assert {:ok, _} = Autumn.highlight("swift", "foo")
      assert {:ok, _} = Autumn.highlight("toml", "foo")
      assert {:ok, _} = Autumn.highlight("typescript", "foo")
      assert {:ok, _} = Autumn.highlight("yaml", "foo")
      assert {:ok, _} = Autumn.highlight("zig", "foo")
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
