#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Captura de tráfico (tcpdump)"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }

# Verificar tcpdump en dispositivo
local has_tcp
has_tcp=$(adb -s "$SELECTED_DEV" shell which tcpdump 2>/dev/null | tr -d '\r')
if [[ -z "$has_tcp" ]]; then
    nxlog_error "tcpdump no encontrado en el dispositivo."
    nxlog_info  "Requiere tcpdump instalado en el dispositivo."
    nxlog_info  "Alternativa: usa Wireshark con ADB reverse + netcat en el PC."
    nx_pause; exit
fi

echo -ne "\n  ${C_WHITE}Duración en segundos [30]: ${C_NC}"
read -r secs
secs="${secs:-30}"
[[ ! "$secs" =~ ^[0-9]+$ ]] && secs=30

local ts; ts=$(date '+%Y%m%d_%H%M%S')
local remote="/sdcard/.nexora_cap_${ts}.pcap"
local dest="$TOOLKIT_ROOT/logs/${SELECTED_MODEL//[^a-zA-Z0-9]/_}-capture_${ts}.pcap"

nxlog_action "Capturando tráfico por ${secs}s..."
nx_adb shell "tcpdump -i any -w $remote &" &>/dev/null
sleep "$secs"
nx_adb shell "pkill tcpdump" &>/dev/null
sleep 1
nx_adb pull "$remote" "$dest" 2>/dev/null && {
    nx_adb shell rm -f "$remote" &>/dev/null
    nxlog_ok "Captura → $dest"
    command -v wireshark &>/dev/null && nxlog_info "Abrir con: wireshark $dest"
} || nxlog_error "Error descargando captura."
nx_pause
