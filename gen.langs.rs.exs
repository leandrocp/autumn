# https://github.com/zed-industries/zed/tree/main/crates/languages/src
# https://github.com/zed-industries/zed/tree/main/extensions

Mix.install([:toml])

defmodule Autumn.Gen.LangsRs do
  def run do
    langs = parse_langs(Lang.all())
    filetypes = parse_filetypes(langs)

    file =
      EEx.eval_file("langs.rs.eex",
        assigns: %{
          langs: langs,
          filetypes: filetypes,
          tree_sitter_functions: parse_tree_sitter_functions(langs)
        }
      )

    File.write!("native/autumn/src/langs.rs", file)
  end

  def parse_langs(langs) do
    Enum.map(langs, fn lang ->
      IO.puts(lang.name)

      Map.merge(
        lang,
        %{
          highlights: query_source(lang.highlights_src, lang.name, "highlights.scm"),
          injections: query_source(lang.injections_src, lang.name, "injections.scm"),
          locals: query_source(lang.locals_src, lang.name, "locals.scm")
        }
      )
    end)
  end

  defp parse_filetypes(langs) do
    langs
    |> Enum.flat_map(fn lang ->
      config_name = "&#{lang.config_name}"

      filetypes =
        lang.filetypes
        |> List.wrap()
        |> Enum.map(fn filetype -> {filetype, config_name} end)

      # add own lang name as alias
      [{lang.name, config_name} | filetypes]
    end)
    |> Enum.sort()
    |> Enum.dedup()
  end

  defp parse_tree_sitter_functions(langs) do
    langs
    |> Enum.map(& &1.tree_sitter_fun)
    |> Enum.uniq()
  end

  defp query_source(:zed_core, name, file) do
    # TODO: fallback to upstream parser query (tree-sitter package)
    ~s|&download_query("#{name}", "#{file}").unwrap_or("".to_string())|
  end

  defp query_source(file, name, _) when is_binary(file) do
    ~s|include_str!("../../../tmp/langs/#{name}/queries/#{file}")|
  end

  defp query_source(_, _, _), do: "\"\""
end

[{Lang, _}] = Code.require_file("langs.exs")
Autumn.Gen.LangsRs.run()
