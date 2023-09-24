mod langs;
mod themes;
use langs::{Lang, HIGHLIGHT_NAMES};
use rustler::{Atom, Error};
use tree_sitter::Parser;
use tree_sitter_highlight::{Highlighter, HtmlRenderer};

rustler::atoms! {
    ok,
    error,
}

#[rustler::nif]
fn highlight(lang: &str, source: &str, theme: &str) -> Result<(Atom, String), Error> {
    let lang = match Lang::new(lang) {
        Some(lang) => lang,
        None => return Err(Error::Atom("invalid lang")),
    };

    let theme = match themes::theme(theme) {
        Some(theme) => theme,
        None => return Err(Error::Atom("invalid theme")),
    };

    let mut highlighter = Highlighter::new();
    let events = highlighter
        .highlight(lang.highlight_config, source.as_bytes(), None, |_| None)
        .unwrap();

    let mut renderer = HtmlRenderer::new();

    renderer
        .render(events, source.as_bytes(), &|h| {
            let scope = HIGHLIGHT_NAMES.get(h.0).unwrap();
            let style = style(theme, scope);

            // println!("{:?}", scope);
            // println!("{:?}", std::str::from_utf8(style).unwrap());

            style
        })
        .unwrap();

    let rendered = String::from(std::str::from_utf8(&renderer.html).unwrap());

    Ok((ok(), rendered))
}

fn style<'v>(theme_config: &'v toml::Value, scope: &str) -> &'v [u8] {
    match theme_config.get(scope) {
        Some(value) => value.as_str().unwrap().as_bytes(),
        None => {
            if scope.contains('.') {
                let mut split: Vec<&str> = scope.split('.').collect();
                split.pop();
                style(theme_config, split.join(".").as_str())
            } else {
                theme_config
                    .get("text")
                    .unwrap()
                    .as_str()
                    .unwrap()
                    .as_bytes()
            }
        }
    }
}

#[allow(dead_code)]
fn parse(lang: &str, source: &str) -> String {
    let lang = Lang::new(lang).expect("invalid lang");
    let mut parser = Parser::new();
    parser.set_language(lang.grammar).unwrap();
    parser.parse(source, None).unwrap().root_node().to_sexp()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse() {
        let tree = parse(
            "elixir",
            r#"
            defmodule Foo do
            end
            "#,
        );

        println!("{:?}", tree);
    }

    #[test]
    fn test_empty_style_config_if_missing() {
        let config: toml::Value = toml::from_str(
            r#"
            "string" = "color:blue"
            "text" = "color:#000000"
            "#,
        )
        .unwrap();

        let result = std::str::from_utf8(style(&config, "function.special")).unwrap();
        assert_eq!(result, "color:#000000");
    }

    #[test]
    fn test_match_exact_config_style() {
        let config: toml::Value = toml::from_str(
            r#"
            "string" = "color:blue"
            "#,
        )
        .unwrap();

        let result = std::str::from_utf8(style(&config, "string")).unwrap();
        assert_eq!(result, "color:blue");
    }

    #[test]
    fn test_match_prefix_config_style() {
        let config: toml::Value = toml::from_str(
            r#"
            "string" = "color:string"
            "string.special" = "color:special"
            "#,
        )
        .unwrap();

        let result = std::str::from_utf8(style(&config, "string.special.symbol")).unwrap();
        assert_eq!(result, "color:special");

        let result = std::str::from_utf8(style(&config, "string.other")).unwrap();
        assert_eq!(result, "color:string");
    }
}

rustler::init!("Elixir.Autumn.Native", [highlight]);
