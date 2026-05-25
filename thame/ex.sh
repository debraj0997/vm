#!/bin/bash

# ==========================================================
# 🚀 GUIDECLOUD BLUEPRINT EXTENSION MATRIX v4.0
# 🛠️ POWERED BY: B1 @ HQ
# 📅 ARCHITECTURE EDITION: 2026
# ==========================================================
[[ $EUID -ne 0 ]] && echo "Run as root!" && exit 1

# ==========================================
# 🎨 PREMIUM CYBER NEON THEME
# ==========================================
R="\e[31m"; G="\e[32m"; Y="\e[33m"
B="\e[34m"; M="\e[35m"; C="\e[36m"
W="\e[97m"; N="\e[0m"

BR="\e[1;31m"; BG="\e[1;32m"; BY="\e[1;33m"
BM="\e[1;35m"; BC="\e[1;36m"; BW="\e[1;97m"
VIOLET="\e[1;38;5;135m"

URL="https://github.com/debraj0997/vm/tree/main/thame/all/ex"
selected_indices=()

trap 'echo -e "\n${R}[!] Force exit detected.${N}"; exit 1' SIGINT

# ==========================================
# 🧠 BLUEPRINT LIST
# ==========================================
names=(
"adminauditlogs.blueprint" "huxregister.blueprint" "loader.blueprint" 
"lyrdyannounce.blueprint" "mclogs.blueprint" "mcplugins.blueprint"
"mctools.blueprint" "minecraftplayermanager.blueprint" "playerlisting.blueprint" 
"resourcealerts.blueprint" "resourcemanager.blueprint" "serverbackgrounds.blueprint"
"serversplitter.blueprint" "simplefavicons.blueprint" "snowflakes.blueprint" 
"sociallogin.blueprint" "startupchanger.blueprint" "subdomains.blueprint"
"tawkto.blueprint" "versionchanger.blueprint" "pteromonaco.blueprint" 
"urldownloader.blueprint" "consolelogs.blueprint" "laravellogs.blueprint"
"vanillatweaks.blueprint" "modrinthbrowser.blueprint" "nopagination.blueprint" 
"activitypurges.blueprint" "redirect.blueprint" "simplefooters.blueprint"
"paneladdressoverride.blueprint" "shownodeids.blueprint" "votifiertester.blueprint" 
"sidebar.blueprint" "translations.blueprint" "monacoeditor.blueprint"
"minecraftpluginmanager.blueprint" "subdomainmanager.blueprint" "serverimporter.blueprint" 
"pstatistics.blueprint" "pullfiles.blueprint" "serverpropsmanager.blueprint" 
"motdmaker.blueprint" "servericonimporter.blueprint" "sagaautosuspension.blueprint"
"sagaminecraftmodpackinstaller.blueprint" "blueannoucements.blueprint" "trashbin.blueprint" 
"eggchanger.blueprint" "mysqlautobackup.blueprint" "configeditor.blueprint" "customserversort.blueprint" "databaseimportexport.blueprint"
"minecraftmodmanager.blueprint" "serverid.blueprint" "stats.blueprint" "vminfo.blueprint" "customcss.blueprint" "autobackups.blueprint" "node.blueprint" "mcp.blueprint"
"mcplayer.blueprint"
)

# ==========================================
# 🔍 HELPERS
# ==========================================
is_installed() {
    [[ -d "/var/www/pterodactyl/storage/extensions/${1%.blueprint}" ]] && return 0 || return 1
}

is_selected() {
    local index=$1
    [[ " ${selected_indices[*]} " =~ " $index " ]] && return 0 || return 1
}

run_blueprint() {
    local NAME="$1"
    local ACTION="$2"
    cd /var/www/pterodactyl || exit 1
    if [[ "$ACTION" == "install" ]]; then
        echo -e "${G}📥 Injecting Extension: ${NAME%.blueprint}...${N}"
        wget -q "$URL/$NAME" -O "$NAME"
        [[ -s "$NAME" ]] && yes | blueprint -i "$NAME" && rm -f "$NAME"
    else
        echo -e "${R}🗑️ Wiping Extension: ${NAME%.blueprint}...${N}"
        yes | blueprint -r "${NAME%.blueprint}"
    fi
}

