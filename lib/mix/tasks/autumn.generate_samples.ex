defmodule Mix.Tasks.Autumn.GenerateSamples do
  use Mix.Task

  @shortdoc "Parse and generate langs module"

  @layout ~S"""
  <!DOCTYPE html>
  <html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Autumn Sample - <%= @lang %> - <%= @theme %></title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:ital,wght@0,300;0,400;0,700;1,300;1,400;1,700&display=swap" rel="stylesheet">
    <style>
      * {
        font-family: 'JetBrains Mono', monospace;
        font-size: 14px;
      }
    </style>
  </head>
  <body>
    <%= @inner_content %>
  </body>
  </html>
  """

  @langs [
    {"elixir",
     ~c"https://raw.githubusercontent.com/elixir-lang/elixir/main/lib/elixir/lib/list.ex",
     "onedark"},
    {"elixir",
     ~c"https://raw.githubusercontent.com/elixir-lang/elixir/main/lib/elixir/lib/list.ex",
     "github_light"},
    {"rust",
     ~c"https://raw.githubusercontent.com/tree-sitter/tree-sitter/master/highlight/src/lib.rs",
     "catppuccin_macchiato"},
    {"ruby", ~c"https://raw.githubusercontent.com/rack/rack/main/lib/rack/request.rb",
     "base16_default_dark"}
  ]

  @impl true
  def run(_args) do
    :inets.start()
    :ssl.start()

    debug()

    for {lang, url, theme} <- @langs do
      generate(lang, url, theme)
    end
  end

  defp generate(lang, url, theme) do
    Mix.shell().info("Generating sample HTML for #{lang} using theme #{theme}")
    source = download_source(url)
    code = Autumn.highlight!(lang, source, theme: theme)
    html = EEx.eval_string(@layout, assigns: %{inner_content: code, lang: lang, theme: theme})

    dest_path =
      Path.join([:code.priv_dir(:autumn), "generated", "samples", "#{lang}_#{theme}.html"])

    File.write!(dest_path, html)
  end

  defp debug() do
    lang = "elixir"
    source_path = Path.join([File.cwd!(), "lib", "autumn.ex"])
    source = File.read!(source_path)

    # source = ~S"""
    # import Kernel, except: [def: 1]
    # """

    code = Autumn.highlight!(lang, source)

    html =
      EEx.eval_string(@layout, assigns: %{inner_content: code, lang: "debug", theme: "onedark"})

    dest_path = Path.join([:code.priv_dir(:autumn), "generated", "samples", "debug.html"])
    File.write!(dest_path, html)
  end

  defp download_source(url) do
    {:ok, {_, _, body}} = :httpc.request(url)
    to_string(body)
  end
end
