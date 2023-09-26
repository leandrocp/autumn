use inkjet::{constants, formatter::Formatter, Result};
use toml::Value;
use tree_sitter_highlight::HighlightEvent;

#[derive(Debug, Clone)]
pub struct InlineHTML<'a> {
    lang: &'a str,
    theme: &'a Value,
}

impl<'a> InlineHTML<'a> {
    pub fn new(lang: &'a str, theme: &'a Value) -> Self {
        Self { lang, theme }
    }
}

impl<'a> Formatter for InlineHTML<'a> {
    fn write<W>(&self, source: &str, w: &mut W, event: HighlightEvent) -> Result<()>
    where
        W: std::fmt::Write,
    {
        match event {
            HighlightEvent::Source { start, end } => {
                let span = source
                    .get(start..end)
                    .expect("Source bounds should be in bounds!");
                let span = v_htmlescape::escape(span).to_string();
                w.write_str(&span)?;
            }
            HighlightEvent::HighlightStart(idx) => {
                let scope = constants::HIGHLIGHT_NAMES[idx.0];
                let attrs = attrs(self.theme, scope);

                w.write_str("<span ")?;
                w.write_str(attrs)?;
                w.write_str(">")?;
            }
            HighlightEvent::HighlightEnd => {
                w.write_str("</span>")?;
            }
        }

        Ok(())
    }

    fn start<W>(&self, _: &str, w: &mut W) -> Result<()>
    where
        W: std::fmt::Write,
    {
        let background_style = self.theme.get("background").unwrap();

        w.write_str("<pre ")?;
        w.write_str(background_style.as_str().unwrap())?;
        w.write_str(">\n")?;
        w.write_str("<code class=\"language-")?;
        w.write_str(self.lang)?;
        w.write_str("\">\n")?;

        Ok(())
    }

    fn finish<W>(&self, _: &str, writer: &mut W) -> Result<()>
    where
        W: std::fmt::Write,
    {
        writeln!(writer, "\n</code></pre>")?;

        Ok(())
    }
}

fn attrs<'a>(theme: &'a toml::Value, scope: &str) -> &'a str {
    match theme.get(scope) {
        Some(value) => value.as_str().unwrap(),
        None => {
            if scope.contains('.') {
                let mut split: Vec<&str> = scope.split('.').collect();
                split.pop();
                attrs(theme, split.join(".").as_str())
            } else {
                theme.get("text").unwrap().as_str().unwrap()
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_empty_attrs_config_if_missing() {
        let config: toml::Value = toml::from_str(
            r#"
            "string" = "color:blue"
            "text" = "color:#000000"
            "#,
        )
        .unwrap();

        let result = attrs(&config, "function.special");
        assert_eq!(result, "color:#000000");
    }

    #[test]
    fn test_match_exact_config_attrs() {
        let config: toml::Value = toml::from_str(
            r#"
            "string" = "color:blue"
            "#,
        )
        .unwrap();

        let result = attrs(&config, "string");
        assert_eq!(result, "color:blue");
    }

    #[test]
    fn test_match_prefix_config_attrs() {
        let config: toml::Value = toml::from_str(
            r#"
            "string" = "color:string"
            "string.special" = "color:special"
            "#,
        )
        .unwrap();

        let result = attrs(&config, "string.special.symbol");
        assert_eq!(result, "color:special");

        let result = attrs(&config, "string.other");
        assert_eq!(result, "color:string");
    }
}
