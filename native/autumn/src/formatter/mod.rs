// Formatter based on https://github.com/Colonial-Dev/inkjet/tree/da289fa8b68f11dffad176e4b8fabae8d6ac376d/src/formatter

mod html_inline;
pub use html_inline::*;

mod html_linked;
pub use html_linked::*;

mod terminal;
pub use terminal::*;

use tree_sitter_highlight::HighlightEvent;

#[allow(unused_variables)]
pub trait Formatter {
    #[inline]
    fn start<W>(&self, source: &str, writer: &mut W) -> ()
    where
        W: std::fmt::Write,
    {
        ()
    }

    fn write<W>(&self, source: &str, writer: &mut W, event: HighlightEvent) -> ()
    where
        W: std::fmt::Write;

    #[inline]
    fn finish<W>(&self, source: &str, writer: &mut W) -> ()
    where
        W: std::fmt::Write,
    {
        ()
    }
}
