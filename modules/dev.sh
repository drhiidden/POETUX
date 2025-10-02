#!/bin/bash
################################################################################
# POET - Módulo de Desarrollo
# Instala herramientas de desarrollo: Git, Python, Node.js, Rust, Docker, VSCode
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
        print_info "  Módulo: Desarrollo"
    else
        print_info "  Module: Development"
    fi
    print_info "═══════════════════════════════════════════════════════════"
    echo ""
    
    # Build essentials
    stage_apt_package "build-essential"
    stage_apt_package "make"
    stage_apt_package "cmake"
    stage_apt_package "autoconf"
    stage_apt_package "automake"
    stage_apt_package "libtool"
    stage_apt_package "pkg-config"
    
    # Git
    if ! is_package_installed "git"; then
        stage_apt_package "git"
    fi
    
    # Python
    if ask_yes_no "$(t 'ask.install_python')" "s"; then
        stage_apt_package "python3"
        stage_apt_package "python3-pip"
        stage_apt_package "python3-venv"
        stage_apt_package "python3-dev"
        
        if ask_yes_no "  $(t 'ask.install_python_tools')" "s"; then
            stage_custom_command "python3 -m pip install --user --upgrade pip pipenv poetry"
        fi
    fi
    
    # Node.js
    if ask_yes_no "$(t 'ask.install_nodejs')" "s"; then
        stage_custom_command "curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -"
        stage_apt_package "nodejs"
        
        if ask_yes_no "  $(t 'ask.install_yarn_pnpm')" "s"; then
            stage_custom_command "npm install -g yarn pnpm"
        fi
    fi
    
    # Rust
    if ask_yes_no "$(t 'ask.install_rust')" "s"; then
        stage_custom_command "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
    fi
    
    # Docker
    if ask_yes_no "$(t 'ask.install_docker')" "s"; then
        stage_custom_command "sudo install -m 0755 -d /etc/apt/keyrings"
        stage_custom_command "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg"
        stage_custom_command "sudo chmod a+r /etc/apt/keyrings/docker.gpg"
        stage_custom_command 'echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null'
        stage_custom_command "sudo apt update"
        stage_apt_package "docker-ce"
        stage_apt_package "docker-ce-cli"
        stage_apt_package "containerd.io"
        stage_apt_package "docker-buildx-plugin"
        stage_apt_package "docker-compose-plugin"
        stage_custom_command "sudo usermod -aG docker $USER"
    fi
    
    # VSCode
    if ask_yes_no "$(t 'ask.install_vscode')" "s"; then
        stage_flatpak_package "com.visualstudio.code"
    fi
    
    # Otros editores
    if ask_yes_no "$(t 'ask.install_other_editors')" "n"; then
        if ask_yes_no "  $(t 'ask.install_neovim')" "s"; then
            stage_apt_package "neovim"
        fi
        
        if ask_yes_no "  $(t 'ask.install_intellij')" "n"; then
            stage_flatpak_package "com.jetbrains.IntelliJ-IDEA-Community"
        fi
    fi
}

################################################################################
# Main
################################################################################

main() {
    # Staging
    ask_and_stage_packages
    
    # Ejecución
    if ! execute_installation "dev"; then
        return 1
    fi
    
    # Post-instalación
    echo ""
    print_success "═══════════════════════════════════════════════════════════"
    if [[ "$CURRENT_LANG" == "es" ]]; then
        print_success "  Módulo de Desarrollo completado"
        echo ""
        print_info "Notas:"
        echo "  • Si instalaste Docker, cierra sesión y vuelve a entrar"
        echo "  • Si instalaste Node.js o Rust, reinicia tu terminal"
        echo "  • Configura Git: git config --global user.name 'Tu Nombre'"
    else
        print_success "  Development module completed"
        echo ""
        print_info "Notes:"
        echo "  • If you installed Docker, log out and log back in"
        echo "  • If you installed Node.js or Rust, restart your terminal"
        echo "  • Configure Git: git config --global user.name 'Your Name'"
    fi
    print_success "═══════════════════════════════════════════════════════════"
    echo ""
    
    return 0
}

main "$@"
