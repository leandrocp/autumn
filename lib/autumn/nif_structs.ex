defmodule Autumn.HtmlElement do
  @moduledoc false

  @type t :: %Autumn.HtmlElement{
          open_tag: String.t(),
          close_tag: String.t()
        }

  defstruct open_tag: nil, close_tag: nil
end

defmodule Autumn.HtmlInlineHighlightLinesStyle do
  @moduledoc false

  @type t :: :theme | {:style, String.t()}
end

defmodule Autumn.HtmlInlineHighlightLines do
  @moduledoc false

  @type t :: %Autumn.HtmlInlineHighlightLines{
          lines: [{integer(), integer()}],
          style: Autumn.HtmlInlineHighlightLinesStyle.t()
        }

  defstruct lines: [], style: :theme
end

defmodule Autumn.HtmlLinkedHighlightLines do
  @moduledoc false

  @type t :: %Autumn.HtmlLinkedHighlightLines{
          lines: [{integer(), integer()}],
          class: String.t()
        }

  defstruct lines: [], class: nil
end
