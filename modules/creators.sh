#!/bin/bash
################################################################################
# POET - Módulo de Creadores de Contenido
# Instala OBS Studio, GIMP, Krita, Kdenlive, Blender y más
################################################################################

set -euo pipefail

# Cargar bibliotecas
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"
source "${SCRIPT_DIR}/../lib/installer.sh"

################################################################################
# Staging de paquetes
################################################################################

ask_and_stage_packages() {
    echo ""
    print_info "═══════════════════════════════════════════════════════════"
    if [[ "$CURRENT_LANG" == "es" ]]; then
        print_info "  Módulo: Creadores de Contenido"
    else
        print_info "  Module: Content Creators"
    fi
    print_info "═══════════════════════════════════════════════════════════"
    echo ""
    
    # OBS Studio
    if ask_yes_no "$(t 'ask.install_obs')" "s"; then
        stage_ppa "ppa:obsproject/obs-studio"
        stage_apt_package "obs-studio"
    fi
    
    # GIMP
    if ask_yes_no "$(t 'ask.install_gimp')" "s"; then
        stage_flatpak_package "org.gimp.GIMP"
    fi
    
    # Krita
    if ask_yes_no "$(t 'ask.install_krita')" "s"; then
        stage_flatpak_package "org.kde.krita"
    fi
    
    # Inkscape
    if ask_yes_no "$(t 'ask.install_inkscape')" "s"; then
        stage_flatpak_package "org.inkscape.Inkscape"
    fi
    
    # Kdenlive
    if ask_yes_no "$(t 'ask.install_kdenlive')" "s"; then
        stage_flatpak_package "org.kde.kdenlive"
    fi
    
    # Blender
    if ask_yes_no "$(t 'ask.install_blender')" "s"; then
        stage_flatpak_package "org.blender.Blender"
    fi
    
    # Audacity
    if ask_yes_no "$(t 'ask.install_audacity')" "s"; then
        stage_apt_package "audacity"
    fi
    
    # DaVinci Resolve deps
    if ask_yes_no "$(t 'ask.davinci_deps')" "n"; then
        stage_apt_package "libfuse2"
        stage_apt_package "libssl1.1" || stage_apt_package "libssl3"
        stage_apt_package "libapr1"
        stage_apt_package "libaprutil1"
        stage_apt_package "libnuma1"
        stage_apt_package "ocl-icd-opencl-dev"
    fi
}

################################################################################
# Main
################################################################################

main() {
    # Staging
    ask_and_stage_packages
    
    # Ejecución
    if ! execute_installation "creators"; then
        return 1
    fi
    
    # Post-instalación
    echo ""
    print_success "═══════════════════════════════════════════════════════════"
    if [[ "$CURRENT_LANG" == "es" ]]; then
        print_success "  Módulo de Creadores completado"
        echo ""
        print_info "Notas:"
        echo "  • OBS: configura escenas y fuentes de video/audio"
        echo "  • Para mejor rendimiento: usa NVENC/VAAPI"
        echo "  • DaVinci: descarga desde blackmagicdesign.com"
    else
        print_success "  Content Creators module completed"
        echo ""
        print_info "Notes:"
        echo "  • OBS: configure scenes and video/audio sources"
        echo "  • For better performance: use NVENC/VAAPI"
        echo "  • DaVinci: download from blackmagicdesign.com"
    fi
    print_success "═══════════════════════════════════════════════════════════"
    echo ""
    
    return 0
}

main "$@"
