#!/usr/bin/env bash
# ==============================================================================
# MODULE NAME:  reload-engine.sh (Module 7 - 1-Click Instant Shell Reloader)
# AUTHOR:       Saleem (Open Source DevOps/Sec Contributor)
# DESCRIPTION:  Instantly reloads and executes the active shell (ZSH/BASH)
#               to apply all themes, plugins, and aliases immediately.
# ==============================================================================

_install_reload_hook() {
    local rc sh marker="# Shell-Wizard auto-reload"
    for rc in "${HOME}/.zshrc" "${HOME}/.bashrc"; do
        [[ -f "$rc" ]] || continue
        grep -q "$marker" "$rc" && continue
        case "$rc" in *zshrc) sh=zsh ;; *) sh=bash ;; esac
        printf '\n%s\nshell-wizard() { command shell-wizard "$@"; exec %s; }\n' "$marker" "$sh" >> "$rc"
        echo -e "${GREEN}[✔] Auto-reload hook added to ~/${rc##*/}${NC}"
    done
    command -v shell-wizard &>/dev/null || \
        echo -e "${YELLOW}[i] Run main menu option 8 so the 'shell-wizard' command exists.${NC}"
}

reload_active_shell() {
    show_header
    echo -e "${YELLOW}${BOLD}⚡ MODULE 7: INSTANT SHELL RELOADER ENGINE${NC}\n"

    # Detect current running shell
    CURRENT_SHELL=$(basename "$SHELL")
_install_reload_hook

    echo -e "${CYAN}--> Flushing terminal buffers and applying updated shell configuration...${NC}\n"
    sleep 0.5

    if [[ "$CURRENT_SHELL" == "zsh" ]] || [[ -n "$ZSH_VERSION" ]]; then
        echo -e "${GREEN}[✔] Reloading ZSH session with updated ~/.zshrc theme...${NC}\n"
        sleep 0.5
        exec zsh
    elif [[ "$CURRENT_SHELL" == "bash" ]] || [[ -n "$BASH_VERSION" ]]; then
        echo -e "${GREEN}[✔] Reloading BASH session with updated ~/.bashrc theme...${NC}\n"
        sleep 0.5
        exec bash
    else
        echo -e "${YELLOW}[!] Unknown shell environment (${CURRENT_SHELL}). Attempting fallback to ZSH...${NC}\n"
        sleep 0.5
        exec zsh 2>/dev/null || exec bash
    fi
}