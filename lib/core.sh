#!/usr/bin/env bash
# =============================================================================
#  NEXORA-TOOLKIT — lib/core.sh
#  Librería central compartida por todos los módulos
#  by krypthane | github.com/wavegxz-design
# =============================================================================

# ─── Paleta de colores profesional ───────────────────────────────────────────
export C_RED='\e[38;5;196m'
export C_GREEN='\e[38;5;82m'
export C_YELLOW='\e[38;5;220m'
export C_BLUE='\e[38;5;39m'
export C_CYAN='\e[38;5;51m'
export C_PURPLE='\e[38;5;135m'
export C_ORANGE='\e[38;5;208m'
export C_WHITE='\e[38;5;255m'
export C_GRAY='\e[38;5;245m'
export C_BOLD='\e[1m'
export C_DIM='\e[2m'
export C_NC='\e[0m'

# ─── Directorios base (exportados para todos los módulos) ─────────────────────
export TOOLKIT_ROOT="${TOOLKIT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export LOG_FILE="$TOOLKIT_ROOT/logs/nexora.log"
export PULL_DIR="$TOOLKIT_ROOT/device-pull"
export BACKUP_DIR="$TOOLKIT_ROOT/backups"

# Crear directorios si no existen
mkdir -p "$TOOLKIT_ROOT/logs" \
         "$PULL_DIR" "$BACKUP_DIR" \
         "$TOOLKIT_ROOT/screenshots" \
         "$TOOLKIT_ROOT/screenrecords" \
         "$TOOLKIT_ROOT/bug-report" \
         "$TOOLKIT_ROOT/.temp" 2>/dev/null

# ─── Logger con timestamp ─────────────────────────────────────────────────────
_log_write() { echo "[$(date '+%F %T')] [$1] $2" >> "$LOG_FILE" 2>/dev/null; }

nxlog_ok()     { echo -e " ${C_GREEN}${C_BOLD}[✔]${C_NC} ${C_WHITE}$*${C_NC}"; _log_write "OK"     "$*"; }
nxlog_warn()   { echo -e " ${C_YELLOW}${C_BOLD}[!]${C_NC} ${C_YELLOW}$*${C_NC}"; _log_write "WARN"   "$*"; }
nxlog_error()  { echo -e " ${C_RED}${C_BOLD}[✗]${C_NC} ${C_RED}$*${C_NC}";    _log_write "ERROR"  "$*"; }
nxlog_action() { echo -e " ${C_CYAN}${C_BOLD}[>]${C_NC} ${C_CYAN}$*${C_NC}";  _log_write "ACTION" "$*"; }
nxlog_info()   { echo -e " ${C_BLUE}${C_BOLD}[i]${C_NC} ${C_GRAY}$*${C_NC}";  _log_write "INFO"   "$*"; }

