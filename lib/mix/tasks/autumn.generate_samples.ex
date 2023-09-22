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
    <title>Autumn Sample</title>
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

  @impl true
  def run(_args) do
    elixir()
    rust()
  end

  defp elixir do
    Mix.shell().info("Generating sample HTML for Elixir...")

    source = File.read!(Path.join([File.cwd!(), "lib", "autumn", "theme_generator.ex"]))

    code = Autumn.highlight("elixir", source)
    html = EEx.eval_string(@layout, assigns: %{inner_content: code})
    dest_path = Path.join([:code.priv_dir(:autumn), "generated", "samples", "elixir.html"])
    File.write!(dest_path, html)
  end

  defp rust do
    Mix.shell().info("Generating sample HTML for Rust...")

    source = File.read!(Path.join([File.cwd!(), "native", "autumn", "src", "lib.rs"]))

    code = Autumn.highlight("rust", source)
    html = EEx.eval_string(@layout, assigns: %{inner_content: code})
    dest_path = Path.join([:code.priv_dir(:autumn), "generated", "samples", "rust.html"])
    File.write!(dest_path, html)
  end
end
