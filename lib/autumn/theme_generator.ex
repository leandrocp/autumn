defmodule Autumn.ThemeGenerator do
  @moduledoc false
  # https://docs.helix-editor.com/themes.html

  @double_quote ?"
  @escape ?\\
  @semicolon ?;
  @space " "
  @eol "\n"
  @default_text_color "#000000"
  @default_bg_color "#ffffff"

  def generate(path) when is_binary(path) do
    file_name = Path.basename(path)
    {:ok, theme_config} = Toml.decode_file(path)
    {palette, theme_config} = Map.pop(theme_config, "palette", %{})
    {inherits, theme_config} = Map.pop(theme_config, "inherits", "")

    {parent_palette, parent_theme_config} =
      path
      |> parent_theme_config(inherits)
      |> Map.pop("palette", %{})

    palette = Map.merge(parent_palette, palette)

    theme_config =
      parent_theme_config
      |> Map.merge(theme_config)
      |> scope_text(palette)
      |> scope_background(palette)
      |> scope_module(palette)
      |> scope_operator(palette)

    theme_config =
      theme_config
      |> Enum.reduce(theme_config, fn
        {"text", _style}, acc ->
          acc

        {"background", _style}, acc ->
          acc

        {"module", _style}, acc ->
          acc

        {"operator", _style}, acc ->
          acc

        {<<"ui."::binary, _rest::binary>> = scope, _style}, acc ->
          Map.drop(acc, [scope])

        {<<"diagnostic"::binary, _rest::binary>> = scope, _style}, acc ->
          Map.drop(acc, [scope])

        {<<"warning"::binary, _rest::binary>> = scope, _style}, acc ->
          Map.drop(acc, [scope])

        {<<"error"::binary, _rest::binary>> = scope, _style}, acc ->
          Map.drop(acc, [scope])

        {<<"info"::binary, _rest::binary>> = scope, _style}, acc ->
          Map.drop(acc, [scope])

        {<<"hint"::binary, _rest::binary>> = scope, _style}, acc ->
          Map.drop(acc, [scope])

        {scope, style}, acc ->
          attrs = %{
            "class" => String.replace(scope, ".", " "),
            "style" => style(palette, style)
          }

          Map.put(acc, scope, attrs)
      end)
      |> Enum.map(&line/1)
      |> IO.iodata_to_binary()

    file_name =
      file_name
      |> String.replace(" ", "_")
      |> String.replace("-", "_")

    dest_path = Path.join([:code.priv_dir(:autumn), "generated", "themes", file_name])
    File.write!(dest_path, theme_config)

    {:ok, theme_config}
  end

  defp parent_theme_config(path, inherits) do
    path = Path.join(Path.dirname(path), "#{inherits}.toml")
    if File.exists?(path), do: Toml.decode_file!(path), else: %{}
  end

  def scope_text(theme_config, palette) do
    Map.put(theme_config, "text", %{
      "class" => ["text"],
      "style" => [text_style(theme_config, palette)]
    })
  end

  defp text_style(%{"text" => %{"fg" => fg}}, palette), do: fg(palette, fg)
  defp text_style(%{"text" => fg}, palette) when is_binary(fg), do: fg(palette, fg)
  defp text_style(%{"ui.text" => %{"fg" => fg}}, palette), do: fg(palette, fg)
  defp text_style(%{"ui.text" => fg}, palette) when is_binary(fg), do: fg(palette, fg)
  defp text_style(_config, palette), do: fg(palette, @default_text_color)

  def scope_background(theme_config, palette) do
    Map.put(theme_config, "background", %{
      "class" => ["background"],
      "style" => [background_style(theme_config, palette)]
    })
  end

  defp background_style(%{"background" => %{"bg" => bg}}, palette), do: bg(palette, bg)
  defp background_style(%{"background" => bg}, palette) when is_binary(bg), do: bg(palette, bg)
  defp background_style(%{"ui.background" => %{"bg" => bg}}, palette), do: bg(palette, bg)
  defp background_style(%{"ui.background" => bg}, palette) when is_binary(bg), do: bg(palette, bg)
  defp background_style(%{"ui.window" => %{"bg" => bg}}, palette), do: bg(palette, bg)
  defp background_style(_config, palette), do: bg(palette, @default_bg_color)

  def scope_module(theme_config, palette) do
    Map.put(theme_config, "module", %{
      "class" => ["module"],
      "style" => [module_style(theme_config, palette)]
    })
  end

  defp module_style(%{"module" => %{"fg" => fg}}, palette), do: fg(palette, fg)
  defp module_style(%{"module" => fg}, palette), do: fg(palette, fg)
  defp module_style(%{"namespace" => %{"fg" => fg}}, palette), do: fg(palette, fg)
  defp module_style(%{"namespace" => fg}, palette), do: fg(palette, fg)
  defp module_style(%{"keyword" => %{"fg" => fg}}, palette), do: fg(palette, fg)
  defp module_style(%{"keyword" => fg}, palette), do: fg(palette, fg)
  defp module_style(_scope, _palette), do: []

  def scope_operator(theme_config, palette) do
    Map.put(theme_config, "operator", %{
      "class" => ["operator"],
      "style" => [operator_style(theme_config, palette)]
    })
  end

  defp operator_style(%{"operator" => %{"fg" => fg}}, palette), do: fg(palette, fg)
  defp operator_style(%{"operator" => fg}, palette), do: fg(palette, fg)
  defp operator_style(%{"keyword.operator" => %{"fg" => fg}}, palette), do: fg(palette, fg)
  defp operator_style(%{"keyword.operator" => fg}, palette), do: fg(palette, fg)
  defp operator_style(_scope, _palette), do: []

  def line({scope, %{"class" => class, "style" => style}}) do
    [
      @double_quote,
      scope,
      @double_quote,
      " = ",
      @double_quote,
      "class=",
      @escape,
      @double_quote,
      class,
      @escape,
      @double_quote,
      @space,
      "style=",
      @escape,
      @double_quote,
      style,
      @escape,
      @double_quote,
      @double_quote,
      @eol
    ]
  end

  # TODO: support all attrs

  # https://docs.helix-editor.com/themes.html#color-palettes
  defp palette_color(palette, color_name), do: Map.get(palette, color_name, "")

  def style(_palette, <<"#"::binary, _rest::binary>> = color) do
    ["color: ", color, @semicolon]
  end

  def style(palette, fg) when is_binary(fg) do
    ["color: ", palette_color(palette, fg), @semicolon]
  end

  def style(palette, style) when is_map(style) do
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
      "underlined", acc ->
        ["text-decoration: underline; " | acc]

      "italic", acc ->
        ["font-style: italic; " | acc]

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
