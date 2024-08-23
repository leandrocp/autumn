#![allow(unused_variables)]
#![allow(unused_imports)]
#![allow(dead_code)]

use std::io::Write;
use std::{cell::RefCell, sync::Arc};

use termcolor::ColorSpec;
use termcolor::WriteColor;
use tree_sitter_highlight::HighlightEvent;

use crate::color::Rgba;
use crate::constants::HIGHLIGHT_NAMES;
use crate::theme::Theme;

use super::Formatter;

// TODO: bg color?
pub struct Terminal {
    theme: Arc<Theme>,
    buffer: RefCell<termcolor::Buffer>,
    debug: bool,
}

impl Terminal {
    pub fn new(theme: Theme, debug: bool) -> Self {
        let theme = Arc::new(theme);

        Self {
            theme,
            buffer: RefCell::new(termcolor::Buffer::ansi()),
            debug,
        }
    }
}

impl From<Rgba> for termcolor::Color {
    fn from(rgba: Rgba) -> Self {
        termcolor::Color::Rgb(
            (rgba.r * 255.0) as u8,
            (rgba.g * 255.0) as u8,
            (rgba.b * 255.0) as u8,
        )
    }
}

impl Formatter for Terminal {
    fn write<W>(&self, source: &str, _writer: &mut W, event: HighlightEvent) -> ()
    where
        W: std::fmt::Write,
    {
        match event {
            HighlightEvent::HighlightStart(idx) => {
                let scope = HIGHLIGHT_NAMES[idx.0];

                self.theme.get_syntax(scope).and_then(|syntax| {
                    syntax.color.map(|color| {
                        let rgba: Rgba = color.into();
                        let rgb: termcolor::Color = rgba.into();

                        let _ = self
                            .buffer
                            .borrow_mut()
                            .set_color(ColorSpec::new().set_fg(Some(rgb)));
                    })
                });
            }
            HighlightEvent::Source { start, end } => {
                let text = source
                    .get(start..end)
                    .expect("source bounds should be in bounds!");

                let _ = self.buffer.borrow_mut().write_all(text.as_bytes());
            }
            HighlightEvent::HighlightEnd => {
                let _ = self.buffer.borrow_mut().reset();
            }
        }
    }

    fn finish<W>(&self, _: &str, writer: &mut W) -> ()
    where
        W: std::fmt::Write,
    {
        let output = String::from_utf8(self.buffer.borrow_mut().clone().into_inner()).unwrap();
        let _ = writer.write_str(output.as_str());
    }
}
