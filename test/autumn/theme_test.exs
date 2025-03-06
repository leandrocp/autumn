defmodule Autumn.ThemeTest do
  use ExUnit.Case, async: true

  alias Autumn.Theme

  describe "fetch" do
    test "fetch existing theme" do
      assert {:ok, %Theme{name: "github_light", appearance: "light", highlights: highlights}} =
               Theme.get("github_light")

      assert highlights["variable"] == %Theme.Style{fg: "#1f2328"}
    end

    test "fetch invalid theme" do
      assert Theme.fetch("invalid") == {:error, "Theme 'invalid' not found"}
    end
  end
end
