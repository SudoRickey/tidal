# Tidal

*A Quickshell rice for Hyprland.*

Tidal is a personal desktop shell built with **Quickshell** on **Arch Linux** and **Hyprland**. Designed to be clean, modular, and customizable.

> 🌊 Make Tidal your OWN desktop.

## ✨ Features

- **Custom bar** — A minimal desktop bar with workspaces and system information.
- **Dashboard** — Quick access to system controls and useful widgets.
- **Modular design** — Organized QML components, modules, and configuration.
- **Wallpaper controls** — Change wallpapers with helper scripts.
- **Hyprland integration** — Built for a Wayland desktop powered by Hyprland.
- **Ready to 

## 🖥️ Built With

- [Quickshell](https://quickshell.org/)
- [Hyprland](https://hypr.land/)
- QML

## 📁 Structure

```text
quickshell/
├── shell.qml
├── components/
├── config/
├── modules/
├── scripts/
├── README.md
└── LICENSE
```

## 🚀 Installation

> These instructions are a starting point. Dependencies and setup steps may vary depending on your configuration.

1. Install [Quickshell](https://quickshell.org/) and [Hyprland](https://hypr.land/).
2. Back up your existing Quickshell configuration.
3. Clone Tidal:

   ```bash
   git clone https://github.com/SudoRickey/tidal.git
   ```

4. Copy the repository's configuration files into `~/.config/quickshell/`.
5. Launch Quickshell using your usual setup.

Review the configuration and scripts before running them. Your setup may require additional tools, fonts, or wallpaper utilities.

## 🎨 Customization

built in theme are based on the users wallpaper theme.

Explore `config/` to adjust the theme and settings, `modules/` to customize shell modules, and `components/` to modify reusable UI elements.
customize setting gui coming soon.

## 📄 License

Tidal is released under the [MIT License](LICENSE).
