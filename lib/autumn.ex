defmodule Autumn do
  @external_resource "README.md"

  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC -->")
             |> Enum.fetch!(1)

  require Logger
  alias Autumn.Theme

  @default_theme "onedark"

  @typedoc """
  A language name, filename, or path with extension.

  ## Examples

      - "elixir"
      - ".ex"
      - "app.ex"
      - "lib/app.ex"

  """
  @type language :: String.t() | nil

  @typedoc """
  Theme used to apply styles on the highlighted source code.

  See `Autumn.available_themes/0` to list all available themes or check out a list of [available themes](https://docs.rs/autumnus/latest/autumnus/#themes-available).
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

      - `:theme` (`t:theme/0` - default: `nil`) - the theme to apply styles on the highlighted source code.
      - `:pre_class` (`t:String.t/0` - default: `nil`) - the CSS class to append into the wrapping `<pre>` tag.
      - `:italic` (`t:boolean/0` - default: `false`) - enable italic style for the highlighted code.
      - `:include_highlights` (`t:boolean/0` - default: `false`) - include the highlight scope name in a `data-highlight` attribute. Useful for debugging.

  * `html_linked`:

      - `:pre_class` (`t:String.t/0` - default: `nil`) - the CSS class to append into the wrapping `<pre>` tag.


  * `terminal`:

      - `:theme` (`t:theme/0` - default: `nil`) - the theme to apply styles on the highlighted source code.

  ## Examples

      :html_inline

      {:html_inline, theme: "onedark", pre_class: "example-01", include_highlights: true}

      {:html_linked, pre_class: "example-01"}

      :terminal

      {:terminal, theme: "github_light"}

  See https://docs.rs/autumnus/latest/autumnus/enum.FormatterOption.html for more info.
  """
  @type formatter ::
          :html_inline
          | {:html_inline,
             [
               theme: theme(),
               pre_class: String.t(),
               italic: boolean(),
               include_highlights: boolean()
             ]}
          | :html_linked
          | {:html_linked, [pre_class: String.t()]}
          | :terminal
          | {:terminal, [theme: theme()]}

  @formatter_schema [
    type: {:custom, Autumn, :formatter_type, []},
    type_spec: quote(do: Autumn.formatter()),
    type_doc: "`t:Autumn.formatter/0`",
    default: {:html_inline, theme: "onedark"},
    doc: "Formatter to apply on the highlighted source code. See the type doc for more info."
  ]

  @options_schema [
    language: [
      type: {:or, [:string, nil]},
      type_spec: quote(do: Autumn.language()),
      type_doc: "`t:Autumn.language/0`",
      default: nil,
      doc: """
      The language used to highlight source code.
      You can also pass a filename or extension, for eg: `"enum.ex"` or just `"ex"`. If no language is provided, the highlighter will
      try to guess it based on the content of the given source code. Use `Autumn.available_languages/0` to list all available languages.
      """
    ],
    formatter: @formatter_schema,
    theme: [
      type: {:or, [{:struct, Autumn.Theme}, :string, nil]},
      deprecated: "Use :formatter instead."
    ],
    inline_style: [
      type: :boolean,
      deprecated: "Use :formatter instead."
    ],
    pre_class: [
      type: {:or, [:string, nil]},
      deprecated: "Use :formatter instead."
    ]
  ]

  def formatter_schema, do: @formatter_schema
  def options_schema, do: @options_schema

  @doc false
  def formatter_type(formatter)
      when formatter in [:html_inline, :html_linked, :terminal] do
    formatter_type({formatter, []})
  end

  def formatter_type({:html_inline, options}) when is_list(options) do
    case Keyword.keys(options) -- [:theme, :pre_class, :italic, :include_highlights] do
      [] ->
        default_opts = [
          theme: @default_theme,
          pre_class: nil,
          italic: false,
          include_highlights: false
        ]

        opts = Keyword.merge(default_opts, options) |> Map.new()
        {:ok, {:html_inline, opts}}

      invalid ->
        {:error, "invalid options given to html_inline: #{inspect(invalid)}"}
    end
  end

  def formatter_type({:html_linked, options}) when is_list(options) do
    case Keyword.keys(options) -- [:pre_class] do
      [] ->
        default_opts = [pre_class: nil]
        opts = Keyword.merge(default_opts, options) |> Map.new()
        {:ok, {:html_linked, opts}}

      invalid ->
        {:error, "invalid options given to html_linked: #{inspect(invalid)}"}
    end
  end

  def formatter_type({:terminal, options}) when is_list(options) do
    case Keyword.keys(options) -- [:theme] do
      [] ->
        default_opts = [theme: @default_theme]
        opts = Keyword.merge(default_opts, options) |> Map.new()
        {:ok, {:terminal, opts}}

      invalid ->
        {:error, "invalid options given to terminal: #{inspect(invalid)}"}
    end
  end

  def formatter_type(other) do
    {:error, "invalid formatter option: #{inspect(other)}"}
  end

  @typedoc """
  #{NimbleOptions.docs(@options_schema)}

  See each option type for more info.
  """
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
  def highlight(language, source, options) do
    IO.warn("""
      passing the language in the first argument is deprecated, pass a `:language` option instead:

        Autumn.highlight("import Kernel", language: "elixir")

    """)

    {_, options} =
      Keyword.get_and_update(options, :theme, fn
        nil -> {nil, nil}
        current -> {current, String.capitalize(current)}
      end)

    options = Keyword.put(options, :language, language)

    highlight(source, options)
  end

  @deprecated "Use highlight!/2 instead"
  def highlight!(language, source, options) do
    IO.warn("""
      passing the language in the first argument is deprecated, pass a `:language` option instead:

        Autumn.highlight!("import Kernel", language: "elixir")

    """)

    {_, options} =
      Keyword.get_and_update(options, :theme, fn
        nil -> {nil, nil}
        current -> {current, String.capitalize(current)}
      end)

    options = Keyword.put(options, :language, language)
    highlight!(source, options)
  end

  @doc """
  Highlights `source` code and outputs into a formatted string.

  ## Options

  See `t:options/0`.

  ## Examples

  Defining the language name:

      iex> Autumn.highlight("Atom.to_string(:elixir)", language: "elixir")
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

      iex> Autumn.highlight("Atom.to_string(:elixir)", language: "example.ex", formatter: {:html_inline, pre_class: "example-elixir"})
      {:ok,
       ~s|<pre class="athl example-elixir" style="color: #abb2bf; background-color: #282c34;"><code class="language-elixir" translate="no" tabindex="0"><span class="line" data-line="1"><span style="color: #e5c07b;">Atom</span><span style="color: #56b6c2;">.</span><span style="color: #61afef;">to_string</span><span style="color: #c678dd;">(</span><span style="color: #e06c75;">:elixir</span><span style="color: #c678dd;">)</span>
       </span></code></pre>|
      }

  Terminal formatter:

      iex> Autumn.highlight("Atom.to_string(:elixir)", language: "elixir", formatter: :terminal)
      {:ok, "\e[0m\e[38;2;229;192;123mAtom\e[0m\e[0m\e[38;2;86;182;194m.\e[0m\e[0m\e[38;2;97;175;239mto_string\e[0m\e[0m\e[38;2;198;120;221m(\e[0m\e[0m\e[38;2;224;108;117m:elixir\e[0m\e[0m\e[38;2;198;120;221m)\e[0m"}

  See https://docs.rs/autumnus/latest/autumnus/fn.highlight.html for more info.

  """
  @spec highlight(String.t(), options()) :: {:ok, String.t()} | {:error, term()}
  def highlight(source, options \\ [])

  def highlight(source, options) when is_binary(source) and is_list(options) do
    options = NimbleOptions.validate!(options, @options_schema)

    {formatter, formatter_opts} = options[:formatter]

    # deprecated options
    {theme, options} = Keyword.pop(options, :theme)
    theme = build_theme(theme || formatter_opts[:theme])

    {pre_class, options} = Keyword.pop(options, :pre_class)
    pre_class = pre_class || formatter_opts[:pre_class]

    {inline_style, options} = Keyword.pop(options, :inline_style)

    formatter =
      case inline_style do
        true -> :html_inline
        false -> :html_linked
        nil -> formatter
      end

    options =
      options
      |> Keyword.put(
        :formatter,
        {formatter, Map.merge(formatter_opts, %{theme: theme, pre_class: pre_class})}
      )
      |> Map.new()

    case Autumn.Native.highlight(source, options) do
      {:error, error} -> raise Autumn.HighlightError, error: error
      output -> output
    end
  end

  def highlight(language, source)
      when is_binary(language) and is_binary(source) do
    highlight(source, language: language)
  end

  @doc false
  def build_theme(theme) do
    cond do
      match?(%Theme{}, theme) ->
        {:theme, theme}

      is_binary(theme) && String.contains?(theme, " ") ->
        Logger.warning("""
        Helix themes are deprecated, use Neovim theme names instead.

        See `Autumn.available_themes/0` for a list of available themes.
        """)

        theme
        |> String.downcase()
        |> String.replace(" ", "")
        |> then(&{:string, &1})

      is_binary(theme) ->
        theme
        |> String.downcase()
        |> then(&{:string, &1})

      :else ->
        nil
    end
  end

  @doc """
  Same as `highlight/2` but raises in case of failure.
  """
  @spec highlight!(String.t(), keyword()) :: String.t()
  def highlight!(source, options \\ [])

  def highlight!(source, options) when is_binary(source) and is_list(options) do
    case highlight(source, options) do
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

  def highlight!(language, source)
      when is_binary(language) and is_binary(source) do
    highlight!(source, language: language)
  end
end
