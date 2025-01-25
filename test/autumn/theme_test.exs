defmodule Autumn.ThemeTest do
  use ExUnit.Case, async: true
  alias Autumn.Theme

  setup do
    [
      good: Path.join([File.cwd!(), "test", "fixtures", "one.json"]) |> File.read!(),
      malformed: Path.join([File.cwd!(), "test", "fixtures", "malformed.json"]) |> File.read!()
    ]
  end

  describe "get" do
    test "by display name" do
      assert %Theme{name: "One Dark"} = Theme.get("One Dark")
    end

    test "by function name" do
      assert %Theme{name: "One Dark"} = Theme.get("one_dark")
    end
  end

  test "malformed", %{malformed: malformed} do
    assert {:error, %Autumn.ThemeDecodeError{}} = Theme.load_themes(malformed)
  end

  test "load all themes", %{good: good} do
    {:ok, themes} = Theme.load_themes(good)
    assert [%Theme{name: "One Dark"}, %Theme{name: "One Light"}] = themes
  end

  test "author", %{good: good} do
    {:ok, [theme | _]} = Theme.load_themes(good)
    assert theme.author == "Zed Industries"
  end

  test "family", %{good: good} do
    {:ok, [theme | _]} = Theme.load_themes(good)
    assert theme.family == "One"
  end

  test "fun_name", %{good: good} do
    {:ok, [theme | _]} = Theme.load_themes(good)
    assert theme.private.fun_name == (&Autumn.Themes.one_dark/0)
  end
end
