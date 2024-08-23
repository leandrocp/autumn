defmodule Autumn.ThemeTest do
  use ExUnit.Case, async: true
  alias Autumn.Theme

  @theme Path.join([File.cwd!(), "test", "fixtures", "one.json"]) |> File.read!()

  test "load" do
    assert [
             %Autumn.Theme{author: "Zed Industries", name: "One Light", appearance: "light", style: %{syntax: %{}}},
             %Autumn.Theme{author: "Zed Industries", name: "One Dark", appearance: "dark", style: %{syntax: %{}}}
           ] =
             Theme.load(@theme)
  end
end
