#!/usr/bin/env bash
# =============================================================================
#  NEXORA-TOOLKIT v1.0
#  by krypthane | github.com/wavegxz-design
#  Uso exclusivo en dispositivos propios o con autorización escrita.
# =============================================================================

export TOOLKIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export VERSION="1.0"
source "$TOOLKIT_ROOT/lib/core.sh"

# ─── Verificaciones al inicio ─────────────────────────────────────────────────
_startup_checks() {
    # Root no requerido para la mayoría de funciones
    if [[ $(id -u) -ne 0 ]]; then
        nxlog_warn "Sin root — funciones avanzadas pueden requerir permisos adicionales."
    fi

    # ADB instalado
    if ! command -v adb &>/dev/null; then
        nxlog_error "ADB no instalado. Ejecuta: sudo bash install.sh -i"
        exit 1
    fi

    # .temp dir
    mkdir -p "$TOOLKIT_ROOT/.temp" 2>/dev/null
}

# ─── Check de versión (background) ────────────────────────────────────────────
_check_version() {
    if ping -q -c 1 -W 2 github.com &>/dev/null 2>&1; then
        local remote
        remote=$(curl -sf --max-time 5 \
            "https://raw.githubusercontent.com/wavegxz-design/NEXORA-TOOLKIT/main/version" \
            2>/dev/null || echo "")
        if [[ -n "$remote" && "$remote" != "$VERSION" ]]; then
            echo -e "  ${C_YELLOW}${C_BOLD}[↑] Nueva versión disponible: v$remote${C_NC}"
            echo -e "  ${C_GRAY}    git pull origin main${C_NC}\n"
        fi
    fi
}

# ─── Banner principal ─────────────────────────────────────────────────────────
_banner() {
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
    echo -e "  ${C_CYAN}${C_BOLD}NEXORA-TOOLKIT${C_NC} ${C_GRAY}v${VERSION}${C_NC}  │  ${C_BLUE}${C_BOLD}github.com/wavegxz-design${C_NC}"
    echo -e "  ${C_GRAY}Solo en dispositivos propios o con autorización escrita.${C_NC}"
    echo ""
}

