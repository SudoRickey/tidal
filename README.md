 <div align="center">

# 🌊 Tidal

### A fluid desktop experience for Hyprland.

A custom desktop shell built with Quickshell, designed to bring a clean and cohesive experience to your Linux desktop.

<br/>

[![Arch Linux](https://img.shields.io/badge/OS-Arch%20Linux-1793D1?style=for-the-badge&logo=archlinux&logoColor=white)](https://archlinux.org/)
[![Hyprland](https://img.shields.io/badge/WM-Hyprland-58E1FF?style=for-the-badge)](https://hypr.land/)
[![Quickshell](https://img.shields.io/badge/Built%20with-Quickshell-8B7BFF?style=for-the-badge)](https://quickshell.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-82C91E?style=for-the-badge)](LICENSE)

<br/>

**[Features](#-features) · [Installation](#-installation) · [Customization](#-customization) · [Community](#-community)**

</div>

> [!WARNING]
> Tidal is still a work in progress. Bugs, incomplete features, and compatibility issues may occur. Use at your own risk.

---

## ✨ Features

- **Custom bar** — A minimal, modular desktop bar.
- **Interactive dashboard** — Quick access to system controls and useful widgets.
- **Workspace integration** — Navigate Hyprland workspaces.
- **Wallpaper controls** — Change wallpapers using included helper scripts.
- **System controls** — Convenient access to volume, brightness, media, and power actions where configured.
- **Hardware monitoring** — View system information and resource usage.
- **Calendar and clock** — Check the date and time from the dashboard.
- **Matugen theming** — Generate a coordinated color palette from your wallpaper.
- **Modular architecture** — Organized QML modules, reusable components, and configuration files.

## 📸 Preview

> Screenshots coming soon.

## 🚀 Installation

### Requirements

- Arch Linux or a compatible Linux distribution
- [Hyprland](https://hypr.land/)
- [Quickshell](https://quickshell.org/)
- Bash, Git, Python 3, and `rsync`
- [Matugen](https://github.com/InioX/matugen) for dynamic colors

### Recommended packages

Depending on the features you use, you may need:

- `quickshell`
- `hyprland`
- `swaybg`
- `pipewire`
- `wireplumber`
- `brightnessctl`
- `playerctl`
- `networkmanager`
- `git`
- `rsync`
- `python`

Package names and availability may vary by distribution.

### Setup

> [!IMPORTANT]
> Back up your existing Quickshell and Matugen configurations before installing. Review `install.sh` before running it.

**1. Clone the repository outside your existing Quickshell configuration directory.**

```bash
git clone https://github.com/SudoRickey/tidal.git ~/Tidal
cd ~/Tidal
```

**2. Run the installer.**

```bash
chmod +x install.sh
./install.sh
```

The installer is designed to:

- Back up existing Quickshell and relevant Matugen configuration files.
- Copy Tidal's shell files into `~/.config/quickshell`.
- Install Tidal's Matugen color template.
- Configure a dedicated `[templates.tidal]` section in Matugen.
- Adapt the color file path to your cache directory.

If existing configuration files are detected, the installer asks before proceeding. Files with matching names may be overwritten; unrelated files are intended to remain in place.

**3. Configure wallpaper-based colors.**

Make sure Matugen is installed and configured correctly. Generate the color palette using your preferred wallpaper and the Matugen command supported by your setup.

**4. Launch Tidal.**

```bash
qs -c ~/.config/quickshell
```

If Tidal is already running, restart Quickshell to load the updated files.

> [!NOTE]
> Tidal is designed for Hyprland and Quickshell. Other desktop environments and window managers are not currently guaranteed to work.

## 🎨 Customization

Tidal is organized into separate directories to make customization easier.

| Path | Purpose |
| --- | --- |
| `modules/` | Desktop modules, including the bar and dashboard |
| `modules/dashboard/` | Dashboard pages and controls |
| `components/` | Reusable UI components |
| `config/` | Colors, theme, and settings |
| `assets/` | Images and other visual assets |
| `scripts/` | Helper scripts and wallpaper controls |
| `matugen/templates/` | Matugen color templates |
| `shell.qml` | Main shell entry point |

Edit the QML files to customize the layout, behavior, and appearance of Tidal.

### Updating Tidal

If you installed Tidal by cloning the repository, enter your clone directory and pull the latest changes:

```bash
cd ~/Tidal
git pull
```

Review changes before restarting Quickshell, especially if you have customized files in `~/.config/quickshell`.

## 💬 Community

Want to share your setup, suggest features, report bugs, or get help with Tidal?

**Join the Tidal community on Discord!**

[![Discord](https://img.shields.io/badge/Discord-Join%20the%20community-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/YOUR_INVITE_CODE)

> Replace `YOUR_INVITE_CODE` with your actual Discord server invite before publishing.

## 📄 License

Tidal is licensed under the [MIT License](LICENSE).

---

<div align="center">

🌊 Tidal is made with care by [SudoRickey](https://github.com/SudoRickey).

*Made solo.*

</div>
