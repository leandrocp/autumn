defmodule Autumn do
  @external_resource "README.md"

  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC -->")
             |> Enum.fetch!(1)

  require Logger
  alias Autumn.Theme

  @typedoc """
  A language name, filename, or path with extension.

  ## Examples

      - "elixir"
      - ".ex"
      - "app.ex"
      - "lib/app.ex"

  """
  @type lang_or_file :: String.t() | nil

  @typedoc """
  Theme used to apply styles on the highlighted source code.

  See `Autumn.available_themes/0` to list all available themes or visit [available themes](https://docs.rs/autumnus/latest/autumnus/#themes-available) to see a list.
  """
  @type theme :: String.t() | Autumn.Theme.t() | nil

  @typedoc """
  Highlighter formatter and its options.

  Available formatters: `:html_inline`, `:html_linked`, `:terminal`

  * `:html_inline` - generates `<span>` tags with inline styles for each token, for example: `<span style="color: #6eb4bff;">Atom</span>`.
  * `:html_linked` - generates `<span>` tags with `class` representing the token type, for example: `<span class="keyword-special">Atom</span>`.
     Must link an external CSS in order to render colors, see more at [HTML Linked](https://hexdocs.pm/autumn/Autumn.html#module-html-linked).
  * `:terminal` - generates ANSI escape codes for terminal output.

  You can either pass the formatter as an atom to use default options or a tuple with the formatter name and options, so both are equivalent:

      # passing only the formatter name like below:
      :html_inline
      # is the same as passing an empty list of options:
      {:html_inline, []}

  ## Available Options:

  * `html_inline`:

      - `:pre_class` (`t:String.t/0` - default: `nil`) - the CSS class to append into the wrapping `<pre>` tag.
      - `:italic` (`t:boolean/0` - default: `false`) - enable italic style for the highlighted code.
      - `:include_highlights` (`t:boolean/0` - default: `false`) - include the highlight scope name in a `data-highlight` attribute. Useful for debugging.

  * `html_linked`:

      - `:pre_class` (`t:String.t/0` - default: `nil`) - the CSS class to append into the wrapping `<pre>` tag.

  * `terminal`:

      - `:italic` (`t:boolean/0` - default: `false`) - enable italic style for the highlighted code.

  ## Examples

      :html_linked

      {:html_inline, pre_class: "example-01", include_highlights: true}

      {:html_linked, pre_class: "example-01"}

      {:terminal, []}

  See https://docs.rs/autumnus/latest/autumnus/enum.FormatterOption.html for more info.
  """
  @type formatter ::
          :html_inline
          | {:html_inline,
             [pre_class: String.t(), italic: boolean(), include_highlights: boolean()]}
          | :html_linked
          | {:html_linked, [pre_class: String.t()]}
          | :terminal
          | {:terminal, keyword()}

  @options_schema [
    lang_or_file: [
      type: {:or, [:string, nil]},
      type_spec: quote(do: lang_or_file()),
      type_doc: "`t:lang_or_file/0`",
      default: nil,
      doc: """
      The language used to highlight source code.
      You can also pass a filename or extension, for eg: `"enum.ex"` or just `"ex"`. If no language is provided, the highlighter will
      try to guess it based on the content of the given source code. Use `Autumn.available_languages/0` to list all available languages.
      """
    ],
    theme: [
      type: {:or, [{:struct, Autumn.Theme}, :string, nil]},
      type_spec: quote(do: theme()),
      type_doc: "`t:theme/0`",
      default: "onedark",
      doc: """
      A theme to apply styles on the highlighted source code.
      You can pass either the theme name or a `Autumn.Theme` struct.
      """
    ],
    formatter: [
      type: :any,
      type_spec: quote(do: formatter()),
      type_doc: "`t:formatter/0`",
      default: :html_inline,
      doc: "Formatter to apply on the highlighted source code. See the type doc for more info."
    ]
  ]

  @type options() :: [unquote(NimbleOptions.option_typespec(@options_schema))]

  @doc """
  Returns the list of all available languages.

  ## Example

      iex> Autumn.available_languages()
      %{
        "diff" => {"Diff", ["*.diff"]},
        "lua" => {"Lua", ["*.lua"]},
        "javascript" => {"JavaScript", ["*.cjs", "*.js", "*.mjs", "*.snap", "*.jsx"]},
        "elixir" => {"Elixir", ["*.ex", "*.exs"]},
        ...
      }

      iex> Autumn.available_languages()["elixir"]
      {"Elixir", ["*.ex", "*.exs"]}

  """
  @spec available_languages() :: %{
          (id :: String.t()) => {name :: String.t(), [extension :: String.t()]}
        }
  def available_languages, do: Autumn.Native.available_languages()

  @doc """
  Returns the list of all available themes.

  Use `Autumn.Theme.get/1` to get the actual theme struct.

  ## Example

      iex> Autumn.available_themes()
      ["github_light", "github_dark", "catppuccin_frappe", "catppuccin_latte", "nightfox", ...]

  """
  @spec available_themes() :: [name :: String.t()]
  def available_themes, do: Autumn.Native.available_themes()

  @deprecated "Use highlight/2 instead"
  def highlight(lang_or_file, source, opts) do
    IO.warn("""
      passing the language in the first argument is deprecated, pass a `:lang_or_file` option instead:

        Autumn.highlight("import Kernel", lang_or_file: "elixir")

    """)

    {_, opts} =
      Keyword.get_and_update(opts, :theme, fn
        nil -> {nil, nil}
        current -> {current, String.capitalize(current)}
      end)

    opts = Keyword.put(opts, :lang_or_file, lang_or_file)

    highlight(source, opts)
  end

  @deprecated "Use highlight!/2 instead"
  def highlight!(lang_or_file, source, opts) do
    IO.warn("""
      passing the language in the first argument is deprecated, pass a `:lang_or_file` option instead:

        Autumn.highlight!("import Kernel", lang_or_file: "elixir")

    """)

    {_, opts} =
      Keyword.get_and_update(opts, :theme, fn
        nil -> {nil, nil}
        current -> {current, String.capitalize(current)}
      end)

    opts = Keyword.put(opts, :lang_or_file, lang_or_file)
    highlight!(source, opts)
  end

  @doc """
  Highlights `source` code and outputs into a formatted string.

  ## Options

  #{NimbleOptions.docs(@options_schema)}

  ## Examples

  Defining the language name:

      iex> Autumn.highlight("Atom.to_string(:elixir)", lang_or_file: "elixir")
      {:ok,
       ~s|<pre class="athl" style="color: #abb2bf; background-color: #282c34;"><code class="language-elixir" translate="no" tabindex="0"><span class="line" data-line="1"><span style="color: #e5c07b;">Atom</span><span style="color: #56b6c2;">.</span><span style="color: #61afef;">to_string</span><span style="color: #c678dd;">(</span><span style="color: #e06c75;">:elixir</span><span style="color: #c678dd;">)</span>
       </span></code></pre>|
      }

  Guessing the language based on the provided source code:

      iex> Autumn.highlight("#!/usr/bin/env bash\\nID=1")
      {:ok,
       ~s|<pre class="athl" style="color: #abb2bf; background-color: #282c34;"><code class="language-bash" translate="no" tabindex="0"><span class="line" data-line="1"><span style="color: #c678dd;">#!/usr/bin/env bash</span>
       </span><span class="line" data-line="2"><span style="color: #d19a66;">ID</span><span style="color: #56b6c2;">=</span><span style="color: #d19a66;">1</span>
       </span></code></pre>|
      }

  With custom options:

      iex> Autumn.highlight("Atom.to_string(:elixir)", lang_or_file: "example.ex", formatter: {:html_inline, pre_class: "example-elixir"})
      {:ok,
       ~s|<pre class="athl example-elixir" style="color: #abb2bf; background-color: #282c34;"><code class="language-elixir" translate="no" tabindex="0"><span class="line" data-line="1"><span style="color: #e5c07b;">Atom</span><span style="color: #56b6c2;">.</span><span style="color: #61afef;">to_string</span><span style="color: #c678dd;">(</span><span style="color: #e06c75;">:elixir</span><span style="color: #c678dd;">)</span>
       </span></code></pre>|
      }

  Terminal formatter:

      iex> Autumn.highlight("Atom.to_string(:elixir)", lang_or_file: "elixir", formatter: :terminal)
      {:ok, "\e[0m\e[38;2;229;192;123mAtom\e[0m\e[0m\e[38;2;86;182;194m.\e[0m\e[0m\e[38;2;97;175;239mto_string\e[0m\e[0m\e[38;2;198;120;221m(\e[0m\e[0m\e[38;2;224;108;117m:elixir\e[0m\e[0m\e[38;2;198;120;221m)\e[0m"}

  See https://docs.rs/autumnus/latest/autumnus/fn.highlight.html for more info.

  """
  @spec highlight(String.t(), options()) :: {:ok, String.t()} | {:error, term()}
  def highlight(source, opts \\ [])

  def highlight(source, opts) when is_binary(source) and is_list(opts) do
    lang_or_file = Keyword.get(opts, :lang_or_file) || Keyword.get(opts, :language)
    theme = Keyword.get(opts, :theme) || "onedark"

    theme =
      cond do
        match?(%Theme{}, theme) ->
          theme

        String.contains?(theme, " ") ->
          Logger.warning("""
          Helix themes are deprecated, use Neovim theme names instead.

          See `Autumn.available_themes/0` for a list of available themes.
          """)

          theme
          |> String.downcase()
          |> String.replace(" ", "")
          |> Theme.get()

        is_binary(theme) ->
          theme
          |> String.downcase()
          |> Theme.get()

        :else ->
          nil
      end

    # backward compatibility
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

        # backward compatibility
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
          opts =
            Map.merge(%{pre_class: nil, italic: false, include_highlights: false}, Map.new(opts))

          {name, opts}

        name when name in [:html_inline, :html_linked, :terminal] ->
          {name, %{pre_class: nil, italic: false, include_highlights: false}}

        _ ->
          message = """
            `:formatter` is invalid, expected a tuple with the formatter name and options or just the formatter name without options

            Got

              #{inspect(formatter)}

          """

          raise Autumn.InputError, message: message
      end

    options =
      [lang_or_file: lang_or_file, theme: theme, formatter: formatter]
      |> NimbleOptions.validate!(@options_schema)
      |> Map.new()

    case Autumn.Native.highlight(source, options) do
      {:error, error} -> raise Autumn.HighlightError, error: error
      output -> output
    end
  end

  def highlight(lang_or_file, source)
      when is_binary(lang_or_file) and is_binary(source) do
    highlight(source, language: lang_or_file)
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

  def highlight!(lang_or_file, source)
      when is_binary(lang_or_file) and is_binary(source) do
    highlight!(source, language: lang_or_file)
  end
end
