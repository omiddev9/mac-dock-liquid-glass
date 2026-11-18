# Mac Dock Liquid Glass

![Mac Dock Liquid Glass](preview.png)

A macOS-style dock for the Omarchy shell with fisheye magnification, a liquid-glass
surface, Hyprland backdrop blur, and optional taskbar styling sync.

Mac Dock Liquid Glass is built for Omarchy's Quickshell-based shell. It provides a
continuous magnifier, smart hide/reveal, window cycling, running indicators,
drag-to-reorder, hover labels, themed tiles, icon tinting, and a settings popup.

## Features

- Continuous fisheye magnification with Gaussian or quadratic falloff
- Liquid-glass card with blur, tint, border glow, and corner shaping
- Smart hide with pressure reveal and intelli-hide for overlapping windows
- Window controls: launch, focus, minimize, cycle windows, and new-window actions
- Running indicators, running-app sections, and per-app window counts
- Drag to reorder and drag running apps across the divider to pin them
- Hover labels, themed tiles, icon tinting, monochrome mode, and border glow
- Taskbar styling sync for opacity, corners, and glow
- Programmatic configurator: `omarchy-dock-config`

## Requirements

- Omarchy (Hyprland + the Quickshell-based `omarchy-shell`)
- `jq`
- `flock` (util-linux)
- `python3` (only for taskbar styling sync)

## Install

```bash
omarchy plugin add https://github.com/omiddev9/mac-dock-liquid-glass --enable
```

The plugin seeds a starter set of pinned apps on first use. Optional extras:

- **Blur behind the dock** — copy `hypr/dock.lua` to
  `~/.config/hypr/dock.lua` and add `pcall(require, "hypr.dock")` to
  `~/.config/hypr/hyprland.lua`.
- **Configurator on PATH**:
  `ln -s ~/.config/omarchy/plugins/io.github.omiddev9.mac-dock-liquid-glass/bin/omarchy-dock-config ~/.local/bin/`

### From a checkout

```bash
git clone https://github.com/omiddev9/mac-dock-liquid-glass ~/src/mac-dock-liquid-glass
cd ~/src/mac-dock-liquid-glass
./install.sh
```

`install.sh` is idempotent, backs up displaced files, and supports `--dry-run`.

## Configure

```bash
omarchy-dock-config --help
```

Right-click the dock and choose **Settings** for common options. All writes go
through `omarchy-dock-config`, so changes apply immediately.

## Taskbar styling sync

The sync toggles can mirror the dock's opacity, corner shape, and border glow onto
the Omarchy taskbar. On first use, the configurator installs the required support
into a user-owned taskbar clone and restarts the shell once.

## Uninstall

```bash
./uninstall.sh
```

Use `./uninstall.sh --purge-config` to also remove the dock entry from
`shell.json`. The uninstaller only removes links that point back into this
checkout.

## Author

Omid.Developer

## License

MIT
```