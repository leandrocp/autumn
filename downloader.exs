Mix.install([:toml, :req])

defmodule Downloader.Zed do
  def run(force \\ false) do
    Downloader.check_bins!()

    zed_path = Path.join(Downloader.tmp_path(), "zed")

    if force do
      File.rm_rf(zed_path)
    end

    File.write!(
      Path.join(Downloader.tmp_path(), "extensions"),
      Req.get!("https://raw.githubusercontent.com/zed-industries/extensions/refs/heads/main/.gitmodules").body
    )

    Downloader.clone_github_repo("https://github.com/zed-industries/zed", zed_path)
  end
end

defmodule Downloader.Themes do
  def run(force \\ false) do
    Downloader.check_bins!()

    tmp_themes_path = Path.join(Downloader.tmp_path(), "themes")
    themes_path = Path.join(Downloader.priv_path(), "themes")

    if force do
      File.rm_rf(tmp_themes_path)
      File.rm_rf(themes_path)
    end

    File.mkdir_p!(tmp_themes_path)
    File.mkdir_p!(themes_path)

    override_themes =
      Downloader.read_csv!("themes.csv", fn line ->
        [family, repo] = String.split(line, ",", parts: 2)
        {String.trim(family), String.trim(repo)}
      end)

    themes =
      Path.join(Downloader.tmp_path(), "extensions")
      |> File.read!()
      |> String.split(~r/\[submodule.*?\]/, trim: true)
      |> Enum.reduce(override_themes, fn ext, acc ->
        [path, url] =
          ext
          |> String.split("\n\t", trim: true, parts: 2)
          |> Enum.map(&String.trim/1)

        if String.contains?(path, "theme") or String.contains?(url, "theme") do
          [_, path] = String.split(path, " = ", trim: true)
          [_, family] = String.split(path, "/", trim: true)
          family = String.replace(family, "-", "_")

          [_, url] = String.split(url, " = ", trim: true)
          url = String.replace(url, ~r/\.git$/, "")

          cond do
            Enum.find(override_themes, fn {_, u} -> u == url end) -> acc
            family == "malibu" -> acc
            family == "call_trans_opt_received" -> acc
            :else -> [{family, url} | acc]
          end
        else
          acc
        end
      end)

    for {family, repo} <- themes do
      :ok = Downloader.clone_github_repo(repo, "#{tmp_themes_path}/#{family}", fetch_main: true)
    end

    copy_zed_themes(tmp_themes_path)

    [tmp_themes_path, "*"]
    |> Path.join()
    |> Path.wildcard()
    |> Enum.each(fn theme_path ->
      name = Path.basename(theme_path)
      IO.puts(name)
      dest_path = Path.join(themes_path, name)
      copy_theme(name, theme_path, dest_path)
    end)

    File.cp!(Path.join([tmp_themes_path, "zed", "assets", "themes", "LICENSES"]), Path.join(themes_path, "LICENSES"))

    # format to fix small issues that cause Jason errors
    System.cmd("find", ~w(#{themes_path} -name *.json -exec prettier --write {} +))

    :ok
  end

  # handle nested assets/themes inside zed repo
  defp copy_zed_themes(tmp_themes_path) do
    [tmp_themes_path, "zed", "assets", "themes", "*"]
    |> Path.join()
    |> Path.wildcard()
    |> Enum.each(fn source ->
      File.cp_r!(source, Path.join(tmp_themes_path, Path.basename(source)))
    end)
  end

  # ignore leftover from zed assets
  defp copy_theme("zed" = _name, _, _), do: :skip
  defp copy_theme("LICENSES" = _name, _, _), do: :skip

  defp copy_theme(name, source_path, dest_path) do
    File.mkdir_p!(dest_path)
    files = Path.wildcard(Path.join(source_path, "{Readme*,readme*,README*,License*,license*,LICENSE*,#{name}*.json}"))
    themes_files = Path.wildcard(Path.join(source_path, "themes/*.json"))
    files = files ++ themes_files

    Enum.each(files, fn file ->
      basename = Path.basename(file)
      File.cp!(file, Path.join(dest_path, basename))
    end)
  end
end

defmodule Downloader.Langs do
  def run(force \\ false) do
    Downloader.check_bins!()

    zed_external_extensions_path = Path.join(Downloader.tmp_path(), "zed_ext")
    parsers_path = Path.join(Downloader.tmp_path(), "parsers")
    langs_path = Path.join(Downloader.tmp_path(), "langs")
    overrides_path = Path.join(Downloader.priv_path(), "overrides")

    if force do
      File.rm_rf(zed_external_extensions_path)
      File.rm_rf(parsers_path)
      File.rm_rf(langs_path)
    end

    File.mkdir_p!(zed_external_extensions_path)
    File.mkdir_p!(parsers_path)
    File.mkdir_p!(langs_path)

    IO.puts("Cloning Zed extensions")

    for lang <- Lang.all(), lang.zed_ext_repo != nil do
      IO.puts("#{lang.name} - #{lang.zed_ext_repo}")
      dest_path = Path.join(zed_external_extensions_path, lang.name)
      :ok = Downloader.clone_github_repo(lang.zed_ext_repo, dest_path)
    end

    IO.puts("Cloning parsers")

    for %{parser_repo: {repo, ref}} = lang <- Lang.all() do
      IO.puts("#{lang.name} - #{repo}")
      dest_path = Path.join(parsers_path, lang.parser_name)
      :ok = Downloader.clone_github_repo(repo, dest_path, commit: ref)
    end

    for lang <- Lang.all(), is_binary(lang.parser_repo) do
      IO.puts("#{lang.name} - #{lang.parser_repo}")
      dest_path = Path.join(parsers_path, lang.parser_name)
      :ok = Downloader.clone_github_repo(lang.parser_repo, dest_path)
    end

    for lang <- Lang.all() do
      IO.puts(lang.name)

      lang_path = Path.join(langs_path, lang.name)
      queries_lang_path = Path.join(lang_path, "queries")

      File.mkdir_p(queries_lang_path)

      parser_path = Path.join(parsers_path, lang.parser_name)
      zed_external_extension_path = Path.join(zed_external_extensions_path, lang.name)

      zed_core_extension_path =
        Path.join([Downloader.tmp_path(), "zed", "extensions", lang.extension_name, "languages", lang.name])

      if lang.generate && !File.exists?(Path.join([parser_path, "src", "parser.c"])) do
        root = File.cwd!()
        File.cd!(parser_path)
        {_, 0} = System.cmd("tree-sitter", ~w(generate))
        File.cd!(root)
      end

      cond do
        lang.name == "markdown" ->
          File.cp_r(Path.join(parser_path, "tree-sitter-markdown"), Path.join(lang_path, "block"))

          File.cp(
            Path.join([parser_path, "tree-sitter-markdown-inline", "src", "parser.c"]),
            Path.join([lang_path, "block", "src", "parser_inline.c"])
          )

          File.cp(
            Path.join([parser_path, "tree-sitter-markdown-inline", "src", "scanner.c"]),
            Path.join([lang_path, "block", "src", "scanner_inline.c"])
          )

          File.cp_r(Path.join(parser_path, "common"), Path.join(lang_path, "common"))

        lang.name == "markdown_inline" ->
          File.cp_r(Path.join(parser_path, "tree-sitter-markdown-inline"), Path.join(lang_path, "inline"))

          File.cp(
            Path.join([parser_path, "tree-sitter-markdown", "src", "parser.c"]),
            Path.join([lang_path, "inline", "src", "parser_block.c"])
          )

          File.cp(
            Path.join([parser_path, "tree-sitter-markdown", "src", "scanner.c"]),
            Path.join([lang_path, "inline", "src", "scanner_block.c"])
          )

          File.cp_r(Path.join(parser_path, "common"), Path.join(lang_path, "common"))

        lang.name == "php" ->
          File.cp_r(Path.join(parser_path, "php"), Path.join(lang_path, "php"))
          File.cp_r(Path.join(parser_path, "common"), Path.join(lang_path, "common"))

        lang.name == "typescript" ->
          File.cp_r(Path.join(parser_path, "tsx"), Path.join(lang_path, "tsx"))
          File.cp_r(Path.join(parser_path, "common"), Path.join(lang_path, "common"))

        :else ->
          src_lang_path = Path.join(lang_path, "src")
          File.cp_r(Path.join(parser_path, "src"), src_lang_path)
      end

      # copy all possible files from all available sources
      # last entries have higher preference
      for path <- [parser_path, zed_external_extension_path, zed_core_extension_path] do
        path
        |> Path.join("**/{highlights,injections,locals}*.scm")
        |> Path.wildcard()
        |> Enum.each(fn src_path ->
          filename = Path.basename(src_path)
          dest_path = Path.join(queries_lang_path, filename)
          File.cp_r(src_path, dest_path)
        end)
      end

      # overrides
      for file <- ~w(highlights.scm injections.scm locals.scm) do
        dest_path = Path.join(queries_lang_path, file)
        override_file_path = Path.join([overrides_path, lang.name, file])

        if File.exists?(override_file_path) && File.exists?(dest_path) do
          query = File.read!(dest_path)
          override = File.read!(override_file_path)
          content = [query, "\n", "; overrides", "\n", override]
          File.write!(dest_path, content)
        end
      end
    end
  end
end

defmodule Downloader do
  def priv_path, do: Path.expand("priv", __DIR__)
  def tmp_path, do: Path.expand("tmp", __DIR__)

  def check_bins! do
    raise = fn bin -> raise "bin #{bin} not found in $PATH, please install it first" end

    for bin <- ~w(git gh find unzip node tree-sitter) do
      System.find_executable(bin) || raise.(bin)
    end
  end

  def read_csv!(path, line_fun) do
    path
    |> File.read!()
    |> String.split("\n")
    |> Enum.drop(1)
    |> Enum.reject(&(String.trim(&1) == ""))
    |> Enum.map(fn line -> line_fun.(line) end)
  end

  def clone_github_repo(repo, dest_path, opts \\ []) do
    fetch_main = Keyword.get(opts, :fetch_main, true)
    commit = Keyword.get(opts, :commit)

    cond do
      !String.contains?(repo, "github.com") ->
        IO.puts("Skipping #{dest_path} - not a github repo")
        :ok

      File.exists?(dest_path) ->
        IO.puts("Skipping #{dest_path} - already exists")
        :ok

      commit ->
        {_, 0} = System.cmd("gh", ~w(repo clone #{repo} #{dest_path}))
        {_, 0} = System.cmd("git", ~w(-C #{dest_path} checkout #{commit}))
        :ok

      :else ->
        latest_release = if fetch_main, do: nil, else: latest_release(repo)

        if latest_release do
          {_, 0} = System.cmd("gh", ~w(repo clone #{repo} #{dest_path} -- --depth 1 --branch #{latest_release}))
        else
          # fallback to main/master
          {_, 0} = System.cmd("gh", ~w(repo clone #{repo} #{dest_path} -- --depth 1))
        end

        :ok
    end
  end

  defp latest_release(repo) do
    {output, status} = System.cmd("gh", ~w(repo view #{repo} --json latestRelease --jq .latestRelease.tagName))
    output = String.trim(output)

    case {output, status} do
      {"", _} -> nil
      {output, 0} -> output
      _ -> nil
    end
  end
end

[{Lang, _}] = Code.require_file("langs.exs")

case System.argv() do
  ["themes"] -> Downloader.Themes.run()
  ["themes", "--force"] -> Downloader.Themes.run(true)
  ["zed"] -> Downloader.Zed.run()
  ["zed", "--force"] -> Downloader.Zed.run(true)
  ["langs"] -> Downloader.Langs.run()
  ["langs", "--force"] -> Downloader.Langs.run(true)
end