# ─── Separadores visuales ─────────────────────────────────────────────────────
nx_separator() {
    local label="${1:-}"
    local width=56
    if [[ -n "$label" ]]; then
        local pad=$(( (width - ${#label} - 2) / 2 ))
        local line; printf -v line '%*s' "$pad" ''; line="${line// /─}"
        echo -e "\n ${C_PURPLE}${C_BOLD}${line} ${label} ${line}${C_NC}\n"
    else
        echo -e " ${C_GRAY}$(printf '%.0s─' {1..58})${C_NC}"
    fi
}

nx_header() {
    echo -e "\n ${C_CYAN}${C_BOLD}╔══════════════════════════════════════════════════════╗${C_NC}"
    printf  "  ${C_CYAN}${C_BOLD}║${C_NC}  %-52s${C_CYAN}${C_BOLD}║${C_NC}\n" "$1"
    echo -e " ${C_CYAN}${C_BOLD}╚══════════════════════════════════════════════════════╝${C_NC}\n"
}

# ─── Detección de dispositivos (sin límite, robusta) ─────────────────────────
declare -ga DEV_IDS=()
declare -ga DEV_MODELS=()
declare -ga DEV_STATUS=()
export TOTAL_DEVS=0
export SELECTED_DEV=""
export SELECTED_MODEL=""

nx_detect_devices() {
    DEV_IDS=(); DEV_MODELS=(); DEV_STATUS=(); TOTAL_DEVS=0

    # Verificar que ADB responde
    if ! adb devices &>/dev/null; then
        nxlog_error "ADB no responde. Verifica la instalación."
        return 1
    fi

    local line id state
    while IFS=$'\t' read -r id state; do
        # Limpiar espacios y saltos
        id=$(echo "$id" | tr -d '\r\n ' | xargs 2>/dev/null)
        state=$(echo "$state" | tr -d '\r\n' | xargs 2>/dev/null)
        [[ -z "$id" || "$id" == "List" || "$id" == "*" ]] && continue
        [[ "$state" != "device" && "$state" != "unauthorized" && "$state" != "offline" ]] && continue

        local model="unknown"
        if [[ "$state" == "device" ]]; then
            model=$(adb -s "$id" shell getprop ro.product.model 2>/dev/null \
                    | tr -d '\r\n' | xargs 2>/dev/null)
            [[ -z "$model" ]] && model="device-$TOTAL_DEVS"
        fi

        DEV_IDS+=("$id")
        DEV_MODELS+=("$model")
        DEV_STATUS+=("$state")
        (( TOTAL_DEVS++ ))
    done < <(adb devices 2>/dev/null | tail -n +2 | grep -v '^$')

    return 0
}

nx_select_device() {
    local prompt="${1:-Selecciona un dispositivo}"
    nx_detect_devices || return 1

    if [[ $TOTAL_DEVS -eq 0 ]]; then
        nxlog_error "Ningún dispositivo ADB detectado."
        echo ""
        echo -e "  ${C_YELLOW}Verifica:${C_NC}"
        echo -e "   ${C_GRAY}1. Cable USB conectado${C_NC}"
        echo -e "   ${C_GRAY}2. USB Debugging activado (Opciones desarrollador)${C_NC}"
        echo -e "   ${C_GRAY}3. Confirmar en el dispositivo si aparece el diálogo${C_NC}"
        echo -e "   ${C_GRAY}4. Ejecutar: adb devices${C_NC}"
        return 1
    fi

    if [[ $TOTAL_DEVS -eq 1 ]]; then
        SELECTED_DEV="${DEV_IDS[0]}"
        SELECTED_MODEL="${DEV_MODELS[0]}"
        nxlog_ok "Dispositivo: ${C_GREEN}${C_BOLD}$SELECTED_MODEL${C_NC} ${C_GRAY}[$SELECTED_DEV]${C_NC}"
        if [[ "${DEV_STATUS[0]}" == "unauthorized" ]]; then
            nxlog_warn "Dispositivo no autorizado — acepta el diálogo en el teléfono."
            return 1
        fi
        return 0
    fi

    echo -e "\n ${C_YELLOW}${C_BOLD}$prompt${C_NC}\n"
    nx_separator
    for i in "${!DEV_IDS[@]}"; do
        local color="$C_GREEN"
        local status_str="${DEV_STATUS[$i]}"
        [[ "$status_str" == "unauthorized" ]] && color="$C_YELLOW" && status_str="no autorizado"
        [[ "$status_str" == "offline" ]]       && color="$C_RED"    && status_str="offline"
        printf "  ${C_CYAN}${C_BOLD}%2d.${C_NC}  ${color}${C_BOLD}%-28s${C_NC}  ${C_GRAY}%-20s  [%s]${C_NC}\n" \
            "$((i+1))" "${DEV_MODELS[$i]}" "${DEV_IDS[$i]}" "$status_str"
    done
    nx_separator

    local choice
    while true; do
        echo -ne "\n ${C_WHITE}${C_BOLD}Selecciona [1-$TOTAL_DEVS]: ${C_NC}"
        read -r choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= TOTAL_DEVS )); then
            SELECTED_DEV="${DEV_IDS[$((choice-1))]}"
            SELECTED_MODEL="${DEV_MODELS[$((choice-1))]}"
            if [[ "${DEV_STATUS[$((choice-1))]}" == "unauthorized" ]]; then
                nxlog_warn "Acepta el diálogo en $SELECTED_MODEL y vuelve a intentar."
                return 1
            fi
            nxlog_ok "Seleccionado: ${C_GREEN}${C_BOLD}$SELECTED_MODEL${C_NC}"
            return 0
        fi
        nxlog_warn "Ingresa un número del 1 al $TOTAL_DEVS"
    done
}

# ─── Wrapper ADB con validación y logging ─────────────────────────────────────
nx_adb() {
    if [[ -z "$SELECTED_DEV" ]]; then
        nxlog_error "Ningún dispositivo seleccionado."
        return 1
    fi
    nxlog_action "adb -s $SELECTED_DEV $*"
    adb -s "$SELECTED_DEV" "$@"
    local rc=$?
    [[ $rc -ne 0 ]] && nxlog_warn "Retornó código $rc"
    return $rc
}

# ─── Crear directorio de destino para pull ────────────────────────────────────
nx_make_dir() {
    local label="${1:-data}"
    local safe_model="${SELECTED_MODEL//[^a-zA-Z0-9_-]/_}"
    local dest="$PULL_DIR/${safe_model}/${label}_$(date '+%Y%m%d_%H%M%S')"
    mkdir -p "$dest" && echo "$dest"
}

# ─── Confirmación interactiva Y/N ─────────────────────────────────────────────
nx_confirm() {
    local question="$1"
    local answer
    while true; do
        echo -ne "\n ${C_YELLOW}${C_BOLD}$question ${C_GRAY}(Y/N): ${C_NC}"
        read -r answer
        case "${answer,,}" in
            y|yes|s|si) return 0 ;;
            n|no)        return 1 ;;
            *) nxlog_warn "Responde Y (sí) o N (no)" ;;
        esac
    done
}

