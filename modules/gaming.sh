#!/bin/bash
################################################################################
# POET - Módulo de Gaming
# Instala Steam, Lutris, Proton, MangoHUD, Gamemode y más
################################################################################

set -euo pipefail

# Colores
readonly GREEN='\e[32m'
readonly YELLOW='\e[33m'
readonly BLUE='\e[34m'
readonly RESET='\e[0m'

print_success() { echo -e "${GREEN}✓ $1${RESET}"; }
print_info() { echo -e "${BLUE}ℹ $1${RESET}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${RESET}"; }

################################################################################
# Funciones
################################################################################

ask_yes_no() {
    local prompt="$1"
    local response
    while true; do
        read -p "$prompt (s/n): " response
        case $response in
            [Ss]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Por favor responde s (sí) o n (no).";;
        esac
    done
}

install_steam() {
    if ask_yes_no "¿Instalar Steam?"; then
        print_info "Instalando Steam..."
        
        # En Pop!_OS, Steam debería estar disponible en repos
        sudo apt install -y steam
        
        print_success "Steam instalado"
    else
        print_info "Saltando instalación de Steam"
    fi
}

install_lutris() {
    if ask_yes_no "¿Instalar Lutris?"; then
        print_info "Instalando Lutris..."
        sudo apt install -y lutris
        print_success "Lutris instalado"
    else
        print_info "Saltando instalación de Lutris"
    fi
}

install_gamemode() {
    if ask_yes_no "¿Instalar GameMode (optimización de rendimiento)?"; then
        print_info "Instalando GameMode..."
        sudo apt install -y gamemode
        print_success "GameMode instalado"
    else
        print_info "Saltando instalación de GameMode"
    fi
}

install_mangohud() {
    if ask_yes_no "¿Instalar MangoHUD (overlay de FPS y stats)?"; then
        print_info "Instalando MangoHUD..."
        sudo apt install -y mangohud
        
        # Instalar GOverlay (GUI para MangoHUD) si está disponible
        if apt-cache show goverlay &> /dev/null; then
            print_info "Instalando GOverlay (GUI para MangoHUD)..."
            sudo apt install -y goverlay
        fi
        
        print_success "MangoHUD instalado"
    else
        print_info "Saltando instalación de MangoHUD"
    fi
}

install_heroic() {
    if ask_yes_no "¿Instalar Heroic Games Launcher (Epic, GOG)?"; then
        print_info "Instalando Heroic Games Launcher..."
        flatpak install -y flathub com.heroicgameslauncher.hgl
        print_success "Heroic Games Launcher instalado"
    else
        print_info "Saltando instalación de Heroic"
    fi
}

install_protonup_qt() {
    if ask_yes_no "¿Instalar ProtonUp-Qt (gestor de versiones de Proton)?"; then
        print_info "Instalando ProtonUp-Qt..."
        flatpak install -y flathub net.davidotek.pupgui2
        print_success "ProtonUp-Qt instalado"
    else
        print_info "Saltando instalación de ProtonUp-Qt"
    fi
}

install_wine() {
    if ask_yes_no "¿Instalar Wine y dependencias?"; then
        print_info "Instalando Wine..."
        
        # Habilitar arquitectura de 32 bits
        sudo dpkg --add-architecture i386
        sudo apt update
        
        # Instalar Wine y dependencias
        sudo apt install -y wine64 wine32 winetricks
        
        print_success "Wine instalado"
    else
        print_info "Saltando instalación de Wine"
    fi
}

configure_gaming_tweaks() {
    print_info "Aplicando optimizaciones de gaming..."
    
    # Aumentar límite de watchers (útil para juegos que usan muchos archivos)
    if ask_yes_no "¿Aumentar límite de fs.inotify.max_user_watches? (recomendado)"; then
        echo "fs.inotify.max_user_watches=524288" | sudo tee /etc/sysctl.d/40-max-user-watches.conf
        sudo sysctl -p /etc/sysctl.d/40-max-user-watches.conf
        print_success "Límite de watchers aumentado"
    fi
    
    # Configurar esync/fsync
    if ask_yes_no "¿Configurar límites para esync/fsync? (recomendado para Proton)"; then
        echo "$USER hard nofile 524288" | sudo tee -a /etc/security/limits.conf
        echo "$USER soft nofile 524288" | sudo tee -a /etc/security/limits.conf
        print_success "Límites configurados"
    fi
}

################################################################################
# Main
################################################################################

main() {
    echo ""
    print_info "═══════════════════════════════════════════════════════════"
    print_info "  Módulo: Gaming"
    print_info "═══════════════════════════════════════════════════════════"
    echo ""
    
    install_steam
    echo ""
    
    install_lutris
    echo ""
    
    install_gamemode
    echo ""
    
    install_mangohud
    echo ""
    
    install_heroic
    echo ""
    
    install_protonup_qt
    echo ""
    
    install_wine
    echo ""
    
    configure_gaming_tweaks
    echo ""
    
    print_success "═══════════════════════════════════════════════════════════"
    print_success "  Módulo de Gaming completado"
    print_success "═══════════════════════════════════════════════════════════"
    echo ""
    print_info "Notas:"
    echo "  • Reinicia tu sesión para que GameMode funcione correctamente"
    echo "  • Para usar MangoHUD: MANGOHUD=1 %command% (en las opciones de lanzamiento de Steam)"
    echo "  • Para usar GameMode: gamemoderun %command%"
    echo ""
}

main "$@"

