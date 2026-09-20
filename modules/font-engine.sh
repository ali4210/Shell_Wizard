#!/usr/bin/env bash
# ==============================================================================
# MODULE NAME:  font-engine.sh (Module 2 - Automated Nerd Font Injector)
# AUTHOR:       Saleem (Open Source DevOps/Sec Contributor)
# DESCRIPTION:  Detects, downloads, and installs Nerd Fonts across Linux & macOS.
# ==============================================================================

# OS-Agnostic Font Directory Detection
if [[ "$OSTYPE" == "darwin"* ]]; then
    FONT_DIR="${HOME}/Library/Fonts"
else
    FONT_DIR="${HOME}/.local/share/fonts"
fi

# --- Check for Installed Nerd Fonts ---
check_nerd_fonts() {
    local FOUND=false
    echo -e "${CYAN}--> Scanning system for active Nerd Fonts...${NC}\n"

    if command -v fc-list &>/dev/null; then
        if fc-list : family | grep -iE "Nerd Font|MesloLGS" &>/dev/null; then
            FOUND=true
        fi
    fi

    if [[ "$FOUND" == true ]]; then
        echo -e "${GREEN}[✔] Nerd Fonts detected on your system!${NC}"
        fc-list : family | grep -iE "Nerd Font|MesloLGS" | sort -u | head -n 10 | sed 's/^/  • /'
    else
        echo -e "${YELLOW}[!] No glyph-compatible Nerd Fonts detected.${NC}"
        echo -e "${YELLOW}[i] Terminal icons (Git branches, OS logos, Docker symbols) will look broken without a Nerd Font.${NC}"
    fi
}

# --- Automated MesloLGS NF Installer ---
install_meslo_font() {
    echo -e "\n${GREEN}--> Downloading and installing MesloLGS NF (Recommended for Powerlevel10k)...${NC}"
    mkdir -p "$FONT_DIR"

    local MESLO_URLS=(
        "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf"
        "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf"
        "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf"
        "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf"
    )

    for url in "${MESLO_URLS[@]}"; do
        local font_file=$(basename "$url" | sed 's/%20/ /g')
        if [[ ! -f "${FONT_DIR}/${font_file}" ]]; then
            echo -e "  Downloading ${CYAN}${font_file}${NC}..."
            curl -sSL "$url" -o "${FONT_DIR}/${font_file}"
        else
            echo -e "  ${GREEN}[✔] Already present:${NC} ${font_file}"
        fi
    done

    if command -v fc-cache &>/dev/null; then
        echo -e "${GREEN}--> Refreshing font cache...${NC}"
        fc-cache -fv "$FONT_DIR" &>/dev/null
    fi
    echo -e "${GREEN}[✔] MesloLGS NF installed successfully in ${FONT_DIR}!${NC}"
}

# --- Automated JetBrainsMono Nerd Font Installer ---
install_jetbrains_font() {
    echo -e "\n${GREEN}--> Downloading and installing JetBrainsMono Nerd Font...${NC}"
    mkdir -p "$FONT_DIR"

    local TEMP_ZIP="/tmp/JetBrainsMono.zip"
    echo -e "  Downloading JetBrainsMono release archive..."
    curl -sSL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" -o "$TEMP_ZIP"

    echo -e "  Extracting font files to ${FONT_DIR}..."
    unzip -o -q "$TEMP_ZIP" "*.ttf" -d "$FONT_DIR" 2>/dev/null || unzip -o -q "$TEMP_ZIP" "*.otf" -d "$FONT_DIR" 2>/dev/null
    rm -f "$TEMP_ZIP"

    if command -v fc-cache &>/dev/null; then
        echo -e "${GREEN}--> Refreshing font cache...${NC}"
        fc-cache -fv "$FONT_DIR" &>/dev/null
    fi
    echo -e "${GREEN}[✔] JetBrainsMono Nerd Font installed successfully in ${FONT_DIR}!${NC}"
}

# --- Terminal Font Application Directions ---
show_font_directions() {
    show_header
    echo -e "${YELLOW}${BOLD}📌 HOW TO APPLY YOUR NERD FONT IN YOUR TERMINAL APP${NC}\n"
    echo -e "${CYAN}After installing the font, select it inside your terminal settings:${NC}\n"
    
    echo -e "  ${GREEN}1. VS Code / Cursor:${NC}"
    echo -e "     Settings -> Search 'Font Family' -> Add: ${BOLD}'MesloLGS NF'${NC} or ${BOLD}'JetBrainsMono Nerd Font'${NC}\n"
    
    echo -e "  ${GREEN}2. macOS Terminal / iTerm2:${NC}"
    echo -e "     Preferences -> Profiles -> Text -> Font -> Select ${BOLD}'MesloLGS NF'${NC}\n"

    echo -e "  ${GREEN}3. Windows Terminal:${NC}"
    echo -e "     Settings -> Profiles -> Appearance -> Font face -> Choose ${BOLD}'MesloLGS NF'${NC}\n"
    
    echo -e "  ${GREEN}4. GNOME Terminal / Kali Terminal:${NC}"
    echo -e "     Preferences -> Profile -> Text -> Custom font -> Select ${BOLD}'MesloLGS NF Regular'${NC}\n"
    
    pause
}

# --- Module 2 Interactive Menu ---
manage_fonts() {
    while true; do
        show_header
        echo -e "${YELLOW}${BOLD}[+] Module 2: Automated Nerd Font Injector${NC}\n"
        echo -e "  ${GREEN}[1]${NC} Scan System for Installed Nerd Fonts"
        echo -e "  ${GREEN}[2]${NC} Install MesloLGS NF ${CYAN}(Recommended for Powerlevel10k)${NC}"
        echo -e "  ${GREEN}[3]${NC} Install JetBrainsMono Nerd Font ${CYAN}(Popular Developer Choice)${NC}"
        echo -e "  ${GREEN}[4]${NC} View Terminal Application Setup Directions"
        echo -e "  ${GREEN}[0]${NC} Back to Main Menu"
        echo -e "\n===================================================================="
        read -p "Select choice [0-4]: " F_CHOICE

        case $F_CHOICE in
            1) check_nerd_fonts; pause ;;
            2) install_meslo_font; pause ;;
            3) install_jetbrains_font; pause ;;
            4) show_font_directions ;;
            0) break ;;
            *) echo -e "${RED}Invalid selection!${NC}"; sleep 1 ;;
        esac
    done
}