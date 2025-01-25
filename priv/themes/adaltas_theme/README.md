
# Adaltas theme

The [Adaltas](https://www.adaltas.com) theme is an elegantly designed dark theme with sharp contrast colors for the Zed editor. The theme is MIT licensed.

![Theme preview](./assets/preview.png)

## Developpers

Please report any issue and improvement request on the [GitHub](https://github.com/adaltas/zed-adaltas-theme/issues).

A penpot file is located inside the [./assets] folder to preview and tweak the colors.

## Colors

### UI

It extends Andromeda with alternative colors. New colors are written in uppercase to differentiate them from the original theme.

```json
{
  "experimental.theme_overrides": {
    "border": "#3F495FFF",
    "border.variant": "#59657EFF",
    "status_bar.background": "#1D2028FF",
    "title_bar.background": "#1D2028FF",
    "title_bar.inactive_background": "#21242bff",
    "toolbar.background": "#272F3EFF",
    "tab_bar.background": "#1D2028FF",
    "tab.inactive_background": "#232936FF",
    "tab.active_background": "#354265FF",
    "search.match_background": "#11A79366",
    "panel.background": "#1D2028FF",
    "editor.foreground": "#F1EFE6FF",
    "editor.background": "#272F3EFF",
    "editor.gutter.background": "#272F3EFF",
    "editor.active_line.background": "#394256FF",
    "terminal.ansi.black": "#E8E4CFFF",
    "terminal.ansi.bright_black": "#989898FF",
    "created": "#62E6CAFF",
    "modified": "#FFDD89FF",
    "text": "#F1EFE6FF",
    "text.muted": "#D2E3EAFF"
  }
}
```

### Syntax

```json
{
  "experimental.theme_overrides": {
    "syntax": {
      "attribute": {
        "color": "#E88DFFFF"
      },
      "boolean": {
        "color": "#96df71ff"
      },
      "comment": {
        "color": "#afabb1ff"
      },
      "comment.doc": {
        "color": "#afabb1ff"
      },
      "constant": {
        "color": "#52D4C9FF"
      },
      "constructor": {
        "color": "#E88DFFFF"
      },
      "embedded": {
        "color": "#f7f7f8ff"
      },
      "emphasis": {
        "color": "#E88DFFFF"
      },
      "emphasis.strong": {
        "color": "#E88DFFFF",
        "font_weight": 700
      },
      "enum": {
        "color": "#82FABDFF"
      },
      "function": {
        "color": "#fee56cff"
      },
      "hint": {
        "color": "#618399ff",
        "font_weight": 700
      },
      "keyword": {
        "color": "#E88DFFFF"
      },
      "label": {
        "color": "#E88DFFFF"
      },
      "link_text": {
        "color": "#82FABDFF",
        "font_style": "italic"
      },
      "link_uri": {
        "color": "#FF77A7FF"
      },
      "number": {
        "color": "#96df71ff"
      },
      "operator": {
        "color": "#82FABDFF"
      },
      "predictive": {
        "color": "#315f70ff",
        "font_style": "italic"
      },
      "preproc": {
        "color": "#f7f7f8ff"
      },
      "primary": {
        "color": "#f7f7f8ff"
      },
      "property": {
        "color": "#59CDFFFF"
      },
      "punctuation": {
        "color": "#d8d5dbff"
      },
      "punctuation.bracket": {
        "color": "#d8d5dbff"
      },
      "punctuation.delimiter": {
        "color": "#d8d5dbff"
      },
      "punctuation.list_marker": {
        "color": "#d8d5dbff"
      },
      "punctuation.special": {
        "color": "#d8d5dbff"
      },
      "string": {
        "color": "#82FABDFF"
      },
      "string.escape": {
        "color": "#82FABDFF"
      },
      "string.regex": {
        "color": "#82FABDFF"
      },
      "string.special": {
        "color": "#82FABDFF"
      },
      "string.special.symbol": {
        "color": "#82FABDFF"
      },
      "tag": {
        "color": "#E88DFFFF"
      },
      "text.literal": {
        "color": "#82FABDFF"
      },
      "title": {
        "color": "#D59AFFFF"
      },
      "type": {
        "color": "#08e7c5ff"
      },
      "variable": {
        "color": "#C4EDFFFF"
      },
      "variable.special": {
        "color": "#C4EDFFFF"
      },
      "variant": {
        "color": "#E88DFFFF"
      }
    }
  }
}
```

## Sponsor

The theme is `developed` by [Adaltas](https://www.adaltas.com), a company offering support and consulting on distributed systems, big data and open source technologies.
