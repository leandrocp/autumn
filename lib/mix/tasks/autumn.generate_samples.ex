defmodule Mix.Tasks.Autumn.GenerateSamples do
  use Mix.Task

  @shortdoc "Generate samples."

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
        line-height: 24px;
      }
      pre {
        margin: 20px;
      }
    </style>
    <%= @style %>
  </head>
  <body>
    <%= if @index do %>
      <img src="https://raw.githubusercontent.com/leandrocp/autumn/main/assets/images/autumn.png" width="512" alt="Autumn logo">
    <% end %>
    <%= @inner_content %>
  </body>
  </html>
  """

  @onedark_style ~S"""
  <style>
    * {
      color: #ABB2BF;
    }
    body {
      background-color: #282C34;
    }
  </style>
  """

  @github_light_style ~S"""
  <style>
    * {
    }
    body {
      background-color: #ffffff;
    }
  </style>
  """

  @langs [
    {
      "elixir",
      ~c"https://raw.githubusercontent.com/elixir-lang/elixir/main/lib/elixir/lib/list.ex"
    },
    {
      "rust",
      ~c"https://raw.githubusercontent.com/tree-sitter/tree-sitter/master/highlight/src/lib.rs"
    },
    {
      "ruby",
      ~c"https://raw.githubusercontent.com/rack/rack/main/lib/rack/request.rb"
    },
    {
      "swift",
      ~c"https://raw.githubusercontent.com/apple/swift/main/test/Parse/async.swift"
    },
    {
      "php",
      ~c"https://raw.githubusercontent.com/php/php-src/master/pear/fetch.php"
    },
    {
      "javascript",
      ~c"https://raw.githubusercontent.com/phoenixframework/phoenix_live_view/main/assets/js/phoenix_live_view/view.js"
    },
    {
      "css",
      ~c"https://raw.githubusercontent.com/phoenixframework/phoenix/main/installer/templates/phx_static/home.css"
    },
    {
      "html",
      ~c"https://raw.githubusercontent.com/h5bp/html5-boilerplate/main/src/index.html"
    }
  ]

  @themes [
    {"onedark", @onedark_style},
    {"github_light", @github_light_style}
  ]

  @impl true
  def run(_args) do
    :inets.start()
    :ssl.start()

    # debug()

    for {lang, url} <- @langs do
      generate(lang, url)
    end

    generate_index()
  end

  defp generate(lang, url) do
    source = download_source(url)

    for {theme, style} <- @themes do
      do_generage(lang, source, theme, style)
    end
  end

  defp do_generage(lang, source, theme, style) do
    Mix.shell().info("#{lang} - #{theme}")

    code = Autumn.highlight!(lang, source, theme: theme)

    html =
      EEx.eval_string(@layout,
        assigns: %{style: style, inner_content: code, lang: lang, theme: theme}
      )

    dest_path =
      Path.join([:code.priv_dir(:autumn), "generated", "samples", "#{lang}_#{theme}.html"])

    File.write!(dest_path, html)
  end

  defp generate_index do
    Mix.shell().info("index.html")

    samples =
      for {lang, _url} <- @langs, {theme, _style} <- @themes do
        sample = "#{String.capitalize(lang)} - #{theme}"
        {sample, "#{lang}_#{theme}.html"}
      end

    links =
      Enum.map(samples, fn {sample, link} ->
        ["<p><a href=", ?", link, ?", ">", sample, "</a></p>", "\n"]
      end)

    inner_content = [
      "<h1>Samples</h1>",
      "\n",
      links
    ]

    html =
      EEx.eval_string(@layout,
        assigns: %{inner_content: inner_content, index: true}
      )

    dest_path =
      Path.join([:code.priv_dir(:autumn), "generated", "samples", "index.html"])

    File.write!(dest_path, html)
  end

  # defp debug() do
  #   lang = "elixir"
  #   source_path = Path.join([File.cwd!(), "lib", "autumn.ex"])
  #   source = File.read!(source_path)
  #
  #   code = Autumn.highlight!(lang, source)
  #
  #   html =
  #     EEx.eval_string(@layout, assigns: %{inner_content: code, lang: "debug", theme: "onedark"})
  #
  #   dest_path = Path.join([:code.priv_dir(:autumn), "generated", "samples", "debug.html"])
  #   File.write!(dest_path, html)
  # end

  defp download_source(url) do
    {:ok, {_, _, body}} = :httpc.request(url)
    to_string(body)
  end
end
