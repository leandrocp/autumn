defmodule Mix.Tasks.Autumn.GenerateThemes do
  @moduledoc false

  use Mix.Task

  @shortdoc "Extract nvim themes"

  @themes [
    {"folke/tokyonight.nvim", ["tokyonight", "tokyonight-day"]},
    {"olimorris/onedarkpro.nvim", ["onedark", "onelight", "onedark_vivid", "onedark_dark"]},
    {"catppuccin/nvim.git",
     ["catppuccin", "catppuccin-latte", "catppuccin-frappe", "catppuccin-macchiato", "catppuccin-mocha"]},
    {"Mofiqul/dracula.nvim.git", ["dracula", "dracula-soft"]}
  ]

  @impl true
  def run(_args) do
    dest_path = Path.join(:code.priv_dir(:autumn), "themes")
    File.mkdir_p!(dest_path)

    for {repo, colorschemes} <- @themes do
      for colorscheme <- colorschemes do
        Mix.shell().info("Extracting #{colorscheme} from #{repo}")
        script = Path.join(File.cwd!(), "extract_themes.lua")
        args = ~w[--headless -u NONE -l #{script} #{repo} #{colorscheme}]

        case System.cmd("nvim", args, stderr_to_stdout: true) do
          {output, 0} ->
            [_, theme, _] = String.split(output, "==theme==")
            IO.puts(theme)

            name =
              colorscheme
              |> String.replace(" ", "_")
              |> String.replace("-", "_")
              |> String.replace("+", "")

            Path.join(dest_path, name <> ".toml")
            |> File.write!(String.trim(theme))

          {error, _} ->
            raise """
            failed to extract colorscheme #{colorscheme} from repo #{repo}

            Got:

              #{inspect(error)}
            """
        end
      end
    end

    Mix.shell().info("Done.")
  end
end