# ==========================================
# 📋 BRANDED HEADER & MENU
# ==========================================
show_menu() {
    clear
    echo -e "${BC} ╔══════════════════════════════════════════════════════════╗${N}"
    printf " ${BC}║${BW}%-58s${BC}║${N}\n" "            💠 GUIDECLOUD EXTENSION CENTER 💠"
    printf " ${BC}║${VIOLET}%-58s${BC}║${N}\n" "         Advanced Multi-Select Blueprint Deployer"
    echo -e "${BC} ╚══════════════════════════════════════════════════════════╝${N}"
    echo -e " ${B}Operator:${N} B1 @ HQ    ${B}Portal:${N} www.guidecloud.in    ${B}Time:${N} $(date +'%H:%M')"
    echo -e "${C} ──────────────────────────────────────────────────────────${N}"
    
    local count=0
    for i in "${!names[@]}"; do
        num=$((i+1))
        clean_name="${names[$i]%.blueprint}"
        
        # Status Icon (Active vs Inactive)
        is_installed "$clean_name" && status="${BG}●${N}" || status="${R}○${N}"
        
        # Selection Mark Check
        is_selected "$i" && select_mark="${BY}[+]${N}" || select_mark="   "

        # Truncate safe layout block
        display_name="${clean_name:0:22}"

        printf " %b ${BG}%2d${N} %-22s %b  " "$select_mark" "$num" "$display_name" "$status"
        ((count++))
        [[ $((count % 2)) -eq 0 ]] && echo ""
    done

    [[ $((count % 2)) -ne 0 ]] && echo ""

    echo -e "${C} ──────────────────────────────────────────────────────────${N}"
    echo -e " ${BW}QUEUE POOL:${N} ${BY}${#selected_indices[@]}${N} Units Selected"
    echo -e " ${BG}[i]${N} Install Batch  ${BR}[r]${N} Remove Batch  ${BM}[a]${N} Select All  ${BC}[c]${N} Reset Selection  ${R}[0]${N} Exit Core"
    echo -e "${C} ──────────────────────────────────────────────────────────${N}"
}

# ==========================================
# 🔁 MAIN LOOP
# ==========================================
while true; do
    show_menu
    read -p " 🪐 ENTER UNITS ID(s) OR EXEC ACTION → " choice

    case $choice in
        0) echo -e "\n${G} [✔] GuideCloud Extension Session Terminated. Goodbye B1!${N}\n"; exit 0 ;;
        c|C) selected_indices=() ;;
        a|A) 
            selected_indices=()
            for i in "${!names[@]}"; do
                selected_indices+=("$i")
            done
            ;;
        i|I|r|R)
            if [[ ${#selected_indices[@]} -eq 0 ]]; then
                echo -e "${R} [!] Operation Terminated: Deployment queue is empty!${N}"; sleep 1; continue
            fi
            action_type="install"
            [[ "$choice" =~ [rR] ]] && action_type="remove"
            
            for idx in "${selected_indices[@]}"; do
                run_blueprint "${names[$idx]}" "$action_type"
            done
            selected_indices=()
            echo ""
            read -p " ↩️ Processing complete. Press [Enter] to return to Matrixboard..."
            ;;
        *)
            # Multi-select toggle logic
            for val in $choice; do
                if [[ "$val" =~ ^[0-9]+$ ]] && (( val >= 1 && val <= ${#names[@]} )); then
                    idx=$((val-1))
                    if is_selected "$idx"; then
                        for i in "${!selected_indices[@]}"; do
                            if [[ ${selected_indices[i]} -eq $idx ]]; then
                                unset 'selected_indices[i]'
                            fi
                        done
                        selected_indices=("${selected_indices[@]}") # Re-index array
                    else
                        selected_indices+=("$idx")
                    fi
                else
                    echo -e "${R} [!] Invalid Option Segment: $val${N}"; sleep 0.5
                fi
            done
            ;;
    esac
done
