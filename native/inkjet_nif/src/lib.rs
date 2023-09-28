mod inline_html;
mod themes;
use inkjet::{Highlighter, Language};
use rustler::{Atom, Error};
use themes::Theme;

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
    let theme = match themes::theme(theme) {
        Some(theme) => theme,
        None => return Err(Error::Term(Box::new("invalid theme"))),
    };

    match Language::from_token(lang) {
        Some(lang_config) => do_highlight(lang, lang_config, source, theme, pre_class),
        None => do_highlight_plain(source, theme, pre_class),
    }
}

fn do_highlight(
    lang_name: &str,
    lang_config: Language,
    source: &str,
    theme: &Theme,
    pre_class: &str,
) -> Result<(Atom, String), Error> {
    let mut highlighter = Highlighter::new();
    let inline_html = inline_html::InlineHTML::new(lang_name, theme, pre_class);

    match highlighter.highlight_to_string(lang_config, &inline_html, source) {
        Ok(rendered) => Ok((ok(), rendered)),
        Err(_err) => Err(Error::Term(Box::new("failed to highlight source code"))),
    }
}

fn do_highlight_plain(
    source: &str,
    theme: &Theme,
    pre_class: &str,
) -> Result<(Atom, String), Error> {
    let mut highlighter = Highlighter::new();
    let inline_html = inline_html::InlineHTML::new("plain", theme, pre_class);

    // pass any small grammar because it's required but the highlight events are ignored
    match highlighter.highlight_to_string(Language::Diff, &inline_html, source) {
        Ok(rendered) => Ok((ok(), rendered)),
        Err(_err) => Err(Error::Term(Box::new("failed to highlight source code"))),
    }
}

rustler::init!("Elixir.Autumn.Native", [highlight]);
