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
         revision: "1.0",
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
          revision: String.t(),
          highlights: map()
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
