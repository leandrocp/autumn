defmodule Autumn.ThemeTest do
  use ExUnit.Case, async: true

  alias Autumn.Theme

  describe "fetch" do
    test "fetch existing theme" do
      assert %Theme{name: "github_light", appearance: "light", highlights: highlights} =
               Theme.get("github_light")

      assert highlights["variable"] == %Theme.Style{fg: "#1f2328"}
    end

    test "fetch invalid theme" do
      refute Theme.get("invalid")
    end
  end
end
