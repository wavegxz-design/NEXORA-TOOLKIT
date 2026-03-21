#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Extracción: redes sociales y mensajería"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }

# Mapa: Nombre | Package | Rutas posibles (separadas por ,)
declare -A APP_NAMES=(
    [1]="WhatsApp"
    [2]="WhatsApp Business"
    [3]="Telegram"
    [4]="Signal"
    [5]="Instagram"
    [6]="Facebook"
    [7]="TikTok"
    [8]="Snapchat"
    [9]="LINE"
    [10]="Viber"
    [11]="Discord"
    [12]="Twitter/X"
    [13]="Messenger"
)
declare -A APP_PKGS=(
    [1]="com.whatsapp"
    [2]="com.whatsapp.w4b"
    [3]="org.telegram.messenger"
    [4]="org.thoughtcrime.securesms"
    [5]="com.instagram.android"
    [6]="com.facebook.katana"
    [7]="com.zhiliaoapp.musically"
    [8]="com.snapchat.android"
    [9]="jp.naver.line.android"
    [10]="com.viber.voip"
    [11]="com.discord"
    [12]="com.twitter.android"
    [13]="com.facebook.orca"
)
declare -A APP_PATHS=(
    [1]="/sdcard/Android/media/com.whatsapp,/sdcard/WhatsApp"
    [2]="/sdcard/Android/media/com.whatsapp.w4b,/sdcard/WhatsApp Business"
    [3]="/sdcard/Telegram"
    [4]="/sdcard/Signal"
    [5]="/sdcard/Pictures/Instagram,/sdcard/Movies/Instagram"
    [6]="/sdcard/DCIM/Facebook,/sdcard/Pictures/Facebook"
    [7]="/sdcard/DCIM/TikTok,/sdcard/Movies/TikTok"
    [8]="/sdcard/Snapchat,/sdcard/Pictures/Snapchat"
    [9]="/sdcard/LINE,/sdcard/Pictures/LINE"
    [10]="/sdcard/viber/media,/sdcard/Pictures/Viber"
    [11]="/sdcard/Pictures/Discord"
    [12]="/sdcard/Pictures/Twitter,/sdcard/Pictures/X"
    [13]="/sdcard/Pictures/Messenger"
)

echo -e "\n  ${C_YELLOW}${C_BOLD}Apps disponibles:${C_NC}\n"
printf "  ${C_CYAN}${C_BOLD}%-4s  %-25s  %s${C_NC}\n" "Nº" "App" "Estado"
nx_separator
for key in $(seq 1 13); do
    local inst_str color
    if nx_app_installed "${APP_PKGS[$key]}"; then
        inst_str="[instalada]"
        color="$C_GREEN"
    else
        inst_str="[no instalada]"
        color="$C_GRAY"
    fi
    printf "  ${C_CYAN}%-4s${C_NC}  ${C_WHITE}%-25s${C_NC}  ${color}%s${C_NC}\n" \
        "$key." "${APP_NAMES[$key]}" "$inst_str"
done
echo -e "  ${C_CYAN}0.${C_NC}  ${C_WHITE}Todas las instaladas${C_NC}"
nx_separator

echo -ne "\n  ${C_WHITE}Opción: ${C_NC}"
read -r sel

_pull_app() {
    local key="$1"
    local name="${APP_NAMES[$key]}"
    local pkg="${APP_PKGS[$key]}"
    local paths="${APP_PATHS[$key]}"
    local dest; dest=$(nx_make_dir "${name//[^a-zA-Z0-9]/_}")
    nxlog_action "Extrayendo $name..."
    local pulled=0
    IFS=',' read -ra path_list <<< "$paths"
    for p in "${path_list[@]}"; do
        p=$(echo "$p" | xargs)
        local res
        res=$(adb -s "$SELECTED_DEV" pull "$p/" "$dest/" 2>&1)
        if ! echo "$res" | grep -qi "error\|does not exist\|no such file"; then
            (( pulled++ ))
        fi
    done
    [[ $pulled -gt 0 ]] && nxlog_ok "$name → $dest" || nxlog_warn "$name: sin archivos encontrados"
}

if [[ "$sel" == "0" ]]; then
    for key in $(seq 1 13); do
        nx_app_installed "${APP_PKGS[$key]}" && _pull_app "$key"
    done
elif [[ "$sel" =~ ^[1-9]$|^1[0-3]$ ]]; then
    _pull_app "$sel"
else
    nxlog_warn "Opción no válida."
fi
nx_pause
