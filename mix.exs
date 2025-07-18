defmodule Autumn.MixProject do
  use Mix.Project

  @source_url "https://github.com/leandrocp/autumn"
  @version "0.4.2-dev"
  @dev? String.ends_with?(@version, "-dev")
  @force_build? System.get_env("AUTUMN_BUILD") in ["1", "true"]

  def project do
    [
      app: :autumn,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.env() == :prod,
      package: package(),
      docs: docs(),
      deps: deps(),
      aliases: aliases(),
      name: "Autumn",
      homepage_url: "https://autumnus.dev",
      description: "Syntax highlighter powered by Tree-sitter and Neovim themes."
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def cli do
    [
      preferred_envs: [
        docs: :docs,
        "hex.publish": :docs
      ]
    ]
  end

  defp package do
    [
      maintainers: ["Leandro Pereira"],
      licenses: ["MIT"],
      links: %{
        Changelog: "https://hexdocs.pm/autumn/changelog.html",
        GitHub: @source_url,
        Site: "https://autumnus.dev"
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
      {:nimble_options, "~> 1.0"},
      {:ex_doc, ">= 0.0.0", only: :docs},
      {:makeup_elixir, "~> 1.0", only: :docs},
      {:makeup_eex, "~> 2.0", only: :docs},
      {:makeup_syntect, "~> 0.1", only: :docs}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "compile"],
      "gen.checksum": "rustler_precompiled.download Autumn.Native --all --print",
      "format.all": ["rust.fmt", "format"],
      "rust.lint": [
        "cmd cargo clippy --manifest-path=native/autumnus_nif/Cargo.toml -- -Dwarnings"
      ],
      "rust.fmt": ["cmd cargo fmt --manifest-path=native/autumnus_nif/Cargo.toml --all"]
    ]
  end
end
