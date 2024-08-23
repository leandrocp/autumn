defmodule Autumn.Theme do
  @moduledoc """
  Load and manipulate themes.

  Themes are sourced from the [Zed ecosystem](https://zed-themes.com),
  and they're based on https://zed.dev/schema/themes/v0.2.0.json

  You can load one of the built-in [bundled themes](Autumn.Themes.html), customize it, or even load custom themes:

  ## Examples

  Load a built-in theme and manipulate a style:

      # load the Dracula theme
      iex> theme = Autumn.Themes.dracula()
      # make all numbers red
      iex> style = put_in(theme.style, ["syntax", "number", "color"], "red")
      iex> %{theme | style: style}
      %Autumn.Theme{name: "Dracula", style: %{"syntax" => %{"number" => %{"color" => "red"}}}}

  Load from a URL:

      iex> Req.get!("https://raw.githubusercontent.com/dracula/zed/refs/heads/main/themes/dracula.json").body |> Autumn.Theme.load_themes!()
      [%Autumn.Theme{name: "Dracula", appearance: "dark"}]

  Once loaded you can pass a `%Autumn.Theme{}` to the functions in `Autumn` to apply the styles into the highlighted source code.

  """

  @type t :: %Autumn.Theme{
          name: String.t(),
          family: String.t(),
          author: String.t(),
          appearance: String.t(),
          style: map()
        }

  @derive {Inspect, only: [:name, :family, :author, :appearance, :style]}

  defstruct name: nil, family: nil, author: nil, appearance: nil, style: %{}, private: nil

  @doc """
  Get a [bundled theme](Autumn.Themes.html) by name.

  Prefer calling one of the functions in `Autumn.Themes` directly,
  which is more optimized than this function.

  ## Examples

  Find a theme by its full name:

      iex> Autumn.Theme.get("Base16 Atlas")
      %Autumn.Theme{name: "Base16 Atlas", family: "base16", author: "Alex Lende (https://ajlende.com)", appearance: "dark", style: %{...}}

  Or by its function name:

      iex> Autumn.Theme.get("one_dark_pro")
      %Autumn.Theme{name: "One Dark Pro", family: "One Dark Pro", author: "One Dark Pro: Zed Theme Importer", appearance: "dark", style: %{...}}

  """
  @spec get(name :: String.t()) :: Autumn.Theme.t() | nil
  def get(name) when is_binary(name) do
    found =
      Enum.find(Autumn.Themes.all(), fn {theme_name, fun} ->
        theme_name == name || apply(fun, []).private.clean_name == name
      end)

    case found do
      nil -> nil
      {_, fun} -> apply(fun, [])
    end
  end

  def get(%Autumn.Theme{} = theme), do: theme

  @doc """
  Load all the themes present in a theme family.

  ## Examples

      iex> Req.get!("https://raw.githubusercontent.com/dracula/zed/refs/heads/main/themes/dracula.json").body |> Autumn.Theme.load_themes!()
      [%Autumn.Theme{name: "Dracula", appearance: "dark"}]

      iex> File.read!("dracula.json") |> Autumn.Theme.load_themes!()
      [%Autumn.Theme{name: "Dracula", appearance: "dark"}]

  """
  @spec load_themes(theme_family :: String.t()) ::
          {:ok, [t()]} | {:error, Autumn.ThemeError.t() | Autumn.ThemeDecodeError.t()}
  def load_themes(theme_family) when is_binary(theme_family) do
    case decode(theme_family) do
      {:ok, {family, author, themes}} ->
        {:ok, build_themes(family, author, themes)}

      error ->
        error
    end
  end

  @doc """
  Load all themes of a theme family, but raises if themes are invalid.
  """
  @spec load_themes!(theme_family :: String.t()) :: [t()]
  def load_themes!(theme_family) when is_binary(theme_family) do
    case load_themes(theme_family) do
      {:ok, themes} -> themes
      {:error, error} -> raise error
    end
  end

  defp decode(theme_family) do
    case Jason.decode(theme_family) do
      {:ok, %{"name" => family, "author" => author, "themes" => [%{"style" => _} | _] = themes}} ->
        {:ok, {family, author, themes}}

      {:ok, theme_family} ->
        {:error, %Autumn.ThemeError{reason: :missing_data, family: theme_family["name"]}}

      {:error, error} ->
        {:error, %Autumn.ThemeDecodeError{error: error}}
    end
  end

  defp build_themes(family, author, themes) do
    themes
    |> Enum.reduce([], fn theme, acc ->
      case new(family, author, theme) do
        {:ok, theme} -> [theme | acc]
        # TODO: log error?
        _ -> acc
      end
    end)
    |> Enum.sort_by(& &1.name)
  end

  defp new(family, author, %{
         "name" => name,
         "appearance" => appearance,
         "style" => style
       }) do
    {_, style} = Map.pop(style, "players")

    clean_name = sanitize_name(name)
    fun_name = Function.capture(Autumn.Themes, String.to_atom(clean_name), 0)

    {:ok,
     %Autumn.Theme{
       name: name,
       family: family,
       author: author,
       appearance: appearance,
       style: style,
       private: %{
         clean_name: clean_name,
         fun_name: fun_name
       }
     }}
  end

  defp new(_family, _author, _theme) do
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

  @doc """
  Generates the stylesheet for a theme.

  Note that stylesheets for all built-in bundled themes are
  available at [/priv/static/css](https://github.com/leandrocp/autumn/tree/main/priv/static/css).

  See the [Linked Formatter](Autumn.html#module-linked) docs for more info.

  ## Example

      iex> Autumn.Themes.catppuccin_frappe() |> Autumn.Theme.stylesheet()
      ~s\"\"\"
      /* Catppuccin Frappé - Catppuccin <releases@catppuccin.dev> */
      pre.athl {
        background-color: #303446; color: #c6d0f5;
      }
      .athl-attribute {
        color: #ef9f76;
      }
      .athl-boolean {
        color: #ef9f76;
      }
      ...
      \"\"\"
  """
  @spec stylesheet(t()) :: String.t()
  def stylesheet(%Autumn.Theme{} = theme) do
    Autumn.Native.stylesheet(theme)
  end
end
