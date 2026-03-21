#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Reiniciar dispositivo"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
nx_confirm "¿Reiniciar $SELECTED_MODEL?" && {
    nxlog_action "Reiniciando $SELECTED_MODEL..."
    nx_adb reboot
    nxlog_ok "Comando de reinicio enviado."
}
nx_pause
