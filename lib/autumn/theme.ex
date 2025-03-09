defmodule Autumn.Theme do
  @moduledoc """
  A Neovim theme.

  Contains the name, appearance, and a map of highlight `Autumn.Theme.Style`'s.

  Autumn bundles the most popular themes from the Neovim community,
  you can see the full list with `Autumn.available_themes/0` and
  then fetch one of the bundled themes with `Autumn.Theme.fetch/1`.

  ## Example

      %Autumn.Theme{
         name: "github_light",
         appearance: "light",
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

  @type t :: %Autumn.Theme{
          name: String.t(),
          appearance: String.t(),
          highlights: map()
        }

  defstruct name: nil, appearance: nil, highlights: %{}

  @doc """
  Fetch a theme by name.
  """
  @spec fetch(String.t()) :: Autumn.Theme.t() | nil
  def fetch(name) do
    Autumn.Native.fetch_theme(name)
  end

  @doc """
  Fetch a theme by name, raising if not found.
  """
  @spec fetch!(String.t()) :: Autumn.Theme.t()
  def fetch!(name) do
    case fetch(name) do
      nil -> raise ArgumentError, "Theme not found: #{name}"
      theme -> theme
    end
  end
end

defmodule Autumn.Theme.Style do
  @moduledoc """
  A highlight style.

  Contains the colors and styles of each highlight of a theme.
  """

  @type t :: %Autumn.Theme.Style{
          fg: nil | String.t(),
          bg: nil | String.t(),
          underline: boolean(),
          bold: boolean(),
          italic: boolean(),
          strikethrough: boolean()
        }

  defstruct fg: nil, bg: nil, underline: false, bold: false, italic: false, strikethrough: false
end
