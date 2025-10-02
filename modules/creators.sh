#!/bin/bash
################################################################################
# POET - Módulo de Creadores de Contenido
# Instala OBS Studio, GIMP, Krita, Kdenlive, Blender y más
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

install_obs() {
    if ask_yes_no "¿Instalar OBS Studio?"; then
        print_info "Instalando OBS Studio..."
        
        # Añadir PPA oficial de OBS
        sudo add-apt-repository -y ppa:obsproject/obs-studio
        sudo apt update
        sudo apt install -y obs-studio
        
        print_success "OBS Studio instalado"
    else
        print_info "Saltando instalación de OBS Studio"
    fi
}

install_gimp() {
    if ask_yes_no "¿Instalar GIMP (editor de imágenes)?"; then
        print_info "Instalando GIMP..."
        flatpak install -y flathub org.gimp.GIMP
        print_success "GIMP instalado"
    else
        print_info "Saltando instalación de GIMP"
    fi
}

install_krita() {
    if ask_yes_no "¿Instalar Krita (pintura digital)?"; then
        print_info "Instalando Krita..."
        flatpak install -y flathub org.kde.krita
        print_success "Krita instalado"
    else
        print_info "Saltando instalación de Krita"
    fi
}

install_kdenlive() {
    if ask_yes_no "¿Instalar Kdenlive (editor de video)?"; then
        print_info "Instalando Kdenlive..."
        flatpak install -y flathub org.kde.kdenlive
        print_success "Kdenlive instalado"
    else
        print_info "Saltando instalación de Kdenlive"
    fi
}

install_blender() {
    if ask_yes_no "¿Instalar Blender (modelado 3D)?"; then
        print_info "Instalando Blender..."
        flatpak install -y flathub org.blender.Blender
        print_success "Blender instalado"
    else
        print_info "Saltando instalación de Blender"
    fi
}

install_inkscape() {
    if ask_yes_no "¿Instalar Inkscape (gráficos vectoriales)?"; then
        print_info "Instalando Inkscape..."
        flatpak install -y flathub org.inkscape.Inkscape
        print_success "Inkscape instalado"
    else
        print_info "Saltando instalación de Inkscape"
    fi
}

install_audacity() {
    if ask_yes_no "¿Instalar Audacity (editor de audio)?"; then
        print_info "Instalando Audacity..."
        sudo apt install -y audacity
        print_success "Audacity instalado"
    else
        print_info "Saltando instalación de Audacity"
    fi
}

install_davinci_resolve_deps() {
    if ask_yes_no "¿Preparar sistema para DaVinci Resolve? (solo dependencias)"; then
        print_info "Instalando dependencias para DaVinci Resolve..."
        
        # Dependencias necesarias para DaVinci Resolve
        sudo apt install -y \
            libfuse2 \
            libssl1.1 \
            libapr1 \
            libaprutil1 \
            libnuma1 \
            ocl-icd-opencl-dev
        
        print_success "Dependencias instaladas"
        print_info "Deberás descargar DaVinci Resolve manualmente desde:"
        echo "  https://www.blackmagicdesign.com/products/davinciresolve"
    else
        print_info "Saltando preparación para DaVinci Resolve"
    fi
}

################################################################################
# Main
################################################################################

main() {
    echo ""
    print_info "═══════════════════════════════════════════════════════════"
    print_info "  Módulo: Creadores de Contenido"
    print_info "═══════════════════════════════════════════════════════════"
    echo ""
    
    install_obs
    echo ""
    
    install_gimp
    echo ""
    
    install_krita
    echo ""
    
    install_inkscape
    echo ""
    
    install_kdenlive
    echo ""
    
    install_blender
    echo ""
    
    install_audacity
    echo ""
    
    install_davinci_resolve_deps
    echo ""
    
    print_success "═══════════════════════════════════════════════════════════"
    print_success "  Módulo de Creadores de Contenido completado"
    print_success "═══════════════════════════════════════════════════════════"
    echo ""
    print_info "Notas:"
    echo "  • OBS Studio: configura tus escenas y fuentes de video/audio"
    echo "  • Para mejor rendimiento en OBS: usa codificación por hardware (NVENC/VAAPI)"
    echo "  • Kdenlive y Blender pueden requerir GPU potente para renderizado"
    echo ""
}

main "$@"

