#!/usr/bin/env bash
# ==============================================================================
# MODULE NAME:  zsh-engine.sh (Module 3 - ZSH & Theme Switcher Suite)
# AUTHOR:       Saleem (Open Source DevOps/Sec Contributor)
# DESCRIPTION:  Installs Oh My Zsh, plugins, and provides instant theme switching.
# ==============================================================================

ZSH_CUSTOM="${HOME}/.oh-my-zsh/custom"

# --- Install Oh My Zsh Silently ---
install_oh_my_zsh() {
    echo -e "${CYAN}--> Checking for Oh My Zsh...${NC}"
    if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
        echo -e "${GREEN}--> Installing Oh My Zsh (Unattended)...${NC}"
        if declare -f create_backup > /dev/null; then
            create_backup
        fi
        RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        echo -e "${GREEN}[✔] Oh My Zsh installed successfully!${NC}"
    else
        echo -e "${GREEN}[✔] Oh My Zsh is already installed.${NC}"
    fi
}

# --- Helper: add plugins to plugins=(...) without removing existing ones ---
_enable_zsh_plugins() {
    local RC="${HOME}/.zshrc" p
    [[ -f "$RC" ]] || return 1
    grep -q '^plugins=(' "$RC" || echo 'plugins=(git)' >> "$RC"

    # Collect existing plugins (single-line or multi-line block), drop syntax-highlighting
    local block existing
    block=$(awk '/^plugins=\(/{f=1} f{print} f&&/\)/{exit}' "$RC")
    existing=$(echo "$block" | sed -e 's/^plugins=(//' -e 's/)//' | tr -s ' \t\n' ' ')
    local -a list=()
    for p in $existing zsh-syntax-highlighting; do
        [[ "$p" == "zsh-syntax-highlighting" ]] && continue
        list+=("$p")
    done
    for p in "$@"; do
        [[ " ${list[*]} " == *" $p "* ]] || list+=("$p")
    done
    list+=("zsh-syntax-highlighting")

    local NEW="plugins=(${list[*]})"
    local TMP; TMP=$(mktemp)
    awk -v new="$NEW" '
        /^plugins=\(/ && !done { print new; skip=1; done=1; if ($0 ~ /\)/) skip=0; next }
        skip { if ($0 ~ /\)/) skip=0; next }
        { print }' "$RC" > "$TMP" && cp "$TMP" "$RC"
    rm -f "$TMP"
    grep -qF "$NEW" "$RC"
}

# --- Install Productivity Plugins ---
install_zsh_plugins() {
    install_oh_my_zsh
    local RC="${HOME}/.zshrc" name url dir failed=0
    touch "$RC"

    if ! command -v git &>/dev/null; then
        echo -e "${RED}[!] git is required. Install it first (e.g. sudo apt install git).${NC}"
        return 1
    fi

    local PLUGINS=(
        "zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions"
        "zsh-completions|https://github.com/zsh-users/zsh-completions"
        "zsh-syntax-highlighting|https://github.com/zsh-users/zsh-syntax-highlighting.git"
    )

    for entry in "${PLUGINS[@]}"; do
        IFS='|' read -r name url <<< "$entry"
        dir="${ZSH_CUSTOM}/plugins/${name}"
        if [[ -f "${dir}/${name}.plugin.zsh" ]]; then
            echo -e "${GREEN}[✔] ${name} already installed.${NC}"
            continue
        fi
        echo -e "${CYAN}--> Installing ${name}...${NC}"
        rm -rf "$dir"
        if git clone --depth=1 "$url" "$dir" &>/dev/null && [[ -f "${dir}/${name}.plugin.zsh" ]]; then
            echo -e "${GREEN}[✔] ${name} installed.${NC}"
        else
            echo -e "${RED}[!] Failed to install ${name}. Check your internet connection.${NC}"
            rm -rf "$dir"
            failed=1
        fi
    done

    echo -e "\n${CYAN}--> Enabling plugins inside ~/.zshrc...${NC}"
    if _enable_zsh_plugins zsh-autosuggestions zsh-completions && (( failed == 0 )); then
        echo -e "${GREEN}[✔] Plugins installed and enabled (your other plugins were kept).${NC}"
        echo -e "${CYAN}[💡] Run ${BOLD}exec zsh${NC}${CYAN} or open a new tab to load them.${NC}"
    else
        echo -e "${RED}[!] Plugin setup incomplete. See the messages above.${NC}"
        return 1
    fi
}

# --- Helper: Apply Specific ZSH Theme ---
set_zsh_theme() {
    local THEME_NAME="$1"
    local RC="${HOME}/.zshrc"
    install_oh_my_zsh
    if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
        echo -e "${RED}[!] Oh My Zsh is not installed, cannot set a theme.${NC}"
        return 1
    fi
    touch "$RC"
    echo -e "${CYAN}--> Setting ZSH_THEME=\"${THEME_NAME}\" in ~/.zshrc...${NC}"
    if grep -q '^ZSH_THEME=' "$RC"; then
        sed -i "s|^ZSH_THEME=.*|ZSH_THEME=\"${THEME_NAME}\"|" "$RC"
    else
        echo "ZSH_THEME=\"${THEME_NAME}\"" >> "$RC"
    fi
    if grep -qxF "ZSH_THEME=\"${THEME_NAME}\"" "$RC"; then
        echo -e "${GREEN}[✔] Theme changed to '${THEME_NAME}'!${NC}"
        echo -e "${CYAN}[💡] Run ${BOLD}exec zsh${NC}${CYAN} to see your new theme in action.${NC}"
    else
        echo -e "${RED}[!] Failed to set the theme in ~/.zshrc${NC}"
        return 1
    fi
}

