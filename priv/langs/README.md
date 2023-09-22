# Languages

## Adding a language

1. Add the git submodule:

```sh
git submodule add --depth 1 https://github.com/tree-sitter/tree-sitter-ruby.git
git config -f ../../.gitmodules submodule.priv/langs/tree-sitter-ruby.shallow true
```

_Execute the commands above from within the `priv/langs/` dir._

2. Update langs.exs:

```sh
mix autumn.generate_langs
```

_Execute this mix task from the root dir._

3. Add the lang in [`Cargo.toml`](https://github.com/leandrocp/autumn/blob/main/native/autumn/Cargo.toml)

4. Add a lang match in [`src/lang.rs`](https://github.com/leandrocp/autumn/blob/main/native/autumn/src/lang.rs)

## Updating submodules

```sh
git submodule update --recursive --remote
```

_Execute the command above from within the `priv/langs/` dir._
