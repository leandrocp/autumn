use std::collections::HashMap;

use autumnus::{languages, themes, FormatterOption, Options};
use rustler::{Encoder, Env, Error, NifMap, NifResult, NifStruct, NifTaggedEnum, Term};

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

#[derive(Debug, NifTaggedEnum)]
pub enum ExFormatterOption<'a> {
    HtmlInline {
        theme: Option<ThemeOrString<'a>>,
        pre_class: Option<&'a str>,
        italic: bool,
        include_highlights: bool,
    },
    HtmlLinked {
        pre_class: Option<&'a str>,
    },
    Terminal {
        theme: Option<ThemeOrString<'a>>,
    },
}

#[derive(Debug, NifTaggedEnum)]
pub enum ThemeOrString<'a> {
    Theme(ExTheme),
    String(&'a str),
}

impl<'a> From<ExFormatterOption<'a>> for FormatterOption<'a> {
    fn from(formatter: ExFormatterOption<'a>) -> Self {
        match formatter {
            ExFormatterOption::HtmlInline {
                theme,
                pre_class,
                italic,
                include_highlights,
            } => {
                let theme = theme.map(|t| match t {
                    ThemeOrString::Theme(theme) => {
                        let theme: themes::Theme = theme.into();
                        let theme = Box::leak(Box::new(theme));
                        &*theme
                    }
                    ThemeOrString::String(name) => themes::get(name).unwrap_or_else(|_| {
                        let theme = Box::leak(Box::new(themes::Theme::default()));
                        &*theme
                    }),
                });

                FormatterOption::HtmlInline {
                    theme,
                    pre_class,
                    italic,
                    include_highlights,
                }
            }
            ExFormatterOption::HtmlLinked { pre_class } => {
                FormatterOption::HtmlLinked { pre_class }
            }
            ExFormatterOption::Terminal { theme } => {
                let theme = theme.map(|t| match t {
                    ThemeOrString::Theme(theme) => {
                        let theme: themes::Theme = theme.into();
                        let theme = Box::leak(Box::new(theme));
                        &*theme
                    }
                    ThemeOrString::String(name) => themes::get(name).unwrap_or_else(|_| {
                        let theme = Box::leak(Box::new(themes::Theme::default()));
                        &*theme
                    }),
                });

                FormatterOption::Terminal { theme }
            }
        }
    }
}

#[derive(Debug, NifStruct)]
#[module = "Autumn.Theme"]
pub struct ExTheme {
    pub name: String,
    pub appearance: String,
    pub highlights: HashMap<String, ExStyle>,
}

impl From<ExTheme> for themes::Theme {
    fn from(theme: ExTheme) -> Self {
        themes::Theme {
            name: theme.name,
            appearance: theme.appearance,
            highlights: theme
                .highlights
                .into_iter()
                .map(|(k, v)| {
                    (
                        k,
                        themes::Style {
                            fg: v.fg,
                            bg: v.bg,
                            underline: v.underline,
                            bold: v.bold,
                            italic: v.italic,
                            strikethrough: v.strikethrough,
                        },
                    )
                })
                .collect(),
        }
    }
}

impl<'a> From<&'a themes::Theme> for ExTheme {
    fn from(theme: &'a themes::Theme) -> Self {
        ExTheme {
            name: theme.name.to_owned(),
            appearance: theme.appearance.to_owned(),
            highlights: theme
                .highlights
                .iter()
                .map(|(k, v)| (k.to_owned(), ExStyle::from(v)))
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
