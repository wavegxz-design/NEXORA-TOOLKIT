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
