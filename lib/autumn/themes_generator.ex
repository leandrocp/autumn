defmodule Autumn.ThemesGenerator do
  @moduledoc false

  @semicolon ?;
  @default_fg_color "#000000"
  @default_bg_color "#ffffff"

  @themes_rs_template ~S"""
  //
  // DO NOT EDIT THIS FILE
  //
  // Generated automatically by mix task `Mix.Tasks.Autumn.GenerateThemes`.
  // Execute `mix autumn.generate_themes` at the root to update this file.
  //
  // Generated at <%= DateTime.utc_now() %>

  #![allow(dead_code)]
  #![allow(unused_variables)]

  use phf::phf_map;

  #[derive(Debug)]
  pub struct Theme {
      pub scopes: phf::Map<&'static str, (&'static str, &'static str)>
  }

  impl Theme {
      pub fn get_scope(&self, name: &str) -> (&str, &str) {
          match self.scopes.get(name) {
              Some((class, style)) => (class, style),
              None => {
                  if name.contains('.') {
                      let split: Vec<&str> = name.split('.').collect();
                      let joined = split[0..split.len() - 1].join(".");
                      self.get_scope(joined.as_str())
                  } else {
                      let (class, style) = self.scopes.get("text").unwrap();
                      (class, style)
                  }
              }
          }
      }
  }

  static THEMES: phf::Map<&'static str, Theme> = phf_map! {<%= for {theme, scopes} <- @themes do %>
      "<%= theme %>" => Theme {
          scopes: phf_map! {<%= for {scope, %{"class" => class, "style" => style}} <- scopes do %>
            "<%= scope %>" => ("<%= class %>", "<%= style %>"),<% end %>
          },
      },<% end %>
  };

  pub fn theme(name: &str) -> Option<&Theme> {
      THEMES.get(name)
  }

  #[cfg(test)]
  mod tests {
      use super::*;
      <%= for {theme, _scopes} <- @themes do %>
      #[test]
      fn load_<%= theme %>() {
          let _theme = theme("<%= theme %>");
      }<% end %>
  }
  """

  def generate(
        src_path \\ Path.join(:code.priv_dir(:autumn), "themes"),
        dest_path \\ Path.join([File.cwd!(), "native", "autumn", "src", "themes.rs"])
      ) do
    theme_files = Path.wildcard(src_path <> "/*.toml")

    themes =
      Enum.reduce(theme_files, %{}, fn theme_file, acc ->
        theme =
          theme_file
          |> Path.basename(".toml")
          |> String.replace(" ", "_")
          |> String.replace("-", "_")
          |> String.replace("+", "")

        %{"scopes" => scopes, "palette" => palette} = parse_theme_file(theme_file)

        scopes =
          scopes
          |> scope_text(palette)
          |> scope_background(palette)
          |> reduce_scopes(palette)

        Map.put(acc, theme, scopes)
      end)

    :ok = generate_themes_rs(themes, dest_path)

    {:ok, themes}
  end

  defp reduce_scopes(scopes, palette) do
    Enum.reduce(scopes, scopes, fn
      {"text", _style}, acc ->
        acc

      {"background", _style}, acc ->
        acc

      {<<"ui."::binary, _rest::binary>>, _style}, acc ->
        acc

      {<<"diagnostic"::binary, _rest::binary>>, _style}, acc ->
        acc

      {<<"warning"::binary, _rest::binary>>, _style}, acc ->
        acc

      {<<"error"::binary, _rest::binary>>, _style}, acc ->
        acc

      {<<"info"::binary, _rest::binary>>, _style}, acc ->
        acc

      {<<"hint"::binary, _rest::binary>>, _style}, acc ->
        acc

      {scope, attrs}, acc ->
        attrs = %{
          "class" => String.replace(scope, ".", "-"),
          "style" => style(palette, attrs)
        }

        Map.put(acc, scope, attrs)
    end)
  end

  def scope_text(scopes, palette) do
    Map.put(scopes, "text", %{
      "class" => "text",
      "style" => IO.iodata_to_binary([text_style(scopes, palette)])
    })
  end

  defp text_style(%{"text" => %{"fg" => fg}}, palette), do: fg(palette, fg)
  defp text_style(%{"text" => fg}, palette) when is_binary(fg), do: fg(palette, fg)
  defp text_style(%{"ui.text" => %{"fg" => fg}}, palette), do: fg(palette, fg)
  defp text_style(%{"ui.text" => fg}, palette) when is_binary(fg), do: fg(palette, fg)
  defp text_style(_scopes, palette), do: fg(palette, @default_fg_color)

  def scope_background(scopes, palette) do
    Map.put(scopes, "background", %{
      "class" => "",
      "style" => IO.iodata_to_binary([background_style(scopes, palette)])
    })
  end

  defp background_style(%{"background" => %{"bg" => bg}}, palette), do: bg(palette, bg)

  defp background_style(%{"background" => bg}, palette) when is_binary(bg), do: bg(palette, bg)
  defp background_style(%{"ui.background" => %{"bg" => bg}}, palette), do: bg(palette, bg)
  defp background_style(%{"ui.background" => bg}, palette) when is_binary(bg), do: bg(palette, bg)
  defp background_style(%{"ui.window" => %{"bg" => bg}}, palette), do: bg(palette, bg)
  defp background_style(_scopes, palette), do: bg(palette, @default_bg_color)

  # https://docs.helix-editor.com/themes.html#color-palettes
  defp palette_color(palette, color_name), do: Map.get(palette, color_name, "")

  def style(_palette, <<"#"::binary, _rest::binary>> = color) do
    IO.iodata_to_binary(["color: ", color, @semicolon])
  end

  def style(palette, fg) when is_binary(fg) do
    IO.iodata_to_binary(["color: ", palette_color(palette, fg), @semicolon])
  end

  def style(palette, style) when is_map(style) do
    style
    |> Enum.reduce([], fn
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
    |> Enum.join(" ")
  end

  defp fg(_palette, <<"#"::binary, _rest::binary>> = fg) do
    ["color: ", fg, @semicolon]
  end

  defp fg(palette, fg) do
    ["color: ", palette_color(palette, fg), @semicolon]
  end

  defp bg(_palette, <<"#"::binary, _rest::binary>> = bg) do
    ["background-color: ", bg, @semicolon]
  end

  defp bg(palette, bg) do
    ["background-color: ", palette_color(palette, bg), @semicolon]
  end

  # https://docs.helix-editor.com/themes.html#modifiers
  defp modifiers(modifiers) do
    Enum.reduce(modifiers, [], fn
      "underlined", acc ->
        ["text-decoration: underline;" | acc]

      "italic", acc ->
        ["font-style: italic;" | acc]

      "bold", acc ->
        ["font-weight: bold;" | acc]

      # TODO: support all modifiers
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
        ["text-decoration: underline;" | acc]

      # TODO: support all underline styles
      {"style", _style}, acc ->
        acc
    end)
  end

  def parse_theme_file(path) when is_binary(path) do
    {:ok, scopes} = Toml.decode_file(path)
    {palette, scopes} = Map.pop(scopes, "palette", %{})
    {inherits, scopes} = Map.pop(scopes, "inherits", "")

    {parent_palette, parent_scopes} =
      path
      |> parent_theme_file(inherits)
      |> Map.pop("palette", %{})

    palette = Map.merge(parent_palette, palette)

    scopes =
      parent_scopes
      |> Map.merge(scopes)

    %{"scopes" => scopes, "palette" => palette}
  end

  defp parent_theme_file(path, inherits) do
    path = Path.join(Path.dirname(path), "#{inherits}.toml")
    if File.exists?(path), do: Toml.decode_file!(path), else: %{}
  end

  def generate_themes_rs(themes, dest_path) do
    themes_rs = EEx.eval_string(@themes_rs_template, assigns: %{themes: themes})
    File.write(dest_path, themes_rs)
  end
end