# ─── Menú principal ───────────────────────────────────────────────────────────
_show_menu() {
    _banner
    _check_version &

    # ── Estado de dispositivos ──
    nx_detect_devices
    if [[ $TOTAL_DEVS -eq 0 ]]; then
        echo -e "  ${C_RED}${C_BOLD}[!] Sin dispositivos conectados${C_NC}  ${C_GRAY}│  Conecta un dispositivo y activa USB Debugging${C_NC}"
    else
        echo -e "  ${C_GREEN}${C_BOLD}[✔] $TOTAL_DEVS dispositivo(s) detectado(s):${C_NC}"
        for i in "${!DEV_IDS[@]}"; do
            printf "      ${C_CYAN}%d.${C_NC} ${C_WHITE}%-25s${C_NC} ${C_GRAY}%s${C_NC}\n" \
                "$((i+1))" "${DEV_MODELS[$i]}" "${DEV_IDS[$i]}"
        done
    fi
    echo ""

    # ── Sección 1: Dispositivo ──
    echo -e "  ${C_PURPLE}${C_BOLD}┌─[ 1. DISPOSITIVO ]─────────────────────────────────┐${C_NC}"
    printf "  ${C_YELLOW}${C_BOLD}  %-4s${C_NC}%-30s  ${C_YELLOW}${C_BOLD}%-4s${C_NC}%s\n" \
        "11." "Listar dispositivos"          "12." "Detalles del dispositivo"
    printf "  ${C_YELLOW}${C_BOLD}  %-4s${C_NC}%-30s  ${C_YELLOW}${C_BOLD}%-4s${C_NC}%s\n" \
        "13." "Reiniciar sistema"            "14." "Reiniciar a Recovery"
    printf "  ${C_YELLOW}${C_BOLD}  %-4s${C_NC}%-30s  ${C_YELLOW}${C_BOLD}%-4s${C_NC}%s\n" \
        "15." "Reiniciar a Fastboot"         "16." "Shell interactivo"
    printf "  ${C_YELLOW}${C_BOLD}  %-4s${C_NC}%-30s  ${C_YELLOW}${C_BOLD}%-4s${C_NC}%s\n" \
        "17." "Verificar root"               "18." "Servidor ADB (reiniciar)"

    # ── Sección 2: Diagnóstico ──
    echo -e "\n  ${C_PURPLE}${C_BOLD}├─[ 2. DIAGNÓSTICO E INFORMACIÓN ]───────────────────┤${C_NC}"
    printf "  ${C_YELLOW}${C_BOLD}  %-4s${C_NC}%-30s  ${C_YELLOW}${C_BOLD}%-4s${C_NC}%s\n" \
        "21." "Dump sistema"                 "22." "Dump CPU"
    printf "  ${C_YELLOW}${C_BOLD}  %-4s${C_NC}%-30s  ${C_YELLOW}${C_BOLD}%-4s${C_NC}%s\n" \
        "23." "Dump memoria"                 "24." "Bug report completo"
    printf "  ${C_YELLOW}${C_BOLD}  %-4s${C_NC}%-30s  ${C_YELLOW}${C_BOLD}%-4s${C_NC}%s\n" \
        "25." "Logcat en vivo"               "26." "Batería en vivo"
    printf "  ${C_YELLOW}${C_BOLD}  %-4s${C_NC}%s\n" \
        "27." "Procesos activos"

    # ── Sección 3: Apps ──
    echo -e "\n  ${C_PURPLE}${C_BOLD}├─[ 3. APLICACIONES ]────────────────────────────────┤${C_NC}"
    printf "  ${C_YELLOW}${C_BOLD}  %-4s${C_NC}%-30s  ${C_YELLOW}${C_BOLD}%-4s${C_NC}%s\n" \
        "31." "Instalar APK"                 "32." "Desinstalar app"
    printf "  ${C_YELLOW}${C_BOLD}  %-4s${C_NC}%-30s  ${C_YELLOW}${C_BOLD}%-4s${C_NC}%s\n" \
        "33." "Listar apps instaladas"       "34." "Lanzar app"
    printf "  ${C_YELLOW}${C_BOLD}  %-4s${C_NC}%s\n" \
        "35." "Gestión de permisos"

    # ── Sección 4: Extracción ──
    echo -e "\n  ${C_PURPLE}${C_BOLD}├─[ 4. EXTRACCIÓN DE DATOS ]─────────────────────────┤${C_NC}"
    printf "  ${C_YELLOW}${C_BOLD}  %-4s${C_NC}%-30s  ${C_YELLOW}${C_BOLD}%-4s${C_NC}%s\n" \
        "41." "Fotos y videos (DCIM)"        "42." "Descargas"
    printf "  ${C_YELLOW}${C_BOLD}  %-4s${C_NC}%-30s  ${C_YELLOW}${C_BOLD}%-4s${C_NC}%s\n" \
        "43." "Redes sociales/mensajería"    "44." "Almacenamiento completo"
    printf "  ${C_YELLOW}${C_BOLD}  %-4s${C_NC}%-30s  ${C_YELLOW}${C_BOLD}%-4s${C_NC}%s\n" \
        "45." "Archivo/carpeta específico"   "46." "Enviar archivo al dispositivo"

    # ── Sección 5: Red ──
    echo -e "\n  ${C_PURPLE}${C_BOLD}├─[ 5. RED Y CONECTIVIDAD ]──────────────────────────┤${C_NC}"
    printf "  ${C_YELLOW}${C_BOLD}  %-4s${C_NC}%-30s  ${C_YELLOW}${C_BOLD}%-4s${C_NC}%s\n" \
        "51." "Conexión WiFi ADB"            "52." "Persistencia WiFi"
    printf "  ${C_YELLOW}${C_BOLD}  %-4s${C_NC}%-30s  ${C_YELLOW}${C_BOLD}%-4s${C_NC}%s\n" \
        "53." "Info red completa"            "54." "Port forwarding"

    # ── Sección 6: Multimedia ──
    echo -e "\n  ${C_PURPLE}${C_BOLD}├─[ 6. MULTIMEDIA ]──────────────────────────────────┤${C_NC}"
    printf "  ${C_YELLOW}${C_BOLD}  %-4s${C_NC}%-30s  ${C_YELLOW}${C_BOLD}%-4s${C_NC}%s\n" \
        "61." "Captura de pantalla"          "62." "Grabar pantalla"

    # ── Sección 7: Backup ──
    echo -e "\n  ${C_PURPLE}${C_BOLD}├─[ 7. BACKUP Y SISTEMA ]────────────────────────────┤${C_NC}"
    printf "  ${C_YELLOW}${C_BOLD}  %-4s${C_NC}%-30s  ${C_YELLOW}${C_BOLD}%-4s${C_NC}%s\n" \
        "71." "Backup ADB completo"          "72." "Restaurar backup"
    printf "  ${C_YELLOW}${C_BOLD}  %-4s${C_NC}%-30s  ${C_YELLOW}${C_BOLD}%-4s${C_NC}%s\n" \
        "73." "Enviar SMS"                   "74." "Captura tráfico (tcpdump)"

    # ── Sección 8: Extra ──
    echo -e "\n  ${C_PURPLE}${C_BOLD}└─[ 8. EXTRA ]───────────────────────────────────────┘${C_NC}"
    printf "  ${C_YELLOW}${C_BOLD}  %-4s${C_NC}%-30s  ${C_YELLOW}${C_BOLD}%-4s${C_NC}%s\n" \
        "81." "Metasploit"                   "0."  "Acerca de / Ayuda"
    echo -e "\n  ${C_RED}${C_BOLD}  q   ${C_NC}${C_GRAY}Salir${C_NC}"
    echo ""

    echo -ne "  ${C_WHITE}${C_BOLD}Opción › ${C_NC}"
    read -r OPT
    echo ""
    _dispatch "$OPT"
}

