defmodule Autumn do
  @moduledoc """
  TODO
  """

  alias Autumn.Native

  @langs_path Path.join([:code.priv_dir(:autumn), "generated", "langs.exs"])
  @external_resource @langs_path

  @themes_path Path.join([:code.priv_dir(:autumn), "generated", "themes"])
  @external_resource @themes_path

  @double_quote ?"
  @gt ?>
  @space " "
  @eol "\n"

  @doc """
  TODO

  ## Examples

      iex> Autumn.highlight("elixir", ":elixir")
      "<span style=\"color: #ff79c6\">:elixir</span>\n"

  ## Options

      TODO

  """
  def highlight(lang_filename_ext, source, opts \\ []) do
    theme_name = Keyword.get(opts, :theme, "onedark")
    pre_class = Keyword.get(opts, :pre_class, "autumn highlight")

    with {:ok, lang} <- language(lang_filename_ext),
         {:ok, theme} <- theme(theme_name) do
      background_style = theme["background"]
      code_class = Keyword.get(opts, :code_class, "language-#{lang}")

      case Native.highlight(lang, source, theme_name) do
        {:ok, highlighted} ->
          {:ok,
           IO.iodata_to_binary([
             "<pre class=",
             @double_quote,
             pre_class,
             @double_quote,
             @space,
             background_style,
             @gt,
             @eol,
             "<code class=",
             @double_quote,
             code_class,
             @double_quote,
             @gt,
             @eol,
             highlighted,
             "</code></pre>"
           ])}

        error ->
          error
      end
    end
  end

  def highlight!(lang_filename_ext, source, opts \\ []) do
    case highlight(lang_filename_ext, source, opts) do
      {:ok, highlighted} ->
        highlighted

      {:error, error} ->
        raise """
        failed to highlight source code for #{lang_filename_ext}

        Got:

          #{inspect(error)}

        """
    end
  end

  def langs do
    {langs, []} = Code.eval_file(@langs_path)
    langs
  end

  @doc false
  def language(lang_filename_ext) do
    lang_filename_ext =
      lang_filename_ext
      |> String.downcase()
      |> Path.basename()

    lang =
      cond do
        String.starts_with?(lang_filename_ext, ".") ->
          find_lang_by_extension(lang_filename_ext)

        String.contains?(lang_filename_ext, ".") ->
          lang_filename_ext |> Path.basename() |> Path.extname() |> find_lang_by_extension

        :else ->
          find_lang_by_name(lang_filename_ext) || find_lang_by_extension(lang_filename_ext)
      end

    if lang, do: {:ok, lang}, else: {:error, "invalid lang"}
  end

  defp find_lang_by_name(name) do
    if Map.has_key?(langs(), name), do: name, else: nil
  end

  defp find_lang_by_extension(<<"."::binary, ext::binary>>) do
    find_lang_by_extension(ext)
  end

  defp find_lang_by_extension(ext) do
    Enum.find_value(langs(), nil, fn {name, exts} ->
      if ext in exts, do: name, else: nil
    end)
  end

  defp theme(name) do
    @themes_path
    |> Path.join("#{name}.toml")
    |> Toml.decode_file()
  end
end
