#!/usr/bin/env bash
# =============================================================================
#  NEXORA-TOOLKIT — generate_modules.sh
#  Genera todos los módulos del toolkit
#  by krypthane | github.com/wavegxz-design
# =============================================================================

export TOOLKIT_ROOT="${TOOLKIT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
MDIR="$TOOLKIT_ROOT/modules"
mkdir -p "$MDIR"

echo "[*] Generando módulos en $MDIR..."

# ─── Cabecera estándar para cada módulo ───────────────────────────────────────
_mhead() {
    echo "#!/usr/bin/env bash"
    echo "# NEXORA-TOOLKIT — $1"
    echo "source \"\$TOOLKIT_ROOT/lib/core.sh\""
    echo ""
}

# =============================================================================
# SECCIÓN 1 — DISPOSITIVO
# =============================================================================

# d_list.sh — Listar dispositivos
cat > "$MDIR/d_list.sh" << 'EOF'
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
EOF

# d_details.sh — Detalles del dispositivo
cat > "$MDIR/d_details.sh" << 'EOF'
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
EOF

# d_reboot.sh — Reiniciar sistema
cat > "$MDIR/d_reboot.sh" << 'EOF'
#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Reiniciar dispositivo"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
nx_confirm "¿Reiniciar $SELECTED_MODEL?" && {
    nxlog_action "Reiniciando $SELECTED_MODEL..."
    nx_adb reboot
    nxlog_ok "Comando de reinicio enviado."
}
nx_pause
EOF

# d_recovery.sh — Recovery
cat > "$MDIR/d_recovery.sh" << 'EOF'
#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Reiniciar a Recovery"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
nx_confirm "¿Reiniciar $SELECTED_MODEL a Recovery?" && {
    nx_adb reboot recovery
    nxlog_ok "Reiniciando a Recovery..."
}
nx_pause
EOF

# d_fastboot.sh — Fastboot
cat > "$MDIR/d_fastboot.sh" << 'EOF'
#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Reiniciar a Fastboot/Bootloader"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
nx_confirm "¿Reiniciar $SELECTED_MODEL a Fastboot?" && {
    nx_adb reboot bootloader
    nxlog_ok "Reiniciando a Fastboot..."
}
nx_pause
EOF

# d_shell.sh — Shell interactivo
cat > "$MDIR/d_shell.sh" << 'EOF'
#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Shell interactivo ADB"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
nxlog_ok "Abriendo shell en $SELECTED_MODEL. Escribe 'exit' para salir."
echo ""
nx_adb shell
echo ""
nxlog_ok "Shell cerrado."
nx_pause
EOF

# d_root.sh — Verificar root
cat > "$MDIR/d_root.sh" << 'EOF'
#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Verificar root"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
nxlog_action "Verificando root en $SELECTED_MODEL..."
echo ""
local su_path magisk selinux uid
su_path=$(adb -s "$SELECTED_DEV" shell which su 2>/dev/null | tr -d '\r')
magisk=$(adb -s "$SELECTED_DEV"  shell pm list packages 2>/dev/null | grep -i "magisk")
selinux=$(adb -s "$SELECTED_DEV" shell getenforce 2>/dev/null | tr -d '\r')
uid=$(adb -s "$SELECTED_DEV"     shell id 2>/dev/null | tr -d '\r')

if [[ -n "$su_path" ]]; then
    echo -e "  ${C_GREEN}${C_BOLD}[✔] ROOTEADO${C_NC}  —  su en: $su_path"
else
    echo -e "  ${C_RED}${C_BOLD}[✗] NO ROOTEADO${C_NC}  —  su no encontrado"
fi
[[ -n "$magisk" ]] && echo -e "  ${C_GREEN}${C_BOLD}[✔] Magisk detectado${C_NC}"
echo -e "  ${C_BLUE}[i]${C_NC} ${C_GRAY}SELinux: ${selinux:-desconocido}${C_NC}"
echo -e "  ${C_BLUE}[i]${C_NC} ${C_GRAY}UID: ${uid:-N/A}${C_NC}"
nx_pause
EOF

# d_adbserver.sh — Reiniciar servidor ADB
cat > "$MDIR/d_adbserver.sh" << 'EOF'
#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Reiniciar servidor ADB"
nxlog_action "Deteniendo servidor ADB..."
adb kill-server 2>/dev/null
sleep 1
nxlog_action "Iniciando servidor ADB..."
adb start-server 2>/dev/null
nxlog_ok "Servidor ADB reiniciado."
nx_pause
EOF

# =============================================================================
# SECCIÓN 2 — DIAGNÓSTICO
# =============================================================================

