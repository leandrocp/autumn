fn main() {
    bash();
    diff();
    elixir();
    lua();
    ruby();
    rust();
}

// https://github.com/tree-sitter/tree-sitter-bash/blob/master/bindings/rust/build.rs
fn bash() {
    let src_dir = std::path::Path::new("../../deps/grammar_bash/src");

    let mut c_config = cc::Build::new();
    c_config.include(src_dir);

    #[cfg(target_env = "msvc")]
    c_config.flag("-utf-8");

    let parser_path = src_dir.join("parser.c");
    c_config.file(&parser_path);
    println!("cargo:rerun-if-changed={}", parser_path.to_str().unwrap());

    let scanner_path = src_dir.join("scanner.c");
    c_config.file(&scanner_path);
    println!("cargo:rerun-if-changed={}", scanner_path.to_str().unwrap());

    c_config.compile("tree-sitter-bash");
}

// https://github.com/the-mikedavis/tree-sitter-diff/blob/main/bindings/rust/build.rs
fn diff() {
    let src_dir = std::path::Path::new("../../deps/grammar_diff/src");

    let mut c_config = cc::Build::new();
    c_config.include(&src_dir);
    c_config
        .flag_if_supported("-Wno-unused-parameter")
        .flag_if_supported("-Wno-unused-but-set-variable")
        .flag_if_supported("-Wno-trigraphs");
    let parser_path = src_dir.join("parser.c");
    c_config.file(&parser_path);

    c_config.compile("parser");
    println!("cargo:rerun-if-changed={}", parser_path.to_str().unwrap());
}

// https://github.com/elixir-lang/tree-sitter-elixir/blob/main/bindings/rust/build.rs
fn elixir() {
    let src_dir = std::path::Path::new("../../deps/grammar_elixir/src");

    let mut c_config = cc::Build::new();
    c_config.include(src_dir);
    c_config
        .flag_if_supported("-Wno-unused-parameter")
        .flag_if_supported("-Wno-unused-but-set-variable")
        .flag_if_supported("-Wno-trigraphs");
    #[cfg(target_env = "msvc")]
    c_config.flag("-utf-8");

    let parser_path = src_dir.join("parser.c");
    c_config.file(&parser_path);
    println!("cargo:rerun-if-changed={}", parser_path.to_str().unwrap());

    let scanner_path = src_dir.join("scanner.c");
    c_config.file(&scanner_path);
    println!("cargo:rerun-if-changed={}", scanner_path.to_str().unwrap());

    c_config.compile("parser-scanner");
}

// https://github.com/tree-sitter-grammars/tree-sitter-lua/blob/main/bindings/rust/build.rs
fn lua() {
    let src_dir = std::path::Path::new("../../deps/grammar_lua/src");

    let mut c_config = cc::Build::new();
    c_config.std("c11").include(src_dir);

    #[cfg(target_env = "msvc")]
    c_config.flag("-utf-8");

    let parser_path = src_dir.join("parser.c");
    c_config.file(&parser_path);
    println!("cargo:rerun-if-changed={}", parser_path.to_str().unwrap());

    let scanner_path = src_dir.join("scanner.c");
    c_config.file(&scanner_path);
    println!("cargo:rerun-if-changed={}", scanner_path.to_str().unwrap());

    c_config.compile("tree-sitter-lua");
}

// https://github.com/tree-sitter/tree-sitter-ruby/blob/master/bindings/rust/build.rs
fn ruby() {
    let src_dir = std::path::Path::new("../../deps/grammar_ruby/src");

    let mut c_config = cc::Build::new();
    c_config
        .std("c11")
        .include(src_dir)
        .flag_if_supported("-Wno-unused-value");

    #[cfg(target_env = "msvc")]
    c_config.flag("-utf-8");

    let parser_path = src_dir.join("parser.c");
    c_config.file(&parser_path);
    println!("cargo:rerun-if-changed={}", parser_path.to_str().unwrap());

    let scanner_path = src_dir.join("scanner.c");
    c_config.file(&scanner_path);
    println!("cargo:rerun-if-changed={}", scanner_path.to_str().unwrap());

    c_config.compile("tree-sitter-ruby");
}

// https://github.com/tree-sitter/tree-sitter-rust/blob/master/bindings/rust/build.rs
fn rust() {
    let src_dir = std::path::Path::new("../../deps/grammar_rust/src");

    let mut c_config = cc::Build::new();
    c_config
        .std("c11")
        .include(src_dir)
        .flag_if_supported("-Wno-unused-parameter");

    #[cfg(target_env = "msvc")]
    c_config.flag("-utf-8");

    let parser_path = src_dir.join("parser.c");
    c_config.file(&parser_path);
    println!("cargo:rerun-if-changed={}", parser_path.to_str().unwrap());

    let scanner_path = src_dir.join("scanner.c");
    c_config.file(&scanner_path);
    println!("cargo:rerun-if-changed={}", scanner_path.to_str().unwrap());

    c_config.compile("tree-sitter-rust");
}
