defmodule Mix.Tasks.Autumn.GenerateThemes do
  use Mix.Task
  alias Autumn.ThemeGenerator

  @shortdoc "Parse and generate themes .toml files"

  @impl true
  def run(_args) do
    Mix.shell().info("Generating themes...")
    root_path = Path.join(:code.priv_dir(:autumn), "themes")
    themes = Path.wildcard(root_path <> "/*.toml")

    for theme <- themes do
      Mix.shell().info("Parsing #{theme}")
      ThemeGenerator.generate_theme_file(theme)
    end

    Mix.shell().info("Generating themes.rs")
    root_path = Path.join([:code.priv_dir(:autumn), "generated", "themes"])
    themes = Path.wildcard(root_path <> "/*.toml")
    ThemeGenerator.generate_themes_rs(themes)
  end
end
