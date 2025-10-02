#!/bin/bash
################################################################################
# POET - Módulo de Streamers
# Instala OBS con plugins, Discord, herramientas de audio y más
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

install_obs_full() {
    if ask_yes_no "¿Instalar OBS Studio?"; then
        print_info "Instalando OBS Studio..."
        
        # Añadir PPA oficial de OBS
        sudo add-apt-repository -y ppa:obsproject/obs-studio
        sudo apt update
        sudo apt install -y obs-studio
        
        print_success "OBS Studio instalado"
        
        # Plugins adicionales
        if ask_yes_no "  ¿Instalar plugins adicionales de OBS?"; then
            install_obs_plugins
        fi
    else
        print_info "Saltando instalación de OBS Studio"
    fi
}

install_obs_plugins() {
    print_info "Instalando plugins de OBS..."
    
    # obs-websocket (control remoto de OBS)
    if ask_yes_no "  ¿Instalar obs-websocket?"; then
        print_info "Instalando obs-websocket..."
        
        # En versiones recientes de OBS, websocket viene integrado
        print_info "obs-websocket viene integrado en OBS Studio 28+"
        print_info "Si tienes una versión anterior, actualiza OBS"
    fi
    
    # v4l2sink (cámara virtual)
    if ask_yes_no "  ¿Instalar v4l2loopback (cámara virtual)?"; then
        print_info "Instalando v4l2loopback..."
        sudo apt install -y v4l2loopback-dkms
        
        # Cargar módulo
        sudo modprobe v4l2loopback
        
        # Hacer que se cargue al inicio
        echo "v4l2loopback" | sudo tee -a /etc/modules-load.d/v4l2loopback.conf
        
        print_success "v4l2loopback instalado"
    fi
}

install_discord() {
    if ask_yes_no "¿Instalar Discord?"; then
        print_info "Instalando Discord..."
        flatpak install -y flathub com.discordapp.Discord
        print_success "Discord instalado"
    else
        print_info "Saltando instalación de Discord"
    fi
}

install_audio_tools() {
    if ask_yes_no "¿Instalar herramientas de audio (PulseAudio, PipeWire)?"; then
        print_info "Instalando herramientas de audio..."
        
        # PulseAudio (control de volumen)
        sudo apt install -y pavucontrol
        
        # PipeWire (sistema de audio moderno)
        if ask_yes_no "  ¿Cambiar a PipeWire? (recomendado, mejor latencia)"; then
            print_info "Instalando PipeWire..."
            sudo apt install -y pipewire pipewire-audio-client-libraries
            sudo apt install -y wireplumber pipewire-media-session-
            sudo apt install -y libspa-0.2-bluetooth pipewire-pulse
            
            # Reemplazar PulseAudio con PipeWire
            systemctl --user --now enable pipewire pipewire-pulse
            
            print_success "PipeWire instalado"
            print_warning "Reinicia tu sesión para aplicar cambios"
        fi
        
        # EasyEffects (procesamiento de audio)
        if ask_yes_no "  ¿Instalar EasyEffects? (ecualizador, compresor, etc.)"; then
            flatpak install -y flathub com.github.wwmm.easyeffects
            print_success "EasyEffects instalado"
        fi
        
        print_success "Herramientas de audio instaladas"
    else
        print_info "Saltando instalación de herramientas de audio"
    fi
}

install_streaming_utilities() {
    print_info "Instalando utilidades para streaming..."
    
    # FFmpeg (procesamiento de video/audio)
    if ! command -v ffmpeg &> /dev/null; then
        print_info "Instalando FFmpeg..."
        sudo apt install -y ffmpeg
        print_success "FFmpeg instalado"
    else
        print_info "FFmpeg ya está instalado"
    fi
    
    # youtube-dl (descargar VODs)
    if ask_yes_no "¿Instalar yt-dlp (descargar videos de YouTube/Twitch)?"; then
        print_info "Instalando yt-dlp..."
        sudo apt install -y python3-pip
        python3 -m pip install --user -U yt-dlp
        print_success "yt-dlp instalado"
    fi
}

install_chat_overlays() {
    if ask_yes_no "¿Instalar herramientas para overlays de chat?"; then
        print_info "Para overlays de chat, recomendamos usar StreamElements u OBS.Ninja"
        echo ""
        echo "  • StreamElements: https://streamelements.com/"
        echo "  • OBS.Ninja: https://obs.ninja/"
        echo ""
        print_info "Estas son herramientas basadas en navegador que funcionan con OBS"
    fi
}

configure_streaming_tweaks() {
    print_info "Aplicando optimizaciones para streaming..."
    
    # Aumentar prioridad de audio
    if ask_yes_no "¿Configurar prioridad en tiempo real para audio? (reduce latencia)"; then
        echo "@audio - rtprio 95" | sudo tee -a /etc/security/limits.d/audio.conf
        echo "@audio - memlock unlimited" | sudo tee -a /etc/security/limits.d/audio.conf
        
        # Añadir usuario al grupo audio
        sudo usermod -aG audio "$USER"
        
        print_success "Prioridad de audio configurada"
        print_warning "Reinicia tu sesión para aplicar cambios"
    fi
}

################################################################################
# Main
################################################################################

main() {
    echo ""
    print_info "═══════════════════════════════════════════════════════════"
    print_info "  Módulo: Streamers"
    print_info "═══════════════════════════════════════════════════════════"
    echo ""
    
    install_obs_full
    echo ""
    
    install_discord
    echo ""
    
    install_audio_tools
    echo ""
    
    install_streaming_utilities
    echo ""
    
    install_chat_overlays
    echo ""
    
    configure_streaming_tweaks
    echo ""
    
    print_success "═══════════════════════════════════════════════════════════"
    print_success "  Módulo de Streamers completado"
    print_success "═══════════════════════════════════════════════════════════"
    echo ""
    print_info "Notas importantes:"
    echo "  • OBS Studio: configura bitrate según tu conexión de internet"
    echo "  • Para Twitch: 6000 kbps máximo, 1080p60 o 900p60"
    echo "  • Para YouTube: hasta 51000 kbps, 1080p60 recomendado"
    echo "  • Usa codificación por hardware (NVENC/VAAPI) para mejor rendimiento"
    echo "  • PipeWire reduce latencia de audio vs PulseAudio"
    echo "  • Reinicia tu sesión si instalaste PipeWire o configuraste audio"
    echo ""
}

main "$@"

