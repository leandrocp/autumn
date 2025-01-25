#![allow(unused_must_use)]

use super::Formatter;
use crate::constants::HIGHLIGHT_NAMES;
use tree_sitter_highlight::HighlightEvent;

pub struct HtmlLinked {
    lang: String,
    pre_class: Option<String>,
    debug: bool,
}

impl HtmlLinked {
    pub fn new(lang: String, pre_class: Option<String>, debug: bool) -> Self {
        Self {
            lang,
            pre_class,
            debug,
        }
    }
}

impl Formatter for HtmlLinked {
    fn start<W>(&self, _: &str, writer: &mut W)
    where
        W: std::fmt::Write,
    {
        write!(writer, "<pre class=\"athl\"");

        if let Some(pre_clas) = &self.pre_class {
            write!(writer, " {}", pre_clas);
        }

        write!(
            writer,
            "><code class=\"language-{}\" translate=\"no\">",
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

                let parts: Vec<&str> = scope.split('.').collect();
                let mut class = Vec::new();

                for i in 0..parts.len() {
                    class.push(format!("athl-{}", parts[..=i].join("-")));
                }

                write!(writer, "<span");

                if self.debug {
                    write!(writer, " data-athl-hl=\"{}\"", scope);
                }

                write!(writer, " class=\"{}\">", class.join(" "));
            }
            HighlightEvent::Source { start, end } => {
                let span = source.get(start..end).expect("failed to get source bounds");
                let span = v_htmlescape::escape(span)
                    .to_string()
                    .replace('{', "&lbrace;")
                    .replace('}', "&rbrace;");
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
