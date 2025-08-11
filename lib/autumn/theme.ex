defmodule Autumn.Theme do
  @moduledoc """
  A Neovim theme.

  Contains the name, appearance, and a map of highlight `Autumn.Theme.Style`'s.

  Autumn bundles the most popular themes from the Neovim community,
  you can see the full list with `Autumn.available_themes/0` and
  then fetch one of the bundled themes with `Autumn.Theme.get/1`.

  Or check out all the [available themes](https://docs.rs/autumnus/latest/autumnus/#themes-available).

  ## Example

      %Autumn.Theme{
         name: "github_light",
         appearance: "light",
         revision: "fe70a27afefa6e10db4a59262d31f259f702fd6a",
         highlights: %{
           "function.macro" => %Autumn.Theme.Style{
             fg: "#6639ba",
             bg: nil,
             underline: false,
             bold: false,
             italic: false,
             strikethrough: false
           },
           "variable.builtin" => %Autumn.Theme.Style{
             fg: "#0550ae",
             bg: nil,
             underline: false,
             bold: false,
             italic: false,
             strikethrough: false
           },
           "character" => %Autumn.Theme.Style{
             fg: "#0a3069",
             bg: nil,
             underline: false,
             bold: false,
             italic: false,
             strikethrough: false
           },
           ...
         }
      }

  """


  @typedoc "A Neovim theme with name, appearance (light or dark), revision, and highlight styles."
  @type t :: %Autumn.Theme{
          name: String.t(),
          appearance: String.t(),
          revision: String.t(),
          highlights: %{String.t() => Autumn.Theme.Style.t()}
        }

  defstruct name: nil, appearance: nil, revision: nil, highlights: %{}

  @doc """
  Get a theme by name.
  """
  @spec get(String.t(), any()) :: Autumn.Theme.t() | nil
  def get(name, default \\ nil) when is_binary(name) do
    case Autumn.Native.get_theme(name) do
      :error -> default
      theme -> theme
    end
  end

  @doc """
  Load a theme from a JSON file.
  """
  @spec from_file(String.t()) :: {:ok, Autumn.Theme.t()} | {:error, term()}
  def from_file(path) when is_binary(path) do
    case Autumn.Native.build_theme_from_file(path) do
      :error -> {:error, :invalid_theme_file}
      theme -> {:ok, theme}
    end
  end

  @doc """
  Load a theme from a JSON string.
  """
  @spec from_json(String.t()) :: {:ok, Autumn.Theme.t()} | {:error, term()}
  def from_json(json_string) when is_binary(json_string) do
    case Autumn.Native.build_theme_from_json_string(json_string) do
      :error -> {:error, :invalid_json}
      theme -> {:ok, theme}
    end
  end
end

defmodule Autumn.Theme.Style do
  @moduledoc """
  A highlight style.

  Contains the colors and styles of each highlight of a theme.
  """

  @typedoc "A highlight style with foreground/background colors and text decorations."
  @type t :: %Autumn.Theme.Style{
          fg: nil | String.t(),
          bg: nil | String.t(),
          underline: boolean(),
          bold: boolean(),
          italic: boolean(),
          strikethrough: boolean()
        }

  defstruct fg: nil,
            bg: nil,
            underline: false,
            bold: false,
            italic: false,
            strikethrough: false
end