# i_sysinfo.sh — Dump sistema
cat > "$MDIR/i_sysinfo.sh" << 'EOF'
#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Dump información del sistema"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
local out="$TOOLKIT_ROOT/logs/${SELECTED_MODEL//[^a-zA-Z0-9]/_}-sysinfo-$(date '+%Y%m%d_%H%M%S').log"
nxlog_action "Dumpeando info del sistema en $SELECTED_MODEL..."
nx_adb shell dumpsys > "$out" 2>/dev/null &
nx_spinner $! "Recopilando información del sistema"
nxlog_ok "Guardado: $out"
less -R "$out"
nx_pause
EOF

# i_cpu.sh
cat > "$MDIR/i_cpu.sh" << 'EOF'
#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Información de CPU"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
nx_adb shell cat /proc/cpuinfo 2>/dev/null | less -R
nx_pause
EOF

# i_memory.sh
cat > "$MDIR/i_memory.sh" << 'EOF'
#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Información de memoria"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
echo -e "\n  ${C_CYAN}${C_BOLD}/proc/meminfo${C_NC}\n"
nx_adb shell cat /proc/meminfo 2>/dev/null | while IFS= read -r line; do
    echo -e "  ${C_GRAY}$line${C_NC}"
done
nx_pause
EOF

# i_bugreport.sh
cat > "$MDIR/i_bugreport.sh" << 'EOF'
#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Bug Report completo"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
local out="$TOOLKIT_ROOT/bug-report/${SELECTED_MODEL//[^a-zA-Z0-9]/_}-$(date '+%Y%m%d_%H%M%S').zip"
nxlog_warn "Puede tardar varios minutos. El dispositivo puede mostrar un diálogo de confirmación."
nxlog_action "Generando bug report..."
adb -s "$SELECTED_DEV" bugreport "$out" &
nx_spinner $! "Generando bug report"
local size; size=$(du -sh "$out" 2>/dev/null | cut -f1)
[[ -f "$out" ]] && nxlog_ok "Bug report guardado: $out [$size]" \
                || nxlog_error "Error generando bug report."
nx_pause
EOF

# i_logcat.sh
cat > "$MDIR/i_logcat.sh" << 'EOF'
#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Logcat en vivo"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }

echo -e "  ${C_YELLOW}${C_BOLD}Nivel de log:${C_NC}\n"
echo -e "  ${C_CYAN}1.${C_NC} Verbose (todo)"
echo -e "  ${C_CYAN}2.${C_NC} Debug"
echo -e "  ${C_CYAN}3.${C_NC} Info"
echo -e "  ${C_CYAN}4.${C_NC} Warning"
echo -e "  ${C_CYAN}5.${C_NC} Error únicamente"
echo -ne "\n  ${C_WHITE}Opción [1-5]: ${C_NC}"
read -r lvl

case "$lvl" in
    1) tag="V" ;; 2) tag="D" ;; 3) tag="I" ;;
    4) tag="W" ;; 5) tag="E" ;; *) tag="V" ;;
esac

local out="$TOOLKIT_ROOT/logs/${SELECTED_MODEL//[^a-zA-Z0-9]/_}-logcat-$(date '+%Y%m%d_%H%M%S').log"
nxlog_ok "Logcat nivel [$tag] en $SELECTED_MODEL — Ctrl+C para detener"
nxlog_info "Guardando en: $out"
nx_adb logcat "*:$tag" 2>/dev/null | tee "$out"
nx_pause
EOF

# i_battery.sh
cat > "$MDIR/i_battery.sh" << 'EOF'
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
EOF

# i_processes.sh
cat > "$MDIR/i_processes.sh" << 'EOF'
#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Procesos activos"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
nxlog_action "Listando procesos en $SELECTED_MODEL..."
nx_adb shell ps -A 2>/dev/null | less -R
nx_pause
EOF

# =============================================================================
# SECCIÓN 3 — APLICACIONES
# =============================================================================

# a_install.sh — Instalar APK
cat > "$MDIR/a_install.sh" << 'EOF'
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
EOF

# a_uninstall.sh
cat > "$MDIR/a_uninstall.sh" << 'EOF'
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
EOF

# a_list.sh
cat > "$MDIR/a_list.sh" << 'EOF'
#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Listar aplicaciones"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }

echo -e "  ${C_YELLOW}${C_BOLD}Filtro:${C_NC}\n"
echo -e "  ${C_CYAN}1.${C_NC} Todas"
echo -e "  ${C_CYAN}2.${C_NC} Solo de terceros"
echo -e "  ${C_CYAN}3.${C_NC} Solo del sistema"
echo -e "  ${C_CYAN}4.${C_NC} Solo habilitadas"
echo -e "  ${C_CYAN}5.${C_NC} Solo deshabilitadas"
echo -ne "\n  ${C_WHITE}Opción [1-5]: ${C_NC}"
read -r flt

