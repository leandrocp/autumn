defmodule Autumn.Themes do
  @moduledoc """
  Bundled themes.
  """

  @theme_files Path.wildcard("priv/themes/**/*.json")

  for path <- @theme_files do
    @external_resource Path.absname(path)
  end

  @external_resource "themes.csv"

  @themes Enum.flat_map(@theme_files, fn theme ->
            themes =
              theme
              |> File.read!()
              |> Autumn.Theme.load_themes()

            case themes do
              {:ok, themes} -> themes
              _ -> []
            end
          end)
          |> Enum.uniq_by(& &1.name)

  for theme <- @themes do
    @doc """
    #{theme.name} by #{theme.author}
    """
    @spec unquote(:"#{theme.private.clean_name}")() :: Autumn.Theme.t()
    def unquote(:"#{theme.private.clean_name}")(), do: unquote(Macro.escape(theme))
  end

  @doc false
  def all do
    for theme <- @themes do
      {theme.name, theme.private.fun_name}
    end
  end
end
