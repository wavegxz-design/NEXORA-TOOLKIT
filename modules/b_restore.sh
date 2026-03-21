#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Restaurar backup ADB"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }

mapfile -t backups < <(find "$BACKUP_DIR" -name "*.ab" -type f 2>/dev/null | sort)
if [[ ${#backups[@]} -eq 0 ]]; then
    nxlog_error "Sin backups en $BACKUP_DIR"
    nx_pause; exit
fi

echo -e "\n  ${C_YELLOW}${C_BOLD}Backups disponibles:${C_NC}\n"
for i in "${!backups[@]}"; do
    local size; size=$(du -sh "${backups[$i]}" 2>/dev/null | cut -f1)
    local ts; ts=$(stat -c '%y' "${backups[$i]}" 2>/dev/null | cut -d'.' -f1)
    printf "  ${C_CYAN}%2d.${C_NC}  ${C_WHITE}%-45s${C_NC}  ${C_GRAY}%s  [%s]${C_NC}\n" \
        "$((i+1))" "$(basename "${backups[$i]}")" "$ts" "$size"
done
echo -ne "\n  ${C_WHITE}Selecciona backup [1-${#backups[@]}]: ${C_NC}"
read -r sel

if [[ "$sel" =~ ^[0-9]+$ ]] && (( sel >= 1 && sel <= ${#backups[@]} )); then
    local bk="${backups[$((sel-1))]}"
    nx_confirm "¿Restaurar $(basename "$bk") en $SELECTED_MODEL?" && {
        nxlog_warn "El dispositivo pedirá confirmación."
        adb -s "$SELECTED_DEV" restore "$bk" \
            && nxlog_ok "Restauración completada." \
            || nxlog_error "Error en la restauración."
    }
else
    nxlog_warn "Opción inválida."
fi
nx_pause