case "$flt" in
    1) flag=""   ; label="todas"          ;;
    2) flag="-3" ; label="terceros"       ;;
    3) flag="-s" ; label="sistema"        ;;
    4) flag="-e" ; label="habilitadas"    ;;
    5) flag="-d" ; label="deshabilitadas" ;;
    *) flag=""   ; label="todas"          ;;
esac

local out="$TOOLKIT_ROOT/logs/${SELECTED_MODEL//[^a-zA-Z0-9]/_}-apps-${label}-$(date '+%Y%m%d_%H%M%S').txt"
nxlog_action "Listando apps ($label)..."
adb -s "$SELECTED_DEV" shell pm list packages $flag 2>/dev/null \
    | sed 's/^package://' | sort | tee "$out" | less -R
nxlog_ok "$(wc -l < "$out") apps — guardadas en: $out"
nx_pause
EOF

# a_launch.sh
cat > "$MDIR/a_launch.sh" << 'EOF'
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
EOF

# a_perms.sh
cat > "$MDIR/a_perms.sh" << 'EOF'
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
EOF

# =============================================================================
# SECCIÓN 4 — EXTRACCIÓN DE DATOS
# =============================================================================

# e_dcim.sh
cat > "$MDIR/e_dcim.sh" << 'EOF'
#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Copiar fotos y videos (DCIM)"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
local dest; dest=$(nx_make_dir "DCIM")
nxlog_action "Copiando DCIM de $SELECTED_MODEL → $dest"
nx_adb pull /sdcard/DCIM/ "$dest/" 2>&1 | tail -5
nxlog_ok "Completado → $dest"
nx_pause
EOF

# e_downloads.sh
cat > "$MDIR/e_downloads.sh" << 'EOF'
#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Copiar descargas"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
local dest; dest=$(nx_make_dir "Downloads")
nxlog_action "Copiando Downloads → $dest"
nx_adb pull /sdcard/Download/ "$dest/" 2>&1 | tail -5
nx_adb pull /sdcard/Downloads/ "$dest/" 2>&1 | tail -5
nxlog_ok "Completado → $dest"
nx_pause
EOF

# e_social.sh — Redes sociales y mensajería (MEJORADO)
cat > "$MDIR/e_social.sh" << 'EOF'
#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Extracción: redes sociales y mensajería"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }

# Mapa: Nombre | Package | Rutas posibles (separadas por ,)
declare -A APP_NAMES=(
    [1]="WhatsApp"
    [2]="WhatsApp Business"
    [3]="Telegram"
    [4]="Signal"
    [5]="Instagram"
    [6]="Facebook"
    [7]="TikTok"
    [8]="Snapchat"
    [9]="LINE"
    [10]="Viber"
    [11]="Discord"
    [12]="Twitter/X"
    [13]="Messenger"
)
declare -A APP_PKGS=(
    [1]="com.whatsapp"
    [2]="com.whatsapp.w4b"
    [3]="org.telegram.messenger"
    [4]="org.thoughtcrime.securesms"
    [5]="com.instagram.android"
    [6]="com.facebook.katana"
    [7]="com.zhiliaoapp.musically"
    [8]="com.snapchat.android"
    [9]="jp.naver.line.android"
    [10]="com.viber.voip"
    [11]="com.discord"
    [12]="com.twitter.android"
    [13]="com.facebook.orca"
)
declare -A APP_PATHS=(
    [1]="/sdcard/Android/media/com.whatsapp,/sdcard/WhatsApp"
    [2]="/sdcard/Android/media/com.whatsapp.w4b,/sdcard/WhatsApp Business"
    [3]="/sdcard/Telegram"
    [4]="/sdcard/Signal"
    [5]="/sdcard/Pictures/Instagram,/sdcard/Movies/Instagram"
    [6]="/sdcard/DCIM/Facebook,/sdcard/Pictures/Facebook"
    [7]="/sdcard/DCIM/TikTok,/sdcard/Movies/TikTok"
    [8]="/sdcard/Snapchat,/sdcard/Pictures/Snapchat"
    [9]="/sdcard/LINE,/sdcard/Pictures/LINE"
    [10]="/sdcard/viber/media,/sdcard/Pictures/Viber"
    [11]="/sdcard/Pictures/Discord"
    [12]="/sdcard/Pictures/Twitter,/sdcard/Pictures/X"
    [13]="/sdcard/Pictures/Messenger"
)

echo -e "\n  ${C_YELLOW}${C_BOLD}Apps disponibles:${C_NC}\n"
printf "  ${C_CYAN}${C_BOLD}%-4s  %-25s  %s${C_NC}\n" "Nº" "App" "Estado"
nx_separator
for key in $(seq 1 13); do
    local inst_str color
    if nx_app_installed "${APP_PKGS[$key]}"; then
        inst_str="[instalada]"
        color="$C_GREEN"
    else
        inst_str="[no instalada]"
        color="$C_GRAY"
    fi
    printf "  ${C_CYAN}%-4s${C_NC}  ${C_WHITE}%-25s${C_NC}  ${color}%s${C_NC}\n" \
        "$key." "${APP_NAMES[$key]}" "$inst_str"
