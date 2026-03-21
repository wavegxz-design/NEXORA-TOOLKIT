#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Información de CPU"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
nx_adb shell cat /proc/cpuinfo 2>/dev/null | less -R
nx_pause
