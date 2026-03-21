#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Dump información del sistema"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
local out="$TOOLKIT_ROOT/logs/${SELECTED_MODEL//[^a-zA-Z0-9]/_}-sysinfo-$(date '+%Y%m%d_%H%M%S').log"
nxlog_action "Dumpeando info del sistema en $SELECTED_MODEL..."
nx_adb shell dumpsys > "$out" 2>/dev/null &
nx_spinner $! "Recopilando información del sistema"
nxlog_ok "Guardado: $out"
less -R "$out"
nx_pause
