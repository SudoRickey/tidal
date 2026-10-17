# Tidal

<div align="center">

# 🌊 Tidal

### A fluid desktop experience for Hyprland.

A custom desktop shell built with Quickshell, designed to bring a clean and cohesive experience to your Linux desktop.

>[!WARNING]
> Tidal is NOT COMPLETE. May have some bugs when using.

<br/>

[![Arch Linux](https://img.shields.io/badge/OS-Arch%20Linux-1793D1?style=for-the-badge&logo=archlinux&logoColor=white)](https://archlinux.org/)
[![Hyprland](https://img.shields.io/badge/WM-Hyprland-58E1FF?style=for-the-badge)](https://hypr.land/)
[![Quickshell](https://img.shields.io/badge/Built%20with-Quickshell-8B7BFF?style=for-the-badge)](https://quickshell.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-82C91E?style=for-the-badge)](LICENSE)

<br/>

**[Features](#-features) · [Installation](#-installation) · [Customization](#-customization) · [Community](#-community)**

</div>

---

## ✨ Features

- **Custom bar** — A minimal, modular desktop bar.
- **Interactive dashboard** — Quick access to system controls and useful widgets.
- **Workspace integration** — Navigate your Hyprland workspaces.
- **Wallpaper controls** — Change wallpapers using included helper scripts.
- **System controls** — Convenient access to volume, brightness, and power actions where configured.
- **Modular architecture** — Organized QML modules, reusable components, and configuration files.

## 📸 Preview

> Screenshots coming soon.


## 🚀 Installation

### Requirements

- Arch Linux or a compatible Linux distribution
- [Hyprland](https://hypr.land/)
- [Quickshell](https://quickshell.org/)
> [!NOTE]
> Additional utilities may be required depending on the modules and scripts you use.

### Setup

>[!IMPORTANT]
> Packages that are needed: 
>  ```bash Quickshell Swaybg Hyprland pipewire wireplumber  brightnessctl playerctl networkmanager git
   ```

1. Back up your existing Quickshell configuration.
2. Clone the repository:

   ```bash
   git clone https://github.com/SudoRickey/tidal.git
   ```

3. Copy the configuration into your Quickshell config directory:

   ```bash
   mkdir -p ~/.config/quickshell
   cp -r tidal/. ~/.config/quickshell/
   ```

4. Launch Tidal:

   ```bash
   qs -c ~/.config/quickshell
   ```

Review the configuration and scripts before running them. Existing configurations may be overwritten during setup.

## 🎨 Customization

Tidal is organized into separate directories to make customization easier.

| Directory | Purpose |
| --- | --- |
| `modules/` | Desktop modules such as the bar and dashboard |
| `components/` | Reusable UI components |
| `config/` | Theme, colors, and settings |
| `scripts/` | Helper scripts and wallpaper controls |
| `shell.qml` | Main shell entry point |

Customize the QML files to make Tidal your own.

## 💬 Community

Want to share your setup, suggest features, report bugs, or get help with Tidal?

**Join the Tidal community on Discord!**

[![Discord](https://img.shields.io/badge/Discord-Join%20the%20community-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/YOUR_INVITE_CODE)

## 📄 License

Tidal is licensed under the [MIT License](LICENSE).

---

<div align="center">

🌊Tidal is made by [SudoRickey](https://github.com/SudoRickey)
(made solo)
</div>
