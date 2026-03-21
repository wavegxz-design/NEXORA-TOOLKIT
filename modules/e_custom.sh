#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Copiar archivo/carpeta específico"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
echo -ne "\n  ${C_WHITE}Ruta en el dispositivo (ej: /sdcard/Documents/): ${C_NC}"
read -r remote_path
[[ -z "$remote_path" ]] && { nxlog_error "Ruta vacía."; nx_pause; exit; }
local dest; dest=$(nx_make_dir "custom")
nxlog_action "Copiando $remote_path → $dest"
nx_adb pull "$remote_path" "$dest/" 2>&1 \
    && nxlog_ok "Completado → $dest" \
    || nxlog_error "Error en la copia. Verifica que la ruta existe."
nx_pause
