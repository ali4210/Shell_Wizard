<div align="center">

# 🧙‍♂️ Shell-Wizard Ultimate

**A cross-platform terminal beautification and modernization toolkit for Linux, macOS, and Windows.**

Fonts, prompts, themes, plugins, modern CLI tools, and safe backups, all from one interactive menu.

![Shell](https://img.shields.io/badge/Bash-4EAA25?style=flat&logo=gnubash&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?style=flat&logo=powershell&logoColor=white)
![Platforms](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS%20%7C%20Windows-blue)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

</div>

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Supported Platforms](#supported-platforms)
- [Quick Start](#quick-start)
- [Optional: Global Command](#optional-global-command-shell-wizard)
- [Modules](#modules)
- [Windows PowerShell Engine](#windows-powershell-engine)
- [Included Themes](#included-oh-my-posh-themes-windows)
- [Repository Structure](#repository-structure)
- [Safety and Permissions](#safety-and-permissions)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [Author](#author)
- [License](#license)

---

## Overview

Setting up a good terminal usually means installing fonts, editing `.zshrc`, cloning theme repos, picking prompts, and swapping out old CLI tools, all by hand. **Shell-Wizard Ultimate** automates that whole process behind a simple menu-driven interface.

It detects your OS, backs up your existing configuration, then lets you pick exactly what to apply: a Nerd Font, Oh My Zsh with plugins, Starship, Oh My Posh, Spaceship, Pure, Atuin history, and a set of modern Rust/Go CLI replacements.

---

## Features

- 🔐 **Backup and rollback**: timestamped snapshots of your shell configs with one-click restore
- 🔤 **Nerd Font installer**: MesloLGS NF and JetBrainsMono Nerd Font, with font-cache refresh
- ⚡ **Zsh supercharger**: Oh My Zsh, autosuggestions, syntax highlighting, completions, Powerlevel10k and more
- 🛠️ **CLI modernization**: `eza`, `bat`, `fzf`, `fastfetch`, `fd`, `ripgrep` with smart aliases
- 🚀 **Starship presets**: Gruvbox Rainbow, Tokyo Night, Nerd Font Symbols, Bracketed, Plain
- 🌌 **Next-gen prompts**: Oh My Posh sub-themes, Spaceship presets, Pure, and Atuin history search
- 🔄 **Instant reload**: apply changes without closing your terminal
- 🪟 **Native Windows engine**: PowerShell orchestrator with dry-run mode, live theme preview, and verified backups
- 🌍 **Global command**: run `shell-wizard` from any directory

---

## Supported Platforms

| Platform | Entry point | Package managers used | Status |
|----------|-------------|-----------------------|--------|
| Windows 10 / 11 | `autorun.bat` or `shell-wizard.bat` | `winget` | ✅ Stable, all modules working |
| Linux (Debian, Ubuntu, Kali, Fedora/RHEL, Arch) | `autorun.sh` | `apt`, `dnf`, `pacman` | 🚧 Under active development |
| macOS | `autorun.sh` | `brew` | 🚧 Under active development |

> **Project status:** Shell-Wizard is designed as a universal tool for all three platforms. The **Windows PowerShell engine is complete and fully runnable**. The Linux/macOS bash modules are still being finished and stabilized, so expect rough edges there. Bug reports and pull requests for Linux/macOS are especially welcome.

---

## Quick Start

Shell-Wizard has one launcher per operating system. Run it and use the on-screen menu.

| Your OS | Launch with | How |
|---------|-------------|-----|
| 🪟 **Windows** | **`autorun.bat`** | Right-click → **Run as administrator** |
| 🐧 **Linux** / 🍎 **macOS** | **`autorun.sh`** | `./autorun.sh` in a terminal |

The launcher shows an OS selection menu, then opens the matching engine. Installing the global `shell-wizard` command is **optional** (see [below](#optional-global-command-shell-wizard)).

**Prerequisites:** `git` and `curl` (Linux/macOS), `winget` (Windows 10/11), and an internet connection for downloading fonts and tools.

### 🐧 Linux / macOS (🚧 under active development)

```bash
git clone https://github.com/ali4210/Shell_Wizard.git
cd Shell_Wizard
chmod +x autorun.sh
./autorun.sh
```

If any script complains about permissions, run the sanitizer:

```bash
bash fix-perms.sh
```

### 🪟 Windows

```powershell
git clone https://github.com/ali4210/Shell_Wizard.git
cd Shell_Wizard
```

1. Right-click **`autorun.bat`** and choose **Run as administrator**.
   (Alternatively, double-click **`shell-wizard.bat`**, which requests elevation for you and then runs `autorun.bat`.)
2. In the gateway menu, choose **[3] Windows Host** to launch the PowerShell engine.
3. Pick a capability from the Windows menu (backup, supercharge, themes, prompts, CLI tools, fonts).

> **Note:** Administrator rights are needed on Windows because the tool installs fonts and CLI tools through `winget`.

---

## Optional: Global Command (`shell-wizard`)

Not required. `autorun.sh` / `autorun.bat` work on their own. If you want to start the tool from any folder by typing `shell-wizard`, install the global command once.

**Linux / macOS**

```bash
bash install.sh
```

This makes scripts executable and symlinks `autorun.sh` to `/usr/local/bin/shell-wizard` (uses `sudo`). Then, from any terminal:

```bash
shell-wizard
```

**Windows**

```powershell
.\install.ps1
```

This creates a `shell-wizard.bat` wrapper in `%LOCALAPPDATA%\Microsoft\WindowsApps` and adds a `shell-wizard` function to your PowerShell profile. If your execution policy is `Restricted` or `Undefined`, the installer asks for your consent before changing it to `RemoteSigned` for the **current user only**. Open a new PowerShell window afterwards.

---

## Modules

The Linux/macOS engine (`linux/shell-wizard.sh`) is a menu that dispatches to the modules below. *(This engine is still under active development; the Windows engine, described in the next section, is the fully working one.)*

| # | Module | File | What it does |
|---|--------|------|--------------|
| 1 | Safety & Backup Engine | `backup-engine.sh` | Snapshots `.zshrc`, `.bashrc`, `.p10k.zsh`, `starship.toml`, and Fish config into `~/.shell_wizard_backups/`, with an interactive restore menu |
| 2 | Nerd Font Injector | `font-engine.sh` | Scans for Nerd Fonts, installs MesloLGS NF or JetBrainsMono Nerd Font, and shows terminal setup directions |
| 3 | ZSH Supercharger | `zsh-engine.sh` | Installs Oh My Zsh and plugins; switches between Powerlevel10k, Agnoster, Robbyrussell, Bira, and Simple |
| 4 | CLI Modernization | `cli-tools.sh` | Installs modern tools and injects aliases (`ls`→`eza`, `cat`→`bat`, `sysinfo`→`fastfetch`) |
| 5 | Starship Suite | `starship-engine.sh` | Installs Starship and applies presets |
| 6 | Next-Gen Themes | `nextgen-engine.sh` | Oh My Posh sub-themes, Spaceship presets, Pure prompt, Atuin history |
| 7 | Instant Reload | `reload-engine.sh` | Restarts the active shell (`exec zsh` / `exec bash`) to apply changes |

### Modern CLI replacements

| Legacy | Replacement | Benefit |
|--------|-------------|---------|
| `ls` | `eza` | Icons, colors, tree view |
| `cat` | `bat` | Syntax highlighting |
| `find` | `fd` | Faster, friendlier syntax |
| `grep` | `ripgrep` (`rg`) | Very fast recursive search |
| `neofetch` | `fastfetch` | Faster system info |
| `Ctrl+R` history | `atuin` | Searchable SQLite history |

---

## Windows PowerShell Engine

`modules/shell-wizard.ps1` is a full orchestrator built for Windows.

- **Managed profile block**: Shell-Wizard only edits the section of `$PROFILE` between its own `SHELL-WIZARD MANAGED BLOCK` markers, leaving the rest of your profile untouched.
- **Dry-run mode**: press `D` in the main menu to preview every change before anything is written.
- **Verified backups**: SHA-256 hashed, atomic copies of your PowerShell profile and Windows Terminal `settings.json`, with a manifest and automatic pruning to the 10 most recent snapshots. Restoring also saves a safety snapshot of your current state first.
- **Live theme preview**: see the prompt rendered before you apply it.
- **Windows Terminal font injection**: sets the Nerd Font in `settings.json` automatically (with a backup).
- **State tracking**: active engine, theme, font, and installed tools are stored in `~/.shell_wizard/current.json`.
- **Idempotent CLI installer**: checks for 15 tools and installs only what is missing via `winget`: `eza`, `bat`, `fastfetch`, `atuin`, `starship`, `ripgrep`, `zoxide`, `fzf`, `lazygit`, `delta`, `fd`, `dust`, `procs`, `bottom`, `gh`.
- **Prompt engines**: Oh My Posh, Starship, Posh-Git, or a dependency-free native prompt.
- **Font Studio**: CascadiaCode, JetBrainsMono, or FiraCode Nerd Font, plus a reset to Cascadia Mono.

---

## Included Oh My Posh Themes (Windows)

Eleven themes ship locally in `modules/themes/`, so theme switching works offline.

`Jebree` · `Paradox` · `Agnoster` · `Bubbles` · `Dracula` · `Blueish` · `Tokyo Night` · `Catppuccin Mocha` · `Gruvbox` · `Nord` · `Rose Pine`

> All prompt themes rely on Nerd Font glyphs. Set your terminal font to a Nerd Font or icons will render as boxes.

---

## Repository Structure

```text
Shell_Wizard/
├── autorun.sh              # Linux/macOS gateway launcher
├── autorun.bat             # Windows gateway launcher (requires admin)
├── shell-wizard.bat        # Windows launcher with auto-elevation
├── install.sh              # Global CLI installer (Linux/macOS)
├── install.ps1             # Global CLI installer (Windows)
├── fix-perms.sh            # Sets +x on all .sh files
├── banner_wrapper.txt      # ASCII banner for the Windows gateway
├── README.md
├── linux/
│   └── shell-wizard.sh     # Linux/macOS main menu engine
└── modules/
    ├── backup-engine.sh    # Module 1: backup and restore
    ├── font-engine.sh      # Module 2: Nerd Fonts
    ├── zsh-engine.sh       # Module 3: Zsh / Oh My Zsh / P10K
    ├── cli-tools.sh        # Module 4: modern CLI tools
    ├── starship-engine.sh  # Module 5: Starship
    ├── nextgen-engine.sh   # Module 6: Oh My Posh / Spaceship / Pure / Atuin
    ├── reload-engine.sh    # Module 7: instant reload
    ├── shell-wizard.ps1    # Windows PowerShell orchestrator
    ├── banner.txt          # ASCII banner
    └── themes/             # 11 Oh My Posh theme files (.omp.json)
```

---

## Safety and Permissions

Shell-Wizard changes shell configuration files and installs software, so please read this before running it:

- **Back up first.** Use Module 1 (Linux/macOS) or the Safety & Backup Engine (Windows) before applying anything.
- **`sudo` / admin is used** for package installs and for creating the global `/usr/local/bin/shell-wizard` symlink on Linux/macOS.
- **Remote installers are downloaded and executed** for Oh My Zsh, Starship, Oh My Posh, and Atuin, each from its official source. Review them if you have strict security requirements.
- **Windows launchers use `-ExecutionPolicy Bypass`** for the session that runs the engine. `install.ps1` only changes the policy with your explicit consent and only for the current user.
- Use **Dry-Run mode** on Windows to preview changes.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `Permission denied` on a script | Run `bash fix-perms.sh` or `chmod +x autorun.sh` |
| Icons show as `□` or `?` | Install a Nerd Font and select it in your terminal settings (Module 2, option 4 has directions) |
| `shell-wizard` not found after install | Open a **new** terminal window |
| Changes not visible | Use Module 7, or run `exec zsh` / `exec bash` |
| Windows: "Administrator privileges required" | Right-click `autorun.bat` → **Run as administrator**, or use `shell-wizard.bat` |
| Windows: theme resets on new tab | Allow the execution policy change in `install.ps1`, or run `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` |
| Restore a previous state | Linux/macOS: Module 1 → option 2. Windows: option 1 → Rollback |

---

## Contributing

Contributions, bug reports, and suggestions are welcome.

1. Fork the repository
2. Create a branch: `git checkout -b feature/my-feature`
3. Commit your changes: `git commit -m "Add my feature"`
4. Push: `git push origin feature/my-feature`
5. Open a Pull Request

---

## Author

**Saleem Ali**: DevOps / Security enthusiast and open-source contributor

- GitHub: [github.com/ali4210](https://github.com/ali4210)
- LinkedIn: [linkedin.com/in/saleem-ali-189719325](https://www.linkedin.com/in/saleem-ali-189719325/)

If this project helped you, consider giving it a ⭐ on GitHub.

---

## License

Distributed under the **MIT License**. See the `LICENSE` file for details.

---

<div align="center">

*Make your terminal your masterpiece.* 🧙‍♂️

</div>