#!/usr/bin/env bash
# =============================================================================
#  NEXORA-TOOLKIT — install.sh
#  Instalador multi-distro: Kali, Ubuntu/Debian, Arch, Fedora
#  by krypthane | github.com/wavegxz-design
# =============================================================================

set -uo pipefail

# ─── Colores básicos (sin depender de core.sh aún) ────────────────────────────
R='\e[38;5;196m'; G='\e[38;5;82m'; Y='\e[38;5;220m'
C='\e[38;5;51m';  B='\e[38;5;39m'; W='\e[38;5;255m'
DIM='\e[2m'; BOLD='\e[1m'; NC='\e[0m'

ok()    { echo -e " ${G}${BOLD}[✔]${NC} $*"; }
warn()  { echo -e " ${Y}${BOLD}[!]${NC} $*"; }
err()   { echo -e " ${R}${BOLD}[✗]${NC} $*"; }
info()  { echo -e " ${B}${BOLD}[i]${NC} ${DIM}$*${NC}"; }
step()  { echo -e "\n ${C}${BOLD}[>]${NC} $*"; }

TOOLKIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FAILED=()

# ─── Ayuda ────────────────────────────────────────────────────────────────────
_help() {
    echo -e "\n${BOLD}  NEXORA-TOOLKIT Installer${NC}\n"
    echo -e "  ${Y}sudo bash install.sh${NC} ${W}-i${NC}    —  Instalación completa"
    echo -e "  ${Y}sudo bash install.sh${NC} ${W}-u${NC}    —  Actualizar módulos"
    echo -e "  ${Y}sudo bash install.sh${NC} ${W}-c${NC}    —  Verificar dependencias"
    echo -e "  ${Y}sudo bash install.sh${NC} ${W}-r${NC}    —  Reparar permisos"
    echo ""
}

