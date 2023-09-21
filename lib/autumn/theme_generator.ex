defmodule Autumn.ThemeGenerator do
  @moduledoc false
  # https://docs.helix-editor.com/themes.html

  @double_quote ?"
  @escape ?\\
  @semicolon ?;
  @space " "
  @eol "\n"

  def generate(path) when is_binary(path) do
    file_name = Path.basename(path)
    {:ok, config} = Toml.decode_file(path)
    config = maybe_merge_parent(path, config)
    {palette, config} = Map.pop(config, "palette", %{})

    inline_theme_config =
      config
      |> Enum.reduce([], fn
        {"palette", _}, acc ->
          acc

        {"inherits", _}, acc ->
          acc

        {scope, style}, acc ->
          [line(palette, scope, style) | acc]
      end)
      |> Enum.sort()

    # IO.inspect(inline_theme_config, pretty: true, limit: :infinity, printable_limit: :infinity)

    inline_theme_config = IO.iodata_to_binary(inline_theme_config)

    dest_path = Path.join([:code.priv_dir(:autumn), "generated", "themes", file_name])
    File.write!(dest_path, inline_theme_config)

    {:ok, inline_theme_config}
  end

  defp maybe_merge_parent(path, config) do
    {inherits, config} = Map.pop(config, "inherits", "")
    parent_path = Path.join(Path.dirname(path), "#{inherits}.toml")

    if File.exists?(parent_path) do
      {:ok, parent_config} = Toml.decode_file(parent_path)
      Map.merge(parent_config, config)
    else
      config
    end
  end

  # remove unnecessary ui styles
  # https://docs.helix-editor.com/themes.html#interface
  def line(_palette, <<"ui."::binary, _rest::binary>>, _style), do: []
  def line(_palette, <<"diagnostic"::binary, _rest::binary>>, _style), do: []
  def line(_palette, "warning", _style), do: []
  def line(_palette, "error", _style), do: []
  def line(_palette, "info", _style), do: []
  def line(_palette, "hint", _style), do: []

  def line(palette, scope, style) do
    attrs = attrs(palette, style)

    [
      @double_quote,
      scope,
      @double_quote,
      " = ",
      @double_quote,
      "style=",
      @escape,
      @double_quote,
      attrs,
      @escape,
      @double_quote,
      @double_quote,
      @eol
    ]
  end

  # TODO: support all attrs

  # https://docs.helix-editor.com/themes.html#color-palettes
  defp palette_color(palette, color_name), do: Map.get(palette, color_name, "")

  def attrs(_palette, <<"#"::binary, _rest::binary>> = color) do
    ["color: ", color, @semicolon]
  end

  def attrs(palette, fg) when is_binary(fg) do
    ["color: ", palette_color(palette, fg), @semicolon]
  end

  def attrs(palette, style) when is_map(style) do
    Enum.reduce(style, [], fn
      {"fg", fg}, acc ->
        [fg(palette, fg) | acc]

      {"bg", bg}, acc ->
        [bg(palette, bg) | acc]

      {"modifiers", modifiers}, acc ->
        [modifiers(modifiers) | acc]

      {"underline", underline}, acc ->
        [underline(palette, underline) | acc]

      # TODO: support all style keys
      _style, acc ->
        acc
    end)
  end

  defp fg(_palette, <<"#"::binary, _rest::binary>> = fg) do
    ["color: ", fg, @semicolon, @space]
  end

  defp fg(palette, fg) do
    ["color: ", palette_color(palette, fg), @semicolon, @space]
  end

  defp bg(_palette, <<"#"::binary, _rest::binary>> = bg) do
    ["background-color: ", bg, @semicolon, @space]
  end

  defp bg(palette, bg) do
    ["background-color: ", palette_color(palette, bg), @semicolon, @space]
  end

  # https://docs.helix-editor.com/themes.html#modifiers
  defp modifiers(modifiers) do
    Enum.reduce(modifiers, [], fn
      "italic", acc ->
        ["text-decoration: underline; " | acc]

      "bold", acc ->
        ["font-weight: bold; " | acc]

      # TODO:support all modifiers
      _modifier, acc ->
        acc
    end)
  end

  # https://docs.helix-editor.com/themes.html#underline-style
  defp underline(palette, underline) do
    Enum.reduce(underline, [], fn
      {"color", color}, acc ->
        [fg(palette, color) | acc]

      {"style", "line"}, acc ->
        ["text-decoration: underline; " | acc]

      # TODO: support all underline styles
      {"style", _style}, acc ->
        acc
    end)
  end
end
