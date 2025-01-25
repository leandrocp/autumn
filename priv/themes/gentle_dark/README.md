# Siri

![Siri icon](https://raw.githubusercontent.com/perragnar/zed-theme-siri/main/assets/icon-xs.jpg)

A dark and light theme for the awesome [Zed editor](https://zed.dev). This is a very early version and a work in progress.

# Siri Code

This is a theme that is based on Visual Studio Code's dark modern theme. I have made some changes though.

![Siri Light theme](https://raw.githubusercontent.com/perragnar/zed-theme-siri/main/assets/screenshot-siri-code.png)

## Siri Dark

Siri Dark is basically the default One Dark but with a few tweaks to make it (in my opinion) a little nicer.

![Siri Dark theme](https://raw.githubusercontent.com/perragnar/zed-theme-siri/main/assets/screenshot-siri-dark.png)

## Siri Light

Siri Light is a work in progress. The goal is to make a nice light theme that is not too bright. Right now it has a bluish palette but it might change later on.

![Siri Light theme](https://raw.githubusercontent.com/perragnar/zed-theme-siri/main/assets/screenshot-siri-light.png)

## Font

In the screenshot I'm using the font [JetBrains mono](https://www.jetbrains.com/lp/mono).

## Indent guides

If you also like the indent guide to only show up on the active indent you can add this to your settings file:

```json
"experimental.theme_overrides": {
  "editor.indent_guide": "#88888800",
  "editor.indent_guide_active": "#88888844"
}
```

It will make all indent guides transparent and the active guide to a semitransparent gray that will work on most dark and light backgrounds. Change the `indent_guide_active` to a different color if you like.

## Siri?

Siri is my dog, btw.
