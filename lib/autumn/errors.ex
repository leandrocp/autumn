defmodule Autumn.InputError do
  defexception [:message]
end

defmodule Autumn.ThemeError do
  defexception [:reason, :family]

  @type t() :: %__MODULE__{reason: atom(), family: String.t()}

  def message(%__MODULE__{reason: :missing_data, family: family}) when is_binary(family) do
    """
    missing data for theme family #{family}

    expected a list of themes with style
    """
  end

  def message(%__MODULE__{reason: :missing_data}) do
    "missing data for theme"
  end
end

defmodule Autumn.ThemeDecodeError do
  defexception [:error]

  @type t() :: %__MODULE__{error: Exception.t()}

  def message(%__MODULE__{error: error}) do
    """
    error decoding theme family

    got:

      #{Exception.message(error)}
    """
  end
end

defmodule Autumn.HighlightError do
  defexception [:error]

  @type t() :: %__MODULE__{error: Exception.t()}

  def message(%__MODULE__{error: error}) do
    """
    error highlighting source code

    got:

      #{Exception.message(error)}
    """
  end
end
