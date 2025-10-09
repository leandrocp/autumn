## Architecture
- **Main API**: `lib/autumn.ex` - Primary public interface with `highlight/2` and `highlight!/2` functions
- **Rust NIF**: `native/autumnus_nif/` - Rust NIF wrapper using rustler that interfaces with the autumnus Rust crate
- **Core Engine**: Uses the `autumnus` crate which leverages Tree-sitter for parsing 70+ languages with 120+ Neovim themes
- **Theme System**: `lib/autumn/theme.ex` - Theme management and style definitions
- **CSS Assets**: `priv/static/css/` - Pre-generated CSS files for the html_linked formatter
- **Precompiled Binaries**: Uses `rustler_precompiled` for distributing precompiled NIFs across multiple platforms

The library supports three output formatters:
- `:html_inline` - HTML with inline styles (default)
- `:html_linked` - HTML with CSS classes (requires linking CSS from `priv/static/css/`)
- `:terminal` - ANSI escape codes for terminal output

Lines are wrapped in `<div class="line" data-line="N">` elements

### Supporting Modules
- `lib/autumn/native.ex` - RustlerPrecompiled configuration and NIF stubs
- `lib/autumn/errors.ex` - Exception definitions (Autumn.HighlightError)
- `lib/autumn/nif_structs.ex` - Internal structs for NIF communication (HtmlElement, HtmlInlineHighlightLines, HtmlLinkedHighlightLines)
- `lib/autumn/comptime_utils.ex` - Compile-time CPU capability detection for optimized binary selection

### Rust Implementation
- Located in `native/autumnus_nif/`
- Minimal NIF wrapper that delegates to the `autumnus` crate
- Cargo.toml specifies `autumnus` with features: `all-languages`, `nif_version_2_15`, `elixir-nif`
- All NIFs are scheduled on DirtyCPU for non-blocking operation
- Precompiled for multiple platforms (see `lib/autumn/native.ex` for target list)

## Elixir
- Read and think about these guidelines before making a plan: https://hexdocs.pm/elixir/code-anti-patterns.html, https://hexdocs.pm/elixir/design-anti-patterns.html, https://hexdocs.pm/elixir/process-anti-patterns.html, and https://hexdocs.pm/elixir/macro-anti-patterns.html
- Run `mix compile --all-warnings` to make sure changes are correct and fix any warnings
- Run `mix format` after making changes, but only after checking compilation warnings
- Try to remove dead code on `warning: variable "x" is unused`
- Prefer running specific tests with `mix test {file:line}` over the whole suite like `mix test`
- Prefer changing existing files or modules related to the topic in the context instead of creating new files or modules
- Place private functions near to where they are used and avoid placing them at the end of the module
- Do not add code comments unless I explicitly ask you to,
- Do not remove existing code comments unless I explicitly ask you to
- Write concise `@moduledoc` and `@doc` for modules and functions

## Changelog
- Follow the https://common-changelog.org format
- Create a "## Unreleased" section if it doesn't exist yet
- Add new entries into the "## Unreleased" section
- Short and concise descriptions
- Review existing entries for accuracy and clarity
- Fetch commits from latest release tag to HEAD

## Important Notes
- Options are defined using nimble_options so fetch https://hexdocs.pm/nimble_options/NimbleOptions.html before making changes
