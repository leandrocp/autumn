// https://github.com/Colonial-Dev/inkjet/blob/da289fa8b68f11dffad176e4b8fabae8d6ac376d/build/language.rs
// https://github.com/Wilfred/difftastic/blob/dfcb26c7af24b78284959506f57ffe84a1b08856/build.rs

use std::fs::{self, DirEntry};
use std::path::{Path, PathBuf};
use std::process::exit;

fn main() {
    println!("cargo:rerun-if-changed=../../langs.exs");
    println!("cargo:rerun-if-changed=src/langs.rs");

    let path = Path::new("../../tmp/langs");

    if path.exists() && path.is_dir() {
        let entries = fs::read_dir(path).expect("failed to read langs dir");

        for entry in entries {
            let entry = entry.expect("invalid path entry");
            let path = entry.path();
            if path.is_dir() && !path.ends_with("plaintext") {
                build(entry);
            }
        }
    }
}

fn build(parser: DirEntry) {
    let name = parser
        .path()
        .file_name()
        .and_then(|n| n.to_str())
        .unwrap_or_default()
        .to_string();

    println!("building: {}", name);

    let src_path = match name.as_str() {
        "markdown" => parser.path().join("block").join("src"),
        "markdown_inline" => parser.path().join("inline").join("src"),
        "php" => parser.path().join("php").join("src"),
        "typescript" => parser.path().join("tsx").join("src"),
        _ => parser.path().join("src"),
    };

    println!("cargo:rerun-if-changed={}", src_path.display());

    let cpp_files = cpp_files(&src_path);

    if !cpp_files.is_empty() {
        let mut build = cc::Build::new();

        build
            .include(&src_path)
            .cpp(true)
            .std("c++14")
            .flag_if_supported("-Wno-implicit-fallthrough")
            .flag_if_supported("-Wno-unused-parameter")
            .flag_if_supported("-Wno-ignored-qualifiers")
            .link_lib_modifier("+whole-archive");

        for file in cpp_files {
            build.file(file);
        }

        build.compile(&format!("{}-cpp", name));
    }

    let c_files = c_files(&src_path);

    if c_files.is_empty() {
        exit(1)
    } else {
        let mut build = cc::Build::new();

        if cfg!(target_env = "msvc") {
            build.flag("-utf-8");
        }

        build.include(&src_path).std("c11").warnings(false); // ignore unused parameter warnings
                                                             // .link_lib_modifier("+whole-archive");

        for file in c_files {
            build.file(file);
        }

        build.compile(&name);
    }
}

fn c_files(src_dir: &PathBuf) -> Vec<String> {
    match fs::read_dir(src_dir) {
        Ok(entries) => entries
            .filter_map(|entry| entry.ok()?.path().to_str().map(|s| s.to_string()))
            .filter(|path| path.ends_with(".c"))
            .collect(),
        Err(_) => Vec::new(),
    }
}

fn cpp_files(src_dir: &PathBuf) -> Vec<String> {
    match fs::read_dir(src_dir) {
        Ok(entries) => entries
            .filter_map(|entry| entry.ok()?.path().to_str().map(|s| s.to_string()))
            .filter(|path| path.ends_with(".cpp") || path.ends_with(".cc"))
            .collect(),
        Err(_) => Vec::new(),
    }
}
