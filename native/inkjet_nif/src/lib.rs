mod inline_html;
use autumn::themes;
use inkjet::{Highlighter, Language};
use rustler::{Atom, Error};

rustler::atoms! {
    ok,
    error,
}

rustler::init!("Elixir.Autumn.Native", [highlight]);

#[rustler::nif]
fn highlight(
    lang: &str,
    source: &str,
    theme: &str,
    pre_class: Option<&str>,
) -> Result<(Atom, String), Error> {
    match do_highlight(lang, source, theme, pre_class) {
        Ok(rendered) => Ok((ok(), rendered)),
        Err(err) => Err(Error::Term(Box::new(err))),
    }
}

fn do_highlight(
    lang: &str,
    source: &str,
    theme: &str,
    pre_class: Option<&str>,
) -> Result<String, String> {
    let theme = match themes::theme(theme) {
        Some(theme) => theme,
        None => return Err(format!("unknown theme: {}", theme)),
    };

    let lang = resolve_lang(lang);

    let mut highlighter = Highlighter::new();
    let inline_html = inline_html::InlineHTML::new(lang, theme, pre_class);

    match highlighter.highlight_to_string(lang, &inline_html, source) {
        Ok(rendered) => Ok(rendered),
        Err(_err) => Err("failed to highlight source code".to_string()),
    }
}

fn resolve_lang<'a>(lang: &'a str) -> Language {
    Language::from_token(lang).unwrap_or(Language::Plaintext)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_fallback_to_plaintext() {
        assert_eq!(resolve_lang("foo"), Language::Plaintext)
    }

    #[test]
    fn test_highlight() {
        let highlited = do_highlight("js", "import { export } from mod", "dracula", None)
            .expect("failed to highlight");
        assert_eq!(highlited, "<pre><code class=\"autumn-highlight language-javascript\" style=\"background-color: #282A36; color: #f8f8f2;\" translate=\"no\"><span class=\"keyword\" style=\"color: #ff79c6;\">import</span> <span class=\"punctuation-bracket\" style=\"color: #f8f8f2;\">{</span> <span class=\"variable\" style=\"color: #f8f8f2;\">export</span> <span class=\"punctuation-bracket\" style=\"color: #f8f8f2;\">}</span> <span class=\"keyword\" style=\"color: #ff79c6;\">from</span> <span class=\"variable\" style=\"color: #f8f8f2;\">mod</span></code></pre>".to_string())
    }
}
