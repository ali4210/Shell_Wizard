#!/usr/bin/env bash
# ==============================================================================
# MODULE NAME:  cli-tools.sh (Module 4 - CLI Modernization & Tooling)
# AUTHOR:       Saleem (Open Source DevOps/Sec Contributor)
# DESCRIPTION:  Installs eza, bat, fzf, fastfetch, and configures smart aliases.
# ==============================================================================

# --- Install Modern CLI Packages ---
install_cli_tools() {
    echo -e "${CYAN}--> Updating package indices and installing modern CLI replacements...${NC}\n"

    if command -v brew &>/dev/null; then
        brew install eza bat fzf fastfetch fd ripgrep curl git
    elif command -v apt &>/dev/null; then
        sudo apt update -y
        sudo apt install -y eza bat fzf fastfetch fd-find ripgrep curl git 2>/dev/null || \
        sudo apt install -y exa bat fzf neofetch fd-find ripgrep curl git -y
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y eza bat fzf fastfetch fd-find ripgrep curl git -y
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm eza bat fzf fastfetch fd ripgrep curl git
    fi

    echo -e "\n${GREEN}[✔] Extended CLI suite (eza, bat, fzf, fastfetch, fd, ripgrep) installed successfully!${NC}"
}

# --- Inject Smart Productivity Aliases ---
inject_aliases() {
    echo -e "\n${CYAN}--> Injecting smart productivity aliases into ~/.zshrc and ~/.bashrc...${NC}"

    local ALIAS_BLOCK='
# --- Shell-Wizard Modern CLI Aliases ---
if command -v eza &>/dev/null; then
    alias ls="eza --icons --group-directories-first"
    alias ll="eza -lh --icons --group-directories-first"
    alias la="eza -lha --icons --group-directories-first"
    alias tree="eza --tree --icons"
elif command -v exa &>/dev/null; then
    alias ls="exa --icons --group-directories-first"
    alias ll="exa -lh --icons --group-directories-first"
    alias la="exa -lha --icons --group-directories-first"
fi

if command -v batcat &>/dev/null; then
    alias cat="batcat --style=plain"
    alias bat="batcat"
elif command -v bat &>/dev/null; then
    alias cat="bat --style=plain"
fi

if command -v fastfetch &>/dev/null; then
    alias sysinfo="fastfetch"
elif command -v neofetch &>/dev/null; then
    alias sysinfo="neofetch"
fi
'

    for rc_file in "${HOME}/.zshrc" "${HOME}/.bashrc"; do
        if [[ -f "$rc_file" ]]; then
            if ! grep -q "Shell-Wizard Modern CLI Aliases" "$rc_file"; then
                echo "$ALIAS_BLOCK" >> "$rc_file"
                echo -e "  ${GREEN}[✔] Aliases injected into:${NC} ~/${rc_file##*/}"
            else
                echo -e "  ${YELLOW}[i] Aliases already present in:${NC} ~/${rc_file##*/}"
            fi
        fi
    done
}

# --- Auto-Run Fastfetch / Neofetch on New Tabs ---
enable_startup_banner() {
    echo -e "\n${CYAN}--> Enabling system dashboard on terminal startup...${NC}"

    for rc_file in "${HOME}/.zshrc" "${HOME}/.bashrc"; do
        if [[ -f "$rc_file" ]]; then
            if ! grep -q "fastfetch\|neofetch" "$rc_file"; then
                echo -e "\n# Launch dashboard on terminal startup\nif command -v fastfetch &>/dev/null; then fastfetch; elif command -v neofetch &>/dev/null; then neofetch; fi" >> "$rc_file"
                echo -e "  ${GREEN}[✔] Startup banner enabled in:${NC} ~/${rc_file##*/}"
            fi
        fi
    done
}

# --- Module 4 Interactive Menu ---
manage_cli_tools() {
    while true; do
        show_header
        echo -e "${YELLOW}${BOLD}[+] Module 4: CLI Modernization & Tooling${NC}\n"
        echo -e "  ${GREEN}[1]${NC} 1-Click Complete Modernization ${CYAN}(Install Tools + Inject Aliases)${NC}"
        echo -e "  ${GREEN}[2]${NC} Install Packages Only ${CYAN}(eza, bat, fzf, fastfetch)${NC}"
        echo -e "  ${GREEN}[3]${NC} Inject Smart Productivity Aliases ${CYAN}(ls -> eza, cat -> bat)${NC}"
        echo -e "  ${GREEN}[4]${NC} Enable System Dashboard on Startup ${CYAN}(fastfetch / neofetch)${NC}"
        echo -e "  ${GREEN}[0]${NC} Back to Main Menu"
        echo -e "\n===================================================================="
        ead -p "Select choice [0-4]: " C_CHOICE

        case $C_CHOICE in
            1)
                install_cli_tools
                inject_aliases
                enable_startup_banner
                echo -e "\n${GREEN}${BOLD}[✔] CLI MODERNIZATION COMPLETE!${NC}"
                pause
                ;;
            2)
                install_cli_tools
                pause
                ;;
            3)
                inject_aliases
                pause
                ;;
            4)
                enable_startup_banner
                pause
                ;;
            0) break ;;
            *) echo -e "${RED}Invalid selection!${NC}"; sleep 1 ;;
        esac
    done
}