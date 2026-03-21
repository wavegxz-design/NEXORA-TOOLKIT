#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Dispositivos conectados"
nx_detect_devices
if [[ $TOTAL_DEVS -eq 0 ]]; then
    nxlog_error "Ningún dispositivo ADB detectado."
    echo -e "\n  ${C_YELLOW}Pasos para conectar:${C_NC}"
    echo -e "   ${C_GRAY}1. Conecta el cable USB${C_NC}"
    echo -e "   ${C_GRAY}2. Activa Opciones de desarrollador en el teléfono${C_NC}"
    echo -e "   ${C_GRAY}3. Activa 'Depuración USB'${C_NC}"
    echo -e "   ${C_GRAY}4. Acepta el diálogo de autorización en el teléfono${C_NC}"
else
    nxlog_ok "Total detectados: $TOTAL_DEVS"
    echo ""
    for i in "${!DEV_IDS[@]}"; do
        local android brand serial battery
        android=$(adb -s "${DEV_IDS[$i]}" shell getprop ro.build.version.release 2>/dev/null | tr -d '\r')
        brand=$(adb -s "${DEV_IDS[$i]}"   shell getprop ro.product.vendor.brand   2>/dev/null | tr -d '\r')
        serial=$(adb -s "${DEV_IDS[$i]}"  shell getprop ro.serialno               2>/dev/null | tr -d '\r')
        printf "  ${C_CYAN}${C_BOLD}%2d.${C_NC}  ${C_WHITE}${C_BOLD}%-28s${C_NC}\n" "$((i+1))" "${DEV_MODELS[$i]}"
        printf "       ${C_GRAY}ID: %-22s  Android: %-6s  Marca: %-12s${C_NC}\n" \
            "${DEV_IDS[$i]}" "${android:-?}" "${brand:-?}"
        printf "       ${C_GRAY}Serie: %-20s  Estado: %s${C_NC}\n" \
            "${serial:-N/A}" "${DEV_STATUS[$i]}"
        echo ""
    done
fi
nx_pause
