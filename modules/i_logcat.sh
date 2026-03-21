#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Logcat en vivo"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }

echo -e "  ${C_YELLOW}${C_BOLD}Nivel de log:${C_NC}\n"
echo -e "  ${C_CYAN}1.${C_NC} Verbose (todo)"
echo -e "  ${C_CYAN}2.${C_NC} Debug"
echo -e "  ${C_CYAN}3.${C_NC} Info"
echo -e "  ${C_CYAN}4.${C_NC} Warning"
echo -e "  ${C_CYAN}5.${C_NC} Error únicamente"
echo -ne "\n  ${C_WHITE}Opción [1-5]: ${C_NC}"
read -r lvl

case "$lvl" in
    1) tag="V" ;; 2) tag="D" ;; 3) tag="I" ;;
    4) tag="W" ;; 5) tag="E" ;; *) tag="V" ;;
esac

local out="$TOOLKIT_ROOT/logs/${SELECTED_MODEL//[^a-zA-Z0-9]/_}-logcat-$(date '+%Y%m%d_%H%M%S').log"
nxlog_ok "Logcat nivel [$tag] en $SELECTED_MODEL — Ctrl+C para detener"
nxlog_info "Guardando en: $out"
nx_adb logcat "*:$tag" 2>/dev/null | tee "$out"
nx_pause
