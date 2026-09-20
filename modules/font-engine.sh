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
        fc-list : family | grep -iE "Nerd Font|MesloLGS" | cut -d',' -f1 | sort -u | sed 's/^/  • /'
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
            if ! curl -fsSL "$url" -o "${FONT_DIR}/${font_file}"; then
                echo -e "  ${RED}[!] Failed to download ${font_file}${NC}"
                rm -f "${FONT_DIR}/${font_file}"
            fi
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
    if fc-list : family 2>/dev/null | grep -qi "JetBrainsMono Nerd Font"; then
        echo -e "\n${GREEN}[✔] JetBrainsMono Nerd Font is already installed. Skipping download.${NC}"
        return 0
    fi
    echo -e "\n${GREEN}--> Downloading and installing JetBrainsMono Nerd Font...${NC}"
    mkdir -p "$FONT_DIR"

    if ! command -v unzip &>/dev/null; then
        echo -e "${RED}[!] 'unzip' is required. Install it first (e.g. sudo apt install unzip).${NC}"
        return 1
    fi

    local TEMP_ZIP
    TEMP_ZIP="$(mktemp /tmp/JetBrainsMono.XXXXXX.zip)"
    echo -e "  Downloading JetBrainsMono release archive..."
    if ! curl -fL --progress-bar --retry 3 --connect-timeout 15 "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" -o "$TEMP_ZIP"; then
        echo -e "${RED}[!] Download failed. Check your internet connection.${NC}"
        rm -f "$TEMP_ZIP"
        return 1
    fi

    echo -e "  Extracting font files to ${FONT_DIR}..."
    unzip -o -q "$TEMP_ZIP" "*.ttf" -d "$FONT_DIR" 2>/dev/null || unzip -o -q "$TEMP_ZIP" "*.otf" -d "$FONT_DIR" 2>/dev/null
    rm -f "$TEMP_ZIP"

    if command -v fc-cache &>/dev/null; then
        echo -e "${GREEN}--> Refreshing font cache...${NC}"
        fc-cache -fv "$FONT_DIR" &>/dev/null
    fi
    echo -e "${GREEN}[✔] JetBrainsMono Nerd Font installed successfully in ${FONT_DIR}!${NC}"
}

# --- Generic Nerd Font Installer (used by Cascadia & Fira) ---
install_nerd_font_zip() {
    local ZIP_NAME="$1"      # e.g. CascadiaCode
    local LABEL="$2"         # e.g. "CascadiaCode Nerd Font"
    if fc-list : family 2>/dev/null | grep -qi "${LABEL}"; then
        echo -e "\n${GREEN}[✔] ${LABEL} is already installed. Skipping download.${NC}"
        return 0
    fi
    echo -e "\n${GREEN}--> Downloading and installing ${LABEL}...${NC}"
    mkdir -p "$FONT_DIR"

    if ! command -v unzip &>/dev/null; then
        echo -e "${RED}[!] 'unzip' is required. Install it first (e.g. sudo apt install unzip).${NC}"
        return 1
    fi

    local TEMP_ZIP
    TEMP_ZIP="$(mktemp "/tmp/${ZIP_NAME}.XXXXXX.zip")"
    echo -e "  Downloading ${ZIP_NAME} release archive..."
    if ! curl -fL --progress-bar --retry 3 --connect-timeout 15 --speed-limit 1000 --speed-time 60 \
        "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${ZIP_NAME}.zip" -o "$TEMP_ZIP"; then
        echo -e "${RED}[!] Download failed. Check your internet connection.${NC}"
        rm -f "$TEMP_ZIP"
        return 1
    fi

    echo -e "  Extracting font files to ${FONT_DIR}..."
    if ! { unzip -o -q "$TEMP_ZIP" "*.ttf" -d "$FONT_DIR" 2>/dev/null || unzip -o -q "$TEMP_ZIP" "*.otf" -d "$FONT_DIR" 2>/dev/null; }; then
        echo -e "${RED}[!] Extraction failed.${NC}"
        rm -f "$TEMP_ZIP"
        return 1
    fi
    rm -f "$TEMP_ZIP"

    if command -v fc-cache &>/dev/null; then
        echo -e "${GREEN}--> Refreshing font cache...${NC}"
        fc-cache -fv "$FONT_DIR" &>/dev/null
    fi
    echo -e "${GREEN}[✔] ${LABEL} installed successfully in ${FONT_DIR}!${NC}"
}

# --- Terminal Font Application Directions ---
show_font_directions() {
    show_header
    echo -e "${YELLOW}${BOLD}📌 HOW TO APPLY YOUR NERD FONT IN YOUR TERMINAL APP${NC}\n"
    echo -e "${CYAN}After installing the font, select it inside your terminal settings:${NC}\n"
    
    echo -e "  ${GREEN}1. VS Code / Cursor:${NC}"
    echo -e "     Settings -> Search 'Font Family' -> Add: ${BOLD}'MesloLGS NF'${NC} , ${BOLD}'JetBrainsMono Nerd Font'${NC}, ${BOLD}'CaskaydiaCove Nerd Font'${NC} or ${BOLD}'FiraCode Nerd Font'${NC}\n"
    
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
        echo -e "  ${GREEN}[4]${NC} Install CascadiaCode Nerd Font ${CYAN}(Clean, Modern)${NC}"
        echo -e "  ${GREEN}[5]${NC} Install FiraCode Nerd Font ${CYAN}(Famous Ligatures)${NC}"
        echo -e "  ${GREEN}[6]${NC} View Terminal Application Setup Directions"
        echo -e "  ${GREEN}[0]${NC} Back to Main Menu"
        echo -e "\n===================================================================="
        read -p "Select choice [0-6]: " F_CHOICE

        case $F_CHOICE in
            1) check_nerd_fonts; pause ;;
            2) install_meslo_font; pause ;;
            3) install_jetbrains_font; pause ;;
            4) install_nerd_font_zip "CascadiaCode" "CaskaydiaCove Nerd Font"; pause ;;
            5) install_nerd_font_zip "FiraCode" "FiraCode Nerd Font"; pause ;;
            6) show_font_directions ;;
            0) break ;;
            *) echo -e "${RED}Invalid selection!${NC}"; sleep 1 ;;
        esac
    done
}