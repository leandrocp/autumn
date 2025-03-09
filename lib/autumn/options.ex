defmodule Autumn.Options do
  @moduledoc """
  Options for the highlighter.

  See https://docs.rs/autumnus/latest/autumnus/struct.Options.html for more info.
  """

  @typedoc """
  A language name, filename, or path with extesion.

  ## Examples

      - "elixir"
      - ".ex"
      - "app.ex"
      - "lib/app.ex"

  """
  @type lang_or_file :: String.t() | nil

  @typedoc """
  Highlighter formatter and its options.

  Available formatters: `:html_inline`, `:html_linked`, `:terminal`

  * `:html_inline` - generates `<span>` tags with inline styles for each token, for example: `<span style="color: #6eb4bff;">Atom</span>`.
  * `:html_linked` - generates `<span>` tags with `class` representing the token type, for example: `<span class="keyword-special">Atom</span>`.
     Must link an external CSS in order to render colors, see an example in the [Formatters](#module-formatters) section.
  * `:terminal` - generates ANSI escape codes for terminal output.

  You can either pass the formatter as an atom to use default options or a tuple with the formatter name and options, so both are equivalent:

      # passing only the formatter name like below:
      :terminal
      # is the same as passing an empty list of options:
      {:terminal, []}

  ## Options available

  * `html_linked` and `html_inline`:

      - `:pre_class` (`t:String.t/0` - default: `nil`) - the CSS class to append into the wrapping `<pre>` tag.
      - `:italic` (`t:boolean/0` - default: `false`) - enable italic style for the highlighted code.
      - `:include_highlight` (`t:boolean/0` - default: `false`) - include the highlight scope name in a `data-highlight` attribute. Useful for debugging.

  * `terminal`:

      - `:italic` (`t:boolean/0` - default: `false`) - enable italic style for the highlighted code.

  ## Examples

      {:html_inline, pre_class: "example-01"}

      {:html_linked, pre_class: "example-01", include_highlight: true}

      {:terminal, []}

      {:terminal, italic: true}

  See https://docs.rs/autumnus/latest/autumnus/enum.FormatterOption.html for more info.

  """
  @type formatter :: formatter_name | formatter_with_options
  @type formatter_name :: :html_inline | :html_linked | :terminal
  @type formatter_with_options :: {formatter_name, Keyword.t()}

  @type t :: %__MODULE__{
          lang_or_file: nil | lang_or_file(),
          theme: nil | Autumn.Theme.t(),
          formatter: formatter()
        }

  defstruct lang_or_file: nil, theme: nil, formatter: :html_inline
end
