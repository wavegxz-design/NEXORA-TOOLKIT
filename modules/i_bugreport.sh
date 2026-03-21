#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Bug Report completo"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
local out="$TOOLKIT_ROOT/bug-report/${SELECTED_MODEL//[^a-zA-Z0-9]/_}-$(date '+%Y%m%d_%H%M%S').zip"
nxlog_warn "Puede tardar varios minutos. El dispositivo puede mostrar un diálogo de confirmación."
nxlog_action "Generando bug report..."
adb -s "$SELECTED_DEV" bugreport "$out" &
nx_spinner $! "Generando bug report"
local size; size=$(du -sh "$out" 2>/dev/null | cut -f1)
[[ -f "$out" ]] && nxlog_ok "Bug report guardado: $out [$size]" \
                || nxlog_error "Error generando bug report."
nx_pause
