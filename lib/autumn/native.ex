defmodule Autumn.Native do
  @moduledoc false

  mix_config = Mix.Project.config()
  version = mix_config[:version]
  github_url = mix_config[:package][:links][:GitHub]
  mode = if Mix.env() in [:dev, :test], do: :debug, else: :release

  use RustlerPrecompiled,
    otp_app: :autumn,
    version: version,
    crate: "autumn",
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
    nif_versions: ["2.15"],
    mode: mode,
    force_build: System.get_env("AUTUMN_BUILD") in ["1", "true"]

  def lang_name(_lang), do: :erlang.nif_error(:nif_not_loaded)
  def parse(_lang, _source), do: :erlang.nif_error(:nif_not_loaded)
  def available_languages, do: :erlang.nif_error(:nif_not_loaded)
  def highlight(_lang, _source, _theme, _formatter, _debug), do: :erlang.nif_error(:nif_not_loaded)
  def stylesheet(_theme), do: :erlang.nif_error(:nif_not_loaded)
end
