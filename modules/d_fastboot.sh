#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Reiniciar a Fastboot/Bootloader"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
nx_confirm "¿Reiniciar $SELECTED_MODEL a Fastboot?" && {
    nx_adb reboot bootloader
    nxlog_ok "Reiniciando a Fastboot..."
}
nx_pause
