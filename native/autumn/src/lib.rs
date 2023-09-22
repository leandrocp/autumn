mod lang;
use tree_sitter_highlight::{Highlighter, HtmlRenderer};

static THEME: &str = include_str!("../../../priv/generated/themes/dracula.toml");

#[rustler::nif]
fn highlight(lang: &str, source: &str, theme: &str) -> String {
    do_highlight(lang, source, theme)
}

fn do_highlight(lang: &str, source: &str, _theme: &str) -> String {
    let mut highlighter = Highlighter::new();
    let lang_config = lang::Lang::config(lang);
    let events = highlighter
        .highlight(&lang_config, source.as_bytes(), None, |_| None)
        .unwrap();
    let mut renderer = HtmlRenderer::new();

    // TODO: themes
    let theme_config: toml::Value = toml::from_str(&THEME).unwrap();

    renderer
        .render(events, source.as_bytes(), &|h| {
            let scope = lang::HIGHLIGHT_NAMES.get(h.0).unwrap();
            let style = style(&theme_config, scope);

            // println!("{:?}", scope);
            // println!("{:?}", std::str::from_utf8(style).unwrap());

            style
        })
        .unwrap();

    String::from(std::str::from_utf8(&renderer.html).unwrap())
}

fn style<'v>(theme_config: &'v toml::Value, scope: &str) -> &'v [u8] {
    match theme_config.get(scope) {
        Some(value) => value.as_str().unwrap().as_bytes(),
        None => {
            if scope.contains(".") {
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

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_highlight() {
        let result = do_highlight("elixir", "@type foo :: :bar", "Dracula");
        assert_eq!(result, "<span class=\"attribute\" style=\"font-style: italic; color: #50fa7b; \">@</span><span class=\"attribute\" style=\"font-style: italic; color: #50fa7b; \">type</span> <span class=\"variable\" style=\"color: #f8f8f2; \">foo</span> <span class=\"operator\" style=\"color: #ff79c6; \">::</span> <span class=\"string special\" style=\"color: #ffb86c; \">:bar</span>\n")
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
