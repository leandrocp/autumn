use std::collections::HashMap;

use autumnus::{languages, themes, FormatterOption, Options};
use rustler::{Encoder, Env, Error, NifResult, NifStruct, NifTaggedEnum, Term};

rustler::atoms! {
    ok,
    error,
}

rustler::init!("Elixir.Autumn.Native");

#[derive(Debug, NifStruct)]
#[module = "Autumn.Options"]
pub struct ExOptions {
    pub lang_or_file: Option<String>,
    pub theme: ExTheme,
    pub formatter: ExFormatterOption,
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

#[derive(Debug, NifTaggedEnum)]
pub enum ExFormatterOption {
    HtmlInline {
        pre_class: Option<String>,
        italic: bool,
        include_highlight: bool,
    },
    HtmlLinked {
        pre_class: Option<String>,
        italic: bool,
        include_highlight: bool,
    },
    Terminal {
        italic: bool,
    },
}

impl From<ExFormatterOption> for FormatterOption {
    fn from(formatter: ExFormatterOption) -> Self {
        match formatter {
            ExFormatterOption::HtmlInline {
                pre_class,
                italic,
                include_highlight,
            } => FormatterOption::HtmlInline {
                pre_class,
                italic,
                include_highlight,
            },
            ExFormatterOption::HtmlLinked {
                pre_class,
                italic,
                include_highlight,
            } => FormatterOption::HtmlLinked {
                pre_class,
                italic,
                include_highlight,
            },
            ExFormatterOption::Terminal { italic } => FormatterOption::Terminal { italic },
        }
    }
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn highlight<'a>(env: Env<'a>, source: &'a str, options: ExOptions) -> NifResult<Term<'a>> {
    let theme: themes::Theme = options.theme.into();
    let formatter: FormatterOption = options.formatter.into();
    let options = Options {
        lang_or_file: options.lang_or_file.as_deref(),
        theme: &theme,
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
        .map(|theme| ExTheme::from(theme))
        .map_err(|_e| Error::Atom("error"))
}
