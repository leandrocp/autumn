defmodule AutumnTest do
  use ExUnit.Case

  defp expected(html), do: String.trim(html)

  test "overwrite pre class" do
    assert Autumn.highlight("elixir", ":elixir", pre_class: "pre") =~ ~s|<pre class="pre"|
    assert Autumn.highlight("elixir", ":elixir", pre_class: "") =~ ~s|<pre class=""|
  end

  test "overwrite code class" do
    assert Autumn.highlight("elixir", ":elixir", code_class: "code") =~ ~s|<code class="code">|
    assert Autumn.highlight("elixir", ":elixir", code_class: "") =~ ~s|<code class="">|
  end

  describe "highlight" do
    test "elixir with default opts" do
      assert Autumn.highlight("elixir", ":elixir") ==
               expected(~s"""
               <pre class="autumn highlight" class="background" style="background-color: #282C34; ">
               <code class="language-elixir">
               <span class="string special" style="color: #ffb86c; ">:elixir</span>
               </code></pre>
               """)
    end

    test "ruby with default opts" do
      assert Autumn.highlight("script.rb", ~s|puts "autumn season"|) ==
               expected(~s"""
               <pre class="autumn highlight" class="background" style="background-color: #282C34; ">
               <code class="language-ruby">
               <span class="function method" style="color: #50fa7b; ">puts</span> <span class="string" style="color: #f1fa8c; ">&quot;autumn season&quot;</span>
               </code></pre>
               """)
    end
  end

  # test "change theme" do
  #   assert Autumn.highlight("elixir", ":elixir", theme: "Dracula") ==
  #            expected(~s"""
  #            <pre class="highlight"><code class="language-elixir">
  #            <span style="color: #">:elixir</span>
  #            </code></pre>
  #            """)
  # end

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

    test "raise if not loaded" do
      assert_raise RuntimeError, "failed to find a loaded language for undefined", fn ->
        Autumn.language("undefined")
      end
    end
  end
end
