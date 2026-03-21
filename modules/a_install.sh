#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Instalar APK"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }

echo -ne "\n  ${C_WHITE}Ruta del APK (arrastra o escribe): ${C_NC}"
read -r apk_path
# Limpiar comillas y espacios si viene arrastrado
apk_path=$(echo "$apk_path" | sed "s/^['\"]//;s/['\"]$//;s/\\ / /g" | xargs)

if [[ ! -f "$apk_path" ]]; then
    nxlog_error "Archivo no encontrado: $apk_path"
    nx_pause; exit
fi

local ext="${apk_path##*.}"
if [[ "$ext" != "apk" && "$ext" != "APK" ]]; then
    nxlog_warn "El archivo no tiene extensión .apk"
    nx_confirm "¿Continuar de todas formas?" || { nx_pause; exit; }
fi

local size; size=$(du -sh "$apk_path" 2>/dev/null | cut -f1)
nxlog_info "APK: $(basename "$apk_path") [$size]"

echo -e "\n  ${C_YELLOW}${C_BOLD}Opciones de instalación:${C_NC}\n"
echo -e "  ${C_CYAN}1.${C_NC} Estándar"
echo -e "  ${C_CYAN}2.${C_NC} Reinstalar (conservar datos)"
echo -e "  ${C_CYAN}3.${C_NC} Permitir APKs de prueba (-t)"
echo -e "  ${C_CYAN}4.${C_NC} Almacenamiento externo"
echo -ne "\n  ${C_WHITE}Opción [1-4]: ${C_NC}"
read -r iopt

case "$iopt" in
    2) flags="-r"  ;;
    3) flags="-t"  ;;
    4) flags="-s"  ;;
    *) flags=""    ;;
esac

nxlog_action "Instalando $(basename "$apk_path") en $SELECTED_MODEL..."
local result
result=$(adb -s "$SELECTED_DEV" install $flags "$apk_path" 2>&1)
echo -e "\n  ${C_GRAY}$result${C_NC}"

if echo "$result" | grep -qi "success"; then
    nxlog_ok "APK instalado correctamente."
else
    nxlog_error "Instalación falló."
    nxlog_info  "Código de error: $(echo "$result" | grep -i 'failure\|error' | head -1)"
fi
nx_pause
