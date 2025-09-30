# Changelog

## Unreleased

### Changed
- Updated languages: latex, markdown, powershell, c_sharp, fsharp, go, make, ocaml, proto, python, scala, zig, css, proto

## 0.5.4 (2025-09-18)

### Enhancements
- Add utility function `validate_options!/1` function to validate options against the schema

## 0.5.3 (2025-09-18)

### Enhancements
- Add `default_options/0` to expose default options

### Changed
- Hide `formatter_schema/0` which was supposed to be private, although it's still available
- Hide `options_schema/0` which was supposed to be private, although it's still available

## 0.5.2 (2025-08-20)

### Changed

- Update `autumnus` to v0.7.3
- Update CSS files

## 0.5.1 (2025-08-11)

### Changed

- Update `autumnus` to v0.7.1

## 0.5.0 (2025-07-26)

### Changed

- **Breaking** Change line wrapper tags from `<span>` to `<div>` for better HTML semantics
- **Breaking** (html_linked) Change default highlight class from `cursorline` to `highlighted`
- **Breaking** Replace `.cursorline` with `.highlighted` in CSS files
- (html_inline) Add option `:class` to highlight lines
- Allow to disable option `:style` to highlight lines
- Add language `caddy`
- Add language `fish`
- Update themes
- Update CSS files
- Build target `x86_64-pc-windows-msvc` on Windows 2022

## 0.4.1 (2025-06-20)

### Changed

- Doc `:highlight_lines` and `:header` options in HTML formatters
- Properly validate `:highlight_lines` option in HTML formatters
- Properly validate `:header` option in HTML formatters

## 0.4.0 (2025-06-19)

### Enhancements
  * Add `Autumn.Theme.from_file/1` to load themes from JSON files
  * Add `Autumn.Theme.from_json/1` to load themes from JSON strings
  * Add `:highlight_lines` option to HTML formatters to highlight specific lines
  * Add `:header` option to HTML formatters to include a wrapper tag around the highlighted code
  * Update parsers: angular, c, cmake, comment, hcl, liquid, llvm, ocaml, perl, vim, vue, yaml
  * Update queries: cmake, elm, fsharp, html, latex, php, vue
  * Update themes: flexoki, modus operandi, moonfly, nightfly
  * Add themes: horizon, horizon_dark, horizon_light, iceberg, molokai, moonlight, nordfox, papercolor_dark, papercolor_light, srcery, zenburn
  * Add languages: assembly, dart
  * Add cursorline highlight in themes
  * Add Elixir ~V live_svelte injection
  * Update CSS files

## 0.3.3 (2025-05-21)

### Enhancements
  * Add neovim light and dark themes - @mhanberg
  * Update CSS files
  * Update `autumnus` to v0.3.2

## 0.3.2 (2025-04-18)

### Enhancements
  * Added target `arm-unknown-linux-gnueabihf`
  * Added target `riscv64gc-unknown-linux-gnu`
  * Added `formatter_schema/0` and `options_schema/0` to expose options schema
  * Update Autumnus to v0.3.0

## 0.3.1 (2025-04-08)

### Enhancements
  * Validate options
  * Update Autumnus to v0.2.0

## 0.3.0 (2025-03-14)

Note this version introduces breaking changes, please open an issue if these changes has caused any issues.

* Now using Neovim themes instead of Helix themes so some themes may look different and others may not be available.
* Language parsers have been updated so tokens may be different.

### Enhancements
  * Wrap each line in a span tag with the line number, eg: `<span class="line" data-line="1">...</span>`
  * Added a `Terminal` formatter that outputs ANSI escape codes

### Changed
  * Replaced https://crates.io/crates/inkjet with https://crates.io/crates/autumnus
  * Change class names and structure of the generated HTML

## 0.2.5 (2025-01-09)

### Fixes
  * Escape curly braces with `&lbrace;` and `&rbrace;`

### Chores
  * Update release targets
  * Update deps

## 0.2.4 (2024-12-13)

### Fixes
  * Escape curly braces to avoid syntax errors on HEEx templates (support LiveView 1.0)

### Enhancements
  * Update ex_doc to v0.34

### Chores
  * Bump min required Elixir to v1.13

## 0.2.3 (2024-04-29)

### Enhancements
  * Update inkjet to v0.10.5
  * Add objc language

## 0.2.2 (2024-04-11)

### Enhancements
  * Add more languages: eex, elm, iex, jsx, ocaml, ocam-interface, svelte, tsx, vim

## 0.2.1 (2024-04-11)

### Backwards incompatible changes
  * Renamed parent `<pre>` class from `autumn-highlight` to `autumn-hl`
  * Added prefix `ahl-` to each scope class

### Fixes
  * Include CSS files in package

## 0.2.0 (2024-04-10)

### Enhancements
  * Update to Inkjet v0.10.4
  * Update themes
  * Update languages
  * Add Pascal language
  * Add new option `:inline_style` to enable/disable inline styles
  * Genrate CSS files

### Fixes
  * Name of CSS classes should be unique and composable

## 0.1.5 (2023-11-20)

### Enhancements
  * Add themes base16-tomorrow and base16-tomorrow-night - @paradox460

## 0.1.4 (2023-10-25)

### Fixes
  * Remove newlines to avoid breaking formatting

## 0.1.3 (2023-10-24)

### Enhancements
  * Add translate="no" attr in `<code>` tag

### Fixes
  * Fix Javascript grammar
  * Fix Typescript grammar

### Enhancements
  * Add icon

## 0.1.2 (2023-09-29)

### Enhancements
  * Add logo

### Fixes
  * Fix broken image links in docs

## 0.1.1 (2023-09-29)

### Enhancements
  * Fallback to plain text on invalid language
  * Add samples

### Fixes
  * Do not render the first line empty
  * Make sure languages are loaded correctly

## 0.1.0 (2023-09-28)

### Enhancements
  * Add `Autumn.highlight/3`
  * Add `Autumn.highlight!/3`
