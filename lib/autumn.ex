defmodule Autumn do
  @external_resource "README.md"

  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC -->")
             |> Enum.fetch!(1)

  require Logger

  @doc """
  Returns the list of all available languages.
  """
  @spec available_languages() :: [String.t()]
  def available_languages, do: Autumn.Native.available_languages()

  @doc """
  Returns the list of all available themes.

  ## Example

      iex> [{name, fun} | _] = Autumn.available_themes()
      iex> name
      "0x96f Theme"
      iex> fun.().name
      "0x96f Theme"

  """
  @spec available_themes() :: [{name :: String.t(), function :: function()}]
  def available_themes, do: Autumn.Themes.all()

  @typedoc """
  A language name, filename, or extesion used to identify a source code.

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

    {_, opts} =
      Keyword.get_and_update(opts, :theme, fn
        nil -> {nil, nil}
        current -> {current, String.capitalize(current)}
      end)

    opts = Keyword.put(opts, :language, lang_filename_ext)

    highlight(source, opts)
  end

  @deprecated "Use highlight!/2 instead"
  def highlight!(lang_filename_ext, source, opts) do
    IO.warn("""
      passing the language in the first argument is deprecated, pass a `:language` option instead:

        Autumn.highlight!("import Kernel", language: "elixir")

    """)

    {_, opts} =
      Keyword.get_and_update(opts, :theme, fn
        nil -> {nil, nil}
        current -> {current, String.capitalize(current)}
      end)

    opts = Keyword.put(opts, :language, lang_filename_ext)
    highlight!(source, opts)
  end

  @typedoc """
  Formatter and options in which the highlighted source will be generated.

  Available formatters: `:html_inline`, `:html_linked`, `:terminal`

  * `:html_inline` - generates `<span>` tags with inline styles for each token.
  * `:html_linked` - generates `<span>` tags with the token class, must link an external CSS in order to render colors, see the [Formatters](#module-formatters) section for more info.
  * `:terminal` - generates ANSI escape codes for terminal output.

  You can either pass the formatter as an atom or a tuple with the formatter name and options, so both are equivalent:

      # passing only the formatter name like below:
      :terminal
      # is the same as passing an empty list of options:
      {:terminal, []}

  The formatters `:html_inline` and `:html_linked` accept the following options:

    * `:pre_class` (`t:String.t/0` - default: `nil`) - the CSS class to append into the wrapping `<pre>` tag.

  ## Examples

      {:html_inline, [pre_class: "example-01"]}

      {:html_linked, [pre_class: "example-01"]}

      {:terminal, []}

  """
  @type formatter :: name :: atom | {name :: atom, opts :: Keyword.t()}

  @doc """
  Highlights `source` code.

  ## Options

  * `:language` (`t:lang_filename_ext/0` - default: `"plaintext"`) - Optional. The language used to highlight `source`.
  You can also pass a filename or extension, for eg: `enum.ex` or `ex`. Note that an invalid language or `nil` will fallback
  to rendering plain text (no colors) using the background and foreground colors defined by the current theme.
  Use `Autumn.available_languages/0` to list all available languages.

  * `:theme` (`t:String.t/0` or `t:Autumn.Theme.t/0` - default: `"One Dark"`) - Optional. A theme to apply styles on the highlighted source code.
  You can pass either the theme name or a `%Autumn.Theme{}` struct. See `Autumn.available_themes/0` to list all available themes.

  * `:formatter` (`t:formatter/0` - default: `{:html_inline, []}`) - the format used to output the highlighted source code.
  See the type doc for more info and examples.

  * `:debug` (`t:boolean()/0` default: `false`) - include extra info on the generated output for debugging purposes.

  ## Examples

  Language name:

      iex> Autumn.highlight("Atom.to_string(:elixir)", language: "elixir")
      {:ok, ~s|<pre class=\"athl\" style=\"background-color: #282c33ff; color: #dce0e5ff;\"><code class=\"language-elixir\" translate=\"no\"><span style=\"color: #6eb4bfff;\">Atom</span><span style=\"color: #6eb4bfff;\">.</span><span style=\"color: #73ade9ff;\">to_string</span><span style=\"color: #b2b9c6ff;\">(</span><span style=\"color: #bf956aff;\">:elixir</span><span style=\"color: #b2b9c6ff;\">)</span></code></pre>|}

  Custom options:

      iex> Autumn.highlight("Atom.to_string(:elixir)", language: "example.ex", formatter: {:html_inline, pre_class: "example-elixir"})
      {:ok, ~s|<pre class=\"athl example-elixir\" style=\"background-color: #282c33ff; color: #dce0e5ff;\"><code class=\"language-elixir\" translate=\"no\"><span style=\"color: #6eb4bfff;\">Atom</span><span style=\"color: #6eb4bfff;\">.</span><span style=\"color: #73ade9ff;\">to_string</span><span style=\"color: #b2b9c6ff;\">(</span><span style=\"color: #bf956aff;\">:elixir</span><span style=\"color: #b2b9c6ff;\">)</span></code></pre>|}

  No language at all which will only apply the theme's background and foreground colors:

      iex> Autumn.highlight("Atom.to_string(:elixir)")
      {:ok, ~s|<pre class=\"athl\" style=\"background-color: #282c33ff; color: #dce0e5ff;\"><code class=\"language-plaintext\" translate=\"no\">Atom.to_string(:elixir)</code></pre>|}

  Terminal formatter:

      iex> Autumn.highlight("Atom.to_string(:elixir)", language: "elixir", formatter: :terminal)
      {:ok, "\e[0m\e[38;2;110;180;191mAtom\e[0m\e[0m\e[38;2;110;180;191m.\e[0m\e[0m\e[38;2;115;173;233mto_string\e[0m\e[0m\e[38;2;178;185;198m(\e[0m\e[0m\e[38;2;191;149;106m:elixir\e[0m\e[0m\e[38;2;178;185;198m)\e[0m"}

  """
  @spec highlight(String.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def highlight(source, opts \\ [])

  def highlight(source, opts) when is_binary(source) and is_list(opts) do
    debug = Keyword.get(opts, :debug, false)

    language =
      opts
      |> Keyword.get(:language)
      |> language()

    theme =
      opts
      |> Keyword.get(:theme, "One Dark")
      |> Autumn.Theme.get()

    pre_class =
      case Keyword.get(opts, :pre_class) do
        nil ->
          nil

        pre_class ->
          Logger.warning("""
          option `:pre_class` is deprecated, use `:formatter` instead

          Example:

            formatter: {:html_inline, [pre_class: "#{pre_class}"]}

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
          Keyword.get(opts, :formatter, {:html_inline, [pre_class: pre_class]})

        inline_style ->
          Logger.warning("""
          option `:inline_style` is deprecated, use `:formatter` instead

          Example:

            formatter: #{if inline_style, do: ":html_inline", else: ":html_linked"}

          """)

          if inline_style do
            {:html_inline, [pre_class: pre_class]}
          else
            {:html_linked, [pres_class: pre_class]}
          end
      end

    formatter =
      case formatter do
        {name, opts} when name in [:html_inline, :html_linked, :terminal] and is_list(opts) ->
          {name, Map.new(opts)}

        name when name in [:html_inline, :html_linked] ->
          {name, %{pre_class: pre_class}}

        name when name in [:terminal] ->
          name

        :default ->
          message = """
            `:formatter` is invalid, expected a tuple with the formatter name and options or just the formatter name without options

            Got

              #{inspect(formatter)}

          """

          raise Autumn.InputError, message: message
      end

    case Autumn.Native.highlight(language, source, theme, formatter, debug) do
      {:error, error} -> raise Autumn.HighlightError, error: error
      output -> output
    end
  end

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

  defp do_language(<<"."::binary, ext::binary>>), do: Autumn.Native.lang_name(ext)

  defp do_language(lang) when is_binary(lang) do
    case lang |> Path.basename() |> Path.extname() do
      "" -> Autumn.Native.lang_name(lang)
      ext -> do_language(ext)
    end
  end
end
