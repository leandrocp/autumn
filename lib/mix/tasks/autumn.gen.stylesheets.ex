defmodule Mix.Tasks.Autumn.Gen.Stylesheets do
  @moduledoc false

  use Mix.Task

  @shortdoc "Parse .toml files to generate static .css files."

  @dest_path Path.join([:code.priv_dir(:autumn), "static", "css"])

  @impl true
  def run(_args) do
    Mix.shell().info("Generating css files...")

    for {name, theme} <- Autumn.available_themes() do
      name = clean(name)
      theme = theme.()
      stylesheet = Autumn.Theme.stylesheet(theme)

      dest_file = Path.join(@dest_path, name <> ".css")
      File.write!(dest_file, stylesheet)
    end

    Mix.shell().info("Done.")
  end

  defp clean(string) do
    string
    |> String.replace(" ", "_")
    |> String.downcase()
  end
end
