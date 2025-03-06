use std::collections::HashMap;

use autumnus::{languages, themes};
use rustler::{Atom, Error, NifResult, NifStruct};

rustler::atoms! {
    ok,
    error,
}

rustler::init!("Elixir.Autumn.Native");

#[derive(Debug, NifStruct)]
#[module = "Autumn.Theme"]
pub struct ExTheme {
    pub name: String,
    pub appearance: String,
    pub highlights: HashMap<String, ExStyle>,
}

impl<'a> From<&'a themes::Theme> for ExTheme {
    fn from(theme: &'a themes::Theme) -> Self {
        ExTheme {
            name: theme.name.to_owned(),
            appearance: theme.appearance.to_owned(),
            highlights: theme
                .highlights
                .iter()
                .map(|(k, v)| (k.to_owned(), v.into()))
                .collect(),
        }
    }
}

#[derive(Debug, NifStruct)]
#[module = "Autumn.Theme.Style"]
pub struct ExStyle {
    pub fg: Option<String>,
    pub bg: Option<String>,
    pub underline: bool,
    pub bold: bool,
    pub italic: bool,
    pub strikethrough: bool,
}

impl<'a> From<&'a themes::Style> for ExStyle {
    fn from(style: &'a themes::Style) -> Self {
        ExStyle {
            fg: style.fg.clone(),
            bg: style.bg.clone(),
            underline: style.underline,
            bold: style.bold,
            italic: style.italic,
            strikethrough: style.strikethrough,
        }
    }
}

#[rustler::nif]
fn highlight(
    lang: &str,
    source: &str,
    theme: &str,
    pre_class: Option<&str>,
    inline_style: bool,
) -> Result<(Atom, String), Error> {
    Ok((ok(), "todo".to_string()))
}

#[rustler::nif]
fn available_languages() -> HashMap<String, (String, Vec<String>)> {
    languages::available_languages()
}

#[rustler::nif]
fn available_themes() -> Vec<String> {
    themes::available_themes()
        .into_iter()
        .map(|theme| theme.name.to_owned())
        .collect()
}

#[rustler::nif]
fn fetch_theme(name: &str) -> NifResult<(Atom, ExTheme)> {
    themes::get(name)
        .map(|theme| (ok(), ExTheme::from(theme)))
        .map_err(|e| Error::Term(Box::new(e.to_string())))
}
