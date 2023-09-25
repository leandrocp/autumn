defmodule AutumnTest do
  use ExUnit.Case

  defp expected(html), do: String.trim(html)

  test "invalid lang" do
    assert Autumn.highlight("invalid", ":elixir") == {:error, "invalid lang"}
  end

  test "overwrite pre class" do
    assert Autumn.highlight!("elixir", ":elixir", pre_class: "pre") =~ ~s|<pre class="pre"|
    assert Autumn.highlight!("elixir", ":elixir", pre_class: "") =~ ~s|<pre class=""|
  end

  test "overwrite code class" do
    assert Autumn.highlight!("elixir", ":elixir", code_class: "code") =~ ~s|<code class="code">|
    assert Autumn.highlight!("elixir", ":elixir", code_class: "") =~ ~s|<code class="">|
  end

  describe "highlight" do
    test "elixir with default opts" do
      assert Autumn.highlight!("elixir", ":elixir") ==
               expected(~s"""
               <pre class="autumn highlight" class="background" style="background-color: #282C34; ">
               <code class="language-elixir">
               <span class="string" style="color: #98C379; ">:elixir</span>
               </code></pre>
               """)
    end

    test "ruby with default opts" do
      assert Autumn.highlight!("script.rb", ~s|puts "autumn season"|) ==
               expected(~s"""
               <pre class="autumn highlight" class="background" style="background-color: #282C34; ">
               <code class="language-ruby">
               <span class="function" style="color: #61AFEF; ">puts</span> <span class="string" style="color: #98C379; ">&quot;autumn season&quot;</span>
               </code></pre>
               """)
    end
  end

  test "change theme" do
    assert Autumn.highlight!("elixir", ":elixir", theme: "dracula") ==
             expected(~s"""
             <pre class="autumn highlight" class="background" style="background-color: #282A36; ">
             <code class="language-elixir">
             <span class="string special" style="color: #ffb86c; ">:elixir</span>
             </code></pre>
             """)
  end

  describe "languages" do
    test "by name" do
      assert Autumn.language("elixir") == {:ok, "elixir"}
      assert Autumn.language("Elixir") == {:ok, "elixir"}
      assert Autumn.language("ELIXIR") == {:ok, "elixir"}
    end

    test "by extension" do
      assert Autumn.language("ex") == {:ok, "elixir"}
      assert Autumn.language(".ex") == {:ok, "elixir"}
    end

    test "by file name" do
      assert Autumn.language("file.rb") == {:ok, "ruby"}
      assert Autumn.language("/path/to/file.rb") == {:ok, "ruby"}
      assert Autumn.language("../file.rb") == {:ok, "ruby"}
    end

    test "invalid" do
      assert Autumn.language("undefined") == {:error, "invalid lang"}
    end
  end
end
