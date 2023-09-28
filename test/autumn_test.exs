defmodule AutumnTest do
  use ExUnit.Case

  describe "highlight" do
    test "elixir with default opts" do
      assert Autumn.highlight!("elixir", ":elixir") ==
               ~s"""
               <pre class="autumn highlight" style="background-color: #282C34;">
               <code class="language-elixir"><span class="string" style="color: #98C379;">:elixir</span>
               </code></pre>
               """
    end

    test "ruby with default opts" do
      assert Autumn.highlight!("script.rb", ~s|puts "autumn season"|) ==
               ~s"""
               <pre class="autumn highlight" style="background-color: #282C34;">
               <code class="language-rb"><span class="function" style="color: #61AFEF;">puts</span> <span class="string" style="color: #98C379;">&quot;autumn season&quot;</span>
               </code></pre>
               """
    end

    test "fallback to plain text on invalid lang" do
      expected = ~s"""
      <pre class="autumn highlight" style="background-color: #282C34; color: #ABB2BF;">
      <code class="language-plain">:elixir
      </code></pre>
      """

      assert Autumn.highlight!("invalid", ":elixir") == expected
      assert Autumn.highlight!(nil, ":elixir") == expected
    end
  end

  test "change theme" do
    assert Autumn.highlight!("elixir", ":elixir", theme: "dracula") ==
             ~s"""
             <pre class="autumn highlight" style="background-color: #282A36;">
             <code class="language-elixir"><span class="string special" style="color: #ffb86c;">:elixir</span>
             </code></pre>
             """
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
