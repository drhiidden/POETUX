#!/bin/bash
################################################################################
# POET - Sistema de Instalación Inteligente
# Instalación por fases con rollback automático
################################################################################

set -euo pipefail

# Cargar funciones comunes
INSTALLER_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${INSTALLER_SCRIPT_DIR}/common.sh"

################################################################################
# Variables Globales de Instalación
################################################################################

# Listas de paquetes a instalar
declare -a APT_PACKAGES=()
declare -a FLATPAK_PACKAGES=()
declare -a PPA_REPOS=()
declare -a CUSTOM_COMMANDS=()

# Estado de instalación
INSTALLATION_STARTED=false
PRE_INSTALL_SNAPSHOT=""
INSTALL_FAILED=false

################################################################################
# Fase 1: STAGING - Preparar lo que se va a instalar
################################################################################

stage_apt_package() {
    local package="$1"
    local description="${2:-$package}"
    
    # Verificar si ya está instalado
    if is_package_installed "$package"; then
        log_info "Package $package already installed - skipping"
        return 0
    fi
    
    # Verificar si está disponible
    if ! apt-cache show "$package" &>/dev/null; then
        print_warning "Package $package not found in repositories"
        log_warning "Package not available: $package"
        return 1
    fi
    
    # Añadir a la lista de staging
    APT_PACKAGES+=("$package")
    log_info "Staged APT package: $package"
    
    return 0
}

stage_flatpak_package() {
    local app_id="$1"
    local description="${2:-$app_id}"
    
    # Verificar si ya está instalado
    if is_flatpak_installed "$app_id"; then
        log_info "Flatpak $app_id already installed - skipping"
        return 0
    fi
    
    # Añadir a la lista de staging
    FLATPAK_PACKAGES+=("$app_id")
    log_info "Staged Flatpak package: $app_id"
    
    return 0
}

