#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Detalles del dispositivo"
nx_select_device "Selecciona dispositivo para ver detalles" || { nx_pause; exit; }
echo ""

declare -A PROPS=(
    ["Modelo"]="ro.product.model"
    ["Marca"]="ro.product.vendor.brand"
    ["Device"]="ro.product.vendor.device"
    ["Chipset"]="ro.product.board"
    ["Arquitectura"]="ro.product.cpu.abi"
    ["Android"]="ro.build.version.release"
    ["SDK"]="ro.build.version.sdk"
    ["Parche de seguridad"]="ro.build.version.security_patch"
    ["Fecha de build"]="ro.build.date"
    ["Cifrado"]="ro.crypto.state"
    ["Bootloader"]="ro.boot.bootloader"
    ["Número de serie"]="ro.serialno"
    ["Operador SIM"]="gsm.sim.operator.alpha"
    ["Interfaz WiFi"]="wifi.interface"
)

printf "  ${C_CYAN}${C_BOLD}%-26s  %s${C_NC}\n" "PROPIEDAD" "VALOR"
nx_separator
for label in $(echo "${!PROPS[@]}" | tr ' ' '\n' | sort); do
    val=$(adb -s "$SELECTED_DEV" shell getprop "${PROPS[$label]}" 2>/dev/null | tr -d '\r')
    printf "  ${C_YELLOW}%-26s${C_NC}  ${C_WHITE}%s${C_NC}\n" "$label" "${val:-N/A}"
done

echo ""
if nx_confirm "¿Exportar todos los props a archivo?"; then
    local out="$TOOLKIT_ROOT/logs/${SELECTED_MODEL//[^a-zA-Z0-9]/_}-allprops-$(date '+%Y%m%d_%H%M%S').log"
    adb -s "$SELECTED_DEV" shell getprop > "$out" 2>/dev/null
    nxlog_ok "Exportado: $out"
fi
nx_pause
