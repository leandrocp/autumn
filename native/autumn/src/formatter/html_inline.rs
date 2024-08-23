#![allow(unused_must_use)]

use super::Formatter;
use crate::constants::HIGHLIGHT_NAMES;
use crate::theme::Theme;
use std::sync::Arc;
use tree_sitter_highlight::HighlightEvent;

pub struct HtmlInline {
    lang: String,
    theme: Arc<Theme>,
    pre_class: Option<String>,
    debug: bool,
}

impl HtmlInline {
    pub fn new(lang: String, theme: Theme, pre_class: Option<String>, debug: bool) -> Self {
        let theme = Arc::new(theme);

        Self {
            lang,
            theme,
            pre_class,
            debug,
        }
    }
}

impl Formatter for HtmlInline {
    fn start<W>(&self, _: &str, writer: &mut W)
    where
        W: std::fmt::Write,
    {
        write!(writer, "<pre class=\"athl");

        if let Some(pre_clas) = &self.pre_class {
            write!(writer, " {}", pre_clas);
        }

        write!(writer, "\" style=\"{}\">", self.theme.pre_style());
        write!(
            writer,
            "<code class=\"language-{}\" translate=\"no\">",
            self.lang
        );
    }

    fn write<W>(&self, source: &str, writer: &mut W, event: HighlightEvent)
    where
        W: std::fmt::Write,
    {
        match event {
            HighlightEvent::HighlightStart(idx) => {
                let scope = HIGHLIGHT_NAMES[idx.0];

                write!(writer, "<span");

                if self.debug {
                    write!(writer, " data-athl-hl=\"{}\"", scope);
                }

                if let Some(syntax) = self.theme.get_syntax(scope) {
                    write!(writer, " style=\"{}\"", syntax.to_css());
                }

                write!(writer, ">");
            }
            HighlightEvent::Source { start, end } => {
                let span = source.get(start..end).expect("failed to get source bounds");
                let span = v_htmlescape::escape(span)
                    .to_string()
                    .replace('{', "&#123")
                    .replace('}', "&#125");
                writer.write_str(&span);
            }
            HighlightEvent::HighlightEnd => {
                writer.write_str("</span>");
            }
        }
    }

    fn finish<W>(&self, _: &str, writer: &mut W)
    where
        W: std::fmt::Write,
    {
        writer.write_str("</code></pre>");
    }
}
