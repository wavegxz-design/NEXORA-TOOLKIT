#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Backup ADB completo"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }

echo -e "  ${C_YELLOW}${C_BOLD}Opciones de backup:${C_NC}\n"
echo -e "  ${C_CYAN}1.${C_NC} Completo (apps + datos + almacenamiento)"
echo -e "  ${C_CYAN}2.${C_NC} Solo apps y datos"
echo -e "  ${C_CYAN}3.${C_NC} Solo almacenamiento externo"
echo -ne "\n  ${C_WHITE}Opción [1-3]: ${C_NC}"
read -r bopt

case "$bopt" in
    1) flags="-apk -shared -all" ;;
    2) flags="-apk -all"         ;;
    3) flags="-shared -noapk"    ;;
    *) flags="-apk -shared -all" ;;
esac

local out="$BACKUP_DIR/${SELECTED_MODEL//[^a-zA-Z0-9]/_}-$(date '+%Y%m%d_%H%M%S').ab"
nxlog_warn "El dispositivo mostrará una pantalla de confirmación — acepta el backup."
nxlog_action "Iniciando backup → $out"
adb -s "$SELECTED_DEV" backup $flags -f "$out" &
nx_spinner $! "Generando backup"
wait $! 2>/dev/null
local size; size=$(du -sh "$out" 2>/dev/null | cut -f1)
[[ -s "$out" ]] \
    && nxlog_ok "Backup completado: $out [$size]" \
    || nxlog_error "Backup falló o el archivo está vacío."
nx_pause
