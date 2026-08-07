# 🧙‍♂️ Shell-Wizard Ultimate

> **The Universal Cross-Platform CLI Suite for Terminal Beautification, Next-Gen Shell Customization, & System Modernization.**  
> *Seamlessly transforms standard Linux, macOS, and Windows terminals into high-productivity, visually stunning workstations.*

---

## ==> 🌟 Overview

**Shell-Wizard Ultimate** automates the entire terminal customization process. From installing glyph-compatible Nerd Fonts and configuring Oh My Zsh with Powerlevel10k to deploying modern Rust/Go CLI replacements (`eza`, `bat`, `fzf`, `fastfetch`, `ripgrep`, `atuin`), **Shell-Wizard** gives developers, security analysts, and DevOps engineers an elite terminal experience with zero manual file editing, live environment reloads, and a built-in **1-click safety backup engine**.

---

## ==> 📁 Repository Structure

```text
Shell_Wizard/
├── autorun.sh                   # Linux/macOS Master Launcher & Dependency Auto-Installer
├── autorun.bat                  # Windows Master Launcher
├── README.md                    # Gold-Standard Documentation & Usage Guide
├── linux/
│   └── shell-wizard.sh          # Master Linux Orchestrator Engine
└── modules/
    ├── backup-engine.sh         # Module 1: Safety & 1-Click Restore Utility
    ├── font-engine.sh           # Module 2: Automated Nerd Font Injector
    ├── zsh-engine.sh            # Module 3: ZSH, Oh My Zsh & P10K Supercharger
    ├── cli-tools.sh             # Module 4: Extended CLI Tools & Alias Injector
    ├── starship-engine.sh       # Module 5: Starship Cross-Shell Prompt Engine
    ├── nextgen-engine.sh        # Module 6: Universal Next-Gen Theme & History Engine
    ├── reload-engine.sh         # Module 7: 1-Click Apply & Instant Reload Shell
    └── shell-wizard.ps1         # Windows PowerShell Master Orchestrator

```

---

## ==> 🚀 Capabilities Suite Matrix

### 🔐 1. Safety & Backup Engine (`backup-engine.sh`)

* => **Timestamped Backups:** Automatically backs up existing `.zshrc`, `.bashrc`, and `.config` files to `~/.shell_wizard_backups/` before any changes are made.
* => **1-Click Rollback:** Restore your original terminal configuration instantly with clean restore prompts.

### 🔤 2. Automated Nerd Font Injector (`font-engine.sh`)

* => **Cross-OS Font Installer:** Auto-detects and installs **MesloLGS NF** and **JetBrainsMono Nerd Font** across Linux (`~/.local/share/fonts`) and macOS (`~/Library/Fonts`).
* => **Glyph Verification:** Refreshes font caches (`fc-cache -fv`) so terminal icons (Git, Docker, Python, Kali) render cleanly without broken glyphs.

### ⚡ 3. ZSH & Oh My Zsh Supercharger (`zsh-engine.sh`)

* => **Unattended Setup:** Auto-installs Oh My Zsh silently without breaking active terminal sessions.
* => **Productivity Plugin Suite:** Clones and enables `zsh-autosuggestions`, `zsh-syntax-highlighting`, `zsh-completions`, `sudo`, and `autojump`.
* => **Theme Deployer:** Deploys Powerlevel10k (`p10k configure`), Agnoster, and Robbyrussell themes out of the box.

### 🛠️ 4. CLI Modernization & Tooling (`cli-tools.sh`)

* => Replaces legacy commands with high-speed modern utilities:
* `ls` $\rightarrow$ **`eza`** (Icon-rich, colorized directory listings)
* `cat` $\rightarrow$ **`bat`** (Syntax highlighting & line numbers)
* `find` $\rightarrow$ **`fd`** & `grep` $\rightarrow$ **`ripgrep`**
* `sysinfo` $\rightarrow$ **`fastfetch`** (System status dashboard)



### 🚀 5. Starship Cross-Shell Suite (`starship-engine.sh`)

* => Deploys **Starship**, the minimal, blazing-fast, and customizable prompt across Bash, ZSH, and Fish with preset themes (Tokyo Night, Gruvbox, and Symbol presets).

### 🌌 6. Universal Next-Gen Theme & History (`nextgen-engine.sh`)

* => **Next-Gen Prompt Suite:** Deploys **Oh My Posh**, **Spaceship**, and **Pure** minimal shell prompts.
* => **Atuin History Engine:** Integrates **Atuin** for encrypted, search-indexed, and syncable shell history navigation.

### ⚡ 7. 1-Click Apply & Instant Reload Shell (`reload-engine.sh`)

* => Instantly compiles and reloads your updated environment (`exec zsh` / `source ~/.zshrc`) so all changes take effect immediately without restarting your terminal window.

---

## ==> 🛠️ Installation & Usage

### 🐧 On Linux / macOS (Ubuntu, Debian, Kali Linux, Fedora, Arch, macOS)

```bash
# 1. Clone the repository
git clone [https://github.com/ali4210/Shell_Wizard.git](https://github.com/ali4210/Shell_Wizard.git)
cd Shell_Wizard

# 2. Make scripts executable and run
chmod +x autorun.sh
./autorun.sh

```

---

### 🪟 On Windows 10 / 11

1. Clone or download the repository.
2. Double-click **`autorun.bat`** (or execute `.\autorun.bat` inside PowerShell).

---

## ==> 📄 License

Distributed under the **MIT License**. See `LICENSE` for details.

```

---
