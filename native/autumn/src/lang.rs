use tree_sitter_highlight::HighlightConfiguration;

// https://github.com/Colonial-Dev/inkjet/blob/d53ddb0fe4de60b299368286ae7e602ea4d48169/src/constants.rs#L6
pub const HIGHLIGHT_NAMES: &[&str] = &[
    "attribute",
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
    "string.regexp",
    "string.special",
    "string.special.path",
    "string.special.url",
    "string.special.symbol",
    "escape",
    "comment",
    "comment.line",
    "comment.block",
    "comment.block.documentation",
    "variable",
    "variable.builtin",
    "variable.parameter",
    "variable.other",
    "variable.other.member",
    "label",
    "punctuation",
    "punctuation.delimiter",
    "punctuation.bracket",
    "punction.special",
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
                "",
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
            &_ => todo!(),
        };

        config.configure(&HIGHLIGHT_NAMES);
        config
    }
}
