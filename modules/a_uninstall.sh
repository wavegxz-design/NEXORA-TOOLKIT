#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Desinstalar aplicación"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }

nxlog_action "Cargando apps de terceros..."
mapfile -t apps < <(adb -s "$SELECTED_DEV" shell pm list packages -3 2>/dev/null \
    | sed 's/^package://' | sort)

if [[ ${#apps[@]} -eq 0 ]]; then
    nxlog_error "No se encontraron apps de terceros."
    nx_pause; exit
fi

echo -e "\n  ${C_YELLOW}${C_BOLD}Apps de terceros (${#apps[@]}):${C_NC}\n"
local page=0 per_page=20
while true; do
    local start=$((page * per_page))
    local end=$((start + per_page))
    [[ $end -gt ${#apps[@]} ]] && end=${#apps[@]}
    for ((i=start; i<end; i++)); do
        printf "  ${C_CYAN}%3d.${C_NC}  ${C_WHITE}%s${C_NC}\n" "$((i+1))" "${apps[$i]}"
    done
    echo ""
    [[ $end -lt ${#apps[@]} ]] && echo -e "  ${C_GRAY}[n] Siguiente página  [b] Anterior${C_NC}"
    echo -ne "  ${C_WHITE}Número de app o package exacto (0=cancelar): ${C_NC}"
    read -r sel
    case "$sel" in
        n) (( page++ )); clear; nx_header "Desinstalar aplicación" ;;
        b) (( page > 0 )) && (( page-- )); clear; nx_header "Desinstalar aplicación" ;;
        0) nx_pause; exit ;;
        *)
            local pkg
            if [[ "$sel" =~ ^[0-9]+$ ]] && (( sel >= 1 && sel <= ${#apps[@]} )); then
                pkg="${apps[$((sel-1))]}"
            else
                pkg="$sel"
            fi
            nx_confirm "¿Desinstalar $pkg de $SELECTED_MODEL?" && {
                local res; res=$(adb -s "$SELECTED_DEV" uninstall "$pkg" 2>&1)
                echo "$res" | grep -qi "success" \
                    && nxlog_ok "$pkg desinstalado." \
                    || nxlog_error "Error: $res"
            }
            break ;;
    esac
done
nx_pause
