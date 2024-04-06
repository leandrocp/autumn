defmodule Mix.Tasks.Autumn.GenerateThemesRs do
  use Mix.Task
  alias Autumn.ThemesGenerator

  @shortdoc "Parse .toml files to generate native/inkjet_nif/src/themes.rs"

  @impl true
  def run(_args) do
    Mix.shell().info("Parsing themes...")
    ThemesGenerator.generate_themes_rs()
    Mix.shell().info("Done.")
  end
end
