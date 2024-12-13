# https://github.com/elixir-explorer/explorer/blob/d11216282bbdb0dcaef2519c2bfefda46c2981e0/lib/explorer/polars_backend/native.ex

defmodule Autumn.Native do
  @moduledoc false

  mix_config = Mix.Project.config()
  version = mix_config[:version]
  github_url = mix_config[:package][:links][:GitHub]
  mode = if Mix.env() in [:dev, :test], do: :debug, else: :release

  use_legacy =
    Application.compile_env(
      :autumn,
      :use_legacy_artifacts,
      System.get_env("AUTUMN_USE_LEGACY_ARTIFACTS") in ["true", "1"]
    )

  variants_for_linux = [
    legacy_cpu: fn ->
      # These are the same from the release workflow.
      # See the meaning in: https://unix.stackexchange.com/a/43540
      needed_caps = ~w[fxsr sse sse2 ssse3 sse4_1 sse4_2 popcnt avx fma]

      use_legacy or
        (is_nil(use_legacy) and
           not Autumn.ComptimeUtils.cpu_with_all_caps?(needed_caps))
    end
  ]

  other_variants = [legacy_cpu: fn -> use_legacy end]

  use RustlerPrecompiled,
    otp_app: :autumn,
    crate: "inkjet_nif",
    version: version,
    base_url: "#{github_url}/releases/download/v#{version}",
    targets: ~w(
      aarch64-apple-darwin
      aarch64-unknown-linux-gnu
      aarch64-unknown-linux-musl
      x86_64-apple-darwin
      x86_64-pc-windows-msvc
      x86_64-pc-windows-gnu
      x86_64-unknown-linux-gnu
      x86_64-unknown-linux-musl
      x86_64-unknown-freebsd
    ),
    variants: %{
      "x86_64-unknown-linux-gnu" => variants_for_linux,
      "x86_64-pc-windows-msvc" => other_variants,
      "x86_64-pc-windows-gnu" => other_variants,
      "x86_64-unknown-freebsd" => other_variants
    },
    # We don't use any features of newer NIF versions, so 2.15 is enough.
    nif_versions: ["2.15"],
    mode: mode,
    force_build: System.get_env("AUTUMN_BUILD") in ["1", "true"]

  def highlight(_lang, _source, _theme, _pre_class, _inline_style),
    do: :erlang.nif_error(:nif_not_loaded)
end
