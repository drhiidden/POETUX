#!/bin/bash
################################################################################
# POET - Sistema de Backup y Restauración
# Gestión de snapshots del sistema para rollback
################################################################################

set -euo pipefail

# Cargar funciones comunes
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

################################################################################
# Menú de Backup
################################################################################

show_backup_menu() {
    echo ""
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════${RESET}"
    if [[ "$CURRENT_LANG" == "es" ]]; then
        echo -e "${CYAN}  Sistema de Backup y Restauración${RESET}"
    else
        echo -e "${CYAN}  Backup and Restore System${RESET}"
    fi
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════${RESET}"
    echo ""
    
    if [[ "$CURRENT_LANG" == "es" ]]; then
        echo "  1) Crear snapshot de backup"
        echo "  2) Listar snapshots existentes"
        echo "  3) Ver diferencias con snapshot"
        echo "  4) Exportar lista de paquetes actual"
        echo "  5) Limpiar snapshots antiguos"
        echo "  0) Volver al menú principal"
    else
        echo "  1) Create backup snapshot"
        echo "  2) List existing snapshots"
        echo "  3) View differences with snapshot"
        echo "  4) Export current package list"
        echo "  5) Clean old snapshots"
        echo "  0) Back to main menu"
    fi
    
    echo ""
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════${RESET}"
    if [[ "$CURRENT_LANG" == "es" ]]; then
        echo -n "Selecciona una opción: "
    else
        echo -n "Select an option: "
    fi
}

################################################################################
# Crear Snapshot Interactivo
################################################################################

interactive_create_snapshot() {
    echo ""
    if [[ "$CURRENT_LANG" == "es" ]]; then
        print_info "═══ Crear Snapshot de Backup ═══"
        echo ""
        read -p "Nombre del snapshot (Enter para auto): " snapshot_name
    else
        print_info "═══ Create Backup Snapshot ═══"
        echo ""
        read -p "Snapshot name (Enter for auto): " snapshot_name
    fi
    
    if [[ -z "$snapshot_name" ]]; then
        snapshot_name="auto_$(date +%Y%m%d_%H%M%S)"
    else
        # Sanitizar nombre
        snapshot_name=$(echo "$snapshot_name" | tr ' ' '_' | tr -cd '[:alnum:]_-')
    fi
    
    create_backup_snapshot "$snapshot_name"
    
    echo ""
    if [[ "$CURRENT_LANG" == "es" ]]; then
        print_success "Snapshot creado exitosamente"
        echo ""
        echo "📁 Ubicación: ${POETUX_BACKUP_DIR}/${snapshot_name}"
        echo ""
        print_info "Este snapshot contiene:"
        echo "  • Lista de paquetes APT instalados"
        echo "  • Lista de aplicaciones Flatpak"
        echo "  • PPAs configurados"
        echo "  • Información del sistema"
    else
        print_success "Snapshot created successfully"
        echo ""
        echo "📁 Location: ${POETUX_BACKUP_DIR}/${snapshot_name}"
        echo ""
        print_info "This snapshot contains:"
        echo "  • List of installed APT packages"
        echo "  • List of Flatpak applications"
        echo "  • Configured PPAs"
        echo "  • System information"
    fi
}

################################################################################
# Ver Diferencias
################################################################################

interactive_show_diff() {
    list_backup_snapshots
    
    if [[ "$CURRENT_LANG" == "es" ]]; then
        read -p "Número de snapshot para comparar (0 para cancelar): " choice
    else
        read -p "Snapshot number to compare (0 to cancel): " choice
    fi
    
    if [[ "$choice" == "0" ]] || [[ -z "$choice" ]]; then
        return
    fi
    
    local snapshots=("$POETUX_BACKUP_DIR"/*)
    local index=$((choice - 1))
    
    if [[ $index -ge 0 ]] && [[ $index -lt ${#snapshots[@]} ]]; then
        local snapshot_dir="${snapshots[$index]}"
        show_backup_diff "$snapshot_dir"
    else
        print_error "Invalid selection"
    fi
}

################################################################################
# Exportar Lista de Paquetes
################################################################################

export_package_list() {
    local export_file="${HOME}/poetux_packages_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "# POETUX Package Export"
        echo "# Generated: $(date)"
        echo "# Hostname: $(hostname)"
        echo ""
        echo "## APT Packages (installed)"
        dpkg --get-selections | grep -v deinstall | awk '{print $1}'
        echo ""
        echo "## Flatpak Applications"
        if command -v flatpak &> /dev/null; then
            flatpak list --app --columns=application
        fi
    } > "$export_file"
    
    print_success "Package list exported to: $export_file"
}

################################################################################
# Limpiar Snapshots Antiguos
################################################################################

clean_old_snapshots() {
    if [[ "$CURRENT_LANG" == "es" ]]; then
        echo ""
        print_info "Snapshots disponibles:"
        echo ""
        
        local count=0
        for snapshot in "$POETUX_BACKUP_DIR"/*; do
            if [[ -d "$snapshot" ]]; then
                local snapshot_name=$(basename "$snapshot")
                local snapshot_date=$(stat -c %y "$snapshot" 2>/dev/null | cut -d' ' -f1)
                local snapshot_size=$(du -sh "$snapshot" 2>/dev/null | cut -f1)
                echo "  • $snapshot_name ($snapshot_date) - $snapshot_size"
                ((count++))
            fi
        done
        
        echo ""
        echo "Total snapshots: $count"
        echo ""
        
        if ask_yes_no "¿Mantener solo los últimos 5 snapshots?"; then
            # Mantener solo los 5 más recientes
            ls -t "$POETUX_BACKUP_DIR" | tail -n +6 | while read -r old_snapshot; do
                rm -rf "${POETUX_BACKUP_DIR}/${old_snapshot}"
                print_info "Eliminado: $old_snapshot"
            done
            print_success "Limpieza completada"
        fi
    else
        echo ""
        print_info "Available snapshots:"
        echo ""
        
        local count=0
        for snapshot in "$POETUX_BACKUP_DIR"/*; do
            if [[ -d "$snapshot" ]]; then
                local snapshot_name=$(basename "$snapshot")
                local snapshot_date=$(stat -c %y "$snapshot" 2>/dev/null | cut -d' ' -f1)
                local snapshot_size=$(du -sh "$snapshot" 2>/dev/null | cut -f1)
                echo "  • $snapshot_name ($snapshot_date) - $snapshot_size"
                ((count++))
            fi
        done
        
        echo ""
        echo "Total snapshots: $count"
        echo ""
        
        if ask_yes_no "Keep only the last 5 snapshots?"; then
            # Keep only 5 most recent
            ls -t "$POETUX_BACKUP_DIR" | tail -n +6 | while read -r old_snapshot; do
                rm -rf "${POETUX_BACKUP_DIR}/${old_snapshot}"
                print_info "Removed: $old_snapshot"
            done
            print_success "Cleanup completed"
        fi
    fi
}

################################################################################
# Main
################################################################################

main() {
    while true; do
        show_backup_menu
        read -r option
        
        case $option in
            1)
                interactive_create_snapshot
                ;;
            2)
                list_backup_snapshots
                ;;
            3)
                interactive_show_diff
                ;;
            4)
                export_package_list
                ;;
            5)
                clean_old_snapshots
                ;;
            0)
                return 0
                ;;
            *)
                print_error "$(t 'msg.invalid_option')"
                ;;
        esac
        
        echo ""
        read -p "$(t 'msg.press_enter')"
    done
}

# Si se ejecuta directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

