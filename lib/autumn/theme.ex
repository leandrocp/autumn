defmodule Autumn.Theme do
  @moduledoc """
  TODO

  ## Examples


  """

  @type t :: %Autumn.Theme{
          name: String.t(),
          appearance: String.t(),
          highlights: map()
        }

  defstruct name: nil, appearance: nil, highlights: %{}

  def fetch(name) do
    Autumn.Native.fetch_theme(name)
  end
end

defmodule Autumn.Theme.Style do
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