done
echo -e "  ${C_CYAN}0.${C_NC}  ${C_WHITE}Todas las instaladas${C_NC}"
nx_separator

echo -ne "\n  ${C_WHITE}Opción: ${C_NC}"
read -r sel

_pull_app() {
    local key="$1"
    local name="${APP_NAMES[$key]}"
    local pkg="${APP_PKGS[$key]}"
    local paths="${APP_PATHS[$key]}"
    local dest; dest=$(nx_make_dir "${name//[^a-zA-Z0-9]/_}")
    nxlog_action "Extrayendo $name..."
    local pulled=0
    IFS=',' read -ra path_list <<< "$paths"
    for p in "${path_list[@]}"; do
        p=$(echo "$p" | xargs)
        local res
        res=$(adb -s "$SELECTED_DEV" pull "$p/" "$dest/" 2>&1)
        if ! echo "$res" | grep -qi "error\|does not exist\|no such file"; then
            (( pulled++ ))
        fi
    done
    [[ $pulled -gt 0 ]] && nxlog_ok "$name → $dest" || nxlog_warn "$name: sin archivos encontrados"
}

if [[ "$sel" == "0" ]]; then
    for key in $(seq 1 13); do
        nx_app_installed "${APP_PKGS[$key]}" && _pull_app "$key"
    done
elif [[ "$sel" =~ ^[1-9]$|^1[0-3]$ ]]; then
    _pull_app "$sel"
else
    nxlog_warn "Opción no válida."
fi
nx_pause
EOF

# e_full.sh
cat > "$MDIR/e_full.sh" << 'EOF'
#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Copiar almacenamiento completo"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
nxlog_warn "Esta operación puede tardar mucho tiempo según el almacenamiento del dispositivo."
nx_confirm "¿Continuar copia completa de $SELECTED_MODEL?" || { nx_pause; exit; }
local dest; dest=$(nx_make_dir "FullStorage")
nxlog_action "Copiando /sdcard → $dest"
nx_adb pull /sdcard/ "$dest/" 2>&1 | tail -10
nxlog_ok "Completado → $dest"
nx_pause
EOF

# e_custom.sh
cat > "$MDIR/e_custom.sh" << 'EOF'
#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Copiar archivo/carpeta específico"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
echo -ne "\n  ${C_WHITE}Ruta en el dispositivo (ej: /sdcard/Documents/): ${C_NC}"
read -r remote_path
[[ -z "$remote_path" ]] && { nxlog_error "Ruta vacía."; nx_pause; exit; }
local dest; dest=$(nx_make_dir "custom")
nxlog_action "Copiando $remote_path → $dest"
nx_adb pull "$remote_path" "$dest/" 2>&1 \
    && nxlog_ok "Completado → $dest" \
    || nxlog_error "Error en la copia. Verifica que la ruta existe."
nx_pause
EOF

# e_push.sh
cat > "$MDIR/e_push.sh" << 'EOF'
#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Enviar archivo al dispositivo"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
echo -ne "\n  ${C_WHITE}Archivo local (ruta completa o arrastra): ${C_NC}"
read -r local_file
local_file=$(echo "$local_file" | sed "s/^['\"]//;s/['\"]$//;s/\\ / /g" | xargs)
[[ ! -f "$local_file" ]] && { nxlog_error "Archivo no encontrado: $local_file"; nx_pause; exit; }
echo -ne "  ${C_WHITE}Destino en dispositivo (Enter = /sdcard/): ${C_NC}"
read -r remote_dest
[[ -z "$remote_dest" ]] && remote_dest="/sdcard/"
nxlog_action "Enviando $(basename "$local_file") → $SELECTED_MODEL:$remote_dest"
nx_adb push "$local_file" "$remote_dest" \
    && nxlog_ok "Archivo enviado correctamente." \
    || nxlog_error "Error enviando archivo."
nx_pause
EOF

# =============================================================================
# SECCIÓN 5 — RED Y CONECTIVIDAD
# =============================================================================

# n_wifi.sh — Conexión WiFi ADB
cat > "$MDIR/n_wifi.sh" << 'EOF'
#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Conexión ADB por WiFi"
nx_select_device "Selecciona dispositivo base (USB)" || { nx_pause; exit; }

nxlog_action "Obteniendo IP de $SELECTED_MODEL..."
local ip; ip=$(nx_get_device_ip)

if [[ -z "$ip" ]]; then
    nxlog_error "Sin IP WiFi. ¿Está el dispositivo conectado a WiFi?"
    nx_pause; exit
fi
nxlog_ok "IP detectada: $ip"

