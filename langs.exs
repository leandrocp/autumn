defmodule Lang do
  defstruct name: nil,
            filetypes: [],
            parser_repo: nil,
            parser_name: nil,
            zed_ext_repo: nil,
            extension_name: nil,
            extension_grammar_name: nil,
            highlights_src: nil,
            injections_src: nil,
            locals_src: nil,
            config_name: nil,
            test_name: nil,
            tree_sitter_fun: nil,
            example_src: nil,
            generate: false

  defp langs do
    [
      %Lang{
        name: "markdown",
        filetypes: ~w(md),
        parser_repo: "https://github.com/tree-sitter-grammars/tree-sitter-markdown",
        example_src:
          {"https://raw.githubusercontent.com/adambard/learnxinyminutes-docs/refs/heads/master/markdown.md", "md"}
      },
      %Lang{
        name: "markdown_inline",
        filetypes: ~w(),
        parser_repo: "https://github.com/tree-sitter-grammars/tree-sitter-markdown",
        example_src: :skip
      },
      %Lang{
        name: "erlang",
        filetypes: ~w(erl hrl app.src app escript rebar.config)
      },
      %Lang{
        name: "scala",
        filetypes: ~w(scala sbt),
        zed_ext_repo: "https://github.com/scalameta/metals-zed"
      },
      %Lang{
        name: "elisp",
        filetypes: ~w(elisp el),
        zed_ext_repo: "https://github.com/JosephTLyons/zed-elisp"
      },
      %Lang{
        name: "make",
        filetypes: ~w(Makefile GNUmakefile mk mak dsp),
        zed_ext_repo: "https://github.com/caius/zed-make"
      },
      %Lang{
        name: "llvm",
        filetypes: ~w(llvm ll),
        parser_repo: "https://github.com/benwilliamgraham/tree-sitter-llvm",
        example_src: :skip
      },
      %Lang{
        name: "dockerfile",
        filetypes: ~w( dockerfile docker containerfile container),
        zed_ext_repo: "https://github.com/d1y/dockerfile.zed",
        example_src:
          {"https://raw.githubusercontent.com/adambard/learnxinyminutes-docs/refs/heads/master/docker.md", "dockerfile"}
      },
      %Lang{
        name: "bash",
        filetypes: ~w(.bash_profile .bashrc ebuild eclass sh),
        zed_ext_repo: "https://github.com/d1y/bash.zed"
      },
      %Lang{
        name: "c",
        filetypes: ~w(c),
        parser_repo: "https://github.com/tree-sitter/tree-sitter-c"
      },
      %Lang{
        name: "csharp",
        filetypes: ~w(c_sharp cs),
        extension_grammar_name: "c_sharp",
        tree_sitter_fun: "tree_sitter_c_sharp",
        example_src:
          {"https://raw.githubusercontent.com/adambard/learnxinyminutes-docs/refs/heads/master/csharp.md", "c#"}
      },
      %Lang{
        name: "clojure",
        filetypes: ~w(bb clj cljc cljs clojure),
        zed_ext_repo: "https://github.com/zed-extensions/clojure"
      },
      %Lang{
        name: "cpp",
        filetypes: ~w(c++ cc cpp cxx h hpp hxx),
        parser_repo: "https://github.com/tree-sitter/tree-sitter-cpp",
        example_src:
          {"https://raw.githubusercontent.com/adambard/learnxinyminutes-docs/refs/heads/master/c%2B%2B.md", "c++"}
      },
      %Lang{
        name: "css",
        filetypes: ~w(css),
        parser_repo: "https://github.com/tree-sitter/tree-sitter-css"
      },
      %Lang{
        name: "diff",
        filetypes: ~w(diff),
        parser_repo: "https://github.com/the-mikedavis/tree-sitter-diff",
        example_src: :skip
      },
      %Lang{
        name: "elixir",
        filetypes: ~w(ex exs),
        parser_repo: {"https://github.com/elixir-lang/tree-sitter-elixir", "02a6f7fd4be28dd94ee4dd2ca19cb777053ea74e"}
      },
      %Lang{
        name: "html",
        filetypes: ~w(html)
      },
      %Lang{
        name: "lua",
        filetypes: ~w(lua)
      },
      %Lang{
        name: "plaintext",
        parser_repo: "https://github.com/the-mikedavis/tree-sitter-diff",
        filetypes: ~w(plain text txt),
        tree_sitter_fun: "tree_sitter_diff",
        example_src: :skip
      },
      %Lang{
        name: "ruby",
        filetypes: ~w(rb),
        zed_ext_repo: "https://github.com/zed-extensions/ruby"
      },
      %Lang{
        name: "rust",
        filetypes: ~w(rs),
        parser_repo: "https://github.com/tree-sitter/tree-sitter-rust"
      },
      %Lang{
        name: "javascript",
        filetypes: ~w(js mjs cjs),
        parser_repo: "https://github.com/tree-sitter/tree-sitter-javascript",
        highlights_src: "highlights.scm",
        injections_src: "injections.scm",
        locals_src: "locals.scm",
        example_src:
          {"https://raw.githubusercontent.com/adambard/learnxinyminutes-docs/refs/heads/master/javascript.md", "js"}
      },
      %Lang{
        name: "jsx",
        filetypes: ~w(jsx),
        parser_repo: "https://github.com/tree-sitter/tree-sitter-javascript",
        tree_sitter_fun: "tree_sitter_javascript",
        highlights_src: "highlights-jsx.scm",
        injections_src: :skip,
        locals_src: :skip,
        example_src: :skip
      },
      %Lang{
        name: "jsdoc",
        filetypes: ~w(),
        parser_repo: "https://github.com/tree-sitter/tree-sitter-jsdoc",
        example_src: :skip
      },
      %Lang{
        name: "ember",
        filetypes: ~w(hbs handlebars html.handlebars glimmer),
        zed_ext_repo: "https://github.com/jylamont/zed-ember",
        extension_grammar_name: "glimmer",
        tree_sitter_fun: "tree_sitter_glimmer",
        example_src: :skip
      },
      %Lang{
        name: "eex",
        filetypes: ~w(eex),
        parser_repo: "https://github.com/connorlay/tree-sitter-eex",
        example_src: :skip
      },
      %Lang{
        name: "iex",
        filetypes: ~w(iex),
        parser_repo: "https://github.com/elixir-lang/tree-sitter-iex",
        example_src: :skip
      },
      %Lang{
        name: "elm",
        filetypes: ~w(elm),
        zed_ext_repo: "https://github.com/zed-extensions/elm",
        example_src:
          {"https://raw.githubusercontent.com/adambard/learnxinyminutes-docs/refs/heads/master/elm.md", "haskell"}
      },
      %Lang{
        name: "gleam",
        filetypes: ~w(gleam),
        zed_ext_repo: "https://github.com/gleam-lang/zed-gleam",
        example_src: {"https://raw.githubusercontent.com/adambard/learnxinyminutes-docs/refs/heads/master/gleam.md", ""}
      },
      %Lang{
        name: "heex",
        filetypes: ~w(heex neex),
        extension_name: "elixir",
        extension_grammar_name: "heex",
        example_src: :skip
      },
      %Lang{
        name: "go",
        filetypes: ~w(go),
        parser_repo: "https://github.com/tree-sitter/tree-sitter-go"
      },
      %Lang{
        name: "haskell",
        filetypes: ~w(hs hs-boot)
      },
      %Lang{
        name: "java",
        filetypes: ~w(java),
        zed_ext_repo: "https://github.com/zed-extensions/java"
      },
      %Lang{
        name: "kotlin",
        filetypes: ~w(kt kts),
        zed_ext_repo: "https://github.com/zed-extensions/kotlin"
      },
      %Lang{
        name: "objc",
        filetypes: ~w(m objc),
        parser_repo: "https://github.com/tree-sitter-grammars/tree-sitter-objc",
        example_src:
          {"https://raw.githubusercontent.com/adambard/learnxinyminutes-docs/refs/heads/master/objective-c.md",
           "objective-c"}
      },
      %Lang{
        name: "proto",
        filetypes: ~w(ml),
        example_src:
          {"https://raw.githubusercontent.com/adambard/learnxinyminutes-docs/refs/heads/master/protocol-buffer-3.md",
           "protobuf"}
      },
      %Lang{
        name: "python",
        filetypes: ~w(py),
        parser_repo: "https://github.com/tree-sitter/tree-sitter-python"
      },
      %Lang{
        name: "r",
        filetypes: ~w(r),
        zed_ext_repo: "https://github.com/ocsmit/zed-r"
      },
      %Lang{
        name: "regex",
        filetypes: ~w(),
        parser_repo: "https://github.com/tree-sitter/tree-sitter-regex",
        example_src: :skip
      },
      %Lang{
        name: "terraform",
        filetypes: ~w(hcl tf tfvars),
        extension_grammar_name: "hcl",
        tree_sitter_fun: "tree_sitter_hcl",
        example_src:
          {"https://raw.githubusercontent.com/adambard/learnxinyminutes-docs/refs/heads/master/hcl.md", "terraform"}
      },
      %Lang{
        name: "json",
        filetypes: ~w(json),
        parser_repo: "https://github.com/tree-sitter/tree-sitter-json"
      },
      %Lang{
        name: "svelte",
        filetypes: ~w(svelte),
        zed_ext_repo: "https://github.com/zed-extensions/svelte",
        example_src: :skip
      },
      %Lang{
        name: "toml",
        filetypes: ~w(toml)
      },
      %Lang{
        name: "yaml",
        filetypes: ~w(yaml),
        parser_repo: "https://github.com/zed-industries/tree-sitter-yaml"
      },
      %Lang{
        name: "zig",
        filetypes: ~w(zig)
      },
      %Lang{
        name: "php",
        filetypes: ~w(php)
      },
      %Lang{
        name: "swift",
        filetypes: ~w(swift),
        zed_ext_repo: "https://github.com/zed-extensions/swift",
        generate: true
      },
      %Lang{
        name: "sql",
        filetypes: ~w(sql),
        zed_ext_repo: "https://github.com/zed-extensions/sql"
      },
      %Lang{
        name: "vimscript",
        filetypes: ~w(vim viml),
        parser_repo: "https://github.com/tree-sitter-grammars/tree-sitter-vim",
        tree_sitter_fun: "tree_sitter_vim",
        example_src:
          {"https://raw.githubusercontent.com/adambard/learnxinyminutes-docs/refs/heads/master/vimscript.md", "vim"}
      },
      %Lang{
        name: "typescript",
        filetypes: ~w(ts),
        parser_repo: "https://github.com/tree-sitter/tree-sitter-typescript",
        tree_sitter_fun: "tree_sitter_tsx",
        example_src:
          {"https://raw.githubusercontent.com/adambard/learnxinyminutes-docs/refs/heads/master/typescript.md", "ts"}
      }
    ]
  end

  def all do
    langs()
    |> Enum.map(fn lang ->
      lang = %{
        lang
        | extension_name: lang.extension_name || lang.name,
          extension_grammar_name: lang.extension_grammar_name || lang.name,
          tree_sitter_fun: lang.tree_sitter_fun || String.replace("tree_sitter_#{lang.name}", "-", "_"),
          config_name: "#{lang.name}_CONFIG" |> String.replace("-", "_") |> String.upcase(),
          test_name: String.replace("test_#{lang.name}", "-", "_")
      }

      parser_repo = lang.parser_repo || parser_repo(lang)

      %{
        lang
        | parser_repo: parser_repo,
          parser_name: parser_name(parser_repo),
          highlights_src: lang.highlights_src || query_src(lang, "highlights.scm"),
          injections_src: lang.injections_src || query_src(lang, "injections.scm"),
          locals_src: lang.locals_src || query_src(lang, "locals.scm"),
          example_src: example_src(lang)
      }
    end)
    |> Enum.sort_by(& &1.name)
  end

  def tmp_path, do: Path.expand("tmp", __DIR__)

  defp extension(lang) do
    zed_core_extension_toml_path = Path.join([tmp_path(), "zed", "extensions", lang.extension_name, "extension.toml"])
    external_extension_toml_path = Path.join([tmp_path(), "zed_ext", lang.extension_name, "extension.toml"])

    cond do
      File.exists?(zed_core_extension_toml_path) -> {:ok, zed_core_extension_toml_path}
      File.exists?(external_extension_toml_path) -> {:ok, external_extension_toml_path}
      :else -> :error
    end
    |> case do
      {:ok, path} ->
        path
        |> File.read!()
        |> Toml.decode()

      _ ->
        :error
    end
  end

  defp parser_repo(lang) do
    with {:ok, extension} <- extension(lang),
         %{"repository" => parser_repo} = grammar <- get_in(extension, ["grammars", lang.extension_grammar_name]) do
      if parser_repo do
        ref = grammar["commit"] || grammar["rev"] || grammar["ref"]
        if ref, do: {parser_repo, ref}, else: parser_repo
      else
        nil
      end
    else
      _ ->
        if is_binary(lang.parser_repo) do
          lang.parser_repo
        else
          nil
        end
    end
  end

  defp parser_name({parser_repo, _}) when is_binary(parser_repo) do
    parser_name(parser_repo)
  end

  defp parser_name(parser_repo) when is_binary(parser_repo) do
    parser_repo |> String.split("/") |> List.last()
  end

  defp parser_name(_), do: nil

  # souces - (highlights, injections, locals)
  # :zed_core -> download from zed repo at runtime
  # file -> include_str!(file) from zed/extensions or parser
  defp query_src(lang, file) do
    cond do
      File.exists?(Path.join([tmp_path(), "zed", "crates", "languages", "src", lang.name, file])) -> :zed_core
      File.exists?(Path.join([tmp_path(), "langs", lang.name, "queries", file])) -> file
      :else -> :not_found
    end
  end

  defp example_src(lang) do
    cond do
      is_tuple(lang.example_src) ->
        lang.example_src

      is_nil(lang.example_src) ->
        {"https://raw.githubusercontent.com/adambard/learnxinyminutes-docs/refs/heads/master/#{lang.name}.md",
         lang.name}

      :else ->
        :skip
    end
  end
end
