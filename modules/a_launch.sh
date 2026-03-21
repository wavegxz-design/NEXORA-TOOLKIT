#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Lanzar aplicación"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
echo -ne "\n  ${C_WHITE}Package de la app (ej: com.whatsapp): ${C_NC}"
read -r pkg
[[ -z "$pkg" ]] && { nxlog_error "Package vacío."; nx_pause; exit; }

local activity
activity=$(adb -s "$SELECTED_DEV" shell cmd package resolve-activity --brief "$pkg" 2>/dev/null \
    | tail -1 | tr -d '\r')
if [[ -n "$activity" && "$activity" != *"No activity"* ]]; then
    nxlog_action "Lanzando $activity..."
    nx_adb shell am start -n "$activity" 2>/dev/null \
        && nxlog_ok "$pkg lanzado." \
        || nxlog_error "Error al lanzar $pkg."
else
    nxlog_action "Intentando con monkey..."
    nx_adb shell monkey -p "$pkg" -c android.intent.category.LAUNCHER 1 &>/dev/null \
        && nxlog_ok "$pkg lanzado." \
        || nxlog_error "No se pudo lanzar $pkg."
fi
nx_pause
