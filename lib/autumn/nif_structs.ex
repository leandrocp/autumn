defmodule Autumn.HtmlElement do
  @moduledoc false
  defstruct open_tag: nil, close_tag: nil
end

defmodule Autumn.HtmlInlineHighlightLines do
  @moduledoc false
  defstruct lines: [], style: :theme
end

defmodule Autumn.HtmlLinkedHighlightLines do
  @moduledoc false
  defstruct lines: [], class: nil
end