nxlog_action "Habilitando ADB TCP/IP en puerto 5555..."
adb -s "$SELECTED_DEV" tcpip 5555 &>/dev/null
sleep 2

nxlog_action "Conectando a $ip:5555..."
local result; result=$(adb connect "$ip:5555" 2>&1)
echo -e "  ${C_GRAY}$result${C_NC}"

if echo "$result" | grep -qi "connected"; then
    nxlog_ok "Conexión WiFi establecida: $SELECTED_MODEL @ $ip:5555"
    nxlog_info "Puedes desconectar el cable USB."
    echo -e "\n  ${C_YELLOW}Para reconectar sin USB:${C_NC}"
    echo -e "  ${C_GRAY}adb connect $ip:5555${C_NC}"
    # Guardar para reconexión rápida
    echo "ip=$ip" > "$TOOLKIT_ROOT/.temp/last_wifi.conf"
    echo "model=$SELECTED_MODEL" >> "$TOOLKIT_ROOT/.temp/last_wifi.conf"
    echo "port=5555" >> "$TOOLKIT_ROOT/.temp/last_wifi.conf"
else
    nxlog_error "Conexión fallida. Verifica que ambos dispositivos estén en la misma red."
fi
nx_pause
EOF

# n_persist.sh — Persistencia WiFi
cat > "$MDIR/n_persist.sh" << 'EOF'
#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Persistencia conexión ADB WiFi"
echo -e "  ${C_GRAY}Mantiene la conexión ADB WiFi disponible entre reinicios${C_NC}\n"

echo -e "  ${C_YELLOW}${C_BOLD}Opciones:${C_NC}\n"
echo -e "  ${C_CYAN}1.${C_NC} Activar persistencia (dispositivo conectado por USB)"
echo -e "  ${C_CYAN}2.${C_NC} Reconectar al último dispositivo WiFi guardado"
echo -e "  ${C_CYAN}3.${C_NC} Ver estado actual"
echo -e "  ${C_CYAN}4.${C_NC} Desactivar persistencia"
echo -ne "\n  ${C_WHITE}Opción [1-4]: ${C_NC}"
read -r popt

case "$popt" in
    1)
        nx_select_device "Selecciona dispositivo (USB)" || { nx_pause; exit; }
        local ip; ip=$(nx_get_device_ip)
        [[ -z "$ip" ]] && { nxlog_error "Sin IP WiFi."; nx_pause; exit; }
        # Habilitar TCP/IP en modo persistente
        nx_adb tcpip 5555 &>/dev/null
        # Intentar configurar prop persistente (requiere root en algunos dispositivos)
        nx_adb shell setprop persist.adb.tcp.port 5555 2>/dev/null || true
        sleep 2
        adb connect "$ip:5555" &>/dev/null
        # Guardar configuración
        {
            echo "ip=$ip"
            echo "model=$SELECTED_MODEL"
            echo "port=5555"
            echo "timestamp=$(date '+%F %T')"
        } > "$TOOLKIT_ROOT/.temp/last_wifi.conf"
        nxlog_ok "Persistencia activada — $SELECTED_MODEL @ $ip:5555"
        nxlog_info "Config guardada en .temp/last_wifi.conf"
        ;;
    2)
        local cfg="$TOOLKIT_ROOT/.temp/last_wifi.conf"
        if [[ ! -f "$cfg" ]]; then
            nxlog_error "Sin configuración guardada. Activa la persistencia primero."
        else
            source "$cfg"
            nxlog_action "Reconectando a $model ($ip:${port:-5555})..."
            local res; res=$(adb connect "$ip:${port:-5555}" 2>&1)
            echo -e "  ${C_GRAY}$res${C_NC}"
            echo "$res" | grep -qi "connected" \
                && nxlog_ok "Reconexión exitosa a $model" \
                || nxlog_error "Falló. Verifica que el dispositivo esté en la misma red."
        fi
        ;;
    3)
        nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
        local port_active
        port_active=$(adb -s "$SELECTED_DEV" shell getprop persist.adb.tcp.port 2>/dev/null | tr -d '\r')
        local ip; ip=$(nx_get_device_ip)
        echo ""
        [[ -n "$port_active" && "$port_active" != "0" && "$port_active" != "" ]] \
            && echo -e "  ${C_GREEN}[✔] Persistencia activa${C_NC}  —  Puerto: $port_active  IP: ${ip:-N/A}" \
            || echo -e "  ${C_YELLOW}[!] Persistencia no configurada${C_NC}"
        ;;
    4)
        nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
        nx_adb shell setprop persist.adb.tcp.port "" 2>/dev/null || true
        rm -f "$TOOLKIT_ROOT/.temp/last_wifi.conf"
        nxlog_ok "Persistencia desactivada."
        ;;
esac
nx_pause
EOF

