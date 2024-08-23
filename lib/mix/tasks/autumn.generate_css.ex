defmodule Mix.Tasks.Autumn.GenerateCss do
  @moduledoc false

  use Mix.Task

  @shortdoc "Parse .toml files to generate static css files."

  @dest_path Path.join([:code.priv_dir(:autumn), "static", "css"])

  @impl true
  def run(_args) do
    Mix.shell().info("Generating css files...")

    Autumn.Themes.available_themes()

    for theme <- Autumn.Themes.available_themes() do
      theme = Autumn.Themes.get!(theme)
      Mix.shell().info("Generating css for #{theme.name}")

      normal_style = theme.private.inline_styles["normal"]

      rules =
        Enum.reduce(theme.private.inline_styles, [], fn {highlight, style}, acc ->
          class = String.replace(highlight, ".", "-")

          rule = [
            ".athl-",
            class,
            " {\n",
            "  ",
            style,
            "\n}\n"
          ]

          [acc | rule]
        end)

      css = [
        "/* ",
        theme.name,
        " */\n",
        "pre.athl {\n",
        "  ",
        normal_style,
        "\n",
        "}\n",
        rules
      ]

      dest_file = Path.join(@dest_path, theme.name <> ".css")
      File.write!(dest_file, IO.iodata_to_binary(css))
    end

    Mix.shell().info("Done.")
  end
end
