# How to Contribute

## Build

First of all export the environment variable `AUTUMN_BUILD`:

```shell
export AUTUMN_BUILD=1
```

Then you can build the project and run tests making sure all deps will be compiled:

```shell
cargo build
mix deps.get
mix test
```

## Update upstream `inkjet` dependency

Update the version in `native/autumn/Cargo.toml` and `native/inkjet_nif/Cargo.toml` and run tests.

## Update or add languages

Update the list of languages in both `native/autumn/Cargo.toml` and `native/inkjet_nif/Cargo.toml`.

Note that languages are loaded from the Inkjet rust library so the name must match the ones defined at https://github.com/Colonial-Dev/inkjet/blob/master/Cargo.toml

If a language you want is not in Inkjet list, please open an issue in that repo.

## Update or add themes

Themes are loaded from Helix editor, they're located at https://github.com/helix-editor/helix/tree/master/runtime/themes

Just copy the theme file to `priv/themes` and execute:

```shell
mix autumn.generate_themes_rs
mix autumn.generate_css
```

## Improve documentation

We are always looking to improve our documentation. If at some moment you are
reading the documentation and something is not clear, or you can't find what you
are looking for, then please open an issue with the repository. This gives us a
chance to answer your question and to improve the documentation if needed.

Pull requests correcting spelling or grammar mistakes are always welcome.

## Found a bug?

Please try to answer at least the following questions when reporting a bug:

 - Which version of the project did you use when you noticed the bug?
 - How do you reproduce the error condition?
 - What happened that you think is a bug?
 - What should it do instead?

It would really help the maintainers if you could provide a reduced test case
that reproduces the error condition.

## Have a feature request?

Please provide some thoughful commentary and code samples on what this feature
should do and why it should be added (your use case). The minimal questions you
should answer when submitting a feature request should be:

 - What will it allow you to do that you can't do today?
 - Why do you need this feature and how will it benefit other users?
 - Are there any drawbacks to this feature?

## Submitting a pull-request?

Here are some things that will increase the chance that your pull-request will
get accepted:
 - Did you confirm this fix/feature is something that is needed?
 - Did you write tests, preferably in a test driven style?
 - Did you add documentation for the changes you made?

If your pull-request addresses an issue then please add the corresponding
issue's number to the description of your pull-request.