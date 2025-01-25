defmodule Autumn.MixProject do
  use Mix.Project

  @source_url "https://github.com/leandrocp/autumn"
  @version "0.3.0-dev"
  @dev? String.ends_with?(@version, "-dev")
  @force_build? System.get_env("AUTUMN_BUILD") in ["1", "true"]

  def project do
    [
      app: :autumn,
      version: @version,
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.env() == :prod,
      package: package(),
      docs: docs(),
      deps: deps(),
      aliases: aliases(),
      name: "Autumn",
      homepage_url: "https://github.com/leandrocp/autumn",
      description: "Syntax highlighter based on Tree-sitter and Zed themes."
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
        lib
        native
        priv/static/css
        checksum-*.exs
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
    [
      {:rustler, "~> 0.29", optional: not (@dev? or @force_build?)},
      {:rustler_precompiled, "~> 0.6"},
      {:jason, "~> 1.0"},
      {:ex_doc, "~> 0.34", only: :dev}
    ]
  end

  defp aliases do
    [
      setup: [
        "deps.get",
        "download.themes",
        "download.zed",
        "download.langs"
      ],
      "download.themes": ["cmd elixir downloader.exs themes"],
      "download.zed": ["cmd elixir downloader.exs zed"],
      "download.langs": ["cmd elixir downloader.exs langs"],
      "gen.langs.rs": ["cmd elixir gen.langs.rs.exs", "format.all", "compile"],
      "gen.stylesheets": ["autumn.gen.stylesheets"],
      "gen.samples": ["cmd elixir gen.samples.exs"],
      "gen.checksum": "rustler_precompiled.download Autumn.Native --all --print",
      "format.all": ["rust.fmt", "format"],
      "rust.fmt": ["cmd cargo fmt --manifest-path=native/autumn/Cargo.toml --all"],
      "rust.lint": ["cmd cargo clippy --manifest-path=native/autumn/Cargo.toml -- -Dwarnings"],
      "rust.lint.fix": ["cmd cargo clippy --manifest-path=native/autumn/Cargo.toml --fix"]
    ]
  end
end
