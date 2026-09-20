#!/usr/bin/env bash
# ==============================================================================
# MODULE NAME:  starship-engine.sh (Module 5 - Starship Preset Engine)
# AUTHOR:       Saleem (Open Source DevOps/Sec Contributor)
# DESCRIPTION:  Installs Starship cross-shell engine & swaps theme presets.
# ==============================================================================

STARSHIP_CONFIG_DIR="${HOME}/.config"
STARSHIP_FILE="${STARSHIP_CONFIG_DIR}/starship.toml"

install_starship() {
    echo -e "${CYAN}--> Checking for Starship Prompt Engine...${NC}"
    if ! command -v starship &>/dev/null; then
        echo -e "${GREEN}--> Installing Starship...${NC}"
        curl -sS https://starship.rs/install.sh | sh -s -- -y
        echo -e "${GREEN}[✔] Starship installed successfully!${NC}"
    else
        echo -e "${GREEN}[✔] Starship is already installed.${NC}"
    fi

    # Inject into ~/.zshrc and ~/.bashrc
    for rc in "${HOME}/.zshrc" "${HOME}/.bashrc"; do
        if [[ -f "$rc" ]]; then
            if ! grep -q "starship init" "$rc"; then
                local SHELL_NAME=$(basename "$rc" | sed 's/\.//;s/rc//')
                echo -e "\n# Starship Cross-Shell Prompt\neval \"\$(starship init ${SHELL_NAME})\"" >> "$rc"
                echo -e "  ${GREEN}[✔] Starship initialized in ~/${rc##*/}${NC}"
            fi
        fi
    done
}

# --- Starship Theme Preset Switcher ---
apply_starship_preset() {
    local PRESET_NAME="$1"
    mkdir -p "$STARSHIP_CONFIG_DIR"

    echo -e "${CYAN}--> Fetching and applying Starship preset '${PRESET_NAME}'...${NC}"
    case $PRESET_NAME in
        "nerd-font")
            starship preset nerd-font-symbols -o "$STARSHIP_FILE"
            ;;
        "gruvbox")
            starship preset gruvbox-rainbow -o "$STARSHIP_FILE"
            ;;
        "tokyo-night")
            curl -sSL "https://raw.githubusercontent.com/starship/starship/main/docs/public/presets/toml/tokyo-night.toml" -o "$STARSHIP_FILE"
            ;;
        "bracketed")
            starship preset bracketed-segments -o "$STARSHIP_FILE"
            ;;
        "plain")
            starship preset plain-text -o "$STARSHIP_FILE"
            ;;
    esac

    echo -e "${GREEN}[✔] Starship preset '${PRESET_NAME}' applied to ~/.config/starship.toml!${NC}"
    echo -e "${CYAN}[💡] Run ${BOLD}exec zsh${NC}${CYAN} (or ${BOLD}exec bash${NC}${CYAN}) to load your new Starship theme.${NC}"
}

switch_starship_presets() {
    install_starship
    while true; do
        show_header
        echo -e "${YELLOW}${BOLD}🚀 STARSHIP THEME PRESET SELECTOR${NC}\n"
        echo -e "  ${GREEN}[1]${NC} Gruvbox Rainbow ${CYAN}(High-Contrast Vibrant Segment Prompt)${NC}"
        echo -e "  ${GREEN}[2]${NC} Tokyo Night ${CYAN}(Modern Cyberpunk Neon Aesthetic)${NC}"
        echo -e "  ${GREEN}[3]${NC} Nerd Font Symbols ${CYAN}(Icon-Rich Segmented Prompt)${NC}"
        echo -e "  ${GREEN}[4]${NC} Bracketed Segments ${CYAN}(Clean Segmented Box Layout)${NC}"
        echo -e "  ${GREEN}[5]${NC} Plain Minimal ${CYAN}(High Speed, Single-Line Prompt)${NC}"
        echo -e "  ${GREEN}[0]${NC} Back to Main Menu"
        echo -e "\n===================================================================="
        read -p "Select preset choice [0-5]: " P_CHOICE

        case $P_CHOICE in
            1) apply_starship_preset "gruvbox"; pause ;;
            2) apply_starship_preset "tokyo-night"; pause ;;
            3) apply_starship_preset "nerd-font"; pause ;;
            4) apply_starship_preset "bracketed"; pause ;;
            5) apply_starship_preset "plain"; pause ;;
            0) break ;;
            *) echo -e "${RED}Invalid selection!${NC}"; sleep 1 ;;
        esac
    done
}

manage_starship() {
    while true; do
        show_header
        echo -e "${YELLOW}${BOLD}[+] Module 5: Starship Cross-Shell Suite${NC}\n"
        echo -e "  ${GREEN}[1]${NC} Install & Initialize Starship Engine ${CYAN}(Works across ZSH, Bash, Fish)${NC}"
        echo -e "  ${GREEN}[2]${NC} Instant Theme Preset Selector ${CYAN}(Gruvbox, Tokyo Night, Nerd Font, Bracketed)${NC}"
        echo -e "  ${GREEN}[0]${NC} Back to Main Menu"
        echo -e "\n===================================================================="
        read -p "Select choice [0-2]: " S_CHOICE

        case $S_CHOICE in
            1) install_starship; pause ;;
            2) switch_starship_presets ;;
            0) break ;;
            *) echo -e "${RED}Invalid selection!${NC}"; sleep 1 ;;
        esac
    done
}