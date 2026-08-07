#!/usr/bin/env bash
# ==============================================================================
# TOOL NAME:    shell-wizard.sh (Linux/macOS Engine)
# AUTHOR:       Saleem (Open Source DevOps/Sec Contributor)
# DESCRIPTION:  Main capabilities orchestrator for Unix environments.
# ==============================================================================

set -e

# Resolve true physical directory even when executed via symlink
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

MODULES_DIR="${REPO_ROOT}/modules"

# --- Terminal Color Formats ---
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'


show_header() {
    clear
    echo -e "${CYAN}${BOLD}"
    cat << "EOF"
                                            #######                                              
                                     ##########################                                     
                                 ##################################                                 
                               ######################################                               
                            #############........##........#############                            
                          ##############.........##.........##############                          
                        ##########....###........##.........##....#########                         
                       ########.......###........##........###.......########                       
                      ########.........##........##........###........########                      
                    ###########........###.......##.......###........##########                     
                    #######..###........##.......##.......##........###..#######                    
                   #######....###.......##.......##.......##........##....#######                   
                  #######......###.......##......##.......#........##......#######                  
                 #######........##.......##......##......##.......##........#######                 
                #########........##.......#.......#......#.......##.........########                
                ##########........##......##......#......#......##........#########                 
                #######.###........##......#......#.....#......##........###..######                
                ######....###.......##.....##...........#.....##.......###....######                
                ######......##.......#......#..........#......#.......##......######                
                ######........##......#................#.....#......##........######                
                ######..........#......#.....#........#.....#......##.........######                
                ########.........##........................#.....##..........#######                
                ##########.........#............................#.........#########                 
                  ##########.........#........................#.........###########                 
                    ###########......................................###########                    
                      ###########..................................###########                      
                         ########..................................########                         
                           ######..................................######                           
                            ######................................#######                           
                            ######................................######                            
                            ######................................######                            
                            ####################....####################                            
                            ############################################                            
                            ###########################################                             
                                               ######                                               
                                                                                                    
                                                                                                    
                  # ##########  ##   #  ##                                                          
                 #################   #####                            ######  ######                
                #######     ######   ##### ####         ##########    ######  ######                
                ################     ##############  ###############  ######  ######                
                  #################  #####   ##############    #####  ######  ######                
                 #####      #######  #####    ######################  ######  ######                
                ###################  #####    ######-#######  ######  ######  ######                
                  ###############    #####    ######  #############   ######  ######                                                              
EOF
    echo -e "${NC}"
    echo -e "${CYAN}${BOLD}====================================================================${NC}"
    echo -e "${CYAN}${BOLD}         🧙‍♂️ SHELL-WIZARD ULTIMATE - TERMINAL BEAUTIFIER ENGINE      ${NC}"
    echo -e "${CYAN}${BOLD}====================================================================${NC}"
    echo -e "${YELLOW}GitHub  :${NC} ${BOLD}https://github.com/ali4210${NC}"
    echo -e "${YELLOW}Active Repository Context:${NC} ${BOLD}${TARGET_REPO_DIR}${NC}\n"
}

pause() {
    echo ""
    read -p "Press [ENTER] to return to menu..."
}

enable_global_cli() {
    show_header
    echo -e "${YELLOW}${BOLD}[+] Installing Global CLI Command ('shell-wizard')...${NC}\n"
    TARGET_LAUNCHER="${REPO_ROOT}/autorun.sh"
    GLOBAL_BIN="/usr/local/bin/shell-wizard"

    chmod +x "$TARGET_LAUNCHER"
    chmod +x "${REPO_ROOT}/linux/"*.sh 2>/dev/null || true
    chmod +x "${REPO_ROOT}/modules/"*.sh 2>/dev/null || true

    if sudo ln -sf "$TARGET_LAUNCHER" "$GLOBAL_BIN"; then
        echo -e "\n${GREEN}[✔] SUCCESS! Shell Wizard is now linked globally at ${GLOBAL_BIN}${NC}"
        echo -e "${CYAN}--> You can now run 'shell-wizard' from ANY terminal in ANY folder!${NC}"
    else
        echo -e "\n${RED}[!] Failed to create global symlink in /usr/local/bin.${NC}"
    fi
    pause
}

# --- Main Capabilities Loop ---
while true; do
    show_header
    echo -e "Main Capabilities Suite:\n"
    echo -e "  ${GREEN}[1]${NC} Safety & Backup Engine (Backups & Rollback)"
    echo -e "  ${GREEN}[2]${NC} Automated Nerd Font Injector (MesloLGS, JetBrainsMono)"
    echo -e "  ${GREEN}[3]${NC} ZSH & Oh My Zsh Supercharger (P10K, Agnoster, Robbyrussell)"
    echo -e "  ${GREEN}[4]${NC} CLI Modernization & Tooling (eza, bat, fzf, fastfetch, fd, rg)"
    echo -e "  ${GREEN}[5]${NC} Starship Cross-Shell Suite (Tokyo Night, Gruvbox, Symbols)"
    echo -e "  ${GREEN}[6]${NC} Universal Next-Gen Theme & History (Oh My Posh, Spaceship, Pure, Atuin)"
    echo -e "  ${GREEN}[7]${NC} ⚡ 1-Click Apply & Instant Reload Shell (Apply Changes Now)"
    echo -e "  ${GREEN}[8]${NC} 🌐 Enable Global CLI Access (Run 'shell-wizard' from anywhere)"
    echo -e "  ${GREEN}[9]${NC} Exit"
    echo -e "\n===================================================================="
    read -p "Enter choice [1-9]: " CHOICE

    case $CHOICE in
        1) [[ -f "${MODULES_DIR}/backup-engine.sh" ]] && bash "${MODULES_DIR}/backup-engine.sh" || echo "Module missing!"; pause ;;
        2) [[ -f "${MODULES_DIR}/font-engine.sh" ]] && bash "${MODULES_DIR}/font-engine.sh" || echo "Module missing!"; pause ;;
        3) [[ -f "${MODULES_DIR}/zsh-engine.sh" ]] && bash "${MODULES_DIR}/zsh-engine.sh" || echo "Module missing!"; pause ;;
        4) [[ -f "${MODULES_DIR}/cli-tools.sh" ]] && bash "${MODULES_DIR}/cli-tools.sh" || echo "Module missing!"; pause ;;
        5) [[ -f "${MODULES_DIR}/starship-engine.sh" ]] && bash "${MODULES_DIR}/starship-engine.sh" || echo "Module missing!"; pause ;;
        6) [[ -f "${MODULES_DIR}/nextgen-engine.sh" ]] && bash "${MODULES_DIR}/nextgen-engine.sh" || echo "Module missing!"; pause ;;
        7) [[ -f "${MODULES_DIR}/reload-engine.sh" ]] && bash "${MODULES_DIR}/reload-engine.sh" || echo "Module missing!"; pause ;;
        8) enable_global_cli ;;
        9) echo -e "\n${GREEN}Make your terminal your masterpiece! Goodbye!${NC}"; exit 0 ;;
        *) echo -e "\n${RED}Invalid option!${NC}"; sleep 1 ;;
    esac
done