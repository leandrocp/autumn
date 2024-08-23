use crate::constants::HIGHLIGHT_NAMES;
use std::sync::LazyLock;
use tree_sitter::Language;
use tree_sitter_highlight::HighlightConfiguration;

extern "C" {
    fn tree_sitter_bash() -> Language;
    fn tree_sitter_diff() -> Language;
    fn tree_sitter_elixir() -> Language;
    fn tree_sitter_lua() -> Language;
    fn tree_sitter_ruby() -> Language;
    fn tree_sitter_rust() -> Language;
}

pub fn langs() -> Vec<&'static str> {
    vec![
        "bash", "diff", "elixir", "lua", "plain", "ruby", "rust", "text",
    ]
}

// extracted from each lang package.json
pub fn config<'a>(lang: &'a str) -> &'static HighlightConfiguration {
    match lang {
        "text" => &PLAINTEXT_CONFIG,
        "plain" => &PLAINTEXT_CONFIG,

        "sh" => &BASH_CONFIG,
        "bash" => &BASH_CONFIG,
        ".bashrc" => &BASH_CONFIG,
        ".bash_profile" => &BASH_CONFIG,
        "ebuild" => &BASH_CONFIG,
        "eclass" => &BASH_CONFIG,

        "diff" => &DIFF_CONFIG,

        "elixir" => &ELIXIR_CONFIG,
        "ex" => &ELIXIR_CONFIG,

        "lua" => &LUA_CONFIG,

        "ruby" => &RUBY_CONFIG,
        "rb" => &RUBY_CONFIG,

        "rust" => &RUST_CONFIG,
        "rs" => &RUST_CONFIG,

        _ => &PLAINTEXT_CONFIG,
    }
}

static BASH_CONFIG: LazyLock<HighlightConfiguration> = LazyLock::new(|| {
    let mut config = HighlightConfiguration::new(
        unsafe { tree_sitter_bash() },
        "bash",
        include_str!("../../../deps/queries_bash/queries/highlights.scm"),
        "",
        "",
    )
    .expect("failed to create Bash highlight configuration");
    config.configure(&HIGHLIGHT_NAMES);
    config
});

static DIFF_CONFIG: LazyLock<HighlightConfiguration> = LazyLock::new(|| {
    let mut config = HighlightConfiguration::new(
        unsafe { tree_sitter_diff() },
        "diff",
        include_str!("../../../deps/queries_diff/queries/highlights.scm"),
        "",
        "",
    )
    .expect("failed to create Diff highlight configuration");
    config.configure(&HIGHLIGHT_NAMES);
    config
});

static ELIXIR_CONFIG: LazyLock<HighlightConfiguration> = LazyLock::new(|| {
    let mut config = HighlightConfiguration::new(
        unsafe { tree_sitter_elixir() },
        "elixir",
        include_str!(
            "../../../deps/zed_extensions/extensions/elixir/languages/elixir/highlights.scm"
        ),
        include_str!(
            "../../../deps/zed_extensions/extensions/elixir/languages/elixir/injections.scm"
        ),
        "",
    )
    .expect("failed to create Elixir highlight configuration");
    config.configure(&HIGHLIGHT_NAMES);
    config
});

static LUA_CONFIG: LazyLock<HighlightConfiguration> = LazyLock::new(|| {
    let mut config = HighlightConfiguration::new(
        unsafe { tree_sitter_lua() },
        "lua",
        include_str!("../../../deps/zed_extensions/extensions/lua/languages/lua/highlights.scm"),
        include_str!("../../../deps/queries_lua/queries/injections.scm"),
        "",
    )
    .expect("failed to create Lua highlight configuration");
    config.configure(&HIGHLIGHT_NAMES);
    config
});

static PLAINTEXT_CONFIG: LazyLock<HighlightConfiguration> = LazyLock::new(|| {
    let mut config = HighlightConfiguration::new(unsafe { tree_sitter_diff() }, "diff", "", "", "")
        .expect("failed to create Plaintext highlight configuration");
    config.configure(&HIGHLIGHT_NAMES);
    config
});

static RUBY_CONFIG: LazyLock<HighlightConfiguration> = LazyLock::new(|| {
    let mut config = HighlightConfiguration::new(
        unsafe { tree_sitter_ruby() },
        "ruby",
        include_str!("../../../deps/zed_extensions/extensions/ruby/languages/ruby/highlights.scm"),
        include_str!("../../../deps/zed_extensions/extensions/ruby/languages/ruby/injections.scm"),
        "",
    )
    .expect("failed to create Ruby highlight configuration");
    config.configure(&HIGHLIGHT_NAMES);
    config
});

static RUST_CONFIG: LazyLock<HighlightConfiguration> = LazyLock::new(|| {
    let mut config = HighlightConfiguration::new(
        unsafe { tree_sitter_rust() },
        "rust",
        include_str!("../../../deps/queries_rust/queries/highlights.scm"),
        include_str!("../../../deps/queries_rust/queries/injections.scm"),
        "",
    )
    .expect("failed to create Ruby highlight configuration");
    config.configure(&HIGHLIGHT_NAMES);
    config
});

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_get_lang() {
        let lang = get_lang("plain");
        assert!(lang.is_some());

        let lang = get_lang("elixir");
        assert!(lang.is_some());
    }
}
