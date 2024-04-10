defmodule Mix.Tasks.Autumn.GenerateSamples do
  use Mix.Task

  @shortdoc "Generate samples."

  @layout_index ~S"""
  <!DOCTYPE html>
  <html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Autumn Samples</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:ital,wght@0,300;0,400;0,700;1,300;1,400;1,700&display=swap" rel="stylesheet">
    <style>
      * {
        font-family: 'JetBrains Mono', monospace;
        line-height: 1.5;
      }
      body {
        padding: 50px;
      }
    </style>
  </head>
  <body>
    <p>
      <a href="https://github.com/leandrocp/autumn">
        <img src="https://raw.githubusercontent.com/leandrocp/autumn/main/assets/images/autumn_logo.png" width="512" alt="Autumn logo">
      </a>
    </p>
    <p><a href="https://github.com/leandrocp/autumn">https://github.com/leandrocp/autumn</a></p>
    <%= @inner_content %>
  </body>
  </html>
  """

  @layout_inline ~S"""
  <!DOCTYPE html>
  <html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Autumn Sample - <%= @lang %> - <%= @theme  %> (inline)</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:ital,wght@0,300;0,400;0,700;1,300;1,400;1,700&display=swap" rel="stylesheet">
    <style>
      * {
        font-family: 'JetBrains Mono', monospace;
        line-height: 1.5;
      }
      pre {
        font-size: 15px;
        margin: 20px;
        padding: 50px;
        border-radius: 10px;
      }
    </style>
  </head>
  <body>
    <%= @inner_content %>
  </body>
  </html>
  """

  @layout_css ~S"""
  <!DOCTYPE html>
  <html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Autumn Sample - <%= @lang %> - <%= @theme  %> (inline)</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:ital,wght@0,300;0,400;0,700;1,300;1,400;1,700&display=swap" rel="stylesheet">
    <style>
      * {
        font-family: 'JetBrains Mono', monospace;
        line-height: 1.5;
      }
      pre {
        font-size: 15px;
        margin: 20px;
        padding: 50px;
        border-radius: 10px;
      }
    </style>
    <style>
    <%= @theme_style %>
    </style>
  </head>
  <body>
    <%= @inner_content %>
  </body>
  </html>
  """

  @catppuccin_frappe ~S"""
  <style>
    * {
      color: #c6d0f5;
    }
    body {
      background-color: #303446;
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
      ~c"https://raw.githubusercontent.com/elixir-lang/elixir/main/lib/elixir/lib/enum.ex"
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
    },
    {
      "lua",
      ~c"https://raw.githubusercontent.com/folke/lazy.nvim/main/lua/lazy/init.lua"
    }
  ]

  @themes [
    {"catppuccin_frappe", @catppuccin_frappe},
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
      do_generage_inline(lang, source, theme, style)
      do_generage_css(lang, source, theme, style)
    end
  end

  defp do_generage_inline(lang, source, theme, style) do
    Mix.shell().info("#{lang} - #{theme} (inline)")

    code = Autumn.highlight!(source, language: lang, theme: theme, inline_style: true)

    html =
      EEx.eval_string(@layout_inline,
        assigns: %{style: style, inner_content: code, lang: lang, theme: theme}
      )

    dest_path =
      Path.join([:code.priv_dir(:autumn), "generated", "samples", "#{lang}_#{theme}_inline.html"])

    File.write!(dest_path, html)
  end

  defp do_generage_css(lang, source, theme, style) do
    Mix.shell().info("#{lang} - #{theme}")

    code = Autumn.highlight!(source, language: lang, theme: theme, inline_style: false)

    theme_style =
      File.read!(Path.join([:code.priv_dir(:autumn), "static", "css", "#{theme}.css"]))

    html =
      EEx.eval_string(@layout_css,
        assigns: %{
          style: style,
          inner_content: code,
          lang: lang,
          theme: theme,
          theme_style: theme_style
        }
      )

    dest_path =
      Path.join([:code.priv_dir(:autumn), "generated", "samples", "#{lang}_#{theme}.html"])

    File.write!(dest_path, html)
  end

  defp generate_index do
    Mix.shell().info("index.html")

    inline_samples =
      for {lang, _url} <- @langs, {theme, _style} <- @themes do
        sample = "#{String.capitalize(lang)} - #{theme} (inline)"
        {sample, "#{lang}_#{theme}_inline.html"}
      end

    css_samples =
      for {lang, _url} <- @langs, {theme, _style} <- @themes do
        sample = "#{String.capitalize(lang)} - #{theme}"
        {sample, "#{lang}_#{theme}.html"}
      end

    samples = Enum.sort(inline_samples ++ css_samples)

    links =
      Enum.map(samples, fn {sample, link} ->
        ["<p><a href=", ?", link, ?", ">", sample, "</a></p>", "\n"]
      end)

    inner_content = [
      "<h1>Samples</h1>",
      "\n",
      links
    ]

    html = EEx.eval_string(@layout_index, assigns: %{inner_content: inner_content})

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
  #     EEx.eval_string(@layout, assigns: %{inner_content: code, lang: "debug", theme: "catppuccin_frappe"})
  #
  #   dest_path = Path.join([:code.priv_dir(:autumn), "generated", "samples", "debug.html"])
  #   File.write!(dest_path, html)
  # end

  defp download_source(url) do
    {:ok, {_, _, body}} = :httpc.request(url)
    to_string(body)
  end
end