# n_info.sh
cat > "$MDIR/n_info.sh" << 'EOF'
#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Info de red completa"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
{
    echo "=== INTERFACES DE RED ==="
    adb -s "$SELECTED_DEV" shell ip addr show 2>/dev/null
    echo -e "\n=== RUTAS DE RED ==="
    adb -s "$SELECTED_DEV" shell ip route show 2>/dev/null
    echo -e "\n=== CONEXIONES ACTIVAS ==="
    adb -s "$SELECTED_DEV" shell ss -tnp 2>/dev/null || \
    adb -s "$SELECTED_DEV" shell netstat -tnp 2>/dev/null || \
    echo "(ss/netstat no disponible)"
    echo -e "\n=== DNS ==="
    adb -s "$SELECTED_DEV" shell getprop 2>/dev/null | grep -i dns
    echo -e "\n=== INFO WiFi ==="
    adb -s "$SELECTED_DEV" shell dumpsys wifi 2>/dev/null | grep -E "mWifiInfo|SSID|BSSID|IP|freq" | head -10
} | less -R
nx_pause
EOF

# n_forward.sh
cat > "$MDIR/n_forward.sh" << 'EOF'
#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Port Forwarding ADB"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }

echo -e "  ${C_YELLOW}${C_BOLD}Opciones:${C_NC}\n"
echo -e "  ${C_CYAN}1.${C_NC} Forward: local → dispositivo"
echo -e "  ${C_CYAN}2.${C_NC} Reverse: dispositivo → local"
echo -e "  ${C_CYAN}3.${C_NC} Listar forwards activos"
echo -e "  ${C_CYAN}4.${C_NC} Eliminar todos los forwards"
echo -ne "\n  ${C_WHITE}Opción [1-4]: ${C_NC}"
read -r fopt

_validate_port() {
    [[ "$1" =~ ^[0-9]+$ ]] && (( $1 >= 1 && $1 <= 65535 ))
}

case "$fopt" in
    1)
        echo -ne "  ${C_WHITE}Puerto local: ${C_NC}"; read -r lport
        echo -ne "  ${C_WHITE}Puerto en dispositivo: ${C_NC}"; read -r rport
        _validate_port "$lport" && _validate_port "$rport" || { nxlog_error "Puerto inválido."; nx_pause; exit; }
        nx_adb forward "tcp:$lport" "tcp:$rport" \
            && nxlog_ok "Forward: localhost:$lport → $SELECTED_MODEL:$rport" \
            || nxlog_error "Error creando forward."
        ;;
    2)
        echo -ne "  ${C_WHITE}Puerto en dispositivo: ${C_NC}"; read -r rport
        echo -ne "  ${C_WHITE}Puerto local: ${C_NC}"; read -r lport
        _validate_port "$rport" && _validate_port "$lport" || { nxlog_error "Puerto inválido."; nx_pause; exit; }
        nx_adb reverse "tcp:$rport" "tcp:$lport" \
            && nxlog_ok "Reverse: $SELECTED_MODEL:$rport → localhost:$lport" \
            || nxlog_error "Error creando reverse."
        ;;
    3)
        nxlog_info "Forwards activos:"
        nx_adb forward --list
        ;;
    4)
        nx_adb forward --remove-all && nxlog_ok "Todos los forwards eliminados."
        ;;
esac
nx_pause
EOF

# =============================================================================
# SECCIÓN 6 — MULTIMEDIA
# =============================================================================

# m_screenshot.sh
cat > "$MDIR/m_screenshot.sh" << 'EOF'
#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Captura de pantalla"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }
local ts; ts=$(date '+%Y%m%d_%H%M%S')
local remote="/sdcard/.nexora_ss_${ts}.png"
local dest="$TOOLKIT_ROOT/screenshots/${SELECTED_MODEL//[^a-zA-Z0-9]/_}_${ts}.png"
nxlog_action "Capturando pantalla de $SELECTED_MODEL..."
nx_adb shell screencap -p "$remote" 2>/dev/null && {
    nx_adb pull "$remote" "$dest" 2>/dev/null && {
        nx_adb shell rm -f "$remote" 2>/dev/null
        nxlog_ok "Screenshot → $dest"
    } || nxlog_error "Error descargando screenshot."
} || nxlog_error "Error capturando pantalla."
nx_pause
EOF

# m_record.sh
cat > "$MDIR/m_record.sh" << 'EOF'
#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Grabar pantalla"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }

echo -ne "\n  ${C_WHITE}Duración en segundos [30-180, Enter=30]: ${C_NC}"
read -r secs
secs="${secs:-30}"
[[ ! "$secs" =~ ^[0-9]+$ ]] && secs=30
(( secs < 1 ))   && secs=30
(( secs > 180 )) && secs=180

