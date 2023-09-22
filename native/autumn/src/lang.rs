use tree_sitter_highlight::HighlightConfiguration;

// https://github.com/Colonial-Dev/inkjet/blob/d53ddb0fe4de60b299368286ae7e602ea4d48169/src/constants.rs#L6
// https://github.com/tree-sitter/tree-sitter/blob/6bbb50bef8249e6460e7d69e42cc8146622fa4fd/highlight/src/lib.rs#L22
// https://github.com/tree-sitter/tree-sitter/blob/6bbb50bef8249e6460e7d69e42cc8146622fa4fd/cli/src/highlight.rs#L147
pub const HIGHLIGHT_NAMES: &[&str] = &[
    "attribute",
    "boolean",
    "carriage-return",
    "constant.builtin",
    "embedded",
    "error",
    "escape",
    "markup",
    "markup.bold",
    "markup.heading",
    "markup.italic",
    "markup.link",
    "markup.link.url",
    "markup.link.text",
    "markup.list",
    "markup.list.checked",
    "markup.list.numbered",
    "markup.list.unchecked",
    "markup.list.unnumbered",
    "markup.quote",
    "markup.raw",
    "markup.raw.block",
    "markup.raw.inline",
    "markup.strikethrough",
    "module",
    "number",
    "property",
    "property.builtin",
    "type",
    "type.builtin",
    "type.enum",
    "type.enum.variant",
    "constructor",
    "constant",
    "constant.builtin",
    "constant.builtin.boolean",
    "constant.character",
    "constant.character.escape",
    "constant.numeric",
    "constant.numeric.integer",
    "constant.numeric.float",
    "string",
    "string.escape",
    "string.regexp",
    "string.special",
    "string.special.path",
    "string.special.url",
    "string.special.symbol",
    "escape",
    "comment",
    "comment.documentation",
    "comment.line",
    "comment.block",
    "comment.block.documentation",
    "variable",
    "variable.builtin",
    "variable.parameter",
    "variable.member",
    "variable.other",
    "variable.other.member",
    "label",
    "punctuation",
    "punctuation.delimiter",
    "punctuation.bracket",
    "punctuation.special",
    "keyword",
    "keyword.control",
    "keyword.control.conditional",
    "keyword.control.repeat",
    "keyword.control.import",
    "keyword.control.return",
    "keyword.control.exception",
    "keyword.operator",
    "keyword.directive",
    "keyword.function",
    "keyword.storage",
    "keyword.storage.type",
    "keyword.storage.modifier",
    "operator",
    "function",
    "function.builtin",
    "function.method",
    "function.macro",
    "function.special",
    "tag",
    "tag.builtin",
    "namespace",
    "special",
    "diff",
    "diff.plus",
    "diff.minus",
    "diff.delta",
    "diff.delta.moved",
];

pub struct Lang {
    pub name: String,
    pub config: HighlightConfiguration,
}

impl Lang {
    pub fn config(name: &str) -> HighlightConfiguration {
        let mut config = match name {
            "elixir" => HighlightConfiguration::new(
                tree_sitter_elixir::language(),
                tree_sitter_elixir::HIGHLIGHTS_QUERY,
                include_str!("../../../priv/langs/tree-sitter-elixir/queries/injections.scm"),
                "",
            )
            .unwrap(),
            "ruby" => HighlightConfiguration::new(
                tree_sitter_ruby::language(),
                tree_sitter_ruby::HIGHLIGHT_QUERY,
                "",
                tree_sitter_ruby::LOCALS_QUERY,
            )
            .unwrap(),
            "rust" => HighlightConfiguration::new(
                tree_sitter_rust::language(),
                tree_sitter_rust::HIGHLIGHT_QUERY,
                tree_sitter_rust::INJECTIONS_QUERY,
                "",
            )
            .unwrap(),
            // "html" => HighlightConfiguration::new(
            //     tree_sitter_html::language(),
            //     include_str!("../../../priv/langs/tree-sitter-html/queries/highlights.scm"),
            //     include_str!("../../../priv/langs/tree-sitter-html/queries/injections.scm"),
            //     "",
            // )
            // .unwrap(),
            "javascript" => HighlightConfiguration::new(
                tree_sitter_javascript::language(),
                tree_sitter_javascript::HIGHLIGHT_QUERY,
                tree_sitter_javascript::INJECTION_QUERY,
                tree_sitter_javascript::LOCALS_QUERY,
            )
            .unwrap(),
            "swift" => HighlightConfiguration::new(
                tree_sitter_swift::language(),
                tree_sitter_swift::HIGHLIGHTS_QUERY,
                "",
                tree_sitter_swift::LOCALS_QUERY,
            )
            .unwrap(),
            &_ => todo!(),
        };

        config.configure(HIGHLIGHT_NAMES);
        config
    }
}
