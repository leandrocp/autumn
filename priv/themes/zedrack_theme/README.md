![preview](/assets/preview.png)

<a href="https://github.com/foorack/zed-theme/blob/main/LICENSE">
    <img src="https://img.shields.io/static/v1.svg?style=for-the-badge&label=License&message=MIT&logoColor=000000&colorA=003b4e&colorB=00bfff"/>
</a>
<a href="https://github.com/foorack/zed-theme/stargazers">
    <img src="https://img.shields.io/github/stars/foorack/zed-theme?colorA=003b4e&colorB=00bfff&style=for-the-badge">
</a>

# Zedrack Theme

## Usage

Zedrack is a Vim-insipred strong-contrast transparent theme, for the [zed.dev](https://zed.dev/) editor.

### Install via Zed Extensions

1. Open Zed.
2. <kbd>cmd+shift+p</kbd> and select _zed: extensions_
3. Select "Zedrack Theme" and Install
4. Search **Zedrack** theme in the dropdown shown after hitting <kbd>cmd+k</kbd>, <kbd>cmd+t</kbd>


## Development

<details>

#### Publishing to Zed Extensions Marketplace

Zed organizes all extensions using `git submodules` in the [zed/extensions](https://github.com/zed-industries/extensions) repo.

1. [Fork the repo](https://github.com/zed-industries/extensions/fork)
2. Pull the currently published `extensions/zedrack-theme/` submodule

   ```
   git submodule update --init --force extensions/zedrack-theme
   ```

3. Bump the submodule

   ```
   cd extensions/zedrack-theme/ && git pull origin main
   ```

4. Modify the extensions/`extensions.toml` version to match value in [zedrack-theme/extension.toml](./extension.toml#L4)
5. Submit a PR to merge back to `zed/extensions`

</details>