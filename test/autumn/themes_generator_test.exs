defmodule Autumn.ThemesGeneratorTest do
  use ExUnit.Case, async: true

  alias Autumn.ThemesGenerator

  @parent_theme ~S"""
  namespace = "black"
  function = "blue"
  "function.macro" = { fg = "green", modifiers = ["italic"] }

  [palette]
  black = "black_parent"
  blue = "blue_parent"
  green = "green_parent"
  """

  @child_theme ~S"""
  inherits = "parent"

  [palette]
  blue = "blue_child"
  """

  @tag :tmp_dir
  test "generate", %{tmp_dir: tmp_dir} do
    parent_theme_path = Path.join(tmp_dir, "parent.toml")
    File.write!(parent_theme_path, @parent_theme)

    child_theme_path = Path.join(tmp_dir, "child.toml")
    File.write!(child_theme_path, @child_theme)

    dest_path = Path.join(tmp_dir, "themes.rs")

    {:ok, themes} = ThemesGenerator.generate(tmp_dir, dest_path)

    assert %{
             "child" => %{
               "text" => %{"class" => "text", "style" => "color: #000000;"},
               "background" => %{"class" => "text", "style" => "background-color: #ffffff;"},
               "function" => %{"class" => "function", "style" => "color: blue_child;"},
               "function.macro" => %{
                 "class" => "function-macro",
                 "style" => "font-style: italic; color: green_parent;"
               },
               "namespace" => %{"class" => "namespace", "style" => "color: black_parent;"}
             },
             "parent" => %{
               "text" => %{"class" => "text", "style" => "color: #000000;"},
               "background" => %{"class" => "text", "style" => "background-color: #ffffff;"},
               "function" => %{"class" => "function", "style" => "color: blue_parent;"},
               "function.macro" => %{
                 "class" => "function-macro",
                 "style" => "font-style: italic; color: green_parent;"
               },
               "namespace" => %{"class" => "namespace", "style" => "color: black_parent;"}
             }
           } = themes
  end

  @tag :tmp_dir
  test "parse_theme_file", %{tmp_dir: tmp_dir} do
    parent_theme_path = Path.join(tmp_dir, "parent.toml")
    File.write!(parent_theme_path, @parent_theme)

    child_theme_path = Path.join(tmp_dir, "child.toml")
    File.write!(child_theme_path, @child_theme)

    assert ThemesGenerator.parse_theme_file(child_theme_path) ==
             %{
               "palette" => %{
                 "black" => "black_parent",
                 "blue" => "blue_child",
                 "green" => "green_parent"
               },
               "scopes" => %{
                 "function" => "blue",
                 "function.macro" => %{"fg" => "green", "modifiers" => ["italic"]},
                 "namespace" => "black"
               }
             }
  end
end
