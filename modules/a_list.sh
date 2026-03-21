#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Listar aplicaciones"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }

echo -e "  ${C_YELLOW}${C_BOLD}Filtro:${C_NC}\n"
echo -e "  ${C_CYAN}1.${C_NC} Todas"
echo -e "  ${C_CYAN}2.${C_NC} Solo de terceros"
echo -e "  ${C_CYAN}3.${C_NC} Solo del sistema"
echo -e "  ${C_CYAN}4.${C_NC} Solo habilitadas"
echo -e "  ${C_CYAN}5.${C_NC} Solo deshabilitadas"
echo -ne "\n  ${C_WHITE}Opción [1-5]: ${C_NC}"
read -r flt

case "$flt" in
    1) flag=""   ; label="todas"          ;;
    2) flag="-3" ; label="terceros"       ;;
    3) flag="-s" ; label="sistema"        ;;
    4) flag="-e" ; label="habilitadas"    ;;
    5) flag="-d" ; label="deshabilitadas" ;;
    *) flag=""   ; label="todas"          ;;
esac

local out="$TOOLKIT_ROOT/logs/${SELECTED_MODEL//[^a-zA-Z0-9]/_}-apps-${label}-$(date '+%Y%m%d_%H%M%S').txt"
nxlog_action "Listando apps ($label)..."
adb -s "$SELECTED_DEV" shell pm list packages $flag 2>/dev/null \
    | sed 's/^package://' | sort | tee "$out" | less -R
nxlog_ok "$(wc -l < "$out") apps — guardadas en: $out"
nx_pause
