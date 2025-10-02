#!/bin/bash
################################################################################
# POET - Módulo de Streamers
# Instala OBS con plugins, Discord, herramientas de audio y más
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
        print_info "  Módulo: Streamers"
    else
        print_info "  Module: Streamers"
    fi
    print_info "═══════════════════════════════════════════════════════════"
    echo ""
    
    # OBS Studio
    if ask_yes_no "$(t 'ask.install_obs')" "s"; then
        stage_ppa "ppa:obsproject/obs-studio"
        stage_apt_package "obs-studio"
        
        # v4l2loopback (cámara virtual)
        if ask_yes_no "  $(t 'ask.install_v4l2')" "s"; then
            stage_apt_package "v4l2loopback-dkms"
            stage_custom_command "sudo modprobe v4l2loopback"
            stage_custom_command 'echo "v4l2loopback" | sudo tee -a /etc/modules-load.d/v4l2loopback.conf'
        fi
    fi
    
    # Discord
    if ask_yes_no "$(t 'ask.install_discord')" "s"; then
        stage_flatpak_package "com.discordapp.Discord"
    fi
    
    # Herramientas de audio
    if ask_yes_no "$(t 'ask.audio_tools')" "s"; then
        stage_apt_package "pavucontrol"
        
        # PipeWire
        if ask_yes_no "  $(t 'ask.install_pipewire')" "s"; then
            stage_apt_package "pipewire"
            stage_apt_package "pipewire-audio-client-libraries"
            stage_apt_package "wireplumber"
            stage_apt_package "libspa-0.2-bluetooth"
            stage_apt_package "pipewire-pulse"
            stage_custom_command "systemctl --user --now enable pipewire pipewire-pulse"
        fi
        
        # EasyEffects
        if ask_yes_no "  $(t 'ask.install_easyeffects')" "s"; then
            stage_flatpak_package "com.github.wwmm.easyeffects"
        fi
    fi
    
    # FFmpeg
    if ! is_package_installed "ffmpeg"; then
        stage_apt_package "ffmpeg"
    fi
    
    # yt-dlp
    if ask_yes_no "$(t 'ask.install_ytdlp')" "s"; then
        stage_custom_command "python3 -m pip install --user -U yt-dlp"
    fi
    
    # Optimizaciones de audio
    if ask_yes_no "$(t 'ask.audio_priority')" "s"; then
        stage_custom_command 'echo "@audio - rtprio 95" | sudo tee -a /etc/security/limits.d/audio.conf'
        stage_custom_command 'echo "@audio - memlock unlimited" | sudo tee -a /etc/security/limits.d/audio.conf'
        stage_custom_command "sudo usermod -aG audio $USER"
    fi
}

################################################################################
# Main
################################################################################

main() {
    # Staging
    ask_and_stage_packages
    
    # Ejecución
    if ! execute_installation "streamers"; then
        return 1
    fi
    
    # Post-instalación
    echo ""
    print_success "═══════════════════════════════════════════════════════════"
    if [[ "$CURRENT_LANG" == "es" ]]; then
        print_success "  Módulo de Streamers completado"
        echo ""
        print_info "Notas importantes:"
        echo "  • Twitch: bitrate máximo 6000 kbps, 1080p60"
        echo "  • YouTube: hasta 51000 kbps recomendado"
        echo "  • Usa NVENC/VAAPI para mejor rendimiento"
        echo "  • Reinicia sesión si instalaste PipeWire"
    else
        print_success "  Streamers module completed"
        echo ""
        print_info "Important notes:"
        echo "  • Twitch: max bitrate 6000 kbps, 1080p60"
        echo "  • YouTube: up to 51000 kbps recommended"
        echo "  • Use NVENC/VAAPI for better performance"
        echo "  • Restart session if you installed PipeWire"
    fi
    print_success "═══════════════════════════════════════════════════════════"
    echo ""
    
    return 0
}

main "$@"