# ─── Dispatcher limpio ────────────────────────────────────────────────────────
_dispatch() {
    local opt="${1,,}"
    local mod="$TOOLKIT_ROOT/modules"

    # Verificar que el módulo existe antes de ejecutarlo
    _run_module() {
        local file="$1"
        if [[ -f "$file" ]]; then
            bash "$file"
        else
            nxlog_error "Módulo no encontrado: $file"
            nxlog_info  "Ejecuta: bash generate_modules.sh"
        fi
    }

    case "$opt" in
        # ── Sección 1: Dispositivo ──
        11) _run_module "$mod/d_list.sh"       ;;
        12) _run_module "$mod/d_details.sh"    ;;
        13) _run_module "$mod/d_reboot.sh"     ;;
        14) _run_module "$mod/d_recovery.sh"   ;;
        15) _run_module "$mod/d_fastboot.sh"   ;;
        16) _run_module "$mod/d_shell.sh"      ;;
        17) _run_module "$mod/d_root.sh"       ;;
        18) _run_module "$mod/d_adbserver.sh"  ;;

        # ── Sección 2: Diagnóstico ──
        21) _run_module "$mod/i_sysinfo.sh"    ;;
        22) _run_module "$mod/i_cpu.sh"        ;;
        23) _run_module "$mod/i_memory.sh"     ;;
        24) _run_module "$mod/i_bugreport.sh"  ;;
        25) _run_module "$mod/i_logcat.sh"     ;;
        26) _run_module "$mod/i_battery.sh"    ;;
        27) _run_module "$mod/i_processes.sh"  ;;

        # ── Sección 3: Apps ──
        31) _run_module "$mod/a_install.sh"    ;;
        32) _run_module "$mod/a_uninstall.sh"  ;;
        33) _run_module "$mod/a_list.sh"       ;;
        34) _run_module "$mod/a_launch.sh"     ;;
        35) _run_module "$mod/a_perms.sh"      ;;

        # ── Sección 4: Extracción ──
        41) _run_module "$mod/e_dcim.sh"       ;;
        42) _run_module "$mod/e_downloads.sh"  ;;
        43) _run_module "$mod/e_social.sh"     ;;
        44) _run_module "$mod/e_full.sh"       ;;
        45) _run_module "$mod/e_custom.sh"     ;;
        46) _run_module "$mod/e_push.sh"       ;;

        # ── Sección 5: Red ──
        51) _run_module "$mod/n_wifi.sh"       ;;
        52) _run_module "$mod/n_persist.sh"    ;;
        53) _run_module "$mod/n_info.sh"       ;;
        54) _run_module "$mod/n_forward.sh"    ;;

        # ── Sección 6: Multimedia ──
        61) _run_module "$mod/m_screenshot.sh" ;;
        62) _run_module "$mod/m_record.sh"     ;;

        # ── Sección 7: Backup ──
        71) _run_module "$mod/b_backup.sh"     ;;
        72) _run_module "$mod/b_restore.sh"    ;;
        73) _run_module "$mod/b_sms.sh"        ;;
        74) _run_module "$mod/b_tcpdump.sh"    ;;

        # ── Extra ──
        81) _run_module "$mod/x_metasploit.sh" ;;
        0)  _run_module "$mod/x_about.sh"      ;;

        q|quit|exit) _clean_exit ;;
        "")          _show_menu  ;;
        *)
            nxlog_warn "Opción no válida: '$opt'"
            sleep 1
            ;;
    esac

    _show_menu
}

# ─── Salida limpia ────────────────────────────────────────────────────────────
_clean_exit() {
    rm -rf "$TOOLKIT_ROOT/.temp/"* 2>/dev/null
    clear
    echo -e "\n  ${C_GREEN}${C_BOLD}NEXORA-TOOLKIT cerrado.${C_NC}"
    echo -e "  ${C_GRAY}Log guardado en: $LOG_FILE${C_NC}\n"
    exit 0
}
trap _clean_exit INT TERM

# ─── Arranque ─────────────────────────────────────────────────────────────────
_startup_checks
_show_menu
