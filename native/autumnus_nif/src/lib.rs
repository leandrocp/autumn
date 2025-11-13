use std::collections::HashMap;

use autumnus::elixir::{ExFormatterOption, ExTheme};
use autumnus::{languages, themes, FormatterOption, Options};
use rustler::{Encoder, Env, Error, NifMap, NifResult, Term};

rustler::atoms! {
    ok,
    error,
}

rustler::init!("Elixir.Autumn.Native");

#[derive(Debug, NifMap)]
pub struct ExOptions<'a> {
    pub language: Option<&'a str>,
    pub formatter: ExFormatterOption<'a>,
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn highlight<'a>(env: Env<'a>, source: &'a str, options: ExOptions) -> NifResult<Term<'a>> {
    let formatter: FormatterOption = options.formatter.into();

    let options = Options {
        lang_or_file: options.language,
        formatter,
    };

    let output = autumnus::highlight(source, options);

    Ok((ok(), output).encode(env))
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
fn get_theme(name: &str) -> NifResult<ExTheme> {
    themes::get(name)
        .map(ExTheme::from)
        .map_err(|_e| Error::Atom("error"))
}

#[rustler::nif]
fn build_theme_from_file(path: &str) -> NifResult<ExTheme> {
    themes::from_file(path)
        .map(|theme| ExTheme::from(&theme))
        .map_err(|_e| Error::Atom("error"))
}

#[rustler::nif]
fn build_theme_from_json_string(json_string: &str) -> NifResult<ExTheme> {
    themes::from_json(json_string)
        .map(|theme| ExTheme::from(&theme))
        .map_err(|_e| Error::Atom("error"))
}

#[cfg(test)]
mod tests {
    use autumnus::Options;

    #[test]
    fn test_highlight_works() {
        let source = "@test :test";

        let result = autumnus::highlight(source, Options::default());

        assert!(!result.is_empty(), "Output should not be empty");

        assert!(
            result.contains("<pre"),
            "Output should contain opening <pre> tag"
        );

        assert!(result.contains("<code"), "Output should contain <code> tag");

        assert!(
            result.contains("test"),
            "Output should contain 'defmodule' keyword"
        );
    }
}
