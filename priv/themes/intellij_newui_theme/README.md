# JetBrains New UI Themes for [Zed](https://zed.dev/)

<p align="center">
	<a href="https://github.com/kpitt/zed-theme-intellij-newui/stargazers"><img alt="GitHub Stars" src="https://img.shields.io/github/stars/kpitt/zed-theme-intellij-newui?style=for-the-badge&labelColor=393B40&color=3574F0"></a>
	<a href="https://github.com/kpitt/zed-theme-intellij-newui/issues"><img alt="GitHub Issues" src="https://img.shields.io/github/issues/kpitt/zed-theme-intellij-newui?style=for-the-badge&labelColor=393B40&color=BD5757"></a>
	<a href="https://github.com/kpitt/zed-theme-intellij-newui/contributors"><img alt="GitHub Contributors" src="https://img.shields.io/github/contributors/kpitt/zed-theme-intellij-newui?style=for-the-badge&labelColor=393B40&color=24A394"></a>
</p>

This is a dark theme for the [Zed editor](https://zed.dev/) based on the UI theme and editor colors from the "New UI" for the JetBrains IntelliJ platform.  Currently, only the new "Dark" theme is implemented, but I plan to eventually add support for the "Light" and "Light with Light Header" themes as well.

The colors used for syntax highlighting should be an exact match to IntelliJ. However, some elements won't be highlighted in exactly the same way due to differences in the syntax queries.

The UI elements are a bit trickier, but I believe this comes close enough to at least be in the _spirit_ of the JetBrains New UI.  The Zed theme system is relatively new, and is still somewhat limited compared to the complexity of IntelliJ or even VSCode.  The documentation is also very minimal at this point, so determining which theme color controls a particular UI element, or finding all the different ways that a particular color might be used, still requires a lot of trial-and-error and searching of the Zed source code.

The Zed editor and its theme system are still evolving rapidly, so the behavior of the theme colors could change at any time.  If you notice an unexpected change in the appearance after installing a Zed update, please [create a GitHub issue](https://github.com/kpitt/zed-theme-intellij-newui/issues/new/choose), preferably including screenshots of both the before and after appearance.

## Usage

### Install via Zed Extensions

1. Open Zed
2. Use the command palette (`zed: extensions`) or the `Zed > Extensions` menu item to open the Extensions view.
3. Search for "JetBrains New UI Theme", then click `Install`.

### Install Manually

1. Download the [intellij-newui.json](./themes/intellij-newui.json) theme file.
2. Put the theme file into your `~/.config/zed/themes/` directory.

### Activate the Theme

1. Use `cmd-k cmd-t`, the command palette (`theme selector: toggle`), or the `Zed > Settings... > Select Theme...` menu item to open the theme selector.
2. Select the "JetBrains New Dark" theme.

## Known Issues

- Starting in Zed 0.137.2, there was a change that broke the ability to properly theme some of the UI buttons.  This affects the hover style most, but also changes some of the normal button backgrounds.  I opened [Zed issue #12592](https://github.com/zed-industries/zed/issues/12592) for the hover styling.

---

<p align="center">
  <a href="https://github.com/kpitt/zed-theme-intellij-newui/blob/main/LICENSE.txt"><img alt="License" src="https://img.shields.io/github/license/kpitt/zed-theme-intellij-newui?style=for-the-badge&labelColor=393B40&color=3574F0"></a>
</p>
