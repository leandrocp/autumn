Mix.install([:toml, :mdex, {:autumn, path: "."}])

defmodule Autumn.Gen.Samples do
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

  @layout_linked ~S"""
  <!DOCTYPE html>
  <html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Autumn Sample - <%= @lang %> - <%= @theme  %> (linked)</title>
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
    <link href="../../static/css/<%= @theme_css %>" rel="stylesheet" />
  </head>
  <body>
    <%= @inner_content %>
  </body>
  </html>
  """

  @themes [
    "Dracula",
    "Github Dark",
    "Github Light"
  ]

  def run do
    File.mkdir_p(Path.join(["priv", "generated", "samples"]))

    langs =
      Enum.filter(Lang.all(), fn lang ->
        is_binary(lang.name) && is_tuple(lang.example_src)
      end)

    for lang <- langs do
      IO.puts(lang.name)
      generate(lang.name, lang.example_src)
    end

    generate_index(langs)
  end

  defp generate(lang, example_src) do
    source =
      case download_source(example_src) do
        nil -> :skip
        source -> source
      end

    for theme <- @themes do
      do_generage_inline(lang, source, theme)
      do_generage_linked(lang, source, theme)
    end
  end

  defp do_generage_inline(lang, source, theme) do
    Mix.shell().info("#{lang} - #{theme} (inline)")

    code = Autumn.highlight!(source, language: lang, theme: theme, formatter: :html_inline, debug: true)

    html =
      EEx.eval_string(@layout_inline,
        assigns: %{inner_content: code, lang: lang, theme: theme}
      )

    dest_path =
      Path.join([:code.priv_dir(:autumn), "generated", "samples", "#{lang}_#{clean(theme)}_inline.html"])

    File.write!(dest_path, html)
  end

  defp do_generage_linked(lang, source, theme) do
    Mix.shell().info("#{lang} - #{theme} (linked)")

    code = Autumn.highlight!(source, language: lang, theme: theme, formatter: :html_linked, debug: true)

    html =
      EEx.eval_string(@layout_linked,
        assigns: %{
          inner_content: code,
          lang: lang,
          theme: theme,
          theme_css: "#{clean(theme)}.css"
        }
      )

    dest_path =
      Path.join([:code.priv_dir(:autumn), "generated", "samples", "#{lang}_#{clean(theme)}_linked.html"])

    File.write!(dest_path, html)
  end

  defp generate_index(langs) do
    Mix.shell().info("index.html")

    inline_samples =
      for lang <- langs, theme <- @themes do
        sample = "#{String.capitalize(lang.name)} - #{theme} (inline)"
        {sample, "#{lang.name}_#{clean(theme)}_inline.html"}
      end

    linked_samples =
      for lang <- langs, theme <- @themes do
        sample = "#{String.capitalize(lang.name)} - #{theme} (linked)"
        {sample, "#{lang.name}_#{clean(theme)}_linked.html"}
      end

    samples = Enum.sort(inline_samples ++ linked_samples)

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

  defp clean(string) do
    string
    |> String.replace(" ", "_")
    |> String.downcase()
  end

  defp download_source({url, code_block_lang}) do
    :inets.start()
    :ssl.start()

    with {:ok, {_, _, body}} = :httpc.request(url),
         body = to_string(body),
         {:ok, doc} <- MDEx.parse_document(body) do
      doc
      |> Enum.filter(fn
        %{info: ^code_block_lang} -> true
        _ -> false
      end)
      |> Enum.map(& &1.literal)
      |> Enum.join("\n")
    else
      _ -> nil
    end
  end

  defp download_source(_), do: nil
end

[{Lang, _}] = Code.require_file("langs.exs")
Autumn.Gen.Samples.run()
