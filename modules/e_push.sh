#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Enviar archivo al dispositivo"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
echo -ne "\n  ${C_WHITE}Archivo local (ruta completa o arrastra): ${C_NC}"
read -r local_file
local_file=$(echo "$local_file" | sed "s/^['\"]//;s/['\"]$//;s/\\ / /g" | xargs)
[[ ! -f "$local_file" ]] && { nxlog_error "Archivo no encontrado: $local_file"; nx_pause; exit; }
echo -ne "  ${C_WHITE}Destino en dispositivo (Enter = /sdcard/): ${C_NC}"
read -r remote_dest
[[ -z "$remote_dest" ]] && remote_dest="/sdcard/"
nxlog_action "Enviando $(basename "$local_file") → $SELECTED_MODEL:$remote_dest"
nx_adb push "$local_file" "$remote_dest" \
    && nxlog_ok "Archivo enviado correctamente." \
    || nxlog_error "Error enviando archivo."
nx_pause
