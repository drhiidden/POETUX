#!/bin/bash
################################################################################
# POET - Módulo de Configuración Básica
# Actualiza el sistema, instala flatpak y utilidades comunes
################################################################################

set -euo pipefail

# Cargar bibliotecas
BASIC_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${BASIC_SCRIPT_DIR}/../lib/common.sh"
source "${BASIC_SCRIPT_DIR}/../lib/installer.sh"

################################################################################
# Staging de paquetes
################################################################################

ask_and_stage_packages() {
    echo ""
    print_info "═══════════════════════════════════════════════════════════"
    if [[ "$CURRENT_LANG" == "es" ]]; then
        print_info "  Módulo: Configuración Básica"
    else
        print_info "  Module: Basic Setup"
    fi
    print_info "═══════════════════════════════════════════════════════════"
    echo ""
    
    # Actualización del sistema
    if [[ "$CURRENT_LANG" == "es" ]]; then
        print_info "Actualizando sistema..."
    else
        print_info "Updating system..."
    fi
    sudo apt update
    sudo apt upgrade -y
    sudo apt autoremove -y
    
    # Flatpak
    if ! command -v flatpak &> /dev/null; then
        stage_apt_package "flatpak"
    fi
    
    # Utilidades comunes
    stage_apt_package "curl"
    stage_apt_package "wget"
    stage_apt_package "htop"
    stage_apt_package "gnome-tweaks"
    stage_apt_package "neofetch"
    stage_apt_package "git"
    stage_apt_package "vim"
    stage_apt_package "nano"
    stage_apt_package "tree"
    stage_apt_package "unzip"
    stage_apt_package "zip"
    stage_apt_package "software-properties-common"
    stage_apt_package "apt-transport-https"
    stage_apt_package "ca-certificates"
    stage_apt_package "gnupg"
    stage_apt_package "lsb-release"
    
    # Configurar Flathub si flatpak está instalado
    if command -v flatpak &> /dev/null; then
        if ! flatpak remote-list | grep -q "flathub"; then
            stage_custom_command "flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo"
        fi
    fi
}

################################################################################
# Main
################################################################################

main() {
    # Staging y ejecución
    ask_and_stage_packages
    
    if ! execute_installation "basic"; then
        return 1
    fi
    
    # Post-instalación
    echo ""
    print_success "═══════════════════════════════════════════════════════════"
    if [[ "$CURRENT_LANG" == "es" ]]; then
        print_success "  Configuración básica completada"
    else
        print_success "  Basic setup completed"
    fi
    print_success "═══════════════════════════════════════════════════════════"
    echo ""
    
    return 0
}

main "$@"

