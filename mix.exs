defmodule Autumn.MixProject do
  use Mix.Project

  @source_url "https://github.com/leandrocp/autumn"
  @version "0.1.0-dev"

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
      description:
        "Syntax highlighter for source code using Tree-Sitter parsing and Helix Editor themes."
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
        priv
        mix.exs
        README.md
      ]
    ]
  end

  defp docs do
    [
      main: "Autumn",
      source_ref: "v#{@version}",
      source_url: @source_url,
      extras: ["CHANGELOG.md"]
    ]
  end

  defp deps do
    [
      {:rustler, ">= 0.0.0", optional: true},
      {:rustler_precompiled, "~> 0.6"},
      {:ex_doc, "~> 0.29", only: :dev},
      {:toml, "~> 0.7", runtime: false},
      {:jason, "~> 1.0", runtime: false}
    ]
  end

  defp aliases do
    [
      generate_checksum: "rustler_precompiled.download Autumn.Native --all --print",
      test: [fn _ -> System.put_env("AUTUMN_BUILD", "true") end, "test"],
      "rust.lint": ["cmd cargo clippy --manifest-path=native/autumn/Cargo.toml -- -Dwarnings"],
      "rust.fmt": ["cmd cargo fmt --manifest-path=native/autumn/Cargo.toml --all"]
    ]
  end
end
