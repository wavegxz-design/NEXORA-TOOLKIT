#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Batería en vivo"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
nxlog_info "Monitoreando batería — Ctrl+C para detener"
echo ""
while true; do
    local raw level temp status voltage health
    raw=$(adb -s "$SELECTED_DEV" shell dumpsys battery 2>/dev/null)
    level=$(echo   "$raw" | grep "level:"       | awk '{print $2}' | tr -d '\r')
    temp=$(echo    "$raw" | grep "temperature:" | awk '{print $2}' | tr -d '\r')
    status=$(echo  "$raw" | grep "status:"      | awk '{print $2}' | tr -d '\r')
    voltage=$(echo "$raw" | grep "voltage:"     | awk '{print $2}' | tr -d '\r')
    health=$(echo  "$raw" | grep "health:"      | awk '{print $2}' | tr -d '\r')
    local st_str st_color
    case "$status" in
        2) st_str="Cargando"     ; st_color="$C_GREEN"  ;;
        3) st_str="Descargando"  ; st_color="$C_YELLOW" ;;
        5) st_str="Carga completa"; st_color="$C_GREEN" ;;
        *) st_str="Desconocido"  ; st_color="$C_GRAY"   ;;
    esac
    local temp_c; temp_c=$(echo "scale=1; ${temp:-0}/10" | bc 2>/dev/null)
    # Barra visual de nivel
    local bar_len=20
    local filled=$(( ${level:-0} * bar_len / 100 ))
    local bar=""
    for ((j=0; j<filled; j++));   do bar+="█"; done
    for ((j=filled; j<bar_len; j++)); do bar+="░"; done
    printf "\r  ${C_WHITE}${C_BOLD}[%s]${C_NC} ${C_YELLOW}%3s%%${C_NC}  ${st_color}%-15s${C_NC}  ${C_GRAY}Temp: %s°C  Voltaje: %smV  Salud: %s${C_NC}    " \
        "$bar" "$level" "$st_str" "$temp_c" "$voltage" "$health"
    sleep 3
done
nx_pause
