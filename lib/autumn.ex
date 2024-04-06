defmodule Autumn do
  @external_resource "README.md"

  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC -->")
             |> Enum.fetch!(1)

  @typedoc """
  A language name, filename, or extesion.

  ## Examples

      - "elixir"
      - "main.rb"
      - ".rs"
      - "php"

  An invalid language or `nil` will fallback to rendering plain text
  using the background and foreground colors defined by the current theme.

  """
  @type lang_filename_ext :: String.t() | nil

  @doc """
  Highlights the `source_code` using the tree-sitter grammar for `lang_filename_ext`.

  ## Options

  * `:theme` (default `"onedark"`) - accepts any theme listed [here](https://github.com/leandrocp/autumn/tree/main/priv/themes).
  You should pass the filename without special chars and without extension,
  for example pass `theme: "adwaita_dark"` to use the [Adwaita Dark](https://github.com/leandrocp/autumn/blob/main/priv/themes/adwaita-dark.toml) theme
  or `theme: "penumbra"` to use the [Penumbra+](https://github.com/leandrocp/autumn/blob/main/priv/themes/penumbra%2B.toml) theme.
  * `:pre_class` (default `nil`) - the CSS class to inject into the wrapping parent `<pre>` tag.
  By default it renders a `<pre>` tag with the `autumn-hl` class which will be merged with the class passed into this option.
  * `:inline_style` (default `true`) - see more info on the module doc.
  """
  @spec highlight(lang_filename_ext(), String.t(), keyword()) ::
          {:ok, String.t()} | {:error, term()}
  def highlight(lang_filename_ext, source_code, opts \\ []) do
    lang = language(lang_filename_ext)
    theme = Keyword.get(opts, :theme, "onedark")
    pre_class = Keyword.get(opts, :pre_class, nil)
    inline_style = Keyword.get(opts, :inline_style, true)
    Autumn.Native.highlight(lang, source_code, theme, pre_class, inline_style)
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
  def language(lang_filename_ext) when is_binary(lang_filename_ext) do
    lang_filename_ext
    |> String.downcase()
    |> Path.basename()
    |> do_language
  end

  def language(_lang_filename_ext), do: "plaintext"

  defp do_language(<<"."::binary, ext::binary>>), do: ext

  defp do_language(lang) when is_binary(lang) do
    case lang |> Path.basename() |> Path.extname() do
      "" -> lang
      ext -> do_language(ext)
    end
  end
end