# ─── Verificar comando disponible ─────────────────────────────────────────────
nx_require() {
    local cmd="$1"
    if ! command -v "$cmd" &>/dev/null; then
        nxlog_error "Comando requerido no encontrado: $cmd"
        return 1
    fi
    return 0
}

# ─── Barra de progreso simple ─────────────────────────────────────────────────
nx_spinner() {
    local pid=$1 msg="${2:-Procesando}"
    local spin=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local i=0
    tput civis 2>/dev/null  # ocultar cursor
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r ${C_CYAN}${C_BOLD}%s${C_NC}  ${C_GRAY}%s${C_NC}  " "${spin[$i]}" "$msg"
        (( i = (i + 1) % ${#spin[@]} ))
        sleep 0.1
    done
    tput cnorm 2>/dev/null  # mostrar cursor
    printf "\r%80s\r" ""   # limpiar línea
}

# ─── Pausa y volver ───────────────────────────────────────────────────────────
nx_pause() {
    echo -e "\n ${C_GRAY}Presiona ${C_WHITE}Enter${C_GRAY} para continuar...${C_NC}"
    read -r
}

# ─── Verificar si app está instalada en el dispositivo ───────────────────────
nx_app_installed() {
    local pkg="$1"
    adb -s "$SELECTED_DEV" shell pm list packages 2>/dev/null \
        | grep -q "^package:${pkg}$"
}

# ─── Obtener IP del dispositivo ───────────────────────────────────────────────
nx_get_device_ip() {
    local ip
    ip=$(adb -s "$SELECTED_DEV" shell ip addr show wlan0 2>/dev/null \
         | grep "inet " | awk '{print $2}' | cut -d'/' -f1 | head -1 | tr -d '\r')
    echo "$ip"
}
