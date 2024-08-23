# Alabaster theme for [zed](https://zed.dev)

Port of the [Alabaster Sublime Scheme](https://github.com/tonsky/sublime-scheme-alabaster) by Nikita Prokopov for zed editor.

Currently, this is basically a theme generated with [theme-importer](https://github.com/zed-industries/zed/tree/main/crates/theme_importer) from the [tonsky/vscode-theme-alabaster](https://github.com/tonsky/vscode-theme-alabaster). It's a start, but it needs imporvements, so feel free to contribute.

## Screenshots

![Screenshot](./assets/screenshot.png)

## Installation

### Installing from the Zed Extension repository

Open the command palette with `Cmd+Shift+P` and run `zed: extensions`. Search for `Alabaster` and install it. Pick the theme in the theme selector with `Cmd+Shift+P` > `theme selector: toggle` > Alabaster.

### Installing from the repo

Downlad the `themes/alabaster-color-theme.json` and place it in your `~/.config/zed/themes` directory. Restart zed editor and select the theme in theme selector.

## Development setup

Fork and clone the repo. Link the repo to `~/Library/Application Support/Zed/extensions/installed` and run `Zed: reload extensions` command in zed editor.

## Current Limitations

Zed's bundled `highliting.scm` files at `https://github.com/zed-industries/zed/tree/main/crates/languages/src` often do not define all the queries for syntax nodes needed to style the theme. This means that some syntax nodes have different colors when compared to the original theme. It seems that currently it's not impossible to extend the `higlighting.scm` files with custom queries in the extension.
