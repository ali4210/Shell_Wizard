#!/usr/bin/env bash
# ==============================================================================
# TOOL NAME:    install.sh (Universal POSIX Global CLI Installer)
# AUTHOR:       Saleem (Open Source DevOps/Sec Contributor)
# DESCRIPTION:  Auto-permissions and symlinks Shell Wizard to /usr/local/bin/shell-wizard
# ==============================================================================

set -e

# --- Terminal Color Formats ---
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_LAUNCHER="${SCRIPT_DIR}/autorun.sh"
GLOBAL_BIN="/usr/local/bin/shell-wizard"

echo -e "${CYAN}${BOLD}====================================================================${NC}"
echo -e "${CYAN}${BOLD}     🧙‍♂️ SHELL-WIZARD ULTIMATE - UNIVERSAL GLOBAL CLI INSTALLER      ${NC}"
echo -e "${CYAN}${BOLD}====================================================================${NC}\n"

if [ ! -f "$TARGET_LAUNCHER" ]; then
    echo -e "${RED}[!] Error: Could not locate '$TARGET_LAUNCHER'!${NC}"
    echo -e "${RED}[!] Run this installer from inside your Shell_Wizard repository root.${NC}"
    exit 1
fi

# ==> Self-Permission Engine: Automatically grant execute rights across all repo scripts
echo -e "${YELLOW}[+] Injecting full executable permissions (chmod +x) across repo...${NC}"
chmod +x "$TARGET_LAUNCHER" 2>/dev/null || true
chmod +x "${SCRIPT_DIR}/install.sh" 2>/dev/null || true
chmod +x "${SCRIPT_DIR}/linux/"*.sh 2>/dev/null || true
chmod +x "${SCRIPT_DIR}/modules/"*.sh 2>/dev/null || true

echo -e "${YELLOW}[+] Deploying global symlink at '${GLOBAL_BIN}'...${NC}"

if sudo ln -sf "$TARGET_LAUNCHER" "$GLOBAL_BIN"; then
    echo -e "\n${GREEN}[✔] SUCCESS! Shell Wizard is installed globally!${NC}"
    echo -e "${CYAN}--> Open ANY terminal window in ANY directory and simply type:${NC}"
    echo -e "    ${BOLD}shell-wizard${NC}\n"
else
    echo -e "\n${RED}[!] Failed to create global symlink in /usr/local/bin.${NC}"
    exit 1
fi