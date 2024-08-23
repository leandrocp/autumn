defmodule Autumn.Themes do
  @moduledoc """
  Bundled themes.
  """

  # FIXME: docs and spec

  @theme_files Path.wildcard("deps/theme_*/**/*.json")

  for path <- @theme_files do
    @external_resource Path.absname(path)
  end

  @themes @theme_files
          |> Enum.flat_map(fn file ->
            file
            |> File.read!()
            |> Autumn.Theme.load!()
          end)
          |> Enum.sort_by(& &1.name)

  for theme <- @themes do
    fn_name = Autumn.Theme.sanitize_name(theme.name)

    def unquote(:"#{fn_name}")(), do: unquote(Macro.escape(theme))

    def unquote(:"#{fn_name}!")() do
      case unquote(:"#{fn_name}")() do
        {:ok, theme} -> theme
        _ -> raise "failed to load theme #{unquote(theme.name)}"
      end
    end
  end

  @doc false
  def available_themes do
    for theme <- @themes do
      {theme.name, theme.private.fn_name}
    end
  end

  @spec get(String.t()) :: Autumn.Theme.t() | nil
  def get(name) do
    case Enum.find(available_themes(), fn {theme_name, _} -> theme_name == name end) do
      nil -> nil
      {_, fn_theme} -> apply(fn_theme, [])
    end
  end

  def get!(name) do
    case get(name) do
      nil -> raise "failed to load theme #{name}"
      theme -> theme
    end
  end
end
