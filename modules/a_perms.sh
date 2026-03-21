#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Gestión de permisos"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
echo -ne "\n  ${C_WHITE}Package de la app: ${C_NC}"
read -r pkg
[[ -z "$pkg" ]] && { nxlog_error "Package vacío."; nx_pause; exit; }

echo -e "\n  ${C_YELLOW}${C_BOLD}Permisos de $pkg:${C_NC}\n"
adb -s "$SELECTED_DEV" shell dumpsys package "$pkg" 2>/dev/null \
    | grep -E "permission|granted" | head -40 | while IFS= read -r line; do
        if echo "$line" | grep -q "granted=true"; then
            echo -e "  ${C_GREEN}[✔]${C_NC} ${C_GRAY}$line${C_NC}"
        elif echo "$line" | grep -q "granted=false"; then
            echo -e "  ${C_RED}[✗]${C_NC} ${C_GRAY}$line${C_NC}"
        else
            echo -e "  ${C_GRAY}$line${C_NC}"
        fi
    done

echo -e "\n  ${C_YELLOW}${C_BOLD}Acciones:${C_NC}"
echo -e "  ${C_CYAN}1.${C_NC} Conceder permiso"
echo -e "  ${C_CYAN}2.${C_NC} Revocar permiso"
echo -e "  ${C_CYAN}3.${C_NC} Solo ver (ya hecho)"
echo -ne "\n  ${C_WHITE}Opción [1-3]: ${C_NC}"
read -r popt

case "$popt" in
    1)
        echo -ne "  ${C_WHITE}Permiso a conceder (ej: android.permission.CAMERA): ${C_NC}"
        read -r perm
        nx_adb shell pm grant "$pkg" "$perm" 2>/dev/null \
            && nxlog_ok "Permiso concedido: $perm" \
            || nxlog_error "Error. Verifica que la app soporte este permiso."
        ;;
    2)
        echo -ne "  ${C_WHITE}Permiso a revocar: ${C_NC}"
        read -r perm
        nx_adb shell pm revoke "$pkg" "$perm" 2>/dev/null \
            && nxlog_ok "Permiso revocado: $perm" \
            || nxlog_error "Error revocando permiso."
        ;;
esac
nx_pause
