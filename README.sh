#!/bin/bash
# ===========================================================
# B1 CONTROL PANEL
# Mode By - B1
# ===========================================================

# --- COLORS ---
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m' 
BOLD='\033[1m'

# ===================== DYNAMIC COLOR =====================
COLORS=('\033[1;31m' '\033[1;32m' '\033[1;34m' '\033[1;35m' '\033[1;36m')
rand_color(){ echo -e "${COLORS[$RANDOM % ${#COLORS[@]}]}"; }

pause(){ 
    echo -e "\n${GRAY}──────────────────────────────────────────────────${NC}"
    read -p "  Press [Enter] to continue..." x
}

# ===================== B1 ULTRA BANNER =====================
banner(){
    clear
    local C=$(rand_color)
    echo -e "${C}  ██████╗  ██╗ ${NC}"
    echo -e "${C}  ██╔══██╗███║ ${NC}"
    echo -e "${C}  ██████╔╝╚██║ ${NC}"
    echo -e "${C}  ██╔══██╗ ██║ ${NC}"
    echo -e "${C}  ██████╔╝ ██║ ${NC}"
    echo -e "${C}  ╚═════╝  ╚═╝ ${NC}"
    echo -e "${BOLD}${WHITE}  ────────────${NC}"
    echo -e "  ${BOLD}${C}  MADE BY B1${NC}"
    echo -e "${BOLD}${WHITE}  ────────────${NC}"
    echo
}

# ===================== PANEL MENU =====================
panel_menu(){
    while true; do 
        banner
        echo -e "  ${PURPLE}┌────────── B1 PANEL ──────────┐${NC}"
        echo -e "  ${WHITE}  01. FeatherPanel   07. Paymenter"
        echo -e "  ${WHITE}  02. Pterodactyl    08. CtrlPanel"
        echo -e "  ${WHITE}  03. Jexactyl v3    09. Reviactyl"
        echo -e "  ${WHITE}  04. Jexpanel v4    10. External"
        echo -e "  ${WHITE}  05. Dashboard v3   11. BACK"
        echo -e "  ${WHITE}  06. Dashboard v4"
        echo -e "  ${PURPLE}└──────────────────────────────┘${NC}"
        echo -ne "  ${BOLD}${CYAN}B1 Choice » ${NC}"
        read p

        case $p in
             1) bash <(curl -s https://raw.githubusercontent.com/debraj0997/vm/refs/heads/main/Uninstall/unFEATHERPANEL.sh) ;;
             2) bash <(curl -s https://raw.githubusercontent.com/debraj0997/vm/refs/heads/main/Uninstall/unPterodactyl.sh) ;;
             3) bash <(curl -s https://raw.githubusercontent.com/debraj0997/vm/refs/heads/main/panel/Jexactyl.sh) ;;
             4) bash <(curl -s https://raw.githubusercontent.com/debraj0997/vm/refs/heads/main/Uninstall/unJexactyl.sh) ;;
             5) bash <(curl -s https://raw.githubusercontent.com/debraj0997/vm/refs/heads/main/Uninstall/undash-3.sh) ;;
             6) bash <(curl -s https://github.com/nobita329/The-Coding-Hub/raw/refs/heads/main/srv/Uninstall/dash-v4.sh) ;;
             7) bash <(curl -s https://raw.githubusercontent.com/debraj0997/vm/refs/heads/main/Uninstall/unPaymenter.sh) ;;
             8) bash <(curl -s https://raw.githubusercontent.com/debraj0997/vm/refs/heads/main/Uninstall/unCtrlPanel.sh) ;;
             9) bash <(curl -s https://raw.githubusercontent.com/debraj0997/vm/refs/heads/main/Uninstall/unReviactyl.sh) ;;
             10) bash <(curl -s https://raw.githubusercontent.com/yourlink/t-panel.sh) ;;
             11) break;;
             *) echo -e "  ${RED}Invalid!${NC}"; sleep 1;;
        esac
    done
}

