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
use tree_sitter::Node;
use tree_sitter_highlight::{HighlightEvent, Highlighter};

mod atoms {
    rustler::atoms! {
        ok,
        error,
    }
}

#[rustler::nif()]
pub fn available_languages(env: Env<'_>) -> Term<'_> {
    langs::langs().encode(env)
}

pub fn download_query(lang: &str, file: &str) -> Option<String> {
    let url = format!("https://raw.githubusercontent.com/zed-industries/zed/refs/heads/main/crates/languages/src/{}/{}", lang, file);
    reqwest::blocking::get(url).ok()?.text().ok()
}

#[derive(Debug, rustler::NifTaggedEnum)]
pub enum FormatterArg {
    HtmlInline { pre_class: Option<String> },
    HtmlLinked { pre_class: Option<String> },
    Terminal,
}

impl Default for FormatterArg {
    fn default() -> Self {
        FormatterArg::HtmlInline { pre_class: None }
    }
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn parse<'a>(env: Env<'a>, lang: &str, source: &str) -> Term<'a> {
    let lang = langs::grammar(lang).expect("invalid lang");
    let mut parser = tree_sitter::Parser::new();
    parser.set_language(&lang).expect("failed to set language");
    let tree = parser.parse(source, None).expect("failed to parse source");
    print_tree(&tree.root_node(), source, 0).encode(env)
}

fn print_tree(node: &Node, source: &str, depth: usize) -> String {
    let mut output = String::new();
    let indent = " ".repeat(depth * 2);
    let start_pos = node.start_position();
    let end_pos = node.end_position();
    let kind = node.kind();

    let display = if node.is_named() {
        let text = node.utf8_text(source.as_bytes()).unwrap_or("");

        let trimmed = if text.len() > 10 {
            format!("{}...", &text[..10])
        } else {
            text.to_string()
        }
        .replace("\n", "");

        format!("{} \"{}\"", kind, trimmed)
    } else {
        kind.to_string()
    };

    output.push_str(&format!(
        "{}{} [{}:{} - {}:{}]\n",
        indent, display, start_pos.row, start_pos.column, end_pos.row, end_pos.column
    ));

    let mut cursor = node.walk();
    for child in node.children(&mut cursor) {
        output.push_str(&print_tree(&child, source, depth + 1));
    }

    output
}

#[rustler::nif()]
pub fn lang_name<'a>(env: Env<'a>, lang: &str) -> Term<'a> {
    langs::lang_name(lang).encode(env)
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
            Some(langs::config(injected))
        })
        .expect("failed to generate highlight events");

    let output = match formatter_arg {
        FormatterArg::HtmlInline { pre_class } => {
            let formatter = HtmlInline::new(lang.to_string(), theme, pre_class, debug);
            format(source, events, &formatter)
        }
        FormatterArg::HtmlLinked { pre_class } => {
            let formatter = HtmlLinked::new(lang.to_string(), pre_class, debug);
            format(source, events, &formatter)
        }
        FormatterArg::Terminal => {
            let formatter = Terminal::new(theme);
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
        let e = event.expect("error formatting");
        formatter.write(source, &mut buffer, e)
    }

    formatter.finish(source, &mut buffer);

    buffer
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn stylesheet(env: Env<'_>, theme: Theme) -> Term<'_> {
    theme.stylesheet().encode(env)
}

rustler::init!("Elixir.Autumn.Native");
