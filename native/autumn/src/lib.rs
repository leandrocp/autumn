pub mod color;
pub mod constants;
pub mod formatter;
pub mod langs;
pub mod theme;

use crate::formatter::Formatter;
use crate::formatter::HtmlInline;
use crate::formatter::HtmlLinked;
use crate::formatter::Terminal;
use crate::theme::Theme;

use atoms::ok;
use rustler::{Encoder, Env, NifResult, Term};
use tree_sitter_highlight::{HighlightEvent, Highlighter};

mod atoms {
    rustler::atoms! {
        ok,
        error,
    }
}

#[rustler::nif()]
pub fn available_languages<'a>(env: Env<'a>) -> Term<'a> {
    langs::langs().encode(env)
}

#[derive(Debug, rustler::NifTaggedEnum)]
pub enum FormatterArg {
    HtmlInline {
        pre_class: Option<String>,
        line_numbers: bool,
    },
    HtmlLinked {
        pre_class: Option<String>,
        line_numbers: bool,
    },
    Terminal,
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn highlight<'a>(
    env: Env<'a>,
    lang: &str,
    source: &str,
    theme: Theme,
    formatter_arg: FormatterArg,
    debug: bool,
) -> NifResult<Term<'a>> {
    let config = langs::config(lang);

    let mut highlighter = Highlighter::new();

    let events = highlighter
        .highlight(config, source.as_bytes(), None, |injected| {
            Some(&langs::config(injected))
        })
        .expect("failed to generate highlight events");

    let output = match formatter_arg {
        FormatterArg::HtmlInline {
            pre_class,
            line_numbers,
        } => {
            let formatter =
                HtmlInline::new(lang.to_string(), theme, pre_class, line_numbers, debug);
            format(source, events, &formatter)
        }
        FormatterArg::HtmlLinked {
            pre_class,
            line_numbers,
        } => {
            let formatter = HtmlLinked::new(theme, pre_class, line_numbers, debug);
            format(source, events, &formatter)
        }
        FormatterArg::Terminal => {
            let formatter = Terminal::new(theme, debug);
            format(source, events, &formatter)
        }
    };

    Ok((ok(), output).encode(env))
}

fn format<F>(
    source: &str,
    events: impl Iterator<Item = Result<HighlightEvent, tree_sitter_highlight::Error>>,
    formatter: &F,
) -> String
where
    F: Formatter,
{
    let mut buffer = String::new();

    formatter.start(source, &mut buffer);

    for event in events {
        let e = event.expect("TODO");
        formatter.write(source, &mut buffer, e)
    }

    formatter.finish(source, &mut buffer);

    buffer.into()
}

#[cfg(test)]
mod tests {
    // use super::*;

    // #[test]
    // fn test_events() {
    //     let html = highlight_html("elixir", "@foo :bar");

    //     assert_eq!(html, "here".to_string());
    // }

    // #[test]
    // fn test_single_line_single_highlight() {
    //     let ast = generate_ast("elixir", ":foo");
    //     assert_eq!(
    //         ast,
    //         vec![vec![(":foo".to_string(), "string.special.symbol")]]
    //     );
    // }

    // #[test]
    // fn test_whitespaces() {
    //     let ast = generate_ast("elixir", "a =     :foo \n   @bar 1");
    //     assert_eq!(
    //         ast,
    //         vec![
    //             vec![
    //                 ("a".to_string(), "variable"),
    //                 (" ".to_string(), ""),
    //                 ("=".to_string(), "operator"),
    //                 ("     ".to_string(), ""),
    //                 (":foo".to_string(), "string.special.symbol"),
    //                 (" ".to_string(), ""),
    //             ],
    //             vec![
    //                 ("   ".to_string(), ""),
    //                 ("@".to_string(), "attribute"),
    //                 ("bar".to_string(), "attribute"),
    //                 (" ".to_string(), ""),
    //                 ("1".to_string(), "number"),
    //             ]
    //         ]
    //     );
    // }

    // #[test]
    // fn test_multline() {
    //     let source = "defmodule Foo do\n  @bar 1\nend";
    //     let ast = generate_ast("elixir", source);

    //     assert_eq!(
    //         ast,
    //         vec![
    //             vec![
    //                 ("defmodule".to_string(), "keyword"),
    //                 (" ".to_string(), ""),
    //                 ("Foo".to_string(), "module"),
    //                 (" ".to_string(), ""),
    //                 ("do".to_string(), "keyword")
    //             ],
    //             vec![
    //                 ("  ".to_string(), ""),
    //                 ("@".to_string(), "attribute"),
    //                 ("bar".to_string(), "attribute"),
    //                 (" ".to_string(), ""),
    //                 ("1".to_string(), "number")
    //             ],
    //             vec![("end".to_string(), "keyword")]
    //         ]
    //     );
    // }
}

rustler::init!("Elixir.Autumn.Native", [available_languages, highlight]);
