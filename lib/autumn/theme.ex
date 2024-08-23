defmodule Autumn.Theme do
  @moduledoc """
  Load and manipulate themes to colorize highlights.

  Themes are sourced from the [Zed ecosystem](https://zedz.dev).

  You can load one of the built-in themes, customize it, or even load custom themes:

  ## Examples

  Load a built-in theme and manipulate a style:

      # make all numbers red
      iex> Autumn.Themes.dracula() |> put_in([:style, "syntax", "number", "color"], "red")
      %Autumn.Theme{name: "Dracula", style: %{"syntax" => %{"number" => %{"color" => "red"}}}}

  _Tip_: use the link above to build and manipulate themes interactively.

  Load from a URL:

      iex> "https://raw.githubusercontent.com/dracula/zed/refs/heads/main/themes/dracula.json" |> Req.get!() |> Autumn.Theme.load!()
      %Autumn.Theme{name: "Dracula"}

  Spec: https://zed.dev/schema/themes/v0.1.0.json

  """

  @type t :: %Autumn.Theme{
          name: String.t(),
          author: String.t(),
          appearance: String.t(),
          style: map()
        }

  @derive {Inspect, only: [:name, :author, :appearance, :style]}

  defstruct name: nil, author: nil, appearance: nil, style: %{}, private: nil

  # FIXME: specs
  def load(theme_family) when is_binary(theme_family) do
    with {:ok, %{"author" => author, "themes" => themes}} <- Jason.decode(theme_family),
         {:ok, themes} <- build_themes(author, themes) do
      themes
    else
      # FIXME: return Autumn.ThemeError
      {:error, _} -> nil
    end
  end

  def load!(theme_family) when is_binary(theme_family) do
    case load(theme_family) do
      # FIXME: raise Autumn.ThemeError
      nil -> raise "failed to load theme"
      themes -> themes
    end
  end

  defp build_themes(author, themes) when is_list(themes) do
    themes =
      Enum.reduce_while(themes, [], fn theme, acc ->
        case new(author, theme) do
          {:ok, theme} -> {:cont, [theme | acc]}
          {:error, _} = error -> {:halt, error}
        end
      end)

    case themes do
      {:error, error} -> {:error, error}
      themes -> {:ok, themes}
    end
  end

  # FIXME: better error
  defp build_themes(_author, _themes) do
    {:error, :invalid_themes}
  end

  defp new(author, %{
         "name" => name,
         "appearance" => appearance,
         "style" => style
       }) do
    colors = Map.take(style, ["background", "text", "editor.background"])
    syntax = Map.get(style, "syntax", %{})

    fn_name =
      name
      |> sanitize_name()
      |> String.to_atom()

    fn_name = Function.capture(Autumn.Themes, fn_name, 0)

    {:ok,
     %Autumn.Theme{
       author: author,
       name: name,
       appearance: appearance,
       style: %{"colors" => colors, "syntax" => syntax},
       private: %{
         fn_name: fn_name
       }
     }}
  end

  defp new(_author, _theme) do
    {:error, :invalid_theme}
  end

  @doc false
  def sanitize_name(name) when is_binary(name) do
    name
    |> String.normalize(:nfd)
    |> String.replace(~r/\W/u, " ")
    |> String.split(" ")
    |> Enum.reject(&(&1 == ""))
    |> Enum.join("_")
    |> String.downcase()
  end
end
