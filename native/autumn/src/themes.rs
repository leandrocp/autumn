use once_cell::sync::Lazy;
use toml::Value;

static DRACULA: Lazy<Value> = Lazy::new(|| {
    let theme = include_str!("../../../priv/generated/themes/dracula.toml");
    toml::from_str(theme).unwrap_or_else(|_| { panic!("failed to parse {}", "dracula.toml")})

});

static ONEDARK: Lazy<Value> = Lazy::new(|| {
    let theme = include_str!("../../../priv/generated/themes/onedark.toml");
    toml::from_str(theme).unwrap_or_else(|_| { panic!("failed to parse {}", "onedark.toml")})
});

pub fn theme(name: &str) -> Option<&Value> {
    match name {
        "dracula" => Some(&DRACULA),
        "onedark" => Some(&ONEDARK),
        &_ => None,
    }
}
