defmodule Mix.Tasks.Autumn.GenerateLangs do
  use Mix.Task

  @shortdoc "Parse and generate langs module"

  @impl true
  def run(_args) do
    Mix.shell().info("Generating langs module...")
    langs_path = Path.join(:code.priv_dir(:autumn), "langs")
    langs = File.ls!(langs_path) |> Enum.reject(&(&1 == "README.md"))

    langs =
      langs
      |> Enum.map(fn lang ->
        Mix.shell().info("Parsing #{lang}")

        package_json = Path.join([langs_path, lang, "package.json"]) |> File.read!()
        package_json = Jason.decode!(package_json)

        parse(lang, package_json["tree-sitter"])
      end)
      |> Map.new()

    dest_path = Path.join([:code.priv_dir(:autumn), "generated", "langs.exs"])
    File.write!(dest_path, inspect(langs, pretty: true))
  end

  defp parse(<<"tree-sitter-"::binary, lang::binary>>, config) do
    file_types =
      config
      |> Enum.reduce([], fn %{"file-types" => file_types}, acc ->
        [file_types | acc]
      end)
      |> List.flatten()
      |> Enum.uniq()

    {lang, file_types}
  end
end
