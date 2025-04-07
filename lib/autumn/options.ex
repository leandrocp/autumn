defmodule Autumn.Options do
  @moduledoc """
  Options for the highlighter.

  See https://docs.rs/autumnus/latest/autumnus/struct.Options.html for more info.
  """

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
             [{:pre_class, String.t()} | {:italic, boolean()} | {:include_highlights, boolean()}]}
          | :html_linked
          | {:html_linked, [{:pre_class, String.t()}]}
          | :terminal
          | {:terminal, keyword()}

  @type t :: %__MODULE__{
          lang_or_file: lang_or_file() | nil,
          theme: Autumn.Theme.t() | nil,
          formatter: formatter()
        }

  defstruct lang_or_file: nil, theme: nil, formatter: :html_inline
end
