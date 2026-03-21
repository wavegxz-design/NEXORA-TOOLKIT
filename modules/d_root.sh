#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Verificar root"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
nxlog_action "Verificando root en $SELECTED_MODEL..."
echo ""
local su_path magisk selinux uid
su_path=$(adb -s "$SELECTED_DEV" shell which su 2>/dev/null | tr -d '\r')
magisk=$(adb -s "$SELECTED_DEV"  shell pm list packages 2>/dev/null | grep -i "magisk")
selinux=$(adb -s "$SELECTED_DEV" shell getenforce 2>/dev/null | tr -d '\r')
uid=$(adb -s "$SELECTED_DEV"     shell id 2>/dev/null | tr -d '\r')

if [[ -n "$su_path" ]]; then
    echo -e "  ${C_GREEN}${C_BOLD}[✔] ROOTEADO${C_NC}  —  su en: $su_path"
else
    echo -e "  ${C_RED}${C_BOLD}[✗] NO ROOTEADO${C_NC}  —  su no encontrado"
fi
[[ -n "$magisk" ]] && echo -e "  ${C_GREEN}${C_BOLD}[✔] Magisk detectado${C_NC}"
echo -e "  ${C_BLUE}[i]${C_NC} ${C_GRAY}SELinux: ${selinux:-desconocido}${C_NC}"
echo -e "  ${C_BLUE}[i]${C_NC} ${C_GRAY}UID: ${uid:-N/A}${C_NC}"
nx_pause
