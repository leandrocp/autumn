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

  """
  @type lang_filename_ext :: String.t() | nil

  @deprecated "Use highlight/2 instead"
  def highlight(lang_filename_ext, source_code, opts) do
    IO.warn("""
      passing the language in the first parameter is deprecated, pass a `:language` option instead:

        Autumn.highlight("import Kernel", language: "elixir")

    """)

    opts = Keyword.put(opts, :language, lang_filename_ext)
    highlight(source_code, opts)
  end

  @deprecated "Use highlight!/2 instead"
  def highlight!(lang_filename_ext, source_code, opts) do
    IO.warn("""
      passing the language in the first parameter is deprecated, pass a `:language` option instead:

        Autumn.highlight!("import Kernel", language: "elixir")

    """)

    opts = Keyword.put(opts, :language, lang_filename_ext)
    highlight!(source_code, opts)
  end

  @doc """
  Highlights the `source_code`.

  ## Options

  * `:language` (default: `nil`) - the language to use for highlighting.
  Besides a language name, you can also pass a filename or extension. Note that an invalid language or `nil` will fallback
  to rendering plain text (no colors) using the background and foreground colors defined by the current theme.
  * `:theme` (default: `"onedark"`) - accepts any theme listed [here](https://github.com/leandrocp/autumn/tree/main/priv/themes).
  You should pass the filename without special chars and without extension,
  for example pass `theme: "adwaita_dark"` to use the [Adwaita Dark](https://github.com/leandrocp/autumn/blob/main/priv/themes/adwaita-dark.toml) theme
  or `theme: "penumbra"` to use the [Penumbra+](https://github.com/leandrocp/autumn/blob/main/priv/themes/penumbra%2B.toml) theme.
  * `:pre_class` (default: `nil`) - the CSS class to inject into the wrapping parent `<pre>` tag.
  By default it renders a `<pre>` tag with the `autumn-hl` class which will be merged with the class passed into this option.
  * `:inline_style` (default: `true`) - see more info on the module doc.

  ## Examples

  Passing a language name:

      iex> {:ok, hl} = Autumn.highlight("Atom.to_string(:elixir)", language: "elixir")
      iex> IO.puts(hl)
      #=> <pre class="autumn-hl" style="background-color: #282C34; color: #ABB2BF;"><code class="language-elixir" translate="no"><span class="ahl-namespace" style="color: #61AFEF;">Atom</span><span class="ahl-operator" style="color: #C678DD;">.</span><span class="ahl-function" style="color: #61AFEF;">to_string</span><span class="ahl-punctuation ahl-bracket" style="color: #ABB2BF;">(</span><span class="ahl-string ahl-special ahl-symbol" style="color: #98C379;">:elixir</span><span class="ahl-punctuation ahl-bracket" style="color: #ABB2BF;">)</span></code></pre>

  Or more options with a file extension:

      iex> {:ok, hl} = Autumn.highlight("Atom.to_string(:elixir)", language: ".ex", inline_style: false, pre_class: "my-app-code")
      iex> IO.puts(hl)
      #=> <pre class="autumn-hl my-app-code"><code class="language-elixir" translate="no"><span class="ahl-namespace">Atom</span><span class="ahl-operator">.</span><span class="ahl-function">to_string</span><span class="ahl-punctuation ahl-bracket">(</span><span class="ahl-string ahl-special ahl-symbol">:elixir</span><span class="ahl-punctuation ahl-bracket">)</span></code></pre>

  And no language results in plain text:

      iex> {:ok, hl} = Autumn.highlight("Atom.to_string(:elixir)")
      iex> IO.puts(hl)
      #=> <pre class="autumn-hl" style="background-color: #282C34; color: #ABB2BF;"><code class="language-plaintext" translate="no">Atom.to_string(:elixir)</code></pre>

  """
  @spec highlight(String.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def highlight(source_code, opts \\ [])

  def highlight(source_code, opts) when is_binary(source_code) and is_list(opts) do
    language = opts |> Keyword.get(:language, nil) |> language()
    theme = Keyword.get(opts, :theme, "onedark")
    pre_class = Keyword.get(opts, :pre_class, nil)
    inline_style = Keyword.get(opts, :inline_style, true)
    Autumn.Native.highlight(language, source_code, theme, pre_class, inline_style)
  end

  def highlight(lang_filename_ext, source_code)
      when is_binary(lang_filename_ext) and is_binary(source_code) do
    highlight(source_code, language: lang_filename_ext)
  end

  @doc """
  Same as `highlight/2` but raises in case of failure.
  """
  @spec highlight!(String.t(), keyword()) :: String.t()
  def highlight!(source_code, opts \\ [])

  def highlight!(source_code, opts) when is_binary(source_code) and is_list(opts) do
    case highlight(source_code, opts) do
      {:ok, highlighted} ->
        highlighted

      {:error, error} ->
        raise """
        failed to highlight source code

        Got:

          #{inspect(error)}

        """
    end
  end

  def highlight!(lang_filename_ext, source_code)
      when is_binary(lang_filename_ext) and is_binary(source_code) do
    highlight!(source_code, language: lang_filename_ext)
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
