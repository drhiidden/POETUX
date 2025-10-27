#!/bin/bash
################################################################################
# POET - Pop!_OS Extended Toolkit
# Script principal con menú interactivo
# Autor: POETUX Project
# Licencia: MIT
# Versión: 1.2.0
################################################################################

set -euo pipefail

# Directorio base del proyecto
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly MODULES_DIR="${SCRIPT_DIR}/modules"
readonly LIB_DIR="${SCRIPT_DIR}/lib"

# Cargar biblioteca común (incluye i18n, colores, logging, etc.)
if [[ -f "${LIB_DIR}/common.sh" ]]; then
    source "${LIB_DIR}/common.sh"
else
    # Fallback si no existe la librería
    RED='\e[31m'
    GREEN='\e[32m'
    YELLOW='\e[33m'
    BLUE='\e[34m'
    MAGENTA='\e[35m'
    CYAN='\e[36m'
    RESET='\e[0m'
    print_error() { echo -e "${RED}✗ Error: $1${RESET}" >&2; }
    print_error "Library not found: ${LIB_DIR}/common.sh"
    print_error "Please ensure the project structure is intact"
    exit 1
fi

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
                            
Pop!_OS Extended Toolkit v1.3.0
EOF
    echo -e "${RESET}"
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
    echo -e "${CYAN}  $(t 'menu.title')${RESET}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════${RESET}"
    echo ""
    echo "  1) $(t 'menu.basic')"
    echo "  2) $(t 'menu.gaming')"
    echo "  3) $(t 'menu.dev')"
    echo "  4) $(t 'menu.creators')"
    echo "  5) $(t 'menu.streamers')"
    echo "  6) $(t 'menu.all')"
    echo ""
    echo -e "${YELLOW}━━━ $(if [[ "$CURRENT_LANG" == "es" ]]; then echo "Herramientas"; else echo "Tools"; fi) ━━━${RESET}"
    echo "  7) $(t 'menu.backup')"
    echo "  8) $(t 'menu.search')"
    echo "  9) $(t 'menu.info')"
    echo ""
    if [[ "$CURRENT_LANG" == "es" ]]; then
        echo "  L) Cambiar idioma (Actual: Español)"
    else
        echo "  L) Change language (Current: English)"
    fi
    echo "  0) $(t 'menu.exit')"
    echo ""
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════${RESET}"
    echo -n "$(t 'prompt.select')"
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

change_language() {
    echo ""
    if [[ "$CURRENT_LANG" == "es" ]]; then
        echo "Idiomas disponibles:"
        echo "  1) Español"
        echo "  2) English"
        echo ""
        read -p "Selecciona idioma: " lang_choice
    else
        echo "Available languages:"
        echo "  1) Español"
        echo "  2) English"
        echo ""
        read -p "Select language: " lang_choice
    fi
    
    case "$lang_choice" in
        1)
            save_language "es"
            CURRENT_LANG="es"
            print_success "Idioma cambiado a Español"
            ;;
        2)
            save_language "en"
            CURRENT_LANG="en"
            print_success "Language changed to English"
            ;;
    esac
}

main() {
    # Parsear argumentos de línea de comandos
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                set_dry_run
                shift
                ;;
            --lang)
                save_language "$2"
                CURRENT_LANG="$2"
                shift 2
                ;;
            --help|-h)
                echo "POETUX - Pop!_OS Extended Toolkit v1.3.0"
                echo ""
                echo "Usage: ./poet.sh [options]"
                echo ""
                echo "Options:"
                echo "  --dry-run        Preview changes without executing"
                echo "  --lang [es|en]   Set language (es=Spanish, en=English)"
                echo "  --help, -h       Show this help message"
                echo ""
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    check_root
    check_modules_dir
    
    # Crear snapshot inicial automáticamente si no existe ninguno
    if [[ ! -d "$POETUX_BACKUP_DIR" ]] || [[ -z "$(ls -A "$POETUX_BACKUP_DIR" 2>/dev/null)" ]]; then
        if [[ "$CURRENT_LANG" == "es" ]]; then
            print_info "Creando snapshot inicial del sistema..."
        else
            print_info "Creating initial system snapshot..."
        fi
        create_backup_snapshot "initial_$(date +%Y%m%d)" >/dev/null 2>&1
    fi
    
    print_header
    
    echo -e "${GREEN}$(t 'msg.welcome')${RESET}"
    echo ""
    echo "$(t 'msg.description')"
    if [[ "$CURRENT_LANG" == "es" ]]; then
        echo "de forma modular y personalizada según tus necesidades."
    else
        echo "in a modular and personalized way according to your needs."
    fi
    echo ""
    
    if [[ "$DRY_RUN" == true ]]; then
        print_warning "DRY RUN MODE ENABLED - No changes will be made"
        echo ""
    fi
    
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
                # Backup y Restauración
                if [[ -f "${LIB_DIR}/backup.sh" ]]; then
                    bash "${LIB_DIR}/backup.sh"
                else
                    print_error "Backup module not found"
                fi
                ;;
            8)
                # Búsqueda de paquetes
                if [[ -f "${LIB_DIR}/search.sh" ]]; then
                    bash "${LIB_DIR}/search.sh"
                else
                    print_error "Search module not found"
                fi
                ;;
            9)
                show_system_info
                ;;
            [Ll])
                change_language
                ;;
            0)
                echo ""
                print_success "$(t 'msg.thanks')"
                echo ""
                if [[ "$CURRENT_LANG" == "es" ]]; then
                    print_info "Logs guardados en: ${POETUX_LOG_DIR}"
                else
                    print_info "Logs saved in: ${POETUX_LOG_DIR}"
                fi
                echo ""
                exit 0
                ;;
            *)
                print_error "$(t 'msg.invalid_option')"
                ;;
        esac
        
        echo ""
        read -p "$(t 'msg.press_enter')"
    done
}

# Ejecutar main
main "$@"

