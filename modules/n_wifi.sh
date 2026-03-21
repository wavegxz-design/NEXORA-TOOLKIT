#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Conexión ADB por WiFi"
nx_select_device "Selecciona dispositivo base (USB)" || { nx_pause; exit; }

nxlog_action "Obteniendo IP de $SELECTED_MODEL..."
local ip; ip=$(nx_get_device_ip)

if [[ -z "$ip" ]]; then
    nxlog_error "Sin IP WiFi. ¿Está el dispositivo conectado a WiFi?"
    nx_pause; exit
fi
nxlog_ok "IP detectada: $ip"

nxlog_action "Habilitando ADB TCP/IP en puerto 5555..."
adb -s "$SELECTED_DEV" tcpip 5555 &>/dev/null
sleep 2

nxlog_action "Conectando a $ip:5555..."
local result; result=$(adb connect "$ip:5555" 2>&1)
echo -e "  ${C_GRAY}$result${C_NC}"

if echo "$result" | grep -qi "connected"; then
    nxlog_ok "Conexión WiFi establecida: $SELECTED_MODEL @ $ip:5555"
    nxlog_info "Puedes desconectar el cable USB."
    echo -e "\n  ${C_YELLOW}Para reconectar sin USB:${C_NC}"
    echo -e "  ${C_GRAY}adb connect $ip:5555${C_NC}"
    # Guardar para reconexión rápida
    echo "ip=$ip" > "$TOOLKIT_ROOT/.temp/last_wifi.conf"
    echo "model=$SELECTED_MODEL" >> "$TOOLKIT_ROOT/.temp/last_wifi.conf"
    echo "port=5555" >> "$TOOLKIT_ROOT/.temp/last_wifi.conf"
else
    nxlog_error "Conexión fallida. Verifica que ambos dispositivos estén en la misma red."
fi
nx_pause