# --- Helper: run p10k configure safely ---
run_p10k_configure() {
    install_p10k || return 1
    zsh -ic 'p10k configure' || true
}

install_p10k() {
    local DIR="${ZSH_CUSTOM}/themes/powerlevel10k"
    local T="${DIR}/powerlevel10k.zsh-theme"
    for tool in git zsh curl; do
        if ! command -v "$tool" &>/dev/null; then
            echo -e "${RED}[!] '$tool' is required. Install it first (e.g. sudo apt install $tool).${NC}"
            return 1
        fi
    done
    install_oh_my_zsh
    if [[ ! -f "$T" ]]; then
        echo -e "${CYAN}--> Installing Powerlevel10k...${NC}"
        rm -rf "$DIR"
        if ! git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$DIR"; then
            echo -e "${RED}[!] Download failed. Check your internet connection and try again.${NC}"
            rm -rf "$DIR"
            return 1
        fi
    fi
    if [[ ! -f "$T" ]]; then
        echo -e "${RED}[!] Powerlevel10k files are missing after install.${NC}"
        return 1
    fi
    set_zsh_theme "powerlevel10k/powerlevel10k" || return 1
    echo -e "${GREEN}[✔] Powerlevel10k installed and selected.${NC}"
}


# --- Theme Selector Engine ---
switch_themes() {
    while true; do
        show_header
        echo -e "${YELLOW}${BOLD}🎨 ZSH THEME SELECTOR SUITE${NC}\n"
        echo -e "  ${GREEN}[1]${NC} Powerlevel10k ${CYAN}(Feature-Rich, Highly Customization Engine)${NC}"
        echo -e "  ${GREEN}[2]${NC} Agnoster ${CYAN}(Classic Segmented Status Prompt)${NC}"
        echo -e "  ${GREEN}[3]${NC} Robbyrussell ${CYAN}(Minimalist Default OMZ Theme)${NC}"
        echo -e "  ${GREEN}[4]${NC} Bira ${CYAN}(Two-Line Prompt with Host & Path Display)${NC}"
        echo -e "  ${GREEN}[5]${NC} Minimal / Simple ${CYAN}(Clean, High-Speed Prompt)${NC}"
        echo -e "  ${GREEN}[6]${NC} Launch Interactive P10K Wizard ${CYAN}(p10k configure)${NC}"
        echo -e "  ${GREEN}[0]${NC} Back to Main ZSH Menu"
        echo -e "\n===================================================================="
        read -p "Select theme [0-6]: " T_CHOICE

        case $T_CHOICE in
            1)
                install_p10k
                pause
                ;;
            2) set_zsh_theme "agnoster"; pause ;;
            3) set_zsh_theme "robbyrussell"; pause ;;
            4) set_zsh_theme "bira"; pause ;;
            5) set_zsh_theme "simple"; pause ;;
            6)
                run_p10k_configure
                pause
                ;;
            0) break ;;
            *) echo -e "${RED}Invalid selection!${NC}"; sleep 1 ;;
        esac
    done
}

# --- Module 3 Interactive Menu ---
manage_zsh() {
    while true; do
        show_header
        echo -e "${YELLOW}${BOLD}[+] Module 3: ZSH & Powerlevel10k Supercharger${NC}\n"
        echo -e "  ${GREEN}[1]${NC} 1-Click Complete Supercharge ${CYAN}(Oh My Zsh + Plugins + P10K)${NC}"
        echo -e "  ${GREEN}[2]${NC} Instant Theme Selector ${CYAN}(Switch between P10K, Agnoster, Robbyrussell, Bira)${NC}"
        echo -e "  ${GREEN}[3]${NC} Install Essential Plugins Only ${CYAN}(Autosuggestions, Syntax Highlighting, Completions)${NC}"
        echo -e "  ${GREEN}[4]${NC} Launch Interactive P10K Configurator ${CYAN}(p10k configure)${NC}"
        echo -e "  ${GREEN}[0]${NC} Back to Main Menu"
        echo -e "\n===================================================================="
        read -p "Select choice [0-4]: " Z_CHOICE

        case $Z_CHOICE in
            1)
                install_zsh_plugins
                if install_p10k; then
                    echo -e "\n${GREEN}${BOLD}[✔] ZSH SUPERCHARGE COMPLETE!${NC}"
                    echo -e "${CYAN}[💡] Run ${BOLD}exec zsh${NC}${CYAN} (or open a new tab). The P10K setup wizard starts automatically.${NC}"
                else
                    echo -e "\n${RED}${BOLD}[!] Supercharge did not complete. See the errors above.${NC}"
                fi
                pause
                ;;
            2) switch_themes ;;
            3) install_zsh_plugins; pause ;;
            4)
                run_p10k_configure
                pause
                ;;
            0) break ;;
            *) echo -e "${RED}Invalid selection!${NC}"; sleep 1 ;;
        esac
    done
}