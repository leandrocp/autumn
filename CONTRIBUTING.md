# How to Contribute

## Build

First of all export the environment variable `AUTUMN_BUILD`:

```sh
export AUTUMN_BUILD=1
```

Next you need to download deps and all temporary files used to build themes and languages:

```sh
mix setup
```

In order to execute all steps, some binaries are required in your system $PATH

`git gh find unzip node tree-sitter`

And C and C++ compilers are also required.

Make sure all are installed.

Now wait. This will take a while to finish.

Finally you can run tests:

```sh
mix test
```

## Adding a new language

1. Add the lang into `langs.exs`
2. Run `mix download.langs`
3. Run `mix gen.langs.rs`

## Add theme

1. Add the theme into `themes.csv`
2. Run `mix download.themes`
