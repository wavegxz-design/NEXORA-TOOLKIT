#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Procesos activos"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
nxlog_action "Listando procesos en $SELECTED_MODEL..."
nx_adb shell ps -A 2>/dev/null | less -R
nx_pause
