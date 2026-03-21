#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Grabar pantalla"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }

echo -ne "\n  ${C_WHITE}Duración en segundos [30-180, Enter=30]: ${C_NC}"
read -r secs
secs="${secs:-30}"
[[ ! "$secs" =~ ^[0-9]+$ ]] && secs=30
(( secs < 1 ))   && secs=30
(( secs > 180 )) && secs=180

local ts; ts=$(date '+%Y%m%d_%H%M%S')
local remote="/sdcard/.nexora_rec_${ts}.mp4"
local dest="$TOOLKIT_ROOT/screenrecords/${SELECTED_MODEL//[^a-zA-Z0-9]/_}_${ts}.mp4"

nxlog_action "Grabando por ${secs}s en $SELECTED_MODEL..."
nx_adb shell screenrecord --time-limit "$secs" "$remote" &
local rpid=$!
nx_spinner $rpid "Grabando pantalla (${secs}s)"
wait $rpid 2>/dev/null

nxlog_action "Descargando grabación..."
nx_adb pull "$remote" "$dest" 2>/dev/null && {
    nx_adb shell rm -f "$remote" 2>/dev/null
    nxlog_ok "Grabación → $dest"
} || nxlog_error "Error descargando grabación."
nx_pause
