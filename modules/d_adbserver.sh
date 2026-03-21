#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Reiniciar servidor ADB"
nxlog_action "Deteniendo servidor ADB..."
adb kill-server 2>/dev/null
sleep 1
nxlog_action "Iniciando servidor ADB..."
adb start-server 2>/dev/null
nxlog_ok "Servidor ADB reiniciado."
nx_pause
