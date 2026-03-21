#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Port Forwarding ADB"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }

echo -e "  ${C_YELLOW}${C_BOLD}Opciones:${C_NC}\n"
echo -e "  ${C_CYAN}1.${C_NC} Forward: local → dispositivo"
echo -e "  ${C_CYAN}2.${C_NC} Reverse: dispositivo → local"
echo -e "  ${C_CYAN}3.${C_NC} Listar forwards activos"
echo -e "  ${C_CYAN}4.${C_NC} Eliminar todos los forwards"
echo -ne "\n  ${C_WHITE}Opción [1-4]: ${C_NC}"
read -r fopt

_validate_port() {
    [[ "$1" =~ ^[0-9]+$ ]] && (( $1 >= 1 && $1 <= 65535 ))
}

case "$fopt" in
    1)
        echo -ne "  ${C_WHITE}Puerto local: ${C_NC}"; read -r lport
        echo -ne "  ${C_WHITE}Puerto en dispositivo: ${C_NC}"; read -r rport
        _validate_port "$lport" && _validate_port "$rport" || { nxlog_error "Puerto inválido."; nx_pause; exit; }
        nx_adb forward "tcp:$lport" "tcp:$rport" \
            && nxlog_ok "Forward: localhost:$lport → $SELECTED_MODEL:$rport" \
            || nxlog_error "Error creando forward."
        ;;
    2)
        echo -ne "  ${C_WHITE}Puerto en dispositivo: ${C_NC}"; read -r rport
        echo -ne "  ${C_WHITE}Puerto local: ${C_NC}"; read -r lport
        _validate_port "$rport" && _validate_port "$lport" || { nxlog_error "Puerto inválido."; nx_pause; exit; }
        nx_adb reverse "tcp:$rport" "tcp:$lport" \
            && nxlog_ok "Reverse: $SELECTED_MODEL:$rport → localhost:$lport" \
            || nxlog_error "Error creando reverse."
        ;;
    3)
        nxlog_info "Forwards activos:"
        nx_adb forward --list
        ;;
    4)
        nx_adb forward --remove-all && nxlog_ok "Todos los forwards eliminados."
        ;;
esac
nx_pause
