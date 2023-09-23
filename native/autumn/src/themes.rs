use once_cell::sync::Lazy;
use std::fs::read_to_string;
use toml::Value;

// TODO: error handling
// FIXME: relative path to themes files

static DRACULA: Lazy<Value> = Lazy::new(|| {
    let file = read_to_string(
        "/Users/leandro/code/github/leandrocp/autumn/priv/generated/themes/dracula.toml",
    )
    .expect("failed to read theme file");
    toml::from_str(file.as_str()).expect("failed to parse theme file")
});

static ONEDARK: Lazy<Value> = Lazy::new(|| {
    let file = read_to_string(
        "/Users/leandro/code/github/leandrocp/autumn/priv/generated/themes/dracula.toml",
    )
    .expect("failed to read theme file");
    toml::from_str(file.as_str()).expect("failed to parse theme file")
});

pub fn theme(name: &str) -> &Value {
    match name {
        "dracula" => &DRACULA,
        "onedark" => &ONEDARK,
        &_ => todo!(),
    }
}
