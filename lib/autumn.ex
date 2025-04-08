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

  @options_schema [
    language: [
      type: {:or, [:string, nil]},
      type_spec: quote(do: language()),
      type_doc: "`t:language/0`",
      default: nil,
      doc: """
      The language used to highlight source code.
      You can also pass a filename or extension, for eg: `"enum.ex"` or just `"ex"`. If no language is provided, the highlighter will
      try to guess it based on the content of the given source code. Use `Autumn.available_languages/0` to list all available languages.
      """
    ],
    formatter: [
      type: {:custom, Autumn, :formatter_type, []},
      type_spec: quote(do: formatter()),
      type_doc: "`t:formatter/0`",
      default: :html_inline,
      doc: "Formatter to apply on the highlighted source code. See the type doc for more info."
    ],
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
  def formatter_type(formatter) when formatter in [:html_inline, :html_linked, :terminal],
    do: {:ok, formatter}

  def formatter_type({:html_inline, opts}) when is_list(opts) do
    case Keyword.keys(opts) -- [:theme, :pre_class, :italic, :include_highlights] do
      [] -> {:ok, {:html_inline, opts}}
      invalid -> {:error, "invalid options given to html_inline: #{inspect(invalid)}"}
    end
  end

  def formatter_type({:html_linked, opts}) when is_list(opts) do
    case Keyword.keys(opts) -- [:pre_class] do
      [] -> {:ok, {:html_linked, opts}}
      invalid -> {:error, "invalid options given to html_linked: #{inspect(invalid)}"}
    end
  end

  def formatter_type({:terminal, opts}) when is_list(opts) do
    case Keyword.keys(opts) -- [:theme] do
      [] -> {:ok, {:terminal, opts}}
      invalid -> {:error, "invalid options given to terminal: #{inspect(invalid)}"}
    end
  end

  def formatter_type(other) do
    {:error, "invalid formatter option: #{inspect(other)}"}
  end

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
  def highlight(language, source, opts) do
    IO.warn("""
      passing the language in the first argument is deprecated, pass a `:language` option instead:

        Autumn.highlight("import Kernel", language: "elixir")

    """)

    {_, opts} =
      Keyword.get_and_update(opts, :theme, fn
        nil -> {nil, nil}
        current -> {current, String.capitalize(current)}
      end)

    opts = Keyword.put(opts, :language, language)

    highlight(source, opts)
  end

  @deprecated "Use highlight!/2 instead"
  def highlight!(language, source, opts) do
    IO.warn("""
      passing the language in the first argument is deprecated, pass a `:language` option instead:

        Autumn.highlight!("import Kernel", language: "elixir")

    """)

    {_, opts} =
      Keyword.get_and_update(opts, :theme, fn
        nil -> {nil, nil}
        current -> {current, String.capitalize(current)}
      end)

    opts = Keyword.put(opts, :language, language)
    highlight!(source, opts)
  end

  @doc """
  Highlights `source` code and outputs into a formatted string.

  ## Options

  #{NimbleOptions.docs(@options_schema)}

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
  def highlight(source, opts \\ [])

  def highlight(source, opts) when is_binary(source) and is_list(opts) do
    opts = NimbleOptions.validate!(opts, @options_schema)

    # deprecated options
    {theme, opts} = Keyword.pop(opts, :theme)
    theme = theme || "onedark"
    {pre_class, opts} = Keyword.pop(opts, :pre_class)
    {inline_style, opts} = Keyword.pop(opts, :inline_style)

    formatter =
      build_formatter(opts[:formatter], theme, inline_style, pre_class) |> build_theme()

    opts =
      opts
      |> Map.new()
      |> Map.put(:formatter, formatter)

    case Autumn.Native.highlight(source, opts) do
      {:error, error} -> raise Autumn.HighlightError, error: error
      output -> output
    end
  end

  def highlight(language, source)
      when is_binary(language) and is_binary(source) do
    highlight(source, language: language)
  end

  defp build_formatter(_formatter, theme, true = _inline_style, pre_class) do
    {:html_inline,
     %{theme: theme, pre_class: pre_class, italic: false, include_highlights: false}}
  end

  defp build_formatter(_formatter, _theme, false = _inline_style, pre_class) do
    {:html_linked, %{pre_class: pre_class}}
  end

  defp build_formatter({:html_inline, opts}, theme, _inline_style, pre_class) do
    opts =
      opts
      |> Keyword.put(:pre_class, opts[:pre_class] || pre_class)
      |> Keyword.put_new(:theme, theme)
      |> Keyword.put_new(:italic, false)
      |> Keyword.put_new(:include_highlights, false)

    {:html_inline, Map.new(opts)}
  end

  defp build_formatter({:html_linked, opts}, _theme, _inline_style, pre_class) do
    opts = Keyword.put(opts, :pre_class, opts[:pre_class] || pre_class)
    {:html_linked, Map.new(opts)}
  end

  defp build_formatter({:terminal, opts}, theme, _inline_style, _pre_class) do
    opts =
      opts
      |> Keyword.put_new(:theme, theme)

    {:terminal, Map.new(opts)}
  end

  defp build_formatter(:html_inline, theme, _inline_style, pre_class) do
    {:html_inline,
     %{theme: theme, pre_class: pre_class, italic: false, include_highlights: false}}
  end

  defp build_formatter(:html_linked, _theme, _inline_style, pre_class) do
    {:html_linked, %{pre_class: pre_class}}
  end

  defp build_formatter(:terminal, theme, _inline_style, _pre_class) do
    {:terminal, %{theme: theme}}
  end

  defp build_theme({formatter, %{theme: theme} = opts}) do
    theme =
      cond do
        match?(%Theme{}, theme) ->
          {:theme, theme}

        String.contains?(theme, " ") ->
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

    {formatter, Map.put(opts, :theme, theme)}
  end

  defp build_theme(formatter), do: formatter

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

  def highlight!(language, source)
      when is_binary(language) and is_binary(source) do
    highlight!(source, language: language)
  end
end
