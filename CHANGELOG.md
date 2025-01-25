# Changelog

## 0.3.0-dev

Starting on this version, Zed grammars and themes are used instead of Helix.
Most languages and themes have been migrated but differences in colors and parsers
might be present. Please open an issue if something is missing or incorrect.

### Breaking changes
  * Renamed parent `<pre>` class from `autumn-hl` to `athl`
  * Renamed each span class prefix from `ahl-` to `athl-` to keep the same pattern as the `pre` tag
  * Removed the option `:inline_style` in favor of `:formatter`
  * Removed the option `:pre_class` in favor of `:formatter`

### Enhancements
  * Added formatters: `:html_inline`, `:html_linked`, `:terminal`
  * Added `%Autumn.Theme{}` to hold styles and allow customization at runtime
  * Added `Autumn.available_themes/0`
  * Added `Autumn.available_languages/0`

### Chores
  * Removed [inkjet](https://crates.io/crates/inkjet) in favor of a custom highlighter

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

### Breaking changes
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
