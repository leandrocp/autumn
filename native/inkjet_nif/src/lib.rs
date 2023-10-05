mod inline_html;
use autumn::themes;
use inkjet::{Highlighter, Language};
use rustler::{Atom, Error};

rustler::atoms! {
    ok,
    error,
}

#[rustler::nif]
fn highlight(
    lang: &str,
    source: &str,
    theme: &str,
    pre_class: Option<&str>,
    code_class: Option<&str>,
) -> Result<(Atom, String), Error> {
    let theme = match themes::theme(theme) {
        Some(theme) => theme,
        None => return Err(Error::Term(Box::new("invalid theme"))),
    };

    let (lang, code_class) = match Language::from_token(lang) {
        Some(lang) => (lang, code_class),
        None => (Language::Diff, Some("language-plain-text")),
    };

    let mut highlighter = Highlighter::new();
    let inline_html = inline_html::InlineHTML::new(lang, theme, pre_class, code_class);

    match highlighter.highlight_to_string(lang, &inline_html, source) {
        Ok(rendered) => Ok((ok(), rendered)),
        Err(_err) => Err(Error::Term(Box::new("failed to highlight source code"))),
    }
}

rustler::init!("Elixir.Autumn.Native", [highlight]);
