use rustler::{Decoder, Encoder, Env, NifResult, NifStruct, Term};
use std::collections::{BTreeMap, HashMap};

#[derive(Debug, Default, NifStruct)]
#[module = "Autumn.Theme"]
pub struct Theme {
    name: String,
    family: String,
    author: String,
    appearance: String,
    style: Style,
}

#[derive(Debug, Default)]
pub struct Style {
    colors: HashMap<String, String>,
    syntax: BTreeMap<String, HighlightStyle>,
}

#[derive(Debug, Default)]
pub struct HighlightStyle {
    pub color: Option<String>,
    pub font_style: Option<String>,
    pub font_weight: Option<u32>,
}

impl HighlightStyle {
    pub fn to_css(&self) -> String {
        let mut css = String::new();

        if let Some(color) = &self.color {
            css.push_str(&format!("color: {};", color));
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
    pub fn stylesheet(&self) -> String {
        let mut stylesheet = format!("/* {} - {} */\n", self.name, self.author);

        stylesheet.push_str(&format!("pre.athl {{\n  {}\n}}\n", self.pre_style()));

        for (class, style) in &self.style.syntax {
            let class = format!("athl-{}", class.replace('.', "-"));

            let mut rules = Vec::new();

            if let Some(color) = &style.color {
                rules.push(format!("  color: {};", color));
            }

            if let Some(font_style) = &style.font_style {
                rules.push(format!("  font-style: {};", font_style));
            }

            if let Some(font_weight) = &style.font_weight {
                rules.push(format!("  font-weight: {};", font_weight));
            }

            if !rules.is_empty() {
                stylesheet.push_str(&format!(".{} {{\n", class));
                stylesheet.push_str(&rules.join("\n"));
                stylesheet.push_str("\n}\n");
            }
        }

        stylesheet
    }

    pub fn get_color(&self, key: &str) -> Option<&String> {
        self.style.colors.get(key)
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
            css.push_str(&format!("background-color: {}; ", bg));
        }

        if let Some(fg) = self.get_color("text") {
            css.push_str(&format!("color: {};", fg));
        }

        css
    }
}

impl Encoder for Style {
    fn encode<'a>(&self, _env: Env<'a>) -> Term<'a> {
        unimplemented!()
    }
}

impl<'a> Decoder<'a> for Style {
    fn decode(term: Term<'a>) -> Result<Self, rustler::Error> {
        let mut colors = HashMap::new();
        let mut syntax = BTreeMap::new();

        let map: HashMap<String, Term> = term.decode()?;

        for (key, value) in map {
            match key.as_str() {
                "syntax" => {
                    if let Ok(syntax_map) = value.decode::<HashMap<String, Term>>() {
                        for (syntax_key, syntax_value) in syntax_map {
                            if let Ok(highlight_style) = syntax_value.decode::<HighlightStyle>() {
                                syntax.insert(syntax_key, highlight_style);
                            }
                        }
                    }
                }
                _ => {
                    if let Ok(color) = value.decode::<String>() {
                        colors.insert(key, color);
                    }
                }
            }
        }

        Ok(Style { colors, syntax })
    }
}

impl<'a> Decoder<'a> for HighlightStyle {
    fn decode(term: Term<'a>) -> NifResult<Self> {
        let map: HashMap<String, Term> = term.decode()?;

        let color: Option<String> = map.get("color").and_then(|value| value.decode().ok());
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
    fn test_get_syntax_ancestor() {
        let theme = Theme {
            name: "test".to_string(),
            family: "test".to_string(),
            author: "test".to_string(),
            appearance: "dark".to_string(),
            style: Style {
                colors: HashMap::new(),
                syntax: BTreeMap::from([
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
                            color: Some("#464b57ff".to_string()),
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

        assert_eq!(syntax.color, Some("#464b57ff".to_string()));
    }
}
