#!/usr/bin/env bash
# ==============================================================================
# MODULE NAME:  backup-engine.sh (Module 1 - Safety & Restoration Engine)
# AUTHOR:       Saleem (Open Source DevOps/Sec Contributor)
# DESCRIPTION:  Creates timestamped backups of user configs & provides 1-click restore.
# ==============================================================================

BACKUP_DIR="${HOME}/.shell_wizard_backups"

# --- Create Automated Backup ---
create_backup() {
    local TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    local TARGET_DIR="${BACKUP_DIR}/backup_${TIMESTAMP}"
    local BACKUP_CREATED=false

    echo -e "${CYAN}--> Creating safety backup in ${TARGET_DIR}...${NC}"
    mkdir -p "$TARGET_DIR"

    # List of critical shell configuration files to protect
    local CONFIG_FILES=(
        ".zshrc"
        ".bashrc"
        ".p10k.zsh"
        ".config/starship.toml"
        ".config/fish/config.fish"
    )

    for file in "${CONFIG_FILES[@]}"; do
        if [[ -f "${HOME}/${file}" ]]; then
            # Create subdirectories if needed (e.g., .config/fish)
            local PARENT_DIR=$(dirname "${TARGET_DIR}/${file}")
            mkdir -p "$PARENT_DIR"
            
            cp -r "${HOME}/${file}" "${TARGET_DIR}/${file}"
            echo -e "  ${GREEN}[✔] Backed up:${NC} ~/${file}"
            BACKUP_CREATED=true
        fi
    done

    if [[ "$BACKUP_CREATED" == true ]]; then
        echo -e "${GREEN}[✔] Safety backup completed successfully!${NC}\n"
    else
        echo -e "${YELLOW}[i] No existing shell config files found to backup. Proceeding safely.${NC}\n"
        rm -rf "$TARGET_DIR"
    fi
}


# --- Interactive Restore Utility ---
restore_backup() {
    show_header
    echo -e "${YELLOW}${BOLD}📌 MODULE 1: SAFETY RESTORATION UTILITY${NC}\n"

    if [[ ! -d "$BACKUP_DIR" ]] || [[ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]]; then
        echo -e "${RED}[!] No previous Shell-Wizard backups found in ${BACKUP_DIR}${NC}"
        pause
        return 1
    fi

    # Read available backup snapshots into array
    local BACKUPS=()
    while IFS= read -r line; do
        [[ -n "$line" ]] && BACKUPS+=("$line")
    done < <(ls -d "${BACKUP_DIR}"/backup_* 2>/dev/null)

    echo -e "${CYAN}Select a backup snapshot to restore:${NC}\n"
    for i in "${!BACKUPS[@]}"; do
        local FOLDER_NAME=$(basename "${BACKUPS[$i]}")
        echo -e "  ${GREEN}[$((i+1))]${NC} ${FOLDER_NAME}"
    done
    echo -e "  ${GREEN}[0]${NC} Cancel"
    echo ""

    read -p "Select backup choice [0-${#BACKUPS[@]}]: " CHOICE

    if [[ "$CHOICE" -ge 1 ]] && [[ "$CHOICE" -le "${#BACKUPS[@]}" ]]; then
        local SELECTED_BACKUP="${BACKUPS[$((CHOICE-1))]}"
        echo -e "\n${YELLOW}--> Restoring configuration from $(basename "$SELECTED_BACKUP")...${NC}"

        # Copy backed up files back to $HOME
        cp -rvf "${SELECTED_BACKUP}"/.* "${HOME}/" 2>/dev/null || true
        if [[ -d "${SELECTED_BACKUP}/.config" ]]; then
            cp -rvf "${SELECTED_BACKUP}/.config/"* "${HOME}/.config/" 2>/dev/null || true
        fi

        echo -e "\n${GREEN}[✔] RESTORATION COMPLETE! Your original shell configs have been fully restored.${NC}"
        echo -e "${CYAN}[i] Please restart your terminal session for changes to take effect.${NC}"
        echo -e "${CYAN}[💡] To apply changes instantly without restarting your terminal, run:${NC}"
        echo -e "     ${BOLD}${GREEN}exec zsh${NC}  (or ${BOLD}${GREEN}exec bash${NC})\n"
    else
        echo -e "\nRestoration cancelled."
    fi
    pause
}

# --- Module 1 Interactive Menu ---
manage_backups() {
    while true; do
        show_header
        echo -e "${YELLOW}${BOLD}[+] Module 1: Safety & Backup Engine${NC}\n"
        echo -e "  ${GREEN}[1]${NC} Create Fresh Safety Snapshot Now"
        echo -e "  ${GREEN}[2]${NC} List & Restore Previous Backup Snapshot ${CYAN}(1-Click Rollback)${NC}"
        echo -e "  ${GREEN}[3]${NC} View Backup Storage Directory (${BACKUP_DIR})"
        echo -e "  ${GREEN}[0]${NC} Back to Main Menu"
        echo -e "\n===================================================================="
        read -p "Select choice [0-3]: " B_CHOICE

        case $B_CHOICE in
            1)
                create_backup
                pause
                ;;
            2)
                restore_backup
                ;;
            3)
                show_header
                echo -e "${CYAN}${BOLD}--- Existing Backup Snapshots ---${NC}\n"
                if [[ -d "$BACKUP_DIR" ]]; then
                    ls -lh "$BACKUP_DIR"
                else
                    echo "No backup directory found yet."
                fi
                pause
                ;;
            0) break ;;
            *) echo -e "${RED}Invalid selection!${NC}"; sleep 1 ;;
        esac
    done
}