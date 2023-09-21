defmodule Autumn.ThemeGeneratorTest do
  use ExUnit.Case, async: true
  alias Autumn.ThemeGenerator

  @parent_theme ~S"""
  variable = "blue"

  [palette]
  blue = "blue_parent"
  """

  @child_theme ~S"""
  inherits = "parent"

  [palette]
  blue = "blue_child"
  """

  @palette %{
    "foreground" => "blue",
    "background" => "black",
    "blue" => "blue",
    "black" => "black"
  }

  defp line(scope, style) do
    @palette
    |> ThemeGenerator.line(scope, style)
    |> IO.iodata_to_binary()
    |> String.trim()
  end

  defp style(style) do
    @palette
    |> ThemeGenerator.attrs(style)
    |> IO.iodata_to_binary()
    |> String.trim()
  end

  defp background(config) do
    @palette
    |> ThemeGenerator.background(config)
    |> IO.iodata_to_binary()
    |> String.trim()
  end

  @tag :tmp_dir
  test "inheritance", %{tmp_dir: tmp_dir} do
    parent_theme_path = Path.join(tmp_dir, "parent.toml")
    File.write!(parent_theme_path, @parent_theme)

    child_theme_path = Path.join(tmp_dir, "child.toml")
    File.write!(child_theme_path, @child_theme)

    assert {:ok,
            "\"background\" = \"style=\\\"background-color: #ffffff; \\\"\"\n\"variable\" = \"style=\\\"color: blue_parent;\\\"\"\n"} =
             ThemeGenerator.generate(parent_theme_path)

    assert {:ok,
            "\"background\" = \"style=\\\"background-color: #ffffff; \\\"\"\n\"variable\" = \"style=\\\"color: blue_child;\\\"\"\n"} =
             ThemeGenerator.generate(child_theme_path)
  end

  test "background" do
    expected = "\"background\" = \"style=\\\"background-color: black; \\\"\""
    assert background(%{"ui.background" => "black"}) == expected
    assert background(%{"ui.background" => %{"bg" => "black"}}) == expected
    assert background(%{"ui.window" => %{"bg" => "black"}}) == expected

    assert background(%{"ui.window" => %{}}) ==
             "\"background\" = \"style=\\\"background-color: #ffffff; \\\"\""
  end

  describe "line" do
    test "render" do
      assert line("variable", %{
               "fg" => "blue",
               "bg" => "black",
               "modifiers" => ["italic", "bold"]
             }) ==
               "\"variable\" = \"style=\\\"font-weight: bold; text-decoration: underline; color: blue; background-color: black; \\\"\""
    end

    test "remove interface styles" do
      assert line("ui.menu", %{"fg" => "blue"}) == ""
    end
  end

  describe "attrs" do
    test "all" do
      assert style(%{"fg" => "blue", "bg" => "black", "modifiers" => ["italic", "bold"]}) ==
               "font-weight: bold; text-decoration: underline; color: blue; background-color: black;"
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
               "text-decoration: underline; color: blue;"

      assert style(%{"fg" => "blue", "modifiers" => ["italic", "bold"]}) ==
               "font-weight: bold; text-decoration: underline; color: blue;"
    end

    test "underline" do
      assert style(%{"underline" => %{"color" => "blue", "style" => "line"}}) ==
               "text-decoration: underline; color: blue;"
    end
  end
end
