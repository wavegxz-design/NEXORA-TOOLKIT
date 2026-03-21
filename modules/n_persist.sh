#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Persistencia conexión ADB WiFi"
echo -e "  ${C_GRAY}Mantiene la conexión ADB WiFi disponible entre reinicios${C_NC}\n"

echo -e "  ${C_YELLOW}${C_BOLD}Opciones:${C_NC}\n"
echo -e "  ${C_CYAN}1.${C_NC} Activar persistencia (dispositivo conectado por USB)"
echo -e "  ${C_CYAN}2.${C_NC} Reconectar al último dispositivo WiFi guardado"
echo -e "  ${C_CYAN}3.${C_NC} Ver estado actual"
echo -e "  ${C_CYAN}4.${C_NC} Desactivar persistencia"
echo -ne "\n  ${C_WHITE}Opción [1-4]: ${C_NC}"
read -r popt

case "$popt" in
    1)
        nx_select_device "Selecciona dispositivo (USB)" || { nx_pause; exit; }
        local ip; ip=$(nx_get_device_ip)
        [[ -z "$ip" ]] && { nxlog_error "Sin IP WiFi."; nx_pause; exit; }
        # Habilitar TCP/IP en modo persistente
        nx_adb tcpip 5555 &>/dev/null
        # Intentar configurar prop persistente (requiere root en algunos dispositivos)
        nx_adb shell setprop persist.adb.tcp.port 5555 2>/dev/null || true
        sleep 2
        adb connect "$ip:5555" &>/dev/null
        # Guardar configuración
        {
            echo "ip=$ip"
            echo "model=$SELECTED_MODEL"
            echo "port=5555"
            echo "timestamp=$(date '+%F %T')"
        } > "$TOOLKIT_ROOT/.temp/last_wifi.conf"
        nxlog_ok "Persistencia activada — $SELECTED_MODEL @ $ip:5555"
        nxlog_info "Config guardada en .temp/last_wifi.conf"
        ;;
    2)
        local cfg="$TOOLKIT_ROOT/.temp/last_wifi.conf"
        if [[ ! -f "$cfg" ]]; then
            nxlog_error "Sin configuración guardada. Activa la persistencia primero."
        else
            source "$cfg"
            nxlog_action "Reconectando a $model ($ip:${port:-5555})..."
            local res; res=$(adb connect "$ip:${port:-5555}" 2>&1)
            echo -e "  ${C_GRAY}$res${C_NC}"
            echo "$res" | grep -qi "connected" \
                && nxlog_ok "Reconexión exitosa a $model" \
                || nxlog_error "Falló. Verifica que el dispositivo esté en la misma red."
        fi
        ;;
    3)
        nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
        local port_active
        port_active=$(adb -s "$SELECTED_DEV" shell getprop persist.adb.tcp.port 2>/dev/null | tr -d '\r')
        local ip; ip=$(nx_get_device_ip)
        echo ""
        [[ -n "$port_active" && "$port_active" != "0" && "$port_active" != "" ]] \
            && echo -e "  ${C_GREEN}[✔] Persistencia activa${C_NC}  —  Puerto: $port_active  IP: ${ip:-N/A}" \
            || echo -e "  ${C_YELLOW}[!] Persistencia no configurada${C_NC}"
        ;;
    4)
        nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
        nx_adb shell setprop persist.adb.tcp.port "" 2>/dev/null || true
        rm -f "$TOOLKIT_ROOT/.temp/last_wifi.conf"
        nxlog_ok "Persistencia desactivada."
        ;;
esac
nx_pause
