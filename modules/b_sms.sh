#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Enviar SMS desde el dispositivo"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }

echo -ne "\n  ${C_WHITE}Número destino (con código de país, ej: +521234567890): ${C_NC}"
read -r phone
phone=$(echo "$phone" | tr -d ' ')
[[ -z "$phone" ]] && { nxlog_error "Número vacío."; nx_pause; exit; }
[[ ! "$phone" =~ ^\+?[0-9]{7,15}$ ]] && nxlog_warn "Formato de número inusual: $phone"

echo -ne "  ${C_WHITE}Mensaje: ${C_NC}"
read -r body
[[ -z "$body" ]] && { nxlog_error "Mensaje vacío."; nx_pause; exit; }

nxlog_action "Enviando SMS a $phone desde $SELECTED_MODEL..."
nx_adb shell am start \
    -a android.intent.action.SENDTO \
    -d "sms:${phone}" \
    --es sms_body "$body" \
    --ez exit_on_sent true &>/dev/null
sleep 1
nx_adb shell input keyevent 22 &>/dev/null
nx_adb shell input keyevent 66 &>/dev/null
nxlog_ok "SMS enviado a $phone."
nx_pause
