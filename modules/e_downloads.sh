#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Copiar descargas"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
local dest; dest=$(nx_make_dir "Downloads")
nxlog_action "Copiando Downloads → $dest"
nx_adb pull /sdcard/Download/ "$dest/" 2>&1 | tail -5
nx_adb pull /sdcard/Downloads/ "$dest/" 2>&1 | tail -5
nxlog_ok "Completado → $dest"
nx_pause
