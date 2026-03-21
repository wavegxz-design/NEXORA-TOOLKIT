#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Shell interactivo ADB"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
nxlog_ok "Abriendo shell en $SELECTED_MODEL. Escribe 'exit' para salir."
echo ""
nx_adb shell
echo ""
nxlog_ok "Shell cerrado."
nx_pause
