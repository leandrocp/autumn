# Changelog

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