# ─── Detectar distro ──────────────────────────────────────────────────────────
_detect_distro() {
    local id_like id
    id_like=$(awk '/^ID_LIKE=/' /etc/*-release 2>/dev/null \
              | head -1 | awk -F'=' '{print tolower($2)}' | tr -d '"')
    id=$(awk '/^ID=/' /etc/*-release 2>/dev/null \
         | head -1 | awk -F'=' '{print tolower($2)}' | tr -d '"')
    echo "${id_like:-$id}"
}

# ─── Instaladores por distro ──────────────────────────────────────────────────
_install_debian() {
    step "Instalando en Debian/Ubuntu/Kali/Mint..."
    apt-get update -qq 2>/dev/null
    local pkgs=(adb fastboot curl wget git bc)
    for pkg in "${pkgs[@]}"; do
        if ! dpkg -s "$pkg" &>/dev/null 2>&1; then
            apt-get install -y -qq "$pkg" 2>/dev/null \
                && ok "$pkg instalado" \
                || { warn "$pkg no disponible en repos — intentando alternativa"
                     apt-get install -y -qq android-tools-adb android-tools-fastboot 2>/dev/null || true; }
        else
            ok "$pkg ya instalado"
        fi
    done
}

_install_arch() {
    step "Instalando en Arch/Manjaro/EndeavourOS..."
    pacman -Sy --noconfirm --needed android-tools android-udev curl wget git bc 2>/dev/null \
        && ok "Dependencias instaladas" \
        || err "Error en pacman"
}

_install_fedora() {
    step "Instalando en Fedora/RHEL..."
    dnf install -y android-tools curl wget git bc 2>/dev/null \
        && ok "Dependencias instaladas" \
        || err "Error en dnf"
}

_install_opensuse() {
    step "Instalando en openSUSE..."
    zypper install -y android-tools curl wget git bc 2>/dev/null \
        && ok "Dependencias instaladas" \
        || err "Error en zypper"
}

# ─── Verificar dependencias ───────────────────────────────────────────────────
_check_deps() {
    echo -e "\n${BOLD}  Verificación de dependencias:${NC}\n"
    local deps=(adb fastboot curl wget git bc)
    local all_ok=true
    for dep in "${deps[@]}"; do
        if command -v "$dep" &>/dev/null; then
            local ver; ver=$(command -v "$dep")
            printf "  ${G}${BOLD}%-12s${NC}  ${DIM}%s${NC}\n" "$dep" "$ver"
        else
            printf "  ${R}${BOLD}%-12s${NC}  ${R}no instalado${NC}\n" "$dep"
            all_ok=false
            FAILED+=("$dep")
        fi
    done
    echo ""
    $all_ok && ok "Todas las dependencias OK" || warn "${#FAILED[@]} dependencia(s) faltante(s): ${FAILED[*]}"
}

# ─── Setup directorios ────────────────────────────────────────────────────────
_setup_dirs() {
    step "Creando estructura de directorios..."
    local dirs=(
        "$TOOLKIT_ROOT/.temp"
        "$TOOLKIT_ROOT/logs"
        "$TOOLKIT_ROOT/modules"
        "$TOOLKIT_ROOT/lib"
        "$TOOLKIT_ROOT/device-pull"
        "$TOOLKIT_ROOT/backups"
        "$TOOLKIT_ROOT/screenshots"
        "$TOOLKIT_ROOT/screenrecords"
        "$TOOLKIT_ROOT/bug-report"
    )
    for d in "${dirs[@]}"; do
        mkdir -p "$d" && ok "$(basename "$d")/" || err "No se pudo crear: $d"
    done
    touch "$TOOLKIT_ROOT/.temp/.keep" 2>/dev/null
}

# ─── Generar módulos ──────────────────────────────────────────────────────────
_generate_modules() {
    step "Generando módulos..."
    if [[ -f "$TOOLKIT_ROOT/generate_modules.sh" ]]; then
        export TOOLKIT_ROOT
        bash "$TOOLKIT_ROOT/generate_modules.sh" \
            && ok "Módulos generados correctamente" \
            || err "Error generando módulos"
    else
        err "generate_modules.sh no encontrado"
        FAILED+=("generate_modules.sh")
    fi
}

# ─── Permisos de ejecución ────────────────────────────────────────────────────
_fix_permissions() {
    step "Configurando permisos..."
    chmod +x "$TOOLKIT_ROOT/ADB-Toolkit.sh" 2>/dev/null   && ok "ADB-Toolkit.sh +x"
    chmod +x "$TOOLKIT_ROOT/install.sh" 2>/dev/null        && ok "install.sh +x"
    chmod +x "$TOOLKIT_ROOT/generate_modules.sh" 2>/dev/null && ok "generate_modules.sh +x"
    [[ -d "$TOOLKIT_ROOT/modules" ]] && \
        chmod +x "$TOOLKIT_ROOT/modules/"*.sh 2>/dev/null && ok "modules/*.sh +x"
    chmod +x "$TOOLKIT_ROOT/lib/"*.sh 2>/dev/null          && ok "lib/*.sh +x"
}

# ─── Alias en shell ───────────────────────────────────────────────────────────
_setup_alias() {
    step "Configurando alias 'nexora'..."
    local alias_line="alias nexora='cd \"$TOOLKIT_ROOT\" && bash ADB-Toolkit.sh'"
    local added=false
    for rc in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.bash_aliases"; do
        if [[ -f "$rc" ]]; then
            if grep -q "alias nexora=" "$rc" 2>/dev/null; then
                ok "Alias ya existe en $rc"
            else
                echo "$alias_line" >> "$rc"
                ok "Alias añadido a $rc"
                added=true
            fi
        fi
    done
    $added && info "Recarga el shell: source ~/.bashrc"
}

# ─── Instalación completa ────────────────────────────────────────────────────
_do_install() {
    if [[ $(id -u) -ne 0 ]]; then
        err "Requiere root: sudo bash install.sh -i"
        exit 1
    fi

    echo -e "\n${C}${BOLD}  NEXORA-TOOLKIT — Instalación${NC}\n"

    local distro; distro=$(_detect_distro)
    info "Distro detectada: $distro"

    case "$distro" in
        *debian*|*ubuntu*|*kali*|*mint*|*raspbian*|*pop*|*elementary*)
            _install_debian ;;
        *arch*|*manjaro*|*endeavour*|*garuda*)
            _install_arch ;;
        *fedora*|*rhel*|*centos*)
            _install_fedora ;;
        *opensuse*|*suse*)
            _install_opensuse ;;
        *)
            warn "Distro '$distro' no reconocida."
            warn "Instala manualmente: adb fastboot curl wget git bc"
            ;;
    esac

    _setup_dirs
    _generate_modules
    _fix_permissions
    _setup_alias

    echo ""
    echo -e "  ${C}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    if [[ ${#FAILED[@]} -eq 0 ]]; then
        ok "Instalación completada sin errores."
    else
        warn "Instalación completada con ${#FAILED[@]} advertencia(s): ${FAILED[*]}"
    fi
    echo -e "  ${C}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    ok "Uso directo:  ${W}sudo bash $TOOLKIT_ROOT/ADB-Toolkit.sh${NC}"
    ok "Alias global: ${W}nexora${NC}  (tras recargar el shell)"
    echo ""
}

# ─── Main ─────────────────────────────────────────────────────────────────────
case "${1:-}" in
    -i|install|-install)   _do_install                                     ;;
    -u|update|-update)     _generate_modules; _fix_permissions             ;;
    -c|check|-check)       _check_deps                                     ;;
    -r|repair|-repair)     _fix_permissions; _generate_modules             ;;
    *)                     _help                                           ;;
esac
