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

# --- Install Productivity Plugins ---
install_zsh_plugins() {
    install_oh_my_zsh

    echo -e "\n${GREEN}--> Installing zsh-autosuggestions...${NC}"
    [[ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]] && \
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"

    echo -e "\n${GREEN}--> Installing zsh-syntax-highlighting...${NC}"
    [[ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]] && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"

    echo -e "\n${GREEN}--> Installing zsh-completions...${NC}"
    [[ ! -d "${ZSH_CUSTOM}/plugins/zsh-completions" ]] && \
    git clone https://github.com/zsh-users/zsh-completions "${ZSH_CUSTOM}/plugins/zsh-completions"

    if [[ -f "${HOME}/.zshrc" ]]; then
        echo -e "\n${CYAN}--> Enabling plugins inside ~/.zshrc...${NC}"
        sed -i 's/plugins=(.*)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions sudo autojump)/g' "${HOME}/.zshrc" 2>/dev/null || true
        echo -e "${GREEN}[✔] Extended plugin suite enabled in ~/.zshrc!${NC}"
    fi
}

# --- Helper: Apply Specific ZSH Theme ---
set_zsh_theme() {
    local THEME_NAME="$1"
    install_oh_my_zsh

    if [[ -f "${HOME}/.zshrc" ]]; then
        echo -e "${CYAN}--> Setting ZSH_THEME=\"${THEME_NAME}\" in ~/.zshrc...${NC}"
        sed -i "s/ZSH_THEME=\".*\"/ZSH_THEME=\"${THEME_NAME}\"/g" "${HOME}/.zshrc"
        echo -e "${GREEN}[✔] Theme changed to '${THEME_NAME}'!${NC}"
        echo -e "${CYAN}[💡] Run ${BOLD}exec zsh${NC}${CYAN} to see your new theme in action.${NC}"
    fi
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
        echo -e "  ${GREEN}[7]${NC} Back to Main ZSH Menu"
        echo -e "\n===================================================================="
        read -p "Select theme [1-7]: " T_CHOICE

        case $T_CHOICE in
            1)
                [[ ! -d "${ZSH_CUSTOM}/themes/powerlevel10k" ]] && \
                git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM}/themes/powerlevel10k"
                set_zsh_theme "powerlevel10k/powerlevel10k"
                pause
                ;;
            2) set_zsh_theme "agnoster"; pause ;;
            3) set_zsh_theme "robbyrussell"; pause ;;
            4) set_zsh_theme "bira"; pause ;;
            5) set_zsh_theme "simple"; pause ;;
            6)
                if command -v zsh &>/dev/null; then
                    zsh -c "source ~/.zshrc 2>/dev/null; p10k configure" || true
                fi
                pause
                ;;
            7) break ;;
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
        echo -e "  ${GREEN}[5]${NC} Back to Main Menu"
        echo -e "\n===================================================================="
        read -p "Select choice [1-5]: " Z_CHOICE

        case $Z_CHOICE in
            1)
                install_zsh_plugins
                [[ ! -d "${ZSH_CUSTOM}/themes/powerlevel10k" ]] && \
                git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM}/themes/powerlevel10k"
                set_zsh_theme "powerlevel10k/powerlevel10k"
                echo -e "\n${GREEN}${BOLD}[✔] ZSH SUPERCHARGE COMPLETE!${NC}"
                pause
                ;;
            2) switch_themes ;;
            3) install_zsh_plugins; pause ;;
            4)
                if command -v zsh &>/dev/null; then
                    zsh -c "source ~/.zshrc 2>/dev/null; p10k configure" || true
                fi
                pause
                ;;
            5) break ;;
            *) echo -e "${RED}Invalid selection!${NC}"; sleep 1 ;;
        esac
    done
}