defmodule Autumn.CssGenerator do
  @moduledoc false

  alias Autumn.Theme

  @id "athl"

  def run(
        src_path \\ Path.join(:code.priv_dir(:autumn), "themes"),
        dest_path \\ Path.join([:code.priv_dir(:autumn), "static", "css"])
      ) do
    File.mkdir_p!(dest_path)
    themes = Theme.parse_themes(src_path)

    Enum.reduce(themes, %{}, fn %{name: name, palette: palette, shared: shared, highlights: highlights}, acc ->
      path = Path.join(dest_path, "#{name}.css")
      palette = Enum.sort(palette)

      css = [
        "/* ",
        name,
        " */\n",
        ":root {\n",
        "  /* palette */\n",
        palette(palette),
        "  /* shared */\n",
        shared(shared),
        "}\n",
        "pre.athl {\n",
        "  background-color: var(--athl-shared-bg-color);\n",
        "  color: var(--athl-shared-fg-color);\n",
        "}\n",
        highlights(highlights)
      ]

      File.write!(path, css)

      Map.put(acc, name, IO.iodata_to_binary(css))
    end)
  end

  defp palette(palette) do
    Enum.reduce(palette, [], fn {name, color}, acc ->
      var = ["  --", @id, "-", sanitize_name(name), ": ", color, ";", "\n"]
      [acc | var]
    end)
  end

  defp shared(%{"background" => bg, "foreground" => fg}) do
    [
      "  --athl-shared-bg-color: ",
      bg,
      ";\n",
      "  --athl-shared-fg-color: ",
      fg,
      ";\n"
    ]
  end

  defp highlights(highlights) do
    Enum.reduce(highlights, [], fn {name, rules}, acc ->
      [
        acc
        | [".", @id, "-", sanitize_name(name), " {\n", rules(rules), "}\n"]
      ]
    end)
  end

  defp rules(rules) when map_size(rules) == 0 do
    ["  color: var(--", @id, "-", "shared-fg-color);\n"]
  end

  defp rules(rules) do
    Enum.reduce(rules, [], fn
      {"color", "foreground"}, acc ->
        [acc | ["  color: var(--", @id, "-", "shared-fg-color);\n"]]

      {"background-color", "background"}, acc ->
        [acc | ["  background-color: var(--", @id, "-", "shared-bg-color);\n"]]

      {"color", color}, acc ->
        [acc | ["  color: var(--", @id, "-", sanitize_name(color), ", ", color, ");\n"]]

      {style, value}, acc ->
        [acc | ["  ", style, ": ", value, ";\n"]]
    end)
  end

  defp sanitize_name(name) do
    name
    |> String.replace(".", "-")
    |> String.replace("_", "-")
  end
end
