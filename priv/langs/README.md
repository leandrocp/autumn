# Languages

## Adding a language

1. Add the git submodule:

```sh
git submodule add --depth 1 https://github.com/tree-sitter/tree-sitter-ruby.git
git config -f ../../.gitmodules submodule.priv/langs/tree-sitter-ruby.shallow true
```

2. Update langs.exs:

```sh
mix autumn.generate_langs
```

3. Add the lang in `Cargo.toml`

4. Add a lang match in `src/lang.rs`

## Updating submodules

```sh
git submodule update --recursive --remote
```
