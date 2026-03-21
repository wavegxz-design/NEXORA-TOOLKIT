#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Info de red completa"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
{
    echo "=== INTERFACES DE RED ==="
    adb -s "$SELECTED_DEV" shell ip addr show 2>/dev/null
    echo -e "\n=== RUTAS DE RED ==="
    adb -s "$SELECTED_DEV" shell ip route show 2>/dev/null
    echo -e "\n=== CONEXIONES ACTIVAS ==="
    adb -s "$SELECTED_DEV" shell ss -tnp 2>/dev/null || \
    adb -s "$SELECTED_DEV" shell netstat -tnp 2>/dev/null || \
    echo "(ss/netstat no disponible)"
    echo -e "\n=== DNS ==="
    adb -s "$SELECTED_DEV" shell getprop 2>/dev/null | grep -i dns
    echo -e "\n=== INFO WiFi ==="
    adb -s "$SELECTED_DEV" shell dumpsys wifi 2>/dev/null | grep -E "mWifiInfo|SSID|BSSID|IP|freq" | head -10
} | less -R
nx_pause