# ===================== TOOLS MENU =====================
tools_menu(){
    while true; do 
        banner
        echo -e "  ${BLUE}┌────────── B1 TOOLS ──────────┐${NC}"
        echo -e "  ${WHITE}  1. Root Access     5. Vps Run"
        echo -e "  ${WHITE}  2. Tailscale       6. TERMINAL"
        echo -e "  ${WHITE}  3. Cloudflare DNS  7. RDP"
        echo -e "  ${WHITE}  4. System Info     8. BACK"
        echo -e "  ${BLUE}└──────────────────────────────┘${NC}"
        echo -ne "  ${BOLD}${CYAN}B1 Choice » ${NC}"
        read t

        case $t in
             1) bash <(curl -s https://raw.githubusercontent.com/debraj0997/vm/refs/heads/main/tools/root.sh) ;;
             2) bash <(curl -s https://raw.githubusercontent.com/debraj0997/vm/refs/heads/main/tools/Tailscale.sh) ;;
             3) bash <(curl -s https://raw.githubusercontent.com/debraj0997/vm/refs/heads/main/tools/cloudflare.sh) ;;
             4) bash <(curl -s https://raw.githubusercontent.com/debraj0997/vm/refs/heads/main/tools/SYSTEM.sh) ;;
             5) bash <(curl -s https://raw.githubusercontent.com/nobita54/-150/refs/heads/main/tools/vps.sh) ;;
             6) bash <(curl -s https://raw.githubusercontent.com/debraj0997/vm/refs/heads/main/tools/terminal.sh) ;;
             7) bash <(curl -s https://raw.githubusercontent.com/debraj0997/vm/refs/heads/main/tools/rdp.sh) ;;
             8) break;;
             *) echo -e "  ${RED}Invalid!${NC}"; sleep 1;;
        esac
    done
}

# ===================== THEME MENU =====================
theme_menu(){
    while true; do 
        banner
        echo -e "  ${YELLOW}┌────────── B1 THEME ──────────┐${NC}"
        echo -e "  ${WHITE}  1. Blueprint Theme"
        echo -e "  ${WHITE}  2. Change Theme"
        echo -e "  ${WHITE}  3. Uninstall Theme"
        echo -e "  ${WHITE}  4. BACK"
        echo -e "  ${YELLOW}└──────────────────────────────┘${NC}"
        echo -ne "  ${BOLD}${CYAN}B1 Choice » ${NC}"
        read th

        case $th in
             1) bash <(curl -s https://raw.githubusercontent.com/debraj0997/vm/refs/heads/main/thame/ch.sh) ;;
             2) bash <(curl -s https://raw.githubusercontent.com/debraj0997/vm/refs/heads/main/thame/chang.sh) ;;
             3) bash <(curl -s https://raw.githubusercontent.com/yourlink/theme_uninstall.sh) ;;
             4) break;;
             *) echo -e "  ${RED}Invalid!${NC}"; sleep 1;;
        esac
    done
}

# ===================== MAIN MENU =====================
main_menu(){
    while true; do 
        banner
        echo -e "  ${GREEN}╔══════════ B1 MAIN ══════════╗${NC}"
        echo -e "    ${CYAN}[1]${NC} VPS RUN       ${CYAN}[5]${NC} THEME"
        echo -e "    ${CYAN}[2]${NC} PANEL         ${CYAN}[6]${NC} SYSTEM"
        echo -e "    ${CYAN}[3]${NC} WINGS         ${CYAN}[7]${NC} ALL BEST"
        echo -e "    ${CYAN}[4]${NC} TOOLS         ${CYAN}[8]${NC} EXIT"
        echo -e "  ${GREEN}╚═════════════════════════════╝${NC}"
        echo -ne "  ${BOLD}${WHITE}B1 Command → ${NC}"
        read c

        case $c in
             1) bash <(curl -s https://raw.githubusercontent.com/debraj0997/vm/refs/heads/main/vm/vps.sh) ;;
             2) panel_menu ;;
             3) bash <(curl -s https://raw.githubusercontent.com/debraj0997/vm/refs/heads/main/wings/www.sh) ;;
             4) tools_menu ;;
             5) theme_menu ;;
             6) bash <(curl -s https://raw.githubusercontent.com/debraj0997/vm/refs/heads/main/menu/System1.sh) ;;
             7) bash <(curl -s https://raw.githubusercontent.com/debraj0997/vm/refs/heads/main/External/INFRA.sh) ;;
             8) echo -e "\n  ${GREEN}Goodbye B1!${NC}"; exit ;;
             *) echo -e "  ${RED}Error!${NC}"; sleep 1 ;;
        esac
    done
}

main_menu
