mod inline_html;
mod themes;
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
    pre_class: &str,
) -> Result<(Atom, String), Error> {
    let language = match Language::from_token(lang) {
        Some(language) => language,
        None => return Err(Error::Term(Box::new("invalid lang"))),
    };

    let theme = match themes::theme(theme) {
        Some(theme) => theme,
        None => return Err(Error::Term(Box::new("invalid theme"))),
    };

    let mut highlighter = Highlighter::new();
    let inline_html = inline_html::InlineHTML::new(lang, theme, pre_class);

    match highlighter.highlight_to_string(language, &inline_html, source) {
        Ok(rendered) => Ok((ok(), rendered)),
        Err(_err) => Err(Error::Term(Box::new("failed to highlight source code"))),
    }
}

rustler::init!("Elixir.Autumn.Native", [highlight]);
