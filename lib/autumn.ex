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

  See `Autumn.available_languages/0` to list all available languages or check out a list of [available languages](https://docs.rs/autumnus/latest/autumnus/#languages-available).

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
  Highlight lines options for Inline HTML formatter.
  """
  @type html_inline_highlight_lines ::
          %{
            lines: [pos_integer() | Range.t()],
            style: :theme | String.t() | nil,
            class: String.t() | nil
          }
          | nil

  @typedoc """
  Highlight lines options for Linked HTML formatter.
  """
  @type html_linked_highlight_lines ::
          %{
            lines: [pos_integer() | Range.t()],
            class: String.t()
          }
          | nil

  @typedoc """
  Wraps the highlighted code with custom open and close HTML tags.
  """
  @type header ::
          %{
            close_tag: String.t(),
            open_tag: String.t()
          }
          | nil

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
      - `:highlight_lines` (`t:html_inline_highlight_lines/0` - default: `nil`) - highlight specific lines either using the theme `highlighted` style or with custom CSS styling.
      - `:header` (`t:header/0` - default: `nil`) - wrap the highlighted code with custom open and close HTML tags.

  * `html_linked`:

      - `:pre_class` (`t:String.t/0` - default: `nil`) - the CSS class to append into the wrapping `<pre>` tag.
      - `:highlight_lines` (`t:html_linked_highlight_lines/0` - default: `nil`) - highlight specific lines either using the `highlighted` class from themes or with a custom CSS class.
      - `:header` (`t:header/0` - default: `nil`) - wrap the highlighted code with custom open and close HTML tags.

  * `terminal`:

      - `:theme` (`t:theme/0` - default: `nil`) - the theme to apply styles on the highlighted source code.

  ## Examples

  ### Inline HTML formatter with default options

      :html_inline

  ### Inline HTML formatter with custom options

      {:html_inline, theme: "onedark", pre_class: "example-01", include_highlights: true}

  ### HTML Inline: highlight specific lines

      # apply theme's `highlighted` style
      {:html_inline, highlight_lines: %{lines: [2..4, 6], style: :theme}}

      # style: :theme is the default
      {:html_inline, highlight_lines: %{lines: [1, 2, 3]}}

      # explicitly use theme style
      {:html_inline, highlight_lines: %{lines: [1, 2, 3], style: :theme}}

      # overrides default style
      {:html_inline, highlight_lines: %{lines: [1, 3..5, 8], style: "background-color: #fff3cd; border-left: 3px solid #ffc107;"}}

      # with only class and no style
      {:html_inline, highlight_lines: %{lines: [1, 2, 3], style: nil, class: "transition-colors duration-500 w-full inline-block bg-yellow-500"}}

  ### HTML Linked: highlight specific lines

      # use default `highlighted` class (already present in themes)
      {:html_linked, highlight_lines: %{lines: [2..4, 6]}}

      # use custom class
      {:html_linked, highlight_lines: %{lines: [1, 2, 3], class: "error-line"}}

  ### Wrap with custom open and close HTML tags

      header = %{
        open_tag: "<div class=\"code-header\"><span>file: app.ex</span>",
        close_tag: "</div>"
      }
      {:html_inline, header: header}

  ### Terminal formatter

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
               include_highlights: boolean(),
               highlight_lines: html_inline_highlight_lines(),
               header: header()
             ]}
          | :html_linked
          | {:html_linked,
             [
               pre_class: String.t(),
               highlight_lines: html_linked_highlight_lines(),
               header: header()
             ]}
          | :terminal
          | {:terminal,
             [
               theme: theme()
             ]}

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

  @doc false
  def formatter_schema, do: @formatter_schema

  @doc false
  def options_schema, do: @options_schema

  @doc false
  def formatter_type(formatter)
      when formatter in [:html_inline, :html_linked, :terminal] do
    formatter_type({formatter, []})
  end

  def formatter_type({:html_inline, options}) when is_list(options) do
    schema = [
      theme: [type: {:or, [{:struct, Autumn.Theme}, :string, nil]}, default: @default_theme],
      pre_class: [type: {:or, [:string, nil]}, default: nil],
      italic: [type: :boolean, default: false],
      include_highlights: [type: :boolean, default: false],
      highlight_lines: [
        type:
          {:or,
           [
             nil,
             map: [
               lines: [type: {:list, {:custom, Autumn, :highlight_lines_type, []}}],
               style: [type: {:or, [:string, {:in, [:theme]}, nil]}, default: :theme],
               class: [type: {:or, [:string, nil]}, default: nil]
             ]
           ]},
        default: nil
      ],
      header: [
        type:
          {:or,
           [
             nil,
             map: [
               open_tag: [type: :string],
               close_tag: [type: :string]
             ]
           ]},
        default: nil
      ]
    ]

    case NimbleOptions.validate(options, schema) do
      {:ok, validated_opts} ->
        case convert_html_inline_options(validated_opts) do
          {:ok, converted_opts} ->
            {:ok, {:html_inline, converted_opts}}

          {:error, error} ->
            {:error, "invalid options given to html_inline: #{error}"}
        end

      {:error, error} ->
        {:error, "invalid options given to html_inline: #{inspect(error)}"}
    end
  end

  def formatter_type({:html_linked, options}) when is_list(options) do
    schema = [
      pre_class: [type: {:or, [:string, nil]}, default: nil],
      highlight_lines: [
        type:
          {:or,
           [
             nil,
             map: [
               lines: [type: {:list, {:custom, Autumn, :highlight_lines_type, []}}],
               class: [type: :string, default: "highlighted"]
             ]
           ]},
        default: nil
      ],
      header: [
        type:
          {:or,
           [
             nil,
             map: [
               open_tag: [type: :string],
               close_tag: [type: :string]
             ]
           ]},
        default: nil
      ]
    ]

    case NimbleOptions.validate(options, schema) do
      {:ok, validated_opts} ->
        case convert_html_linked_options(validated_opts) do
          {:ok, converted_opts} ->
            {:ok, {:html_linked, converted_opts}}

          {:error, error} ->
            {:error, "invalid options given to html_linked: #{error}"}
        end

      {:error, error} ->
        {:error, "invalid options given to html_linked: #{inspect(error)}"}
    end
  end

  def formatter_type({:terminal, options}) when is_list(options) do
    case Keyword.keys(options) -- [:theme] do
      [] ->
        default_opts = [theme: @default_theme]
        opts = Keyword.merge(default_opts, options)
        {:ok, {:terminal, opts}}

      invalid ->
        {:error, "invalid options given to terminal: #{inspect(invalid)}"}
    end
  end

  def formatter_type(other) do
    {:error, "invalid formatter option: #{inspect(other)}"}
  end

  @doc false
  defp convert_html_inline_options(opts) do
    with {:ok, opts} <- convert_highlight_lines_inline(opts),
         {:ok, opts} <- convert_header(opts) do
      {:ok, opts}
    end
  end

  @doc false
  defp convert_html_linked_options(opts) do
    with {:ok, opts} <- convert_highlight_lines_linked(opts),
         {:ok, opts} <- convert_header(opts) do
      {:ok, opts}
    end
  end

  @doc false
  defp convert_highlight_lines_inline(opts) do
    case opts[:highlight_lines] do
      nil ->
        {:ok, opts}

      hl ->
        lines =
          Enum.map(hl[:lines] || [], fn
            %Range{} = range -> {:range, %{start: range.first, end: range.last}}
            n when is_integer(n) -> {:single, n}
          end)

        style =
          case hl[:style] do
            :theme -> :theme
            str when is_binary(str) -> {:style, %{style: str}}
            nil -> nil
            _ -> :theme
          end

        class = hl[:class]

        opts
        |> Keyword.put(:highlight_lines, %Autumn.HtmlInlineHighlightLines{
          lines: lines,
          style: style,
          class: class
        })
        |> then(&{:ok, &1})
    end
  end

  @doc false
  defp convert_highlight_lines_linked(opts) do
    case opts[:highlight_lines] do
      nil ->
        {:ok, opts}

      hl ->
        lines =
          Enum.map(hl[:lines] || [], fn
            %Range{} = range -> {:range, %{start: range.first, end: range.last}}
            n when is_integer(n) -> {:single, n}
          end)

        class = hl[:class] || "highlighted"

        opts
        |> Keyword.put(:highlight_lines, %Autumn.HtmlLinkedHighlightLines{
          lines: lines,
          class: class
        })
        |> then(&{:ok, &1})
    end
  end

  @doc false
  defp convert_header(opts) do
    case opts[:header] do
      nil ->
        {:ok, opts}

      %{open_tag: open_tag, close_tag: close_tag} ->
        opts
        |> Keyword.put(:header, %Autumn.HtmlElement{
          open_tag: open_tag,
          close_tag: close_tag
        })
        |> then(&{:ok, &1})

      _ ->
        {:error,
         "invalid value for :header option, must be a map with :open_tag and :close_tag keys"}
    end
  end

  @doc false
  def highlight_lines_type(line) when is_integer(line), do: {:ok, line}

  def highlight_lines_type(%Range{} = range), do: {:ok, range}

  def highlight_lines_type(other),
    do: {:error, "invalid highlight line type: #{inspect(other)}"}

  @typedoc """
  #{NimbleOptions.docs(@options_schema)}

  See each option type for more info.
  """
  @type options() :: [unquote(NimbleOptions.option_typespec(@options_schema))]

  @doc """
  Returns all default options.
  """
  @spec default_options() :: options()
  def default_options, do: NimbleOptions.validate!([], @options_schema)

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
      {
        :ok,
        <pre class="athl" style="color: #abb2bf; background-color: #282c34;"><code class="language-elixir" translate="no" tabindex="0"><div class="line" data-line="1"><span style="color: #e5c07b;">Atom</span><span style="color: #56b6c2;">.</span><span style="color: #61afef;">to_string</span><span style="color: #c678dd;">(</span><span style="color: #e06c75;">:elixir</span><span style="color: #c678dd;">)</span>
        </div></code></pre>
      }

  Guessing the language based on the provided source code:

      iex> Autumn.highlight("#!/usr/bin/env bash\\nID=1")
      {:ok, "<pre class=\"athl\" ...><code class=\"language-bash\" ...>...</code></pre>"}

  With custom options:

      iex> Autumn.highlight("Atom.to_string(:elixir)", language: "example.ex", formatter: {:html_inline, pre_class: "example-elixir"})
      {:ok, "<pre class=\"athl example-elixir\" ...><code ...>...</code></pre>"}

  Terminal formatter:

      iex> Autumn.highlight("Atom.to_string(:elixir)", language: "elixir", formatter: :terminal)
      {:ok, "\e[0m\e[38;2;229;192;123mAtom\e[0m\e[0m\e[38;2;86;182;194m.\e[0m\e[0m\e[38;2;97;175;239mto_string\e[0m\e[0m\e[38;2;198;120;221m(\e[0m\e[0m\e[38;2;224;108;117m:elixir\e[0m\e[0m\e[38;2;198;120;221m)\e[0m"}

  Highlighting specific lines in HTML Inline formatter:

      iex> code = \"""
      ...> defmodule Example do
      ...>   @lang = :elixir
      ...>   def lang, do: @lang
      ...> end
      ...> \"""
      iex> highlight_lines = %{lines: [2]}
      iex> Autumn.highlight(code, language: "elixir", formatter: {:html_inline, highlight_lines: highlight_lines})
      # Line 2 will be highlighted with the theme's `highlighted` style:
      <div class=\"line\" style=\"background-color: #414858;\" data-line=\"2\">...</div>

  Highlighting specific lines in HTML Linked formatter:
      
      iex> code = \"""
      ...> defmodule Example do
      ...>   @lang = :elixir
      ...>   def lang, do: @lang
      ...> end
      ...> \"""
      iex> highlight_lines = %{lines: [2]}
      iex> Autumn.highlight(code, language: "elixir", formatter: {:html_linked, highlight_lines: highlight_lines})
      # Line 2 will contain a `highlighted` class:
      <div class=\"line highlighted\" data-line=\"2\">...

  Wrapping with custom HTML:

      iex> header = %{
      ...>   open_tag: "<figure><span>file: example.exs</span>",
      ...>   close_tag: "</figure>"
      ...> }
      iex> Autumn.highlight("IO.puts('hello')", language: "elixir", formatter: {:html_inline, header: header})
      # Returns: "<div class='code-block' data-lang='elixir'><pre class='athl'>...</pre></div>"
      {:ok, "<figure><span>file: example.exs</span><pre...><code ...>...</code></pre></figure>"}

  See https://docs.rs/autumnus/latest/autumnus/fn.highlight.html for more info.

  """
  @spec highlight(String.t(), options()) :: {:ok, String.t()} | {:error, term()}
  def highlight(source, options \\ [])

  def highlight(source, options) when is_binary(source) and is_list(options) do
    options = NimbleOptions.validate!(options, @options_schema)

    {formatter, formatter_opts} = options[:formatter]

    # deprecated options
    {theme, options} = Keyword.pop(options, :theme)
    theme = build_theme(theme || Keyword.get(formatter_opts, :theme))

    {pre_class, options} = Keyword.pop(options, :pre_class)
    pre_class = pre_class || Keyword.get(formatter_opts, :pre_class)

    {inline_style, options} = Keyword.pop(options, :inline_style)

    formatter =
      case inline_style do
        true -> :html_inline
        false -> :html_linked
        nil -> formatter
      end

    formatter_opts_map = Map.new(formatter_opts)

    rust_formatter =
      convert_formatter_for_nif(
        formatter,
        Map.merge(formatter_opts_map, %{theme: theme, pre_class: pre_class})
      )

    options =
      options
      |> Keyword.put(:formatter, rust_formatter)
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

  @doc false
  defp convert_formatter_for_nif(:html_inline, opts) do
    {:html_inline, convert_theme_for_nif(opts)}
  end

  defp convert_formatter_for_nif(:html_linked, opts) do
    {:html_linked, Map.take(opts, [:pre_class, :highlight_lines, :header])}
  end

  defp convert_formatter_for_nif(:terminal, opts) do
    {:terminal, convert_theme_for_nif(opts)}
  end

  @doc false
  defp convert_theme_for_nif(opts) do
    opts =
      case opts[:theme] do
        {:theme, %Theme{} = theme} ->
          Map.put(opts, :theme, {:theme, theme})

        {:string, theme_name} when is_binary(theme_name) ->
          Map.put(opts, :theme, {:string, theme_name})

        nil ->
          Map.put(opts, :theme, nil)

        theme_name when is_binary(theme_name) ->
          Map.put(opts, :theme, {:string, theme_name})
      end

    opts
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
