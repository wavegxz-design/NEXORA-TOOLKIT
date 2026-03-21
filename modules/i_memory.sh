#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Información de memoria"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
echo -e "\n  ${C_CYAN}${C_BOLD}/proc/meminfo${C_NC}\n"
nx_adb shell cat /proc/meminfo 2>/dev/null | while IFS= read -r line; do
    echo -e "  ${C_GRAY}$line${C_NC}"
done
nx_pause
