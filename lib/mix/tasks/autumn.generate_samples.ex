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
    <title>Autumn Sample - <%= @lang %></title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:ital,wght@0,300;0,400;0,700;1,300;1,400;1,700&display=swap" rel="stylesheet">
    <style>
      * {
        font-family: 'JetBrains Mono', monospace;
        font-size: 16px;
      }
      body {
        background-color: #282C34;
      }
    </style>
  </head>
  <body>
    <%= @inner_content %>
  </body>
  </html>
  """

  @langs [
    {"elixir", ~c"https://raw.githubusercontent.com/elixir-lang/elixir/main/lib/elixir/lib/kernel.ex"},
    {"rust", ~c"https://raw.githubusercontent.com/tree-sitter/tree-sitter/master/highlight/src/lib.rs"},
    {"ruby", ~c"https://raw.githubusercontent.com/rack/rack/main/lib/rack/request.rb"}
  ]

  @impl true
  def run(_args) do
    :inets.start()
    :ssl.start()

    for {lang, url} <- @langs do
      generate(lang, url)
    end
  end

  defp generate(lang, url) do
    Mix.shell().info("Generating sample HTML for #{lang}...")
    source = download_source(url)
    code = Autumn.highlight(lang, source)
    html = EEx.eval_string(@layout, assigns: %{inner_content: code, lang: lang})
    dest_path = Path.join([:code.priv_dir(:autumn), "generated", "samples", "#{lang}.html"])
    File.write!(dest_path, html)
  end

  defp download_source(url) do
    {:ok, {_, _, body}} = :httpc.request(url)
    to_string(body)
  end
end
