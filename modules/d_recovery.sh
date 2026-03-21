#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Reiniciar a Recovery"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
nx_confirm "¿Reiniciar $SELECTED_MODEL a Recovery?" && {
    nx_adb reboot recovery
    nxlog_ok "Reiniciando a Recovery..."
}
nx_pause
