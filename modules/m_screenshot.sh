#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Captura de pantalla"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
local ts; ts=$(date '+%Y%m%d_%H%M%S')
local remote="/sdcard/.nexora_ss_${ts}.png"
local dest="$TOOLKIT_ROOT/screenshots/${SELECTED_MODEL//[^a-zA-Z0-9]/_}_${ts}.png"
nxlog_action "Capturando pantalla de $SELECTED_MODEL..."
nx_adb shell screencap -p "$remote" 2>/dev/null && {
    nx_adb pull "$remote" "$dest" 2>/dev/null && {
        nx_adb shell rm -f "$remote" 2>/dev/null
        nxlog_ok "Screenshot → $dest"
    } || nxlog_error "Error descargando screenshot."
} || nxlog_error "Error capturando pantalla."
nx_pause
