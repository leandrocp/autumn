defmodule Autumn do
  @external_resource "README.md"

  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC -->")
             |> Enum.fetch!(1)

  require Logger

  # FIXME: docs and spec

  @doc """
  Returns the list of all available languages for syntax highlighting.
  """
  @spec available_languages() :: [String.t()]
  def available_languages, do: Autumn.Native.available_languages()

  @doc """
  Returns the list of all available themes for syntax highlighting.
  """
  @spec available_themes() :: [String.t()]
  def available_themes, do: Autumn.Themes.available_themes()

  @typedoc """
  A language name, filename, or extesion.

  ## Examples

      - "elixir"
      - "main.rb"
      - ".rs"
      - "/example/main.php"

  """
  @type lang_filename_ext :: String.t() | nil

  @deprecated "Use highlight/2 instead"
  def highlight(lang_filename_ext, source, opts) do
    IO.warn("""
      passing the language in the first argument is deprecated, pass a `:language` option instead:

        Autumn.highlight("import Kernel", language: "elixir")

    """)

    opts = Keyword.put(opts, :language, lang_filename_ext)
    highlight(source, opts)
  end

  @deprecated "Use highlight!/2 instead"
  def highlight!(lang_filename_ext, source, opts) do
    IO.warn("""
      passing the language in the first argument is deprecated, pass a `:language` option instead:

        Autumn.highlight!("import Kernel", language: "elixir")

    """)

    opts = Keyword.put(opts, :language, lang_filename_ext)
    highlight!(source, opts)
  end

  @typedoc """
  Formatter and options in which the highlighted source will be generated.

  Available formatters: `:html_inline`, `:html_linked`, `:terminal`

  * `:html_inline` - generates `<span>` tags with inline styles for each token
  * `:html_linked` - generates `<span>` tags with the token class, must link an external CSS in order to render colors
  * `:terminal` - generates ANSI escape codes for terminal output

  You can either pass the formatter as an atom or a tuple with the formatter name and options, so both are equivalent:

      # passing only the formatter name like below:
      :terminal
      # is the same as passing an empty list of options:
      {:terminal, []}

  The formatters `:html_inline` and `:html_linked` accept the following options:

    * `:pre_class` (`t:String.t/0` - default: `nil`) - the CSS class to inject into the wrapping parent `<pre>` tag, along with other classes alread added by the formatter.
    * `:line_numbers` (`t:boolean/0` - default: `false`) - whether to include line numbers in the output.

  ## Examples

      {:html_inline, [pre_class: "example-01"]}

      {:html_linked, [pre_class: "server", line_numbers: true]}

      {:terminal, []}

  """
  @type formatter :: name :: atom | {name :: atom, opts :: Keyword.t()}

  @doc """
  Generates highlights for `source` using the given language and formats to HTML or Terminal.

  ## Options

  * `:language` (`t:lang_filename_ext/0` - default: `"text"`) - Optional. The language used to highlight the `source`.
  You can also pass a filename or extension as `enum.ex` or `ex`. Note that an invalid language or `nil` will fallback
  to rendering plain text (no colors) using the background and foreground colors defined by the current theme.
  See the full list at `Autumn.available_languages/0`.

  * `:theme` (`t:String.t/0` or `t:Autumn.Theme.t/0` - default: `"One Dark"`) - Optional. A theme to colorize highlights,
  either the theme name or a `%Autumn.Theme{}` struct. See the full list at `Autumn.available_themes/0`.

  * `:formatter` (`t:formatter/0` - default: `{:html_inline, []}`) - format to output the highlighted source.
  See the type doc for more info.

  * `:debug` (default: `false`) - include theme and highlights info in data attributes for debugging purposes.

  ## Examples

  Passing a language name:

      iex> {:ok, hl} = Autumn.highlight("Atom.to_string(:elixir)", language: "elixir")
      iex> IO.puts(hl)
      #=> <pre class="athl" style="background-color: #282C34; color: #ABB2BF;"><code class="language-elixir" translate="no"><span class="ahl-namespace" style="color: #61AFEF;">Atom</span><span class="ahl-operator" style="color: #C678DD;">.</span><span class="ahl-function" style="color: #61AFEF;">to_string</span><span class="ahl-punctuation ahl-bracket" style="color: #ABB2BF;">(</span><span class="ahl-string ahl-special ahl-symbol" style="color: #98C379;">:elixir</span><span class="ahl-punctuation ahl-bracket" style="color: #ABB2BF;">)</span></code></pre>

  Or more options with a file extension:

      iex> {:ok, hl} = Autumn.highlight("Atom.to_string(:elixir)", language: ".ex", inline_style: false, pre_class: "my-app-code")
      iex> IO.puts(hl)
      #=> <pre class="athl my-app-code"><code class="language-elixir" translate="no"><span class="ahl-namespace">Atom</span><span class="ahl-operator">.</span><span class="ahl-function">to_string</span><span class="ahl-punctuation ahl-bracket">(</span><span class="ahl-string ahl-special ahl-symbol">:elixir</span><span class="ahl-punctuation ahl-bracket">)</span></code></pre>

  And no language results in plain text:

      iex> {:ok, hl} = Autumn.highlight("Atom.to_string(:elixir)")
      iex> IO.puts(hl)
      #=> <pre class="athl" style="background-color: #282C34; color: #ABB2BF;"><code class="language-plaintext" translate="no">Atom.to_string(:elixir)</code></pre>

  """
  @spec highlight(String.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def highlight(source, opts \\ [])

  def highlight(source, opts) when is_binary(source) and is_list(opts) do
    debug = Keyword.get(opts, :debug, false)

    language =
      opts
      |> Keyword.get(:language, "text")
      |> language()

    theme =
      opts
      |> Keyword.get(:theme, "One Dark")
      |> Autumn.Themes.get!()

    pre_class =
      case Keyword.get(opts, :pre_class) do
        nil ->
          nil

        pre_class ->
          Logger.warning("""
          option `:pre_class` is deprecated, use `:formatter` instead

          Example:

            formatter: {:html_inline, [pre_class: #{pre_class}]}

          """)

          if is_binary(pre_class) do
            pre_class
          else
            Logger.warning("""
            `:pre_class` value is invalid, expected a binary

            Got

              #{inspect(pre_class)}

            """)

            nil
          end
      end

    formatter =
      case Keyword.get(opts, :inline_style) do
        nil ->
          Keyword.get(opts, :formatter, {:html_inline, [pre_class: pre_class, line_numbers: false]})

        inline_style ->
          Logger.warning("""
          option `:inline_style` is deprecated, use `:formatter` instead

          Example:

            formatter: #{if inline_style, do: ":html_inline", else: ":html_linked"}

          """)

          if inline_style do
            {:html_inline, [pre_class: pre_class, line_numbers: false]}
          else
            {:html_linked, [pres_class: pre_class, line_numbers: false]}
          end
      end

    formatter =
      case formatter do
        {name, opts} when name in [:html_inline, :html_linked, :terminal] and is_list(opts) ->
          {name, Map.new(opts)}

        name when name in [:html_inline, :html_linked] ->
          {name, %{pre_class: pre_class, line_numbers: false}}

        name when name in [:terminal] ->
          name

        :default ->
          Logger.error("""
            `:formatter` is invalid, expected a tuple with the formatter name and options or just the formatter name without options

            Got

              #{inspect(formatter)}

          """)

          # FIXME: return error?
          {:html_inline, %{pre_class: pre_class, line_numbers: false}}
      end

    case Autumn.Native.highlight(language, source, theme, formatter, debug) do
      {:error, _error} -> raise "TODO: error struct"
      output -> output
    end
  end

  # defp reduce_lines(lines, inline_styles, mode, line_number, debug) do
  #   {_, lines} =
  #     Enum.reduce(lines, {1, []}, fn line, {lineno, acc} ->
  #       line = [
  #         "  ",
  #         "<span",
  #         line_number(lineno, line_number),
  #         ?>,
  #         reduce_line(line, inline_styles, mode, debug),
  #         "</span>",
  #         "\n"
  #       ]

  #       {lineno + 1, [acc | line]}
  #     end)

  #   lines
  # end

  # defp line_number(lineno, true = _line_number), do: [" data-athl-line=", ?", to_string(lineno), ?"]
  # defp line_number(_lineno, false = _line_number), do: []

  # defp reduce_line(line, inline_styles, mode, debug) do
  #   Enum.reduce(line, [], fn
  #     {source, ""}, acc ->
  #       [acc | [source]]

  #     {source, highlight}, acc ->
  #       line = line(source, highlight, inline_styles, mode, debug)
  #       [acc | line]
  #   end)
  # end

  # defp line(source, highlight, inline_styles, mode, debug) do
  #   if mode == :inline do
  #     case Map.get(inline_styles, highlight) do
  #       nil -> ["<span ", data_highlight(highlight, debug), ?>, source, "</span>"]
  #       style -> ["<span ", data_highlight(highlight, debug), "style=", ?", style, ?", ?>, source, "</span>"]
  #     end
  #   else
  #     class = String.replace(highlight, ".", "-")
  #     ["<span ", data_highlight(highlight, debug), "class=", ?", "athl-", class, ?", ?>, source, "</span>"]
  #   end
  # end

  # defp data_highlight(highlight, true = _debug), do: ["data-athl-hl=", ?", highlight, ?", " "]
  # defp data_highlight(_highlight, false = _debug), do: []

  # defp open_tags(theme_name, normal_style, language, mode, pre_class, debug) do
  #   [
  #     "<pre ",
  #     data_theme(theme_name, debug),
  #     "class=",
  #     ?",
  #     "athl",
  #     pre_class(pre_class),
  #     ?",
  #     pre_style(normal_style, mode),
  #     ?>,
  #     "<code class=",
  #     ?",
  #     "language-",
  #     language,
  #     ?",
  #     " translate=",
  #     ?",
  #     "no",
  #     ?",
  #     ?>
  #   ]
  # end

  # defp data_theme(theme, true = _debug), do: ["data-athl-theme=", ?", theme, ?", " "]
  # defp data_theme(_theme, false = _debug), do: []

  # defp pre_class(class) when is_binary(class), do: [" ", class]
  # defp pre_class(_class), do: []

  # defp pre_style(normal_style, :inline = _mode), do: [" style=", ?", normal_style, ?"]
  # defp pre_style(_normal_style, _mode), do: []

  # defp close_tags do
  #   ["</code></pre>"]
  # end

  def highlight(lang_filename_ext, source)
      when is_binary(lang_filename_ext) and is_binary(source) do
    highlight(source, language: lang_filename_ext)
  end

  @doc """
  Same as `highlight/2` but raises in case of failure.
  """
  @spec highlight!(String.t(), keyword()) :: String.t()
  def highlight!(source, opts \\ [])

  def highlight!(source, opts) when is_binary(source) and is_list(opts) do
    case highlight(source, opts) do
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

  def highlight!(lang_filename_ext, source)
      when is_binary(lang_filename_ext) and is_binary(source) do
    highlight!(source, language: lang_filename_ext)
  end

  @doc false
  def language(lang_filename_ext) when is_binary(lang_filename_ext) do
    lang_filename_ext
    |> String.downcase()
    |> Path.basename()
    |> do_language()
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
