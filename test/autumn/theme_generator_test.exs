defmodule Autumn.ThemeGeneratorTest do
  use ExUnit.Case, async: true
  alias Autumn.ThemeGenerator

  @parent_theme ~S"""
  namespace = "black"
  variable = "blue"

  [palette]
  black = "black_parent"
  blue = "blue_parent"
  """

  @child_theme ~S"""
  inherits = "parent"

  [palette]
  blue = "blue_child"
  """

  @theme_with_module ~S"""
  module = "black"

  [palette]
  black = "black"
  """

  @palette %{
    "foreground" => "blue",
    "background" => "black",
    "blue" => "blue",
    "black" => "black"
  }

  defp style(style) do
    @palette
    |> ThemeGenerator.style(style)
    |> IO.iodata_to_binary()
    |> String.trim()
  end

  defp text(config) do
    ThemeGenerator.scope_text(config, @palette)
  end

  defp background(config) do
    ThemeGenerator.scope_background(config, @palette)
  end

  defp module(config) do
    ThemeGenerator.scope_module(config, @palette)
  end

  @tag :tmp_dir
  test "inheritance", %{tmp_dir: tmp_dir} do
    parent_theme_path = Path.join(tmp_dir, "parent.toml")
    File.write!(parent_theme_path, @parent_theme)

    child_theme_path = Path.join(tmp_dir, "child.toml")
    File.write!(child_theme_path, @child_theme)

    assert {
             :ok,
             "\"background\" = \"class=\\\"autumn highlight background\\\" style=\\\"background-color: #ffffff; \\\"\"\n\"module\" = \"class=\\\"module\\\" style=\\\"color: black_parent; \\\"\"\n\"namespace\" = \"class=\\\"namespace\\\" style=\\\"color: black_parent;\\\"\"\n\"operator\" = \"class=\\\"operator\\\" style=\\\"\\\"\"\n\"text\" = \"class=\\\"text\\\" style=\\\"color: #000000; \\\"\"\n\"variable\" = \"class=\\\"variable\\\" style=\\\"color: blue_parent;\\\"\"\n"
           } = ThemeGenerator.generate_theme_file(parent_theme_path)

    assert {
             :ok,
             "\"background\" = \"class=\\\"autumn highlight background\\\" style=\\\"background-color: #ffffff; \\\"\"\n\"module\" = \"class=\\\"module\\\" style=\\\"color: black_parent; \\\"\"\n\"namespace\" = \"class=\\\"namespace\\\" style=\\\"color: black_parent;\\\"\"\n\"operator\" = \"class=\\\"operator\\\" style=\\\"\\\"\"\n\"text\" = \"class=\\\"text\\\" style=\\\"color: #000000; \\\"\"\n\"variable\" = \"class=\\\"variable\\\" style=\\\"color: blue_child;\\\"\"\n"
           } = ThemeGenerator.generate_theme_file(child_theme_path)
  end

  test "text" do
    assert %{
             "text" => %{
               "class" => ["text"],
               "style" => [["color: ", "black", 59, " "]]
             }
           } = text(%{"ui.text" => "black"})

    assert %{
             "text" => %{
               "class" => ["text"],
               "style" => [["color: ", "#000000", 59, " "]]
             }
           } = text(%{"ui.text" => %{}})
  end

  test "background" do
    assert %{
             "background" => %{
               "class" => ["autumn highlight background"],
               "style" => [["background-color: ", "black", 59, " "]]
             }
           } = background(%{"ui.background" => "black"})

    assert %{
             "background" => %{
               "class" => ["autumn highlight background"],
               "style" => [["background-color: ", "black", 59, " "]]
             }
           } = background(%{"ui.background" => %{"bg" => "black"}})

    assert %{
             "background" => %{
               "class" => ["autumn highlight background"],
               "style" => [["background-color: ", "#ffffff", 59, " "]]
             }
           } = background(%{"ui.background" => %{}})
  end

  describe "module" do
    @tag :tmp_dir
    test "generate", %{tmp_dir: tmp_dir} do
      module_theme_path = Path.join(tmp_dir, "module.toml")
      File.write!(module_theme_path, @theme_with_module)

      assert {
               :ok,
               "\"background\" = \"class=\\\"autumn highlight background\\\" style=\\\"background-color: #ffffff; \\\"\"\n\"module\" = \"class=\\\"module\\\" style=\\\"color: black; \\\"\"\n\"operator\" = \"class=\\\"operator\\\" style=\\\"\\\"\"\n\"text\" = \"class=\\\"text\\\" style=\\\"color: #000000; \\\"\"\n"
             } = ThemeGenerator.generate_theme_file(module_theme_path)
    end

    test "style" do
      assert %{"module" => %{"class" => ["module"], "style" => [["color: ", "black", 59, " "]]}} =
               module(%{"module" => "black"})

      assert %{"module" => %{"class" => ["module"], "style" => [["color: ", "black", 59, " "]]}} =
               module(%{"module" => %{"fg" => "black"}})

      assert %{"module" => %{"class" => ["module"], "style" => [["color: ", "black", 59, " "]]}} =
               module(%{"namespace" => "black"})

      assert %{"module" => %{"class" => ["module"], "style" => [["color: ", "black", 59, " "]]}} =
               module(%{"namespace" => %{"fg" => "black"}})

      assert %{"module" => %{"class" => ["module"], "style" => [["color: ", "black", 59, " "]]}} =
               module(%{"keyword" => "black"})

      assert %{"module" => %{"class" => ["module"], "style" => [["color: ", "black", 59, " "]]}} =
               module(%{"keyword" => %{"fg" => "black"}})

      assert %{"module" => %{"class" => ["module"], "style" => [[]]}} =
               module(%{"other" => "black"})
    end
  end

  describe "style" do
    test "all" do
      assert style(%{
               "fg" => "blue",
               "bg" => "black",
               "modifiers" => ["italic", "bold", "underlined"]
             }) ==
               "text-decoration: underline; font-weight: bold; font-style: italic; color: blue; background-color: black;"
    end

    test "foreground" do
      assert style("blue") == "color: blue;"
      assert style("#fff") == "color: #fff;"
      assert style(%{"fg" => "blue"}) == "color: blue;"
      assert style(%{"fg" => "#fff"}) == "color: #fff;"
    end

    test "with background" do
      assert style(%{"fg" => "blue", "bg" => "black"}) == "color: blue; background-color: black;"
      assert style(%{"fg" => "#fff", "bg" => "#fff"}) == "color: #fff; background-color: #fff;"
    end

    test "with modifiers" do
      assert style(%{"fg" => "blue", "modifiers" => ["italic"]}) ==
               "font-style: italic; color: blue;"

      assert style(%{"fg" => "blue", "modifiers" => ["italic", "bold"]}) ==
               "font-weight: bold; font-style: italic; color: blue;"
    end

    test "underline" do
      assert style(%{"underline" => %{"color" => "blue", "style" => "line"}}) ==
               "text-decoration: underline; color: blue;"
    end
  end
end
