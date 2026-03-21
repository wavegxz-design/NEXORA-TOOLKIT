#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Copiar almacenamiento completo"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
nxlog_warn "Esta operación puede tardar mucho tiempo según el almacenamiento del dispositivo."
nx_confirm "¿Continuar copia completa de $SELECTED_MODEL?" || { nx_pause; exit; }
local dest; dest=$(nx_make_dir "FullStorage")
nxlog_action "Copiando /sdcard → $dest"
nx_adb pull /sdcard/ "$dest/" 2>&1 | tail -10
nxlog_ok "Completado → $dest"
nx_pause
