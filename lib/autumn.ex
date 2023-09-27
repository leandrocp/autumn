defmodule Autumn do
  @external_resource "README.md"

  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC -->")
             |> Enum.fetch!(1)

  alias Autumn.Native

  @typedoc """
  A language name, filename, or extesion.

  The following values are valid to highlight an Elixir source code:

    - "elixir", "my_module.ex", "my_script.exs", "ex", "exs"

  And any other language can be highlighted in the same way.

  """
  @type lang_filename_ext :: String.t()

  @doc """
  Highlight the `source_code` with the rules of `lang_filename_ext`.

  ## Options

  * `:theme` (default `"onedark"`) - accepts any theme listed [here](https://github.com/leandrocp/autumn/tree/main/priv/themes),
  you should pass the filename without special chars and without extension, for example you should pass `theme: "adwaita_dark"` to use the [Adwaita Dark](https://github.com/leandrocp/autumn/blob/main/priv/themes/adwaita-dark.toml) theme.
  * `:pre_class` (default: `"autumn highlight"`) - the CSS class to inject into the `<pre>` tag.

  """
  @spec highlight(lang_filename_ext(), String.t(), keyword()) ::
          {:ok, String.t()} | {:error, term()}
  def highlight(lang_filename_ext, source_code, opts \\ []) do
    lang = language(lang_filename_ext)
    theme = Keyword.get(opts, :theme, "onedark")
    pre_class = Keyword.get(opts, :pre_class, "autumn highlight")
    Native.highlight(lang, source_code, theme, pre_class)
  end

  @doc """
  Same as `highlight/3` but raises in case of failure.
  """
  @spec highlight!(lang_filename_ext(), String.t(), keyword()) :: String.t()
  def highlight!(lang_filename_ext, source_code, opts \\ []) do
    case highlight(lang_filename_ext, source_code, opts) do
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
