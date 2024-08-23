#![allow(unused_variables)]
#![allow(unused_imports)]
#![allow(dead_code)]

use std::sync::Arc;

use tree_sitter_highlight::HighlightEvent;

use crate::{constants::HIGHLIGHT_NAMES, theme::Theme};

use super::Formatter;

pub struct HtmlLinked {
    theme: Arc<Theme>,
    pre_class: Option<String>,
    line_numbers: bool,
    debug: bool,
}

impl HtmlLinked {
    pub fn new(theme: Theme, pre_class: Option<String>, line_numbers: bool, debug: bool) -> Self {
        Self {
            theme: Arc::new(theme),
            pre_class,
            line_numbers,
            debug,
        }
    }
}

impl Formatter for HtmlLinked {
    fn start<W>(&self, _: &str, writer: &mut W) -> ()
    where
        W: std::fmt::Write,
    {
        let _ = writeln!(writer, "<code><pre>");
        ()
    }

    fn write<W>(&self, source: &str, writer: &mut W, event: HighlightEvent) -> ()
    where
        W: std::fmt::Write,
    {
        match event {
            HighlightEvent::HighlightStart(idx) => {
                let scope = HIGHLIGHT_NAMES[idx.0];
                // FIXME: class = scope
                let element = format!("<span class=\"TODO\">");
                let _ = writer.write_str(&element);
            }
            HighlightEvent::Source { start, end } => {
                let span = source
                    .get(start..end)
                    .expect("source bounds should be in bounds!");
                let span = v_htmlescape::escape(span).to_string();
                let _ = writer.write_str(&span);
            }
            HighlightEvent::HighlightEnd => {
                let _ = writer.write_str("</span>");
            }
        }
    }

    fn finish<W>(&self, _: &str, writer: &mut W) -> ()
    where
        W: std::fmt::Write,
    {
        let _ = writeln!(writer, "</pre></code>");
        ()
    }
}
