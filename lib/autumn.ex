defmodule Autumn do
  @moduledoc """
  TODO
  """

  alias Autumn.Native

  @doc """
  TODO

  ## Examples

      iex> Autumn.highlight("elixir", ":elixir")
      "<span style=\"color: #ff79c6\">:elixir</span>\n"

  ## Options

      TODO

  """
  def highlight(lang_filename_ext, source, opts \\ []) do
    lang = language(lang_filename_ext)
    theme = Keyword.get(opts, :theme, "onedark")
    Native.highlight(lang, source, theme)
  end

  def highlight!(lang_filename_ext, source, opts \\ []) do
    case highlight(lang_filename_ext, source, opts) do
      {:ok, highlighted} ->
        highlighted

      {:error, error} ->
        raise """
        failed to highlight source code for #{lang_filename_ext}

        Got:

          #{inspect(error)}

        """
    end
  end

  @doc false
  def language(lang_filename_ext) do
    lang_filename_ext
    |> String.downcase()
    |> Path.basename()
    |> do_language
  end

  defp do_language(<<"."::binary, ext::binary>>), do: ext

  defp do_language(lang) do
    case lang |> Path.basename() |> Path.extname() do
      "" -> lang
      ext -> do_language(ext)
    end
  end
end
