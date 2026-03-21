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