local ts; ts=$(date '+%Y%m%d_%H%M%S')
local remote="/sdcard/.nexora_rec_${ts}.mp4"
local dest="$TOOLKIT_ROOT/screenrecords/${SELECTED_MODEL//[^a-zA-Z0-9]/_}_${ts}.mp4"

nxlog_action "Grabando por ${secs}s en $SELECTED_MODEL..."
nx_adb shell screenrecord --time-limit "$secs" "$remote" &
local rpid=$!
nx_spinner $rpid "Grabando pantalla (${secs}s)"
wait $rpid 2>/dev/null

nxlog_action "Descargando grabación..."
nx_adb pull "$remote" "$dest" 2>/dev/null && {
    nx_adb shell rm -f "$remote" 2>/dev/null
    nxlog_ok "Grabación → $dest"
} || nxlog_error "Error descargando grabación."
nx_pause
EOF

# =============================================================================
# SECCIÓN 7 — BACKUP Y SISTEMA
# =============================================================================

# b_backup.sh
cat > "$MDIR/b_backup.sh" << 'EOF'
#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Backup ADB completo"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }

echo -e "  ${C_YELLOW}${C_BOLD}Opciones de backup:${C_NC}\n"
echo -e "  ${C_CYAN}1.${C_NC} Completo (apps + datos + almacenamiento)"
echo -e "  ${C_CYAN}2.${C_NC} Solo apps y datos"
echo -e "  ${C_CYAN}3.${C_NC} Solo almacenamiento externo"
echo -ne "\n  ${C_WHITE}Opción [1-3]: ${C_NC}"
read -r bopt

case "$bopt" in
    1) flags="-apk -shared -all" ;;
    2) flags="-apk -all"         ;;
    3) flags="-shared -noapk"    ;;
    *) flags="-apk -shared -all" ;;
esac

local out="$BACKUP_DIR/${SELECTED_MODEL//[^a-zA-Z0-9]/_}-$(date '+%Y%m%d_%H%M%S').ab"
nxlog_warn "El dispositivo mostrará una pantalla de confirmación — acepta el backup."
nxlog_action "Iniciando backup → $out"
adb -s "$SELECTED_DEV" backup $flags -f "$out" &
nx_spinner $! "Generando backup"
wait $! 2>/dev/null
local size; size=$(du -sh "$out" 2>/dev/null | cut -f1)
[[ -s "$out" ]] \
    && nxlog_ok "Backup completado: $out [$size]" \
    || nxlog_error "Backup falló o el archivo está vacío."
nx_pause
EOF

# b_restore.sh
cat > "$MDIR/b_restore.sh" << 'EOF'
#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Restaurar backup ADB"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }

