#![allow(unused_variables)]
#![allow(unused_imports)]

// https://convertcolorcode.com

use std::collections::HashMap;

use rustler::{Decoder, Encoder, Env, NifResult, NifStruct, Term};

use crate::color::{Hsla, Rgba};

#[derive(Debug, NifStruct)]
#[module = "Autumn.Theme"]
pub struct Theme {
    name: String,
    author: String,
    appearance: String,
    style: Style,
}

#[derive(Debug)]
pub struct Style {
    colors: HashMap<String, Option<Hsla>>,
    syntax: HashMap<String, HighlightStyle>,
}

#[derive(Debug)]
pub struct HighlightStyle {
    pub color: Option<Hsla>,
    pub font_style: Option<String>,
    pub font_weight: Option<u32>,
}

impl Hsla {
    pub fn to_css(&self) -> String {
        let h = (self.h * 360.0).round() as i32;
        let s = (self.s * 100.0).round() as i32;
        let l = (self.l * 100.0).round() as i32;

        if (self.a - 1.0).abs() < f32::EPSILON {
            format!("hsl({} {}% {}%)", h, s, l)
        } else {
            format!("hsl({} {}% {}% / {})", h, s, l, format!("{:.2}", self.a))
        }
    }
}

impl HighlightStyle {
    pub fn to_css(&self) -> String {
        let mut css = String::new();

        if let Some(color) = &self.color {
            css.push_str(&format!("color: {};", color.to_css()));
        }

        if let Some(font_style) = &self.font_style {
            css.push_str(&format!("font-style: {};", font_style));
        }

        if let Some(font_weight) = &self.font_weight {
            css.push_str(&format!("font-weight: {};", font_weight));
        }

        css
    }
}

impl Theme {
    pub fn get_color(&self, key: &str) -> Option<&Hsla> {
        self.style.colors.get(key).unwrap_or(&None).as_ref()
    }

    pub fn get_syntax(&self, key: &str) -> Option<&HighlightStyle> {
        match self.style.syntax.get(key) {
            Some(syntax) => Some(syntax),
            None => {
                // try to match ancestor
                if key.contains('.') {
                    let split: Vec<&str> = key.split('.').collect();
                    let joined = split[0..split.len() - 1].join(".");
                    self.get_syntax(joined.as_str())
                } else {
                    None
                }
            }
        }
    }

    pub fn pre_style(&self) -> String {
        let mut css = String::new();

        if let Some(bg) = self.get_color("editor.background") {
            css.push_str(&format!("background-color: {}; ", bg.to_css()));
        }

        if let Some(fg) = self.get_color("text") {
            css.push_str(&format!("color: {};", fg.to_css()));
        }

        css
    }

    // FIXME: fn to convert syntax struct to css rules
}

impl Encoder for Style {
    fn encode<'a>(&self, _env: Env<'a>) -> Term<'a> {
        unimplemented!()
    }
}

impl<'a> Decoder<'a> for Style {
    fn decode(term: Term<'a>) -> Result<Self, rustler::Error> {
        let mut colors = HashMap::new();
        let mut syntax = HashMap::new();

        let map: HashMap<String, Term> = term.decode()?;

        for (key, value) in map {
            match key.as_str() {
                "colors" => {
                    colors = value.decode()?;
                }
                "syntax" => {
                    syntax = value.decode()?;
                }
                _ => {}
            }
        }

        Ok(Style { colors, syntax })
    }
}

// FIXME: handle error
impl<'a> Decoder<'a> for Hsla {
    fn decode(term: Term<'a>) -> NifResult<Self> {
        let color: &str = term.decode()?;

        // FIXME: handle error
        let rgba = Rgba::try_from(color).expect("TODO: handle error");

        let hsla = Hsla::from(rgba);

        Ok(hsla)
    }
}

impl<'a> Decoder<'a> for HighlightStyle {
    fn decode(term: Term<'a>) -> NifResult<Self> {
        let map: HashMap<String, Term> = term.decode()?;

        let color: Option<Hsla> = map.get("color").and_then(|value| value.decode().ok());
        let font_style: Option<String> =
            map.get("font_style").and_then(|value| value.decode().ok());
        let font_weight: Option<u32> = map.get("font_weight").and_then(|value| value.decode().ok());

        Ok(HighlightStyle {
            color,
            font_style,
            font_weight,
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_hsla_to_css_without_alpha() {
        let rgba = Rgba::try_from("#282a36ff").expect("failed to convert");
        let hsla = Hsla::from(rgba);
        assert_eq!(hsla.to_css(), "hsl(231 15% 18%)".to_string());
    }

    #[test]
    fn test_hsla_to_css_with_alpha() {
        let rgba = Rgba::try_from("#C9A8F950").expect("failed to convert");
        let hsla = Hsla::from(rgba);
        assert_eq!(hsla.to_css(), "hsl(264 87% 82% / 0.31)".to_string());
    }

    #[test]
    fn test_get_syntax_ancestor() {
        let theme = Theme {
            name: "test".to_string(),
            author: "test".to_string(),
            appearance: "dark".to_string(),
            style: Style {
                colors: HashMap::new(),
                syntax: HashMap::from([
                    (
                        "string".to_string(),
                        HighlightStyle {
                            color: None,
                            font_style: None,
                            font_weight: None,
                        },
                    ),
                    (
                        "string.special".to_string(),
                        HighlightStyle {
                            color: Some(Hsla {
                                h: 0.,
                                s: 0.,
                                l: 0.,
                                a: 0.,
                            }),
                            font_style: None,
                            font_weight: None,
                        },
                    ),
                ]),
            },
        };

        let syntax = theme
            .get_syntax("string.special.keyword")
            .expect("expected syntax");
        assert_eq!(syntax.color.is_some(), true);
    }
}
