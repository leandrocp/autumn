// https://github.com/Colonial-Dev/inkjet/blob/da289fa8b68f11dffad176e4b8fabae8d6ac376d/src/formatter/terminal.rs

#![allow(unused_must_use)]

use super::Formatter;
use crate::constants::HIGHLIGHT_NAMES;
use crate::theme::Theme;
use std::io::Write;
use std::{cell::RefCell, sync::Arc};
use termcolor::ColorSpec;
use termcolor::WriteColor;
use tree_sitter_highlight::HighlightEvent;

pub struct Terminal {
    theme: Arc<Theme>,
    buffer: RefCell<termcolor::Buffer>,
}

impl Terminal {
    pub fn new(theme: Theme) -> Self {
        let theme = Arc::new(theme);

        Self {
            theme,
            buffer: RefCell::new(termcolor::Buffer::ansi()),
        }
    }
}

impl Formatter for Terminal {
    fn write<W>(&self, source: &str, _writer: &mut W, event: HighlightEvent)
    where
        W: std::fmt::Write,
    {
        match event {
            HighlightEvent::HighlightStart(idx) => {
                let scope = HIGHLIGHT_NAMES[idx.0];

                let hex: &str = self
                    .theme
                    .get_syntax(scope)
                    .and_then(|style| style.color.as_deref())
                    // not completely blank so it's still visible in light terminals
                    .unwrap_or("#eeeeee")
                    .trim_start_matches('#');

                let r = u8::from_str_radix(&hex[0..2], 16).unwrap();
                let g = u8::from_str_radix(&hex[2..4], 16).unwrap();
                let b = u8::from_str_radix(&hex[4..6], 16).unwrap();

                self.buffer
                    .borrow_mut()
                    .set_color(ColorSpec::new().set_fg(Some(termcolor::Color::Rgb(r, g, b))));
            }
            HighlightEvent::Source { start, end } => {
                let text = source.get(start..end).expect("failed to get source bounds");
                self.buffer.borrow_mut().write_all(text.as_bytes());
            }
            HighlightEvent::HighlightEnd => {
                self.buffer.borrow_mut().reset();
            }
        }
    }

    fn finish<W>(&self, _: &str, writer: &mut W)
    where
        W: std::fmt::Write,
    {
        let output = String::from_utf8(self.buffer.borrow_mut().clone().into_inner()).unwrap();
        let _ = writer.write_str(output.as_str());
    }
}