mapfile -t backups < <(find "$BACKUP_DIR" -name "*.ab" -type f 2>/dev/null | sort)
if [[ ${#backups[@]} -eq 0 ]]; then
    nxlog_error "Sin backups en $BACKUP_DIR"
    nx_pause; exit
fi

echo -e "\n  ${C_YELLOW}${C_BOLD}Backups disponibles:${C_NC}\n"
for i in "${!backups[@]}"; do
    local size; size=$(du -sh "${backups[$i]}" 2>/dev/null | cut -f1)
    local ts; ts=$(stat -c '%y' "${backups[$i]}" 2>/dev/null | cut -d'.' -f1)
    printf "  ${C_CYAN}%2d.${C_NC}  ${C_WHITE}%-45s${C_NC}  ${C_GRAY}%s  [%s]${C_NC}\n" \
        "$((i+1))" "$(basename "${backups[$i]}")" "$ts" "$size"
done
echo -ne "\n  ${C_WHITE}Selecciona backup [1-${#backups[@]}]: ${C_NC}"
read -r sel

if [[ "$sel" =~ ^[0-9]+$ ]] && (( sel >= 1 && sel <= ${#backups[@]} )); then
    local bk="${backups[$((sel-1))]}"
    nx_confirm "¿Restaurar $(basename "$bk") en $SELECTED_MODEL?" && {
        nxlog_warn "El dispositivo pedirá confirmación."
        adb -s "$SELECTED_DEV" restore "$bk" \
            && nxlog_ok "Restauración completada." \
            || nxlog_error "Error en la restauración."
    }
else
    nxlog_warn "Opción inválida."
fi
nx_pause
EOF

# b_sms.sh
cat > "$MDIR/b_sms.sh" << 'EOF'
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
EOF

# b_tcpdump.sh
cat > "$MDIR/b_tcpdump.sh" << 'EOF'
#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Captura de tráfico (tcpdump)"
nx_select_device "Selecciona dispositivo" || { nx_pause; exit; }

# Verificar tcpdump en dispositivo
local has_tcp
has_tcp=$(adb -s "$SELECTED_DEV" shell which tcpdump 2>/dev/null | tr -d '\r')
if [[ -z "$has_tcp" ]]; then
    nxlog_error "tcpdump no encontrado en el dispositivo."
    nxlog_info  "Requiere tcpdump instalado en el dispositivo."
    nxlog_info  "Alternativa: usa Wireshark con ADB reverse + netcat en el PC."
    nx_pause; exit
fi

echo -ne "\n  ${C_WHITE}Duración en segundos [30]: ${C_NC}"
read -r secs
secs="${secs:-30}"
[[ ! "$secs" =~ ^[0-9]+$ ]] && secs=30

local ts; ts=$(date '+%Y%m%d_%H%M%S')
local remote="/sdcard/.nexora_cap_${ts}.pcap"
local dest="$TOOLKIT_ROOT/logs/${SELECTED_MODEL//[^a-zA-Z0-9]/_}-capture_${ts}.pcap"

nxlog_action "Capturando tráfico por ${secs}s..."
nx_adb shell "tcpdump -i any -w $remote &" &>/dev/null
sleep "$secs"
nx_adb shell "pkill tcpdump" &>/dev/null
sleep 1
nx_adb pull "$remote" "$dest" 2>/dev/null && {
    nx_adb shell rm -f "$remote" &>/dev/null
    nxlog_ok "Captura → $dest"
    command -v wireshark &>/dev/null && nxlog_info "Abrir con: wireshark $dest"
} || nxlog_error "Error descargando captura."
nx_pause
EOF

# =============================================================================
# SECCIÓN 8 — EXTRA
# =============================================================================

# x_metasploit.sh
cat > "$MDIR/x_metasploit.sh" << 'EOF'
#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
nx_header "Sección Metasploit"
if ! command -v msfconsole &>/dev/null; then
    nxlog_error "Metasploit no instalado."
    echo -e "\n  ${C_YELLOW}Instalar:${C_NC}"
    echo -e "  ${C_GRAY}curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall${C_NC}"
    echo -e "  ${C_GRAY}bash msfinstall${C_NC}"
else
    nxlog_action "Iniciando msfconsole..."
    msfconsole
fi
nx_pause
EOF

# x_about.sh
cat > "$MDIR/x_about.sh" << 'EOF'
#!/usr/bin/env bash
source "$TOOLKIT_ROOT/lib/core.sh"
clear
echo -e "${C_PURPLE}${C_BOLD}"
cat << 'BANNER'
  ███╗   ██╗███████╗██╗  ██╗ ██████╗ ██████╗  █████╗
  ████╗  ██║██╔════╝╚██╗██╔╝██╔═══██╗██╔══██╗██╔══██╗
  ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║██████╔╝███████║
  ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║██╔══██╗██╔══██║
  ██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝██║  ██║██║  ██║
  ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝
BANNER
echo -e "${C_NC}"
echo -e "  ${C_CYAN}${C_BOLD}NEXORA-TOOLKIT${C_NC} ${C_GRAY}v1.0${C_NC}"
echo -e "  ${C_BLUE}${C_BOLD}github.com/wavegxz-design${C_NC}\n"
nx_separator
echo -e "  ${C_YELLOW}${C_BOLD}Arquitectura:${C_NC}"
echo -e "  ${C_GRAY}  lib/core.sh        —  Librería central compartida${C_NC}"
echo -e "  ${C_GRAY}  modules/*.sh       —  Módulos independientes por función${C_NC}"
echo -e "  ${C_GRAY}  logs/nexora.log    —  Log completo de operaciones${C_NC}"
echo ""
echo -e "  ${C_YELLOW}${C_BOLD}Funciones principales:${C_NC}"
echo -e "  ${C_GRAY}  Detección ilimitada de dispositivos${C_NC}"
echo -e "  ${C_GRAY}  Extracción: WhatsApp, WA Business, Telegram, Signal, +8 más${C_NC}"
echo -e "  ${C_GRAY}  Conexión WiFi con persistencia entre reinicios${C_NC}"
echo -e "  ${C_GRAY}  Backup/Restore completo (adb backup)${C_NC}"
echo -e "  ${C_GRAY}  Gestión de permisos de apps${C_NC}"
echo -e "  ${C_GRAY}  Port forwarding y reverse tunneling${C_NC}"
echo -e "  ${C_GRAY}  Monitoreo de batería en tiempo real${C_NC}"
echo ""
nx_separator
echo -e "  ${C_RED}${C_BOLD}Nota legal:${C_NC}"
echo -e "  ${C_GRAY}  Solo usar en dispositivos propios o con autorización escrita.${C_NC}"
echo -e "  ${C_GRAY}  El uso no autorizado puede violar leyes locales e internacionales.${C_NC}"
nx_pause
EOF

# ─── Permisos ─────────────────────────────────────────────────────────────────
chmod +x "$MDIR"/*.sh
local count; count=$(ls "$MDIR"/*.sh 2>/dev/null | wc -l)
echo "[✔] $count módulos generados en $MDIR"
