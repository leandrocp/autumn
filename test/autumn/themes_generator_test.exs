defmodule Autumn.ThemesGeneratorTest do
  use ExUnit.Case, async: true

  alias Autumn.ThemesGenerator

  @parent_theme ~S"""
  "comment"              = "comment"
  "comment.block"        = { fg = "comment" }
  "keyword.storage.type" = { fg = "cyan", modifiers = ["italic"] }
  "markup"               = "black"
  "ui.menu"              = "black"

  [palette]
  comment    = "#6272A4"
  cyan       = "#8be9fd"
  """

  @child_theme ~S"""
  inherits  = "parent"
  "child_token" = { fg = "pink" }

  [palette]
  pink = "#ff79c6"
  """

  @fg_color "#f8f8f2"
  @fg_style "color: #f8f8f2;"
  @bg_color "#282a36"
  @bg_style "background-color: #282a36;"

  @tag :tmp_dir
  test "parse_theme_file", %{tmp_dir: tmp_dir} do
    parent_theme_path = Path.join(tmp_dir, "parent.toml")
    File.write!(parent_theme_path, @parent_theme)

    child_theme_path = Path.join(tmp_dir, "child.toml")
    File.write!(child_theme_path, @child_theme)

    assert ThemesGenerator.parse_theme_file(child_theme_path) == %{
             "name" => "child",
             "palette" => %{"comment" => "#6272A4", "cyan" => "#8be9fd", "pink" => "#ff79c6"},
             "scopes" => %{
               "comment" => "comment",
               "comment.block" => %{"fg" => "comment"},
               "keyword.storage.type" => %{"fg" => "cyan", "modifiers" => ["italic"]},
               "markup" => "black",
               "ui.menu" => "black",
               "child_token" => %{"fg" => "pink"}
             }
           }
  end

  describe "expand_theme" do
    test "single attr resolves to fg" do
      assert %{
               "scopes" => %{
                 "comment" => %{
                   "rule" => ".ahl-comment",
                   "style" => @fg_style
                 }
               }
             } =
               ThemesGenerator.expand_theme(%{
                 "palette" => %{"foreground" => @fg_color},
                 "scopes" => %{"comment" => "foreground"}
               })
    end

    test "fg modifier" do
      assert %{
               "scopes" => %{
                 "comment" => %{
                   "rule" => ".ahl-comment",
                   "style" => @fg_style
                 }
               }
             } =
               ThemesGenerator.expand_theme(%{
                 "palette" => %{"foreground" => @fg_color},
                 "scopes" => %{"comment" => %{"fg" => "foreground"}}
               })
    end

    test "bg modifier" do
      assert %{
               "scopes" => %{
                 "comment" => %{
                   "rule" => ".ahl-comment",
                   "style" => @bg_style
                 }
               }
             } =
               ThemesGenerator.expand_theme(%{
                 "palette" => %{"background" => @bg_color},
                 "scopes" => %{"comment" => %{"bg" => "background"}}
               })
    end

    test "multiple modifiers" do
      assert %{
               "scopes" => %{
                 "comment" => %{
                   "rule" => ".ahl-comment",
                   "style" => "#{@fg_style} #{@bg_style}"
                 }
               }
             } =
               ThemesGenerator.expand_theme(%{
                 "palette" => %{"foreground" => @fg_color, "background" => @bg_color},
                 "scopes" => %{"comment" => %{"fg" => "foreground", "bg" => "background"}}
               })
    end

    test "long scope with multiple names" do
      assert %{
               "scopes" => %{
                 "keyword.storage.type" => %{
                   "rule" => ".ahl-keyword.ahl-storage.ahl-type",
                   "style" => "color: black;"
                 }
               }
             } =
               ThemesGenerator.expand_theme(%{
                 "scopes" => %{"keyword.storage.type" => "black"}
               })
    end

    test "ignores scopes with empty styles" do
      %{"scopes" => scopes} =
        ThemesGenerator.expand_theme(%{"scopes" => %{"markup" => %{"modifiers" => []}}})

      assert scopes == %{}
    end

    test "ignores ui scopes" do
      %{"scopes" => scopes} =
        ThemesGenerator.expand_theme(%{"scopes" => %{"ui.menu" => "black"}})

      assert scopes == %{}
    end

    test "resolves global foreground style" do
      assert %{"global" => %{"foreground" => "color: black;"}} =
               ThemesGenerator.expand_theme(%{"scopes" => %{"text" => "black"}})
    end

    test "resolves global background style" do
      assert %{"global" => %{"background" => "background-color: black;"}} =
               ThemesGenerator.expand_theme(%{"scopes" => %{"background" => "black"}})
    end
  end

  @tag :tmp_dir
  test "generate_themes_rs", %{tmp_dir: tmp_dir} do
    parent_theme_path = Path.join(tmp_dir, "parent.toml")
    File.write!(parent_theme_path, @parent_theme)

    child_theme_path = Path.join(tmp_dir, "child.toml")
    File.write!(child_theme_path, @child_theme)

    dest_path = Path.join(tmp_dir, "themes.rs")

    assert %{
             "child" => %{
               "global" => %{
                 "background" => "background-color: #ffffff;",
                 "foreground" => "color: #000000;"
               },
               "scopes" => %{
                 "child_token" => %{"rule" => ".ahl-child_token", "style" => "color: #ff79c6;"},
                 "comment" => %{"rule" => ".ahl-comment", "style" => "color: #6272A4;"},
                 "comment.block" => %{
                   "rule" => ".ahl-comment.ahl-block",
                   "style" => "color: #6272A4;"
                 },
                 "keyword.storage.type" => %{
                   "rule" => ".ahl-keyword.ahl-storage.ahl-type",
                   "style" => "font-style: italic; color: #8be9fd;"
                 },
                 "markup" => %{"rule" => ".ahl-markup", "style" => "color: black;"}
               }
             },
             "parent" => %{
               "global" => %{
                 "background" => "background-color: #ffffff;",
                 "foreground" => "color: #000000;"
               },
               "scopes" => %{
                 "comment" => %{"rule" => ".ahl-comment", "style" => "color: #6272A4;"},
                 "comment.block" => %{
                   "rule" => ".ahl-comment.ahl-block",
                   "style" => "color: #6272A4;"
                 },
                 "keyword.storage.type" => %{
                   "rule" => ".ahl-keyword.ahl-storage.ahl-type",
                   "style" => "font-style: italic; color: #8be9fd;"
                 },
                 "markup" => %{"rule" => ".ahl-markup", "style" => "color: black;"}
               }
             }
           } = ThemesGenerator.generate_themes_rs(tmp_dir, dest_path)
  end

  @tag :tmp_dir
  test "generate_css", %{tmp_dir: tmp_dir} do
    parent_theme_path = Path.join(tmp_dir, "parent.toml")
    File.write!(parent_theme_path, @parent_theme)

    child_theme_path = Path.join(tmp_dir, "child.toml")
    File.write!(child_theme_path, @child_theme)

    dest_path = Path.join(tmp_dir, "themes.rs")

    assert %{"child" => child} = ThemesGenerator.generate_css(tmp_dir, dest_path)

    assert child == ~S"""
           /* child */
           pre.autumn-hl { background-color: #ffffff; color: #000000; }
           .ahl-child_token { color: #ff79c6; }
           .ahl-comment { color: #6272A4; }
           .ahl-comment.ahl-block { color: #6272A4; }
           .ahl-keyword.ahl-storage.ahl-type { font-style: italic; color: #8be9fd; }
           .ahl-markup { color: black; }
           """
  end
end
