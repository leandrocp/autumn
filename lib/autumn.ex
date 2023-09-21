defmodule Autumn do
  @moduledoc """
  TODO
  """

  alias Autumn.Native

  @langs_path Path.join([:code.priv_dir(:autumn), "generated", "langs.exs"])
  @external_resource @langs_path

  @double_quote ?"
  @gt ?>
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
    language = language(lang_filename_ext)
    theme = Keyword.get(opts, :theme, "OneDark")
    pre_class = Keyword.get(opts, :pre_class, "autumn highlight")
    code_class = Keyword.get(opts, :code_class, "language-#{language}")

    IO.iodata_to_binary([
      "<pre class=",
      @double_quote,
      pre_class,
      @double_quote,
      @gt,
      "<code class=",
      @double_quote,
      code_class,
      @double_quote,
      @gt,
      @eol,
      Native.highlight(language, source, theme),
      "</code></pre>"
    ])
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

    cond do
      String.starts_with?(lang_filename_ext, ".") ->
        find_lang_by_extension(lang_filename_ext)

      String.contains?(lang_filename_ext, ".") ->
        lang_filename_ext |> Path.basename() |> Path.extname() |> find_lang_by_extension

      :else ->
        find_lang_by_name(lang_filename_ext) || find_lang_by_extension(lang_filename_ext)
    end || raise "failed to find a loaded language for #{lang_filename_ext}"
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
end
