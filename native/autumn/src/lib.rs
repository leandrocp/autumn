mod lang;
use tree_sitter_highlight::{Highlighter, HtmlRenderer};

static THEME: &str = include_str!("../../../priv/generated/themes/dracula.toml");

#[rustler::nif]
fn highlight(lang: &str, source: String, _theme: String) -> String {
    // TODO: themes
    let value: toml::Value = toml::from_str(&THEME).unwrap();
    let mut highlighter = Highlighter::new();
    let config = lang::Lang::config(lang);
    let events = highlighter
        .highlight(&config, source.as_bytes(), None, |_| None)
        .unwrap();
    let mut result = String::new();
    let mut renderer = HtmlRenderer::new();

    renderer
        .render(events, source.as_bytes(), &|highlight| {
            let name = lang::HIGHLIGHT_NAMES.get(highlight.0).unwrap();
            let config = value.get(name);

            match config {
                Some(style) => style.as_str().unwrap().as_bytes(),
                None => {
                    // TODO: fallback color
                    let fallback = value.get("keyword");
                    fallback.unwrap().as_str().unwrap().as_bytes()
                }
            }
        })
        .unwrap();

    for line in renderer.lines() {
        result.push_str(line);
    }

    result
}

rustler::init!("Elixir.Autumn.Native", [highlight]);
