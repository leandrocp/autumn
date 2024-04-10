use crate::themes::Theme;
use inkjet::{formatter::Formatter, Language, Result};
use tree_sitter_highlight::HighlightEvent;

#[derive(Debug)]
pub struct InlineHTML<'a> {
    lang: Language,
    theme: &'a Theme,
    pre_class: Option<&'a str>,
    inline_style: bool,
}

impl<'a> InlineHTML<'a> {
    pub fn new(
        lang: Language,
        theme: &'a Theme,
        pre_class: Option<&'a str>,
        inline_style: bool,
    ) -> Self {
        Self {
            lang,
            theme,
            pre_class,
            inline_style,
        }
    }
}

impl<'a> Formatter for InlineHTML<'a> {
    fn write<Write>(&self, source: &str, output: &mut Write, event: HighlightEvent) -> Result<()>
    where
        Write: std::fmt::Write,
    {
        let highlighted = autumn::inner_highlights(source, event, self.theme, self.inline_style);
        write!(output, "{}", highlighted)?;
        Ok(())
    }

    fn start<Write>(&self, _: &str, output: &mut Write) -> Result<()>
    where
        Write: std::fmt::Write,
    {
        let open_tags = autumn::open_tags(self.lang, self.theme, self.pre_class, self.inline_style);
        write!(output, "{}", open_tags)?;
        Ok(())
    }

    fn finish<Write>(&self, _: &str, output: &mut Write) -> Result<()>
    where
        Write: std::fmt::Write,
    {
        let close_tags = autumn::close_tags();
        write!(output, "{}", close_tags)?;
        Ok(())
    }
}
