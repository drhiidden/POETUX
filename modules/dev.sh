#!/bin/bash
################################################################################
# POET - Módulo de Desarrollo
# Instala herramientas de desarrollo: Git, Python, Node.js, Rust, Docker, VSCode
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

install_build_essentials() {
    print_info "Instalando build-essential y herramientas básicas..."
    sudo apt install -y build-essential
    sudo apt install -y make cmake autoconf automake libtool pkg-config
    print_success "Build essentials instalados"
}

install_git() {
    if command -v git &> /dev/null; then
        print_info "Git ya está instalado ($(git --version))"
    else
        print_info "Instalando Git..."
        sudo apt install -y git
        print_success "Git instalado"
    fi
    
    # Configuración básica de Git
    if ask_yes_no "¿Configurar Git (nombre y email)?"; then
        read -p "Nombre completo: " git_name
        read -p "Email: " git_email
        
        git config --global user.name "$git_name"
        git config --global user.email "$git_email"
        git config --global init.defaultBranch main
        
        print_success "Git configurado"
    fi
}

install_python() {
    if ask_yes_no "¿Instalar Python y herramientas de desarrollo?"; then
        print_info "Instalando Python..."
        
        sudo apt install -y python3 python3-pip python3-venv python3-dev
        
        # Actualizar pip
        python3 -m pip install --user --upgrade pip
        
        # Herramientas útiles
        if ask_yes_no "  ¿Instalar pipenv y poetry?"; then
            python3 -m pip install --user pipenv poetry
        fi
        
        print_success "Python instalado ($(python3 --version))"
    else
        print_info "Saltando instalación de Python"
    fi
}

install_nodejs() {
    if ask_yes_no "¿Instalar Node.js y npm?"; then
        print_info "Instalando Node.js..."
        
        # Instalar Node.js desde repositorio de NodeSource (última LTS)
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt install -y nodejs
        
        # Configurar npm para instalar globales sin sudo
        mkdir -p "$HOME/.npm-global"
        npm config set prefix "$HOME/.npm-global"
        
        # Añadir al PATH si no está
        if ! grep -q ".npm-global/bin" "$HOME/.bashrc"; then
            echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> "$HOME/.bashrc"
            print_info "Añadido .npm-global/bin al PATH en .bashrc"
        fi
        
        # Instalar herramientas globales comunes
        if ask_yes_no "  ¿Instalar yarn y pnpm?"; then
            npm install -g yarn pnpm
        fi
        
        print_success "Node.js instalado ($(node --version))"
        print_info "Reinicia tu terminal para que los cambios de PATH surtan efecto"
    else
        print_info "Saltando instalación de Node.js"
    fi
}

install_rust() {
    if ask_yes_no "¿Instalar Rust (rustup)?"; then
        print_info "Instalando Rust..."
        
        # Instalar rustup
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        
        # Source para usar rust en esta sesión
        source "$HOME/.cargo/env"
        
        print_success "Rust instalado ($(rustc --version))"
        print_info "Reinicia tu terminal para que los cambios surtan efecto"
    else
        print_info "Saltando instalación de Rust"
    fi
}

install_docker() {
    if ask_yes_no "¿Instalar Docker?"; then
        print_info "Instalando Docker..."
        
        # Instalar dependencias
        sudo apt install -y ca-certificates curl gnupg lsb-release
        
        # Añadir clave GPG de Docker
        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg
        
        # Añadir repositorio
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
          $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        # Instalar Docker
        sudo apt update
        sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        
        # Añadir usuario al grupo docker
        sudo usermod -aG docker "$USER"
        
        print_success "Docker instalado ($(docker --version))"
        print_warning "Cierra sesión y vuelve a entrar para usar Docker sin sudo"
        
        # Docker Compose
        if ask_yes_no "  ¿Instalar Docker Compose standalone?"; then
            sudo apt install -y docker-compose
            print_success "Docker Compose instalado"
        fi
    else
        print_info "Saltando instalación de Docker"
    fi
}

install_vscode() {
    if ask_yes_no "¿Instalar Visual Studio Code?"; then
        print_info "Instalando VSCode..."
        flatpak install -y flathub com.visualstudio.code
        print_success "VSCode instalado"
    else
        print_info "Saltando instalación de VSCode"
    fi
}

install_other_editors() {
    if ask_yes_no "¿Instalar otros editores/IDEs? (Neovim, IntelliJ IDEA Community)"; then
        if ask_yes_no "  ¿Instalar Neovim?"; then
            sudo apt install -y neovim
            print_success "Neovim instalado"
        fi
        
        if ask_yes_no "  ¿Instalar IntelliJ IDEA Community?"; then
            flatpak install -y flathub com.jetbrains.IntelliJ-IDEA-Community
            print_success "IntelliJ IDEA Community instalado"
        fi
    fi
}

################################################################################
# Main
################################################################################

main() {
    echo ""
    print_info "═══════════════════════════════════════════════════════════"
    print_info "  Módulo: Desarrollo"
    print_info "═══════════════════════════════════════════════════════════"
    echo ""
    
    install_build_essentials
    echo ""
    
    install_git
    echo ""
    
    install_python
    echo ""
    
    install_nodejs
    echo ""
    
    install_rust
    echo ""
    
    install_docker
    echo ""
    
    install_vscode
    echo ""
    
    install_other_editors
    echo ""
    
    print_success "═══════════════════════════════════════════════════════════"
    print_success "  Módulo de Desarrollo completado"
    print_success "═══════════════════════════════════════════════════════════"
    echo ""
    print_info "Notas:"
    echo "  • Si instalaste Docker, cierra sesión y vuelve a entrar"
    echo "  • Si instalaste Node.js o Rust, reinicia tu terminal"
    echo "  • Configura tus editores según tus preferencias"
    echo ""
}

main "$@"