stage_ppa() {
    local ppa="$1"
    
    # Verificar si ya está añadido
    if grep -q "$ppa" /etc/apt/sources.list.d/*.list 2>/dev/null; then
        log_info "PPA $ppa already added - skipping"
        return 0
    fi
    
    PPA_REPOS+=("$ppa")
    log_info "Staged PPA: $ppa"
    
    return 0
}

stage_custom_command() {
    local command="$1"
    local description="${2:-custom command}"
    
    CUSTOM_COMMANDS+=("$command")
    log_info "Staged custom command: $description"
    
    return 0
}

################################################################################
# Fase 2: PLANNING - Mostrar plan de instalación
################################################################################

show_installation_plan() {
    echo ""
    if [[ "$CURRENT_LANG" == "es" ]]; then
        echo -e "${CYAN}═══════════════════════════════════════════════════════════${RESET}"
        echo -e "${CYAN}  Plan de Instalación${RESET}"
        echo -e "${CYAN}═══════════════════════════════════════════════════════════${RESET}"
    else
        echo -e "${CYAN}═══════════════════════════════════════════════════════════${RESET}"
        echo -e "${CYAN}  Installation Plan${RESET}"
        echo -e "${CYAN}═══════════════════════════════════════════════════════════${RESET}"
    fi
    echo ""
    
    local total_items=0
    
    # PPAs
    if [[ ${#PPA_REPOS[@]} -gt 0 ]]; then
        echo -e "${BLUE}📦 PPAs to add (${#PPA_REPOS[@]}):${RESET}"
        for ppa in "${PPA_REPOS[@]}"; do
            echo "  • $ppa"
            ((total_items++))
        done
        echo ""
    fi
    
    # APT Packages
    if [[ ${#APT_PACKAGES[@]} -gt 0 ]]; then
        echo -e "${BLUE}📦 APT Packages (${#APT_PACKAGES[@]}):${RESET}"
        for pkg in "${APT_PACKAGES[@]}"; do
            echo "  • $pkg"
            ((total_items++))
        done
        echo ""
    fi
    
    # Flatpak Apps
    if [[ ${#FLATPAK_PACKAGES[@]} -gt 0 ]]; then
        echo -e "${BLUE}📦 Flatpak Apps (${#FLATPAK_PACKAGES[@]}):${RESET}"
        for app in "${FLATPAK_PACKAGES[@]}"; do
            echo "  • $app"
            ((total_items++))
        done
        echo ""
    fi
    
    # Custom Commands
    if [[ ${#CUSTOM_COMMANDS[@]} -gt 0 ]]; then
        echo -e "${BLUE}⚙️  Custom Commands (${#CUSTOM_COMMANDS[@]}):${RESET}"
        for cmd in "${CUSTOM_COMMANDS[@]}"; do
            echo "  • $cmd"
            ((total_items++))
        done
        echo ""
    fi
    
    if [[ $total_items -eq 0 ]]; then
        if [[ "$CURRENT_LANG" == "es" ]]; then
            print_info "No hay nada que instalar (todo ya está instalado)"
        else
            print_info "Nothing to install (everything already installed)"
        fi
        return 1
    fi
    
    echo -e "${GREEN}Total items: $total_items${RESET}"
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${RESET}"
    
    return 0
}

################################################################################
# Fase 3: INSTALLATION - Instalar con rollback automático
################################################################################

execute_installation() {
    local module_name="${1:-unknown}"
    
    # Mostrar plan
    if ! show_installation_plan; then
        return 0  # Nada que instalar
    fi
    
    # Confirmar con usuario
    echo ""
    if [[ "$CURRENT_LANG" == "es" ]]; then
        if ! ask_yes_no "¿Proceder con la instalación?" "s"; then
            print_info "Instalación cancelada por el usuario"
            return 0
        fi
    else
        if ! ask_yes_no "Proceed with installation?" "y"; then
            print_info "Installation cancelled by user"
            return 0
        fi
    fi
    
    # Crear snapshot de seguridad
    echo ""
    if [[ "$CURRENT_LANG" == "es" ]]; then
        print_info "Creando snapshot de seguridad antes de instalar..."
    else
        print_info "Creating safety snapshot before installation..."
    fi
    
    PRE_INSTALL_SNAPSHOT=$(create_backup_snapshot "pre_${module_name}_$(date +%Y%m%d_%H%M%S)")
    INSTALLATION_STARTED=true
    
    # Calcular total de tareas
    local total_tasks=$((${#PPA_REPOS[@]} + ${#APT_PACKAGES[@]} + ${#FLATPAK_PACKAGES[@]} + ${#CUSTOM_COMMANDS[@]}))
    local current_task=0
    
    echo ""
    if [[ "$CURRENT_LANG" == "es" ]]; then
        print_info "Iniciando instalación..."
    else
        print_info "Starting installation..."
    fi
    echo ""
    
    # Instalar PPAs
    if [[ ${#PPA_REPOS[@]} -gt 0 ]]; then
        for ppa in "${PPA_REPOS[@]}"; do
            ((current_task++))
            show_progress $current_task $total_tasks "Adding PPAs"
            
            if ! execute_command "sudo add-apt-repository -y $ppa"; then
                handle_installation_failure "Failed to add PPA: $ppa"
                return 1
            fi
        done
        
        # Update after adding PPAs
        if ! execute_command "sudo apt update"; then
            handle_installation_failure "Failed to update after adding PPAs"
            return 1
        fi
    fi
    
    # Instalar paquetes APT en BATCH (todos juntos)
    if [[ ${#APT_PACKAGES[@]} -gt 0 ]]; then
        ((current_task++))
        show_progress $current_task $total_tasks "Installing APT packages"
        
        # Instalar TODOS los paquetes en un solo comando
        local apt_cmd="sudo apt install -y ${APT_PACKAGES[*]}"
        
        if ! execute_command "$apt_cmd"; then
            handle_installation_failure "Failed to install APT packages"
            return 1
        fi
        
        # Actualizar progreso por cada paquete instalado
        for pkg in "${APT_PACKAGES[@]}"; do
            ((current_task++))
            show_progress $current_task $total_tasks "Installed: $pkg"
        done
    fi
    
    # Instalar Flatpaks (uno por uno con progreso)
    if [[ ${#FLATPAK_PACKAGES[@]} -gt 0 ]]; then
        for app in "${FLATPAK_PACKAGES[@]}"; do
            ((current_task++))
            show_progress $current_task $total_tasks "Installing: $app"
            
            if ! execute_command "flatpak install -y flathub $app"; then
                print_warning "Failed to install Flatpak: $app (continuing...)"
                log_warning "Flatpak installation failed: $app"
            fi
        done
    fi
    
    # Ejecutar comandos personalizados
    if [[ ${#CUSTOM_COMMANDS[@]} -gt 0 ]]; then
        for cmd in "${CUSTOM_COMMANDS[@]}"; do
            ((current_task++))
            show_progress $current_task $total_tasks "Executing custom command"
            
            if ! execute_command "$cmd"; then
                print_warning "Custom command failed: $cmd"
                log_warning "Custom command failed: $cmd"
            fi
        done
    fi
    
    echo ""
    print_success "Installation completed successfully!"
    
    # Limpiar estado
    clear_staging
    INSTALLATION_STARTED=false
    
    return 0
}

################################################################################
# Manejo de Fallos y Rollback Automático
################################################################################

handle_installation_failure() {
    local error_message="$1"
    
    INSTALL_FAILED=true
    
    echo ""
    print_error "$error_message"
    echo ""
    
    if [[ "$CURRENT_LANG" == "es" ]]; then
        print_warning "⚠️  La instalación ha fallado"
        echo ""
        echo "Opciones:"
        echo "  1) Restaurar desde snapshot (revertir cambios)"
        echo "  2) Continuar de todos modos (no recomendado)"
        echo "  3) Ver detalles del error en logs"
        echo ""
        read -p "Selecciona una opción [1]: " choice
    else
        print_warning "⚠️  Installation has failed"
        echo ""
        echo "Options:"
        echo "  1) Restore from snapshot (revert changes)"
        echo "  2) Continue anyway (not recommended)"
        echo "  3) View error details in logs"
        echo ""
        read -p "Select an option [1]: " choice
    fi
    
    choice="${choice:-1}"
    
    case "$choice" in
        1)
            restore_from_failure
            ;;
        2)
            if [[ "$CURRENT_LANG" == "es" ]]; then
                print_warning "Continuando sin restaurar..."
            else
                print_warning "Continuing without restore..."
            fi
            ;;
        3)
            tail -n 50 "$log_file"
            echo ""
            read -p "$(t 'msg.press_enter')"
            handle_installation_failure "$error_message"
            ;;
    esac
}

restore_from_failure() {
    if [[ -z "$PRE_INSTALL_SNAPSHOT" ]]; then
        print_error "No snapshot available for restore"
        return 1
    fi
    
    echo ""
    if [[ "$CURRENT_LANG" == "es" ]]; then
        print_info "Intentando restaurar paquetes desde snapshot..."
        echo ""
        print_warning "⚠️  Nota: La restauración automática está limitada"
        echo "Solo se pueden desinstalar paquetes que se instalaron en esta sesión"
        echo ""
    else
        print_info "Attempting to restore packages from snapshot..."
        echo ""
        print_warning "⚠️  Note: Automatic restore is limited"
        echo "Can only remove packages installed in this session"
        echo ""
    fi
    
    # Intentar desinstalar paquetes APT que se instalaron
    if [[ ${#APT_PACKAGES[@]} -gt 0 ]]; then
        for pkg in "${APT_PACKAGES[@]}"; do
            if is_package_installed "$pkg"; then
                print_info "Removing: $pkg"
                sudo apt remove -y "$pkg" 2>/dev/null || true
            fi
        done
    fi
    
    # Intentar desinstalar Flatpaks que se instalaron
    if [[ ${#FLATPAK_PACKAGES[@]} -gt 0 ]]; then
        for app in "${FLATPAK_PACKAGES[@]}"; do
            if is_flatpak_installed "$app"; then
                print_info "Removing: $app"
                flatpak uninstall -y "$app" 2>/dev/null || true
            fi
        done
    fi
    
    print_success "Restore attempt completed"
    print_info "Snapshot kept at: $PRE_INSTALL_SNAPSHOT"
}

################################################################################
# Utilidades
################################################################################

clear_staging() {
    APT_PACKAGES=()
    FLATPAK_PACKAGES=()
    PPA_REPOS=()
    CUSTOM_COMMANDS=()
}

get_staged_count() {
    echo $((${#APT_PACKAGES[@]} + ${#FLATPAK_PACKAGES[@]} + ${#PPA_REPOS[@]} + ${#CUSTOM_COMMANDS[@]}))
}

################################################################################
# Exportar funciones
################################################################################

export -f stage_apt_package
export -f stage_flatpak_package
export -f stage_ppa
export -f stage_custom_command
export -f show_installation_plan
export -f execute_installation
export -f clear_staging
export -f get_staged_count

