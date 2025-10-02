#!/bin/bash
################################################################################
# POET - Pop!_OS Extended Toolkit
# Script principal con menú interactivo
# Autor: POETUX Project
# Licencia: MIT
################################################################################

set -euo pipefail

# Colores para output
readonly RED='\e[31m'
readonly GREEN='\e[32m'
readonly YELLOW='\e[33m'
readonly BLUE='\e[34m'
readonly MAGENTA='\e[35m'
readonly CYAN='\e[36m'
readonly RESET='\e[0m'

# Directorio base del proyecto
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly MODULES_DIR="${SCRIPT_DIR}/modules"

################################################################################
# Funciones auxiliares
################################################################################

print_header() {
    echo -e "${CYAN}"
    cat << "EOF"
    ____  ____  ___________
   / __ \/ __ \/ ____/_  __/
  / /_/ / / / / __/   / /   
 / ____/ /_/ / /___  / /    
/_/    \____/_____/ /_/     
                            
Pop!_OS Extended Toolkit
EOF
    echo -e "${RESET}"
}

print_success() {
    echo -e "${GREEN}✓ $1${RESET}"
}

print_error() {
    echo -e "${RED}✗ Error: $1${RESET}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${RESET}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${RESET}"
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "No ejecutes este script como root. Usará sudo cuando sea necesario."
        exit 1
    fi
}

check_modules_dir() {
    if [[ ! -d "$MODULES_DIR" ]]; then
        print_error "No se encuentra el directorio de módulos: $MODULES_DIR"
        exit 1
    fi
}

load_module() {
    local module_name="$1"
    local module_path="${MODULES_DIR}/${module_name}.sh"
    
    if [[ ! -f "$module_path" ]]; then
        print_error "Módulo no encontrado: $module_path"
        return 1
    fi
    
    if [[ ! -x "$module_path" ]]; then
        print_warning "El módulo no tiene permisos de ejecución. Aplicándolos..."
        chmod +x "$module_path"
    fi
    
    print_info "Ejecutando módulo: $module_name"
    echo ""
    bash "$module_path"
    local exit_code=$?
    echo ""
    
    if [[ $exit_code -eq 0 ]]; then
        print_success "Módulo $module_name completado exitosamente"
    else
        print_error "El módulo $module_name terminó con errores (código: $exit_code)"
    fi
    
    return $exit_code
}

show_menu() {
    echo ""
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════${RESET}"
    echo -e "${CYAN}  Menú Principal${RESET}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════${RESET}"
    echo ""
    echo "  1) Configuración Básica (actualizar sistema, flatpak, utilidades)"
    echo "  2) Gaming (Steam, Lutris, Proton, MangoHUD, Gamemode)"
    echo "  3) Desarrollo (Git, Python, Node.js, Rust, Docker, VSCode)"
    echo "  4) Creadores de Contenido (OBS, GIMP, Krita, Kdenlive, Blender)"
    echo "  5) Streamers (OBS + plugins, Discord, herramientas de audio)"
    echo "  6) Ejecutar todos los módulos"
    echo "  7) Información del sistema"
    echo "  0) Salir"
    echo ""
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════${RESET}"
    echo -n "Selecciona una opción: "
}

show_system_info() {
    echo ""
    print_info "Información del sistema:"
    echo ""
    echo -e "  ${CYAN}OS:${RESET}       $(lsb_release -ds 2>/dev/null || echo "No disponible")"
    echo -e "  ${CYAN}Kernel:${RESET}   $(uname -r)"
    echo -e "  ${CYAN}Hostname:${RESET} $(hostname)"
    echo -e "  ${CYAN}Usuario:${RESET}  $USER"
    echo ""
    
    if command -v nvidia-smi &> /dev/null; then
        echo -e "  ${CYAN}GPU:${RESET}      $(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null || echo "NVIDIA detectada")"
    else
        echo -e "  ${CYAN}GPU:${RESET}      $(lspci | grep -i vga | cut -d: -f3 | head -n1 || echo "No detectada")"
    fi
    echo ""
}

run_all_modules() {
    print_info "Ejecutando todos los módulos en secuencia..."
    echo ""
    
    local modules=("basic" "gaming" "dev" "creators" "streamers")
    local failed_modules=()
    
    for module in "${modules[@]}"; do
        print_info "═══ Iniciando módulo: $module ═══"
        echo ""
        if ! load_module "$module"; then
            failed_modules+=("$module")
        fi
        echo ""
        read -p "Presiona Enter para continuar con el siguiente módulo..."
        echo ""
    done
    
    echo ""
    print_info "═══════════════════════════════════════════════════════════"
    if [[ ${#failed_modules[@]} -eq 0 ]]; then
        print_success "Todos los módulos se ejecutaron correctamente"
    else
        print_warning "Los siguientes módulos tuvieron errores: ${failed_modules[*]}"
    fi
    print_info "═══════════════════════════════════════════════════════════"
    echo ""
}

################################################################################
# Main
################################################################################

main() {
    check_root
    check_modules_dir
    
    print_header
    
    echo -e "${GREEN}Bienvenido a POET - Pop!_OS Extended Toolkit${RESET}"
    echo ""
    echo "Este toolkit te ayudará a configurar tu sistema Pop!_OS"
    echo "de forma modular y personalizada según tus necesidades."
    echo ""
    
    while true; do
        show_menu
        read -r option
        
        case $option in
            1)
                load_module "basic"
                ;;
            2)
                load_module "gaming"
                ;;
            3)
                load_module "dev"
                ;;
            4)
                load_module "creators"
                ;;
            5)
                load_module "streamers"
                ;;
            6)
                run_all_modules
                ;;
            7)
                show_system_info
                ;;
            0)
                echo ""
                print_success "¡Gracias por usar POET! 🚀"
                echo ""
                exit 0
                ;;
            *)
                print_error "Opción no válida. Por favor, selecciona una opción del menú."
                ;;
        esac
        
        echo ""
        read -p "Presiona Enter para volver al menú principal..."
    done
}

# Ejecutar main
main "$@"

