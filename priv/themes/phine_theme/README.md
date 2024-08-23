# Phine zed theme
A dark theme I maintain for myself. Enjoy!

## Variables support
I wrote a small helper application to substitute variables in the theme file. This is helpful until zed themes have implemented variable support natively.
You can check it out in the [phisch/variable-substitutor](https://github.com/phisch/variable-substitutor) repository.

Here is a quick guide on how to use it:

```sh
git clone git@github.com:phisch/variable-substitutor.git
cargo build --release --manifest-path variable-substitutor/Cargo.toml
./variable-substitutor/target/release/substitutor -o ~/.config/zed/themes/phine.json themes/phine.json -w
```

Or, even easier, just run the `Setup variable-substitutor` zed task, and then the `Start theming` one, which will watch the theme and variable source and continuously update the `~/.config/zed/themes/phine.json` theme file, so you can see live updates in zed.

## Building

Run the `Setup variable-substitutor` task and then the `Build Theme` task. This will build into the `themes` directory.
