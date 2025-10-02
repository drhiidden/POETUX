#!/bin/bash
################################################################################
# POET - Módulo de Configuración Básica
# Actualiza el sistema, instala flatpak y utilidades comunes
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

update_system() {
    print_info "Actualizando sistema..."
    sudo apt update
    sudo apt upgrade -y
    sudo apt autoremove -y
    sudo apt autoclean
    print_success "Sistema actualizado"
}

install_flatpak() {
    if command -v flatpak &> /dev/null; then
        print_info "Flatpak ya está instalado"
    else
        print_info "Instalando Flatpak..."
        sudo apt install -y flatpak
        print_success "Flatpak instalado"
    fi
    
    # Añadir Flathub si no está añadido
    if ! flatpak remote-list | grep -q "flathub"; then
        print_info "Añadiendo repositorio Flathub..."
        sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        print_success "Flathub añadido"
    else
        print_info "Flathub ya está configurado"
    fi
}

install_utilities() {
    print_info "Instalando utilidades comunes..."
    
    local packages=(
        "curl"
        "wget"
        "htop"
        "gnome-tweaks"
        "neofetch"
        "git"
        "vim"
        "nano"
        "tree"
        "unzip"
        "zip"
        "software-properties-common"
        "apt-transport-https"
        "ca-certificates"
        "gnupg"
        "lsb-release"
    )
    
    for package in "${packages[@]}"; do
        if ! dpkg -l | grep -q "^ii.*$package"; then
            print_info "Instalando $package..."
            sudo apt install -y "$package"
        else
            print_info "$package ya está instalado"
        fi
    done
    
    print_success "Utilidades instaladas"
}

configure_pop_shell() {
    if [[ -d "$HOME/.local/share/gnome-shell/extensions/pop-shell@system76.com" ]] || \
       [[ -d "/usr/share/gnome-shell/extensions/pop-shell@system76.com" ]]; then
        print_info "Pop!_Shell detectado - todo OK"
    else
        print_warning "Pop!_Shell no detectado. En Pop!_OS debería estar preinstalado."
    fi
}

################################################################################
# Main
################################################################################

main() {
    echo ""
    print_info "═══════════════════════════════════════════════════════════"
    print_info "  Módulo: Configuración Básica"
    print_info "═══════════════════════════════════════════════════════════"
    echo ""
    
    update_system
    echo ""
    
    install_flatpak
    echo ""
    
    install_utilities
    echo ""
    
    configure_pop_shell
    echo ""
    
    print_success "═══════════════════════════════════════════════════════════"
    print_success "  Configuración básica completada"
    print_success "═══════════════════════════════════════════════════════════"
    echo ""
}

main "$@"

