defmodule Mix.Tasks.Autumn.GenerateCss do
  use Mix.Task
  alias Autumn.ThemesGenerator

  @shortdoc "Parse .toml files to generate static css files."

  @impl true
  def run(_args) do
    Mix.shell().info("Parsing themes...")
    ThemesGenerator.generate_css()
    Mix.shell().info("Done.")
  end
end
