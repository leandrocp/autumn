defmodule Autumn.MixProject do
  use Mix.Project

  @source_url "https://github.com/leandrocp/autumn"
  @version "0.3.0-dev"
  @dev? String.ends_with?(@version, "-dev")
  @force_build? System.get_env("AUTUMN_BUILD") in ["1", "true"]

  @zed_version "v0.154.3"

  @langs [
    {"bash", "tree-sitter/tree-sitter-bash", "152c934b24cd7b3290e77cd6c9d80401f23fc915"},
    {"elixir", "elixir-lang/tree-sitter-elixir", "a2861e88a730287a60c11ea9299c033c7d076e30"},
    {"diff", "the-mikedavis/tree-sitter-diff", "19dd5aa52fe339a1d974768a09ee2537303e8ca5"},
    {"lua", "tree-sitter-grammars/tree-sitter-lua", "a24dab177e58c9c6832f96b9a73102a0cfbced4a"},
    {"ruby", "tree-sitter/tree-sitter-ruby", "7dbc1e2d0e2d752577655881f73b4573f3fe85d4"},
    {"rust", "tree-sitter/tree-sitter-rust", "6b7d1fc73ded57f73b1619bcf4371618212208b1"}
  ]

  @themes [
    {"catppuccin", "catppuccin/zed"},
    {"dracula", "dracula/zed"},
    {"github", "PyaeSoneAungRgn/github-zed-theme"},
    {"zed", "zed-industries/zed", "assets/themes"}
  ]

  def project do
    [
      app: :autumn,
      version: @version,
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.env() == :prod,
      package: package(),
      docs: docs(),
      deps: deps(),
      aliases: aliases(),
      name: "Autumn",
      homepage_url: "https://github.com/leandrocp/autumn",
      description: "Tree-sitter powered syntax highlighter for source code. Supports 50+ languages and 100+ themes."
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      maintainers: ["Leandro Pereira"],
      licenses: ["MIT"],
      links: %{
        Changelog: "https://hexdocs.pm/autumn/changelog.html",
        GitHub: @source_url
      },
      files: ~w[
        lib/autumn.ex
        lib/autumn
        native/inkjet_nif/src
        native/inkjet_nif/Cargo.*
        native/autumn/src
        native/autumn/Cargo.*
        priv/static/css
        Cargo.*
        Cross.toml
        .cargo
        checksum-Elixir.Autumn.Native.exs
        mix.exs
        README.md
        LICENSE.md
        CHANGELOG.md
      ]
    ]
  end

  defp docs do
    [
      main: "Autumn",
      assets: "assets/images",
      logo: "assets/images/autumn_icon.png",
      source_ref: "v#{@version}",
      source_url: @source_url,
      extras: ["CHANGELOG.md"],
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"]
    ]
  end

  defp deps do
    grammars = Enum.map(@langs, &grammar_dep(&1))

    # reuse Zed queries as much as possible, license permitting
    queries =
      [
        {:zed_extensions,
         github: "zed-industries/zed", tag: @zed_version, depth: 1, sparse: "extensions", app: false, compile: false}
      ] ++ Enum.map(@langs, &queries_dep(&1))

    themes = Enum.map(@themes, &theme_dep(&1))

    [
      {:rustler, "~> 0.29", optional: not (@dev? or @force_build?)},
      {:rustler_precompiled, "~> 0.6"},
      {:jason, "~> 1.0"},
      {:ex_doc, "~> 0.34", only: :dev},
      {:toml, "~> 0.7", runtime: false}
    ] ++ grammars ++ queries ++ themes
  end

  defp grammar_dep({lang, github, ref}) do
    name = String.to_atom("grammar_#{lang}")
    {name, github: github, ref: ref, sparse: "src", app: false, compile: false}
  end

  defp queries_dep({lang, github, ref}) do
    name = String.to_atom("queries_#{lang}")
    {name, github: github, ref: ref, sparse: "queries", app: false, compile: false}
  end

  # must start with `theme_` prefix
  defp theme_dep({name, github}) do
    {String.to_atom("theme_#{name}"), github: github, depth: 1, sparse: "themes", app: false, compile: false}
  end

  defp theme_dep({name, github, sparse}) do
    {String.to_atom("theme_#{name}"), github: github, depth: 1, sparse: sparse, app: false, compile: false}
  end

  defp aliases do
    [
      generate_checksum: "rustler_precompiled.download Autumn.Native --all --print",
      "format.all": ["rust.fmt", "format"],
      "rust.lint": ["cmd cargo clippy --manifest-path=native/autumn/Cargo.toml -- -Dwarnings"],
      "rust.fmt": ["cmd cargo fmt --manifest-path=native/autumn/Cargo.toml --all"],
      "generate.all": ["autumn.generate_css", "autumn.generate_themes_rs", "format.all", "autumn.generate_samples"]
    ]
  end
end
