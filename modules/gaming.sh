#!/bin/bash
################################################################################
# POET - Módulo de Gaming
# Instala Steam, Lutris, Proton, MangoHUD, Gamemode y más
################################################################################

set -euo pipefail

# Cargar bibliotecas
GAMING_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${GAMING_SCRIPT_DIR}/../lib/common.sh"
source "${GAMING_SCRIPT_DIR}/../lib/installer.sh"

################################################################################
# Staging de paquetes
################################################################################

ask_and_stage_packages() {
    echo ""
    print_info "═══════════════════════════════════════════════════════════"
    if [[ "$CURRENT_LANG" == "es" ]]; then
        print_info "  Módulo: Gaming"
    else
        print_info "  Module: Gaming"
    fi
    print_info "═══════════════════════════════════════════════════════════"
    echo ""
    
    # Steam
    if ask_yes_no "$(t 'ask.install_steam')" "s"; then
        stage_apt_package "steam"
    fi
    
    # Lutris
    if ask_yes_no "$(t 'ask.install_lutris')" "s"; then
        stage_apt_package "lutris"
    fi
    
    # GameMode
    if ask_yes_no "$(t 'ask.install_gamemode')" "s"; then
        stage_apt_package "gamemode"
    fi
    
    # MangoHUD
    if ask_yes_no "$(t 'ask.install_mangohud')" "s"; then
        stage_apt_package "mangohud"
        stage_apt_package "goverlay" || true
    fi
    
    # Heroic Games Launcher
    if ask_yes_no "$(t 'ask.install_heroic')" "s"; then
        stage_flatpak_package "com.heroicgameslauncher.hgl"
    fi
    
    # ProtonUp-Qt
    if ask_yes_no "$(t 'ask.install_protonup')" "s"; then
        stage_flatpak_package "net.davidotek.pupgui2"
    fi
    
    # Wine
    if ask_yes_no "$(t 'ask.install_wine')" "s"; then
        stage_custom_command "sudo dpkg --add-architecture i386"
        stage_custom_command "sudo apt update"
        stage_apt_package "wine64"
        stage_apt_package "wine32"
        stage_apt_package "winetricks"
    fi
    
    # Gaming tweaks
    if ask_yes_no "$(t 'ask.gaming_tweaks')" "s"; then
        stage_custom_command 'echo "fs.inotify.max_user_watches=524288" | sudo tee /etc/sysctl.d/40-max-user-watches.conf'
        stage_custom_command 'sudo sysctl -p /etc/sysctl.d/40-max-user-watches.conf'
        stage_custom_command 'echo "$USER hard nofile 524288" | sudo tee -a /etc/security/limits.conf'
        stage_custom_command 'echo "$USER soft nofile 524288" | sudo tee -a /etc/security/limits.conf'
    fi
}

################################################################################
# Main
################################################################################

main() {
    # Staging
    ask_and_stage_packages
    
    # Ejecución
    if ! execute_installation "gaming"; then
        return 1
    fi
    
    # Post-instalación
    echo ""
    print_success "═══════════════════════════════════════════════════════════"
    if [[ "$CURRENT_LANG" == "es" ]]; then
        print_success "  Módulo de Gaming completado"
        echo ""
        print_info "Notas:"
        echo "  • Reinicia tu sesión para que GameMode funcione"
        echo "  • Para usar MangoHUD: MANGOHUD=1 %command% (en Steam)"
        echo "  • Para usar GameMode: gamemoderun %command%"
    else
        print_success "  Gaming module completed"
        echo ""
        print_info "Notes:"
        echo "  • Restart your session for GameMode to work"
        echo "  • To use MangoHUD: MANGOHUD=1 %command% (in Steam)"
        echo "  • To use GameMode: gamemoderun %command%"
    fi
    print_success "═══════════════════════════════════════════════════════════"
    echo ""
    
    return 0
}

main "$@"
