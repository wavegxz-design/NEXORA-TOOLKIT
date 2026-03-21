#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Copiar fotos y videos (DCIM)"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
local dest; dest=$(nx_make_dir "DCIM")
nxlog_action "Copiando DCIM de $SELECTED_MODEL → $dest"
nx_adb pull /sdcard/DCIM/ "$dest/" 2>&1 | tail -5
nxlog_ok "Completado → $dest"
nx_pause
