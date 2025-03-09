defmodule Autumn do
  @external_resource "README.md"

  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC -->")
             |> Enum.fetch!(1)

  require Logger
  alias Autumn.Options
  alias Autumn.Theme

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
      passing the language in the first argument is deprecated, pass a `:language` option instead:

        Autumn.highlight("import Kernel", language: "elixir")

    """)

    {_, opts} =
      Keyword.get_and_update(opts, :theme, fn
        nil -> {nil, nil}
        current -> {current, String.capitalize(current)}
      end)

    opts = Keyword.put(opts, :language, lang_or_file)

    highlight(source, opts)
  end

  @deprecated "Use highlight!/2 instead"
  def highlight!(lang_or_file, source, opts) do
    IO.warn("""
      passing the language in the first argument is deprecated, pass a `:language` option instead:

        Autumn.highlight!("import Kernel", language: "elixir")

    """)

    {_, opts} =
      Keyword.get_and_update(opts, :theme, fn
        nil -> {nil, nil}
        current -> {current, String.capitalize(current)}
      end)

    opts = Keyword.put(opts, :language, lang_or_file)
    highlight!(source, opts)
  end

  @doc """
  Highlights `source` code and outputs into a formatted string.

  ## Options

  * `:language` (`t:Autumn.Options.lang_or_file/0` - default: `nil`) - Optional. The language used to highlight `source`.
  You can also pass a filename or extension, for eg: `enum.ex` or `ex`. If no `language` is provided, the highlighter will
  try to guess it based on the content of the given `source` code. Use `Autumn.available_languages/0` to list all available languages.

  * `:theme` (`t:String.t/0` or `t:Autumn.Theme.t/0` - default: `"onedark"`) - Optional. A theme to apply styles on the highlighted source code.
  You can pass either the theme name or a `%Autumn.Theme{}` struct. See `Autumn.available_themes/0` to list all available themes.

  * `:formatter` (`t:Autumn.Options.formatter/0` - default: `:html_inline`) - See the type doc in `Autumn.Options` for more info and examples.

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
    language = Keyword.get(opts, :language)
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
          |> String.replace(" ", "_")
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
        opts = Map.merge(%{pre_class: nil, italic: false, include_highlight: false}, Map.new(opts))
          {name, opts}

        :else ->
          message = """
            `:formatter` is invalid, expected a tuple with the formatter name and options or just the formatter name without options

            Got

              #{inspect(formatter)}

          """

          raise Autumn.InputError, message: message
      end

    options = %Options{lang_or_file: language, theme: theme, formatter: formatter}

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
