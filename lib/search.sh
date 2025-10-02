#!/bin/bash
################################################################################
# POET - Sistema de Búsqueda de Paquetes
# Búsqueda en repositorios APT, Flatpak y más
################################################################################

set -euo pipefail

# Cargar funciones comunes
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

################################################################################
# Búsqueda Interactiva
################################################################################

interactive_search() {
    echo ""
    if [[ "$CURRENT_LANG" == "es" ]]; then
        echo -e "${CYAN}═══ Búsqueda de Paquetes ═══${RESET}"
        echo ""
        read -p "Término de búsqueda: " search_term
    else
        echo -e "${CYAN}═══ Package Search ═══${RESET}"
        echo ""
        read -p "Search term: " search_term
    fi
    
    if [[ -z "$search_term" ]]; then
        print_warning "No search term provided"
        return 1
    fi
    
    echo ""
    print_info "Searching for: $search_term"
    echo ""
    
    # Buscar en APT
    search_apt "$search_term"
    
    # Buscar en Flatpak
    search_flatpak "$search_term"
    
    # Opciones adicionales
    echo ""
    if [[ "$CURRENT_LANG" == "es" ]]; then
        echo "Opciones:"
        echo "  1) Ver detalles de un paquete APT"
        echo "  2) Ver detalles de una aplicación Flatpak"
        echo "  0) Volver"
        echo ""
        read -p "Selecciona una opción (Enter para omitir): " choice
    else
        echo "Options:"
        echo "  1) View APT package details"
        echo "  2) View Flatpak app details"
        echo "  0) Back"
        echo ""
        read -p "Select an option (Enter to skip): " choice
    fi
    
    case "$choice" in
        1)
            if [[ "$CURRENT_LANG" == "es" ]]; then
                read -p "Nombre del paquete: " pkg_name
            else
                read -p "Package name: " pkg_name
            fi
            show_apt_details "$pkg_name"
            ;;
        2)
            if [[ "$CURRENT_LANG" == "es" ]]; then
                read -p "ID de la aplicación: " app_id
            else
                read -p "Application ID: " app_id
            fi
            show_flatpak_details "$app_id"
            ;;
    esac
}

################################################################################
# Búsqueda en APT
################################################################################

search_apt() {
    local search_term="$1"
    local max_results="${2:-15}"
    
    echo -e "${BLUE}━━━ APT Repositories ━━━${RESET}"
    echo ""
    
    if ! apt-cache search "$search_term" &> /dev/null; then
        print_warning "Error searching APT repositories"
        return 1
    fi
    
    local results=$(apt-cache search "$search_term" | head -n "$max_results")
    
    if [[ -z "$results" ]]; then
        if [[ "$CURRENT_LANG" == "es" ]]; then
            print_warning "No se encontraron paquetes en APT"
        else
            print_warning "No packages found in APT"
        fi
        return 0
    fi
    
    echo "$results" | while IFS= read -r line; do
        local package=$(echo "$line" | awk '{print $1}')
        local description=$(echo "$line" | cut -d' ' -f2-)
        
        # Verificar si está instalado
        if is_package_installed "$package"; then
            echo -e "  ${GREEN}✓${RESET} ${CYAN}$package${RESET} - $description"
        else
            echo -e "    ${CYAN}$package${RESET} - $description"
        fi
    done
    
    echo ""
}

show_apt_details() {
    local package="$1"
    
    echo ""
    echo -e "${CYAN}═══ Detalles del Paquete: $package ═══${RESET}"
    echo ""
    
    if is_package_installed "$package"; then
        print_success "Estado: INSTALADO"
    else
        print_info "Estado: No instalado"
    fi
    
    echo ""
    apt-cache show "$package" 2>/dev/null | head -n 20
    echo ""
    
    if [[ "$CURRENT_LANG" == "es" ]]; then
        if ask_yes_no "¿Instalar $package?"; then
            execute_command "sudo apt install -y $package"
        fi
    else
        if ask_yes_no "Install $package?"; then
            execute_command "sudo apt install -y $package"
        fi
    fi
}

################################################################################
# Búsqueda en Flatpak
################################################################################

search_flatpak() {
    local search_term="$1"
    local max_results="${2:-10}"
    
    if ! command -v flatpak &> /dev/null; then
        return 0
    fi
    
    echo -e "${BLUE}━━━ Flathub ━━━${RESET}"
    echo ""
    
    local results=$(flatpak search "$search_term" 2>/dev/null | head -n "$max_results")
    
    if [[ -z "$results" ]]; then
        if [[ "$CURRENT_LANG" == "es" ]]; then
            print_warning "No se encontraron aplicaciones en Flathub"
        else
            print_warning "No applications found in Flathub"
        fi
        return 0
    fi
    
    echo "$results" | tail -n +2 | while IFS=$'\t' read -r name desc app_id version branch; do
        # Verificar si está instalado
        if is_flatpak_installed "$app_id"; then
            echo -e "  ${GREEN}✓${RESET} ${CYAN}$name${RESET} ($app_id)"
        else
            echo -e "    ${CYAN}$name${RESET} ($app_id)"
        fi
        echo -e "      $desc"
        echo ""
    done
}

show_flatpak_details() {
    local app_id="$1"
    
    echo ""
    echo -e "${CYAN}═══ Detalles de Aplicación: $app_id ═══${RESET}"
    echo ""
    
    if is_flatpak_installed "$app_id"; then
        print_success "Estado: INSTALADO"
    else
        print_info "Estado: No instalado"
    fi
    
    echo ""
    flatpak info "$app_id" 2>/dev/null || flatpak search "$app_id" | grep "^$app_id"
    echo ""
    
    if [[ "$CURRENT_LANG" == "es" ]]; then
        if ask_yes_no "¿Instalar $app_id?"; then
            execute_command "flatpak install -y flathub $app_id"
        fi
    else
        if ask_yes_no "Install $app_id?"; then
            execute_command "flatpak install -y flathub $app_id"
        fi
    fi
}

################################################################################
# Búsqueda de Paquetes Populares por Categoría
################################################################################

show_popular_packages() {
    echo ""
    if [[ "$CURRENT_LANG" == "es" ]]; then
        echo -e "${CYAN}═══ Paquetes Populares por Categoría ═══${RESET}"
        echo ""
        echo "  1) Gaming"
        echo "  2) Desarrollo"
        echo "  3) Multimedia"
        echo "  4) Productividad"
        echo "  5) Internet"
        echo "  0) Volver"
        echo ""
        read -p "Selecciona categoría: " category
    else
        echo -e "${CYAN}═══ Popular Packages by Category ═══${RESET}"
        echo ""
        echo "  1) Gaming"
        echo "  2) Development"
        echo "  3) Multimedia"
        echo "  4) Productivity"
        echo "  5) Internet"
        echo "  0) Back"
        echo ""
        read -p "Select category: " category
    fi
    
    case "$category" in
        1)
            search_apt "steam lutris wine gamemode" 20
            ;;
        2)
            search_apt "git python3 nodejs docker vscode" 20
            ;;
        3)
            search_apt "vlc gimp obs kdenlive blender" 20
            ;;
        4)
            search_apt "libreoffice thunderbird timeshift" 20
            ;;
        5)
            search_apt "firefox chrome telegram discord" 20
            ;;
    esac
}

################################################################################
# Main
################################################################################

main() {
    interactive_search
}

# Si se ejecuta directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

