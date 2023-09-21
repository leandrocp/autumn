# Languages

## Adding a language

```sh
git submodule add --depth 1 https://github.com/tree-sitter/tree-sitter-ruby.git
git config -f ../../.gitmodules submodule.priv/langs/tree-sitter-ruby.shallow true
```

## Updating submodules

```sh
git submodule update --recursive --remote
```
