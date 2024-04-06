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
    inline_style: bool,
) -> Result<(Atom, String), Error> {
    match do_highlight(lang, source, theme, pre_class, inline_style) {
        Ok(rendered) => Ok((ok(), rendered)),
        Err(err) => Err(Error::Term(Box::new(err))),
    }
}

fn do_highlight(
    lang: &str,
    source: &str,
    theme: &str,
    pre_class: Option<&str>,
    inline_style: bool,
) -> Result<String, String> {
    let theme = match themes::theme(theme) {
        Some(theme) => theme,
        None => return Err(format!("unknown theme: {}", theme)),
    };

    let lang = resolve_lang(lang);

    let mut highlighter = Highlighter::new();
    let inline_html = inline_html::InlineHTML::new(lang, theme, pre_class, inline_style);

    match highlighter.highlight_to_string(lang, &inline_html, source) {
        Ok(rendered) => Ok(rendered),
        Err(_err) => Err("failed to highlight source code".to_string()),
    }
}

fn resolve_lang(lang: &str) -> Language {
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
        let source = r#"
        import Browser from "./browser"
        export default class View {}
        "#;

        let highlited =
            do_highlight("js", source, "dracula", None, true).expect("test_highlight failed");

        assert_eq!(highlited, "<pre class=\"autumn-hl\" style=\"background-color: #282A36; color: #f8f8f2;\"><code class=\"language-javascript\" translate=\"no\">\n        <span class=\"ahl-keyword\" style=\"color: #ff79c6;\">import</span> <span class=\"ahl-variable\" style=\"color: #f8f8f2;\">Browser</span> <span class=\"ahl-keyword\" style=\"color: #ff79c6;\">from</span> <span class=\"ahl-string\" style=\"color: #f1fa8c;\">&quot;.&#x2f;browser&quot;</span>\n        <span class=\"ahl-keyword\" style=\"color: #ff79c6;\">export</span> <span class=\"ahl-keyword\" style=\"color: #ff79c6;\">default</span> <span class=\"ahl-keyword\" style=\"color: #ff79c6;\">class</span> <span class=\"ahl-variable\" style=\"color: #f8f8f2;\">View</span> <span class=\"ahl-punctuation ahl-bracket\" style=\"color: #f8f8f2;\">{</span><span class=\"ahl-punctuation ahl-bracket\" style=\"color: #f8f8f2;\">}</span>\n        </code></pre>")
    }
}
