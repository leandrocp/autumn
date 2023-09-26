defmodule Autumn.Native do
  @moduledoc false

  mix_config = Mix.Project.config()
  version = mix_config[:version]
  github_url = mix_config[:package][:links][:GitHub]
  mode = if Mix.env() in [:dev, :test], do: :debug, else: :release

  use RustlerPrecompiled,
    otp_app: :autumn,
    crate: "inkjet_nif",
    base_url: "#{github_url}/releases/download/v#{version}",
    version: version,
    nif_versions: ["2.15"],
    mode: mode,
    force_build: System.get_env("AUTUMN_BUILD") in ["1", "true"]

  def highlight(_lang, _source, _theme), do: :erlang.nif_error(:nif_not_loaded)
end
