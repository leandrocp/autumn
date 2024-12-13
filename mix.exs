defmodule Autumn.MixProject do
  use Mix.Project

  @source_url "https://github.com/leandrocp/autumn"
  @version "0.2.4-dev"
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
      description:
        "Syntax highlighter for source code parsed with Tree-Sitter and styled with Helix Editor themes."
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
    [
      {:rustler, "~> 0.29", optional: not (@dev? or @force_build?)},
      {:rustler_precompiled, "~> 0.6"},
      {:ex_doc, "~> 0.34", only: :dev},
      {:toml, "~> 0.7", runtime: false}
    ]
  end

  defp aliases do
    [
      generate_checksum: "rustler_precompiled.download Autumn.Native --all --print",
      "format.all": ["rust.fmt", "format"],
      "rust.lint": ["cmd cargo clippy --manifest-path=native/inkjet_nif/Cargo.toml -- -Dwarnings"],
      "rust.fmt": ["cmd cargo fmt --manifest-path=native/inkjet_nif/Cargo.toml --all"]
    ]
  end
end
