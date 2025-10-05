#!/bin/bash
################################################################################
# POET - Biblioteca de Funciones Comunes
# Funciones compartidas entre todos los módulos
################################################################################

# Include guard para evitar carga múltiple
[[ -n "${POETUX_COMMON_LOADED:-}" ]] && return 0
readonly POETUX_COMMON_LOADED=1

set -euo pipefail

# Colores para output
readonly RED='\e[31m'
readonly GREEN='\e[32m'
readonly YELLOW='\e[33m'
readonly BLUE='\e[34m'
readonly MAGENTA='\e[35m'
readonly CYAN='\e[36m'
readonly RESET='\e[0m'

# Directorio de datos de POETUX
readonly POETUX_DATA_DIR="${HOME}/.local/share/poetux"
readonly POETUX_BACKUP_DIR="${POETUX_DATA_DIR}/backups"
readonly POETUX_LOG_DIR="${POETUX_DATA_DIR}/logs"
readonly POETUX_LANG_FILE="${POETUX_DATA_DIR}/lang"

# Crear directorios si no existen
mkdir -p "$POETUX_DATA_DIR" "$POETUX_BACKUP_DIR" "$POETUX_LOG_DIR"

################################################################################
# Funciones de Logging
################################################################################

log_file="${POETUX_LOG_DIR}/poetux_$(date +%Y%m%d_%H%M%S).log"

log_message() {
    local level="$1"
    shift
    local message="$*"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" >> "$log_file"
}

log_info() {
    log_message "INFO" "$@"
}

log_error() {
    log_message "ERROR" "$@"
}

log_warning() {
    log_message "WARNING" "$@"
}

################################################################################
# Sistema de Internacionalización (i18n)
################################################################################

# Detectar idioma del sistema o usar el guardado
detect_language() {
    if [[ -f "$POETUX_LANG_FILE" ]]; then
        cat "$POETUX_LANG_FILE"
    else
        # Detectar del sistema
        local sys_lang="${LANG:-en_US.UTF-8}"
        if [[ "$sys_lang" == es_* ]]; then
            echo "es"
        else
            echo "en"
        fi
    fi
}

# Guardar preferencia de idioma
save_language() {
    local lang="$1"
    echo "$lang" > "$POETUX_LANG_FILE"
    log_info "Language set to: $lang"
}

# Cargar idioma actual
CURRENT_LANG=$(detect_language)

# Función de traducción
t() {
    local key="$1"
    
    case "$CURRENT_LANG" in
        es)
            case "$key" in
                "menu.title") echo "Menú Principal" ;;
                "menu.basic") echo "Configuración Básica (actualizar sistema, flatpak, utilidades)" ;;
                "menu.gaming") echo "Gaming (Steam, Lutris, Proton, MangoHUD, Gamemode)" ;;
                "menu.dev") echo "Desarrollo (Git, Python, Node.js, Rust, Docker, VSCode)" ;;
                "menu.creators") echo "Creadores de Contenido (OBS, GIMP, Krita, Kdenlive, Blender)" ;;
                "menu.streamers") echo "Streamers (OBS + plugins, Discord, herramientas de audio)" ;;
                "menu.all") echo "Ejecutar todos los módulos" ;;
                "menu.info") echo "Información del sistema" ;;
                "menu.backup") echo "Backup y Restauración" ;;
                "menu.search") echo "Buscar paquetes" ;;
                "menu.exit") echo "Salir" ;;
                "prompt.select") echo "Selecciona una opción: " ;;
                "msg.welcome") echo "Bienvenido a POET - Pop!_OS Extended Toolkit" ;;
                "msg.description") echo "Este toolkit te ayudará a configurar tu sistema Pop!_OS" ;;
                "msg.thanks") echo "¡Gracias por usar POET! 🚀" ;;
                "msg.invalid_option") echo "Opción no válida. Por favor, selecciona una opción del menú." ;;
                "msg.press_enter") echo "Presiona Enter para continuar..." ;;
                "error.no_root") echo "No ejecutes este script como root. Usará sudo cuando sea necesario." ;;
                "error.modules_not_found") echo "No se encuentra el directorio de módulos:" ;;
                "error.module_not_found") echo "Módulo no encontrado:" ;;
                "info.loading_module") echo "Ejecutando módulo:" ;;
                "success.module_completed") echo "Módulo completado exitosamente" ;;
                "warning.module_fixing") echo "El módulo no tiene permisos de ejecución. Aplicándolos..." ;;
                # Preguntas de instalación
                "ask.install_steam") echo "¿Instalar Steam?" ;;
                "ask.install_lutris") echo "¿Instalar Lutris?" ;;
                "ask.install_gamemode") echo "¿Instalar GameMode?" ;;
                "ask.install_mangohud") echo "¿Instalar MangoHUD?" ;;
                "ask.install_heroic") echo "¿Instalar Heroic Games Launcher?" ;;
                "ask.install_protonup") echo "¿Instalar ProtonUp-Qt?" ;;
                "ask.install_wine") echo "¿Instalar Wine?" ;;
                "ask.gaming_tweaks") echo "¿Aplicar optimizaciones de gaming?" ;;
                "ask.install_python") echo "¿Instalar Python y herramientas?" ;;
                "ask.install_python_tools") echo "¿Instalar pipenv y poetry?" ;;
                "ask.install_nodejs") echo "¿Instalar Node.js?" ;;
                "ask.install_yarn_pnpm") echo "¿Instalar yarn y pnpm?" ;;
                "ask.install_rust") echo "¿Instalar Rust?" ;;
                "ask.install_docker") echo "¿Instalar Docker?" ;;
                "ask.install_vscode") echo "¿Instalar Visual Studio Code?" ;;
                "ask.install_other_editors") echo "¿Instalar otros editores?" ;;
                "ask.install_neovim") echo "¿Instalar Neovim?" ;;
                "ask.install_intellij") echo "¿Instalar IntelliJ IDEA Community?" ;;
                "ask.install_obs") echo "¿Instalar OBS Studio?" ;;
                "ask.install_gimp") echo "¿Instalar GIMP?" ;;
                "ask.install_krita") echo "¿Instalar Krita?" ;;
                "ask.install_inkscape") echo "¿Instalar Inkscape?" ;;
                "ask.install_kdenlive") echo "¿Instalar Kdenlive?" ;;
                "ask.install_blender") echo "¿Instalar Blender?" ;;
                "ask.install_audacity") echo "¿Instalar Audacity?" ;;
                "ask.davinci_deps") echo "¿Instalar dependencias para DaVinci Resolve?" ;;
                "ask.install_v4l2") echo "¿Instalar v4l2loopback (cámara virtual)?" ;;
                "ask.install_discord") echo "¿Instalar Discord?" ;;
                "ask.audio_tools") echo "¿Instalar herramientas de audio?" ;;
                "ask.install_pipewire") echo "¿Cambiar a PipeWire?" ;;
                "ask.install_easyeffects") echo "¿Instalar EasyEffects?" ;;
                "ask.install_ytdlp") echo "¿Instalar yt-dlp?" ;;
                "ask.audio_priority") echo "¿Configurar prioridad de audio?" ;;
                "msg.system_updated") echo "Sistema actualizado" ;;
                *) echo "$key" ;;
            esac
            ;;
        en)
            case "$key" in
                "menu.title") echo "Main Menu" ;;
                "menu.basic") echo "Basic Setup (update system, flatpak, utilities)" ;;
                "menu.gaming") echo "Gaming (Steam, Lutris, Proton, MangoHUD, Gamemode)" ;;
                "menu.dev") echo "Development (Git, Python, Node.js, Rust, Docker, VSCode)" ;;
                "menu.creators") echo "Content Creators (OBS, GIMP, Krita, Kdenlive, Blender)" ;;
                "menu.streamers") echo "Streamers (OBS + plugins, Discord, audio tools)" ;;
                "menu.all") echo "Run all modules" ;;
                "menu.info") echo "System information" ;;
                "menu.backup") echo "Backup and Restore" ;;
                "menu.search") echo "Search packages" ;;
                "menu.exit") echo "Exit" ;;
                "prompt.select") echo "Select an option: " ;;
                "msg.welcome") echo "Welcome to POET - Pop!_OS Extended Toolkit" ;;
                "msg.description") echo "This toolkit will help you configure your Pop!_OS system" ;;
                "msg.thanks") echo "Thanks for using POET! 🚀" ;;
                "msg.invalid_option") echo "Invalid option. Please select an option from the menu." ;;
                "msg.press_enter") echo "Press Enter to continue..." ;;
                "error.no_root") echo "Don't run this script as root. It will use sudo when needed." ;;
                "error.modules_not_found") echo "Modules directory not found:" ;;
                "error.module_not_found") echo "Module not found:" ;;
                "info.loading_module") echo "Running module:" ;;
                "success.module_completed") echo "Module completed successfully" ;;
                "warning.module_fixing") echo "Module doesn't have execution permissions. Applying them..." ;;
                # Installation questions
                "ask.install_steam") echo "Install Steam?" ;;
                "ask.install_lutris") echo "Install Lutris?" ;;
                "ask.install_gamemode") echo "Install GameMode?" ;;
                "ask.install_mangohud") echo "Install MangoHUD?" ;;
                "ask.install_heroic") echo "Install Heroic Games Launcher?" ;;
                "ask.install_protonup") echo "Install ProtonUp-Qt?" ;;
                "ask.install_wine") echo "Install Wine?" ;;
                "ask.gaming_tweaks") echo "Apply gaming optimizations?" ;;
                "ask.install_python") echo "Install Python and tools?" ;;
                "ask.install_python_tools") echo "Install pipenv and poetry?" ;;
                "ask.install_nodejs") echo "Install Node.js?" ;;
                "ask.install_yarn_pnpm") echo "Install yarn and pnpm?" ;;
                "ask.install_rust") echo "Install Rust?" ;;
                "ask.install_docker") echo "Install Docker?" ;;
                "ask.install_vscode") echo "Install Visual Studio Code?" ;;
                "ask.install_other_editors") echo "Install other editors?" ;;
                "ask.install_neovim") echo "Install Neovim?" ;;
                "ask.install_intellij") echo "Install IntelliJ IDEA Community?" ;;
                "ask.install_obs") echo "Install OBS Studio?" ;;
                "ask.install_gimp") echo "Install GIMP?" ;;
                "ask.install_krita") echo "Install Krita?" ;;
                "ask.install_inkscape") echo "Install Inkscape?" ;;
                "ask.install_kdenlive") echo "Install Kdenlive?" ;;
                "ask.install_blender") echo "Install Blender?" ;;
                "ask.install_audacity") echo "Install Audacity?" ;;
                "ask.davinci_deps") echo "Install DaVinci Resolve dependencies?" ;;
                "ask.install_v4l2") echo "Install v4l2loopback (virtual camera)?" ;;
                "ask.install_discord") echo "Install Discord?" ;;
                "ask.audio_tools") echo "Install audio tools?" ;;
                "ask.install_pipewire") echo "Switch to PipeWire?" ;;
                "ask.install_easyeffects") echo "Install EasyEffects?" ;;
                "ask.install_ytdlp") echo "Install yt-dlp?" ;;
                "ask.audio_priority") echo "Configure audio priority?" ;;
                "msg.system_updated") echo "System updated" ;;
                *) echo "$key" ;;
            esac
            ;;
    esac
}

################################################################################
# Funciones de Output
################################################################################

print_success() {
    echo -e "${GREEN}✓ $1${RESET}"
    log_info "SUCCESS: $1"
}

print_error() {
    echo -e "${RED}✗ Error: $1${RESET}" >&2
    log_error "$1"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${RESET}"
    log_warning "$1"
}

print_info() {
    echo -e "${BLUE}ℹ $1${RESET}"
    log_info "$1"
}

################################################################################
# Progress Bar
################################################################################

show_progress() {
    local current="$1"
    local total="$2"
    local task_name="${3:-Processing}"
    
    local percentage=$((current * 100 / total))
    local completed=$((percentage / 2))
    local remaining=$((50 - completed))
    
    printf "\r${CYAN}%s${RESET} [" "$task_name"
    printf "%${completed}s" | tr ' ' '█'
    printf "%${remaining}s" | tr ' ' '░'
    printf "] %d%%" "$percentage"
    
    if [[ $current -eq $total ]]; then
        echo ""
    fi
}

################################################################################
# Preguntas al Usuario
################################################################################

ask_yes_no() {
    local prompt="$1"
    local default="${2:-n}"
    local response
    
    while true; do
        if [[ "$CURRENT_LANG" == "es" ]]; then
            read -p "$prompt (s/n) [${default}]: " response
        else
            read -p "$prompt (y/n) [${default}]: " response
        fi
        
        response="${response:-$default}"
        
        if [[ "$CURRENT_LANG" == "es" ]]; then
            case $response in
                [Ss]* ) log_info "User confirmed: $prompt"; return 0;;
                [Nn]* ) log_info "User declined: $prompt"; return 1;;
                * ) echo "Por favor responde s (sí) o n (no).";;
            esac
        else
            case $response in
                [Yy]* ) log_info "User confirmed: $prompt"; return 0;;
                [Nn]* ) log_info "User declined: $prompt"; return 1;;
                * ) echo "Please answer y (yes) or n (no).";;
            esac
        fi
    done
}

################################################################################
# Verificación de Paquetes
################################################################################

is_package_installed() {
    local package="$1"
    dpkg -l | grep -q "^ii.*$package" 2>/dev/null
}

is_flatpak_installed() {
    local package="$1"
    flatpak list | grep -q "$package" 2>/dev/null
}

################################################################################
# Sistema de Backup/Rollback
################################################################################

create_backup_snapshot() {
    local snapshot_name="${1:-manual_$(date +%Y%m%d_%H%M%S)}"
    local snapshot_dir="${POETUX_BACKUP_DIR}/${snapshot_name}"
    
    mkdir -p "$snapshot_dir"
    
    print_info "Creating backup snapshot: $snapshot_name"
    
    # Guardar lista de paquetes instalados
    dpkg --get-selections > "${snapshot_dir}/dpkg_selections.txt"
    apt-mark showauto > "${snapshot_dir}/apt_auto.txt"
    apt-mark showmanual > "${snapshot_dir}/apt_manual.txt"
    
    # Guardar lista de Flatpaks
    if command -v flatpak &> /dev/null; then
        flatpak list --app --columns=application > "${snapshot_dir}/flatpak_list.txt"
    fi
    
    # Guardar información del sistema
    {
        echo "Hostname: $(hostname)"
        echo "Kernel: $(uname -r)"
        echo "OS: $(lsb_release -ds)"
        echo "Date: $(date)"
        echo "POETUX Version: 1.0.0"
    } > "${snapshot_dir}/system_info.txt"
    
    # Guardar lista de PPAs
    grep -r --include '*.list' '^deb ' /etc/apt/sources.list.d/ > "${snapshot_dir}/ppas.txt" 2>/dev/null || true
    
    print_success "Backup snapshot created: $snapshot_name"
    log_info "Backup snapshot created at: $snapshot_dir"
    
    echo "$snapshot_dir"
}

list_backup_snapshots() {
    if [[ ! -d "$POETUX_BACKUP_DIR" ]] || [[ -z "$(ls -A "$POETUX_BACKUP_DIR" 2>/dev/null)" ]]; then
        if [[ "$CURRENT_LANG" == "es" ]]; then
            print_warning "No hay snapshots de backup disponibles"
        else
            print_warning "No backup snapshots available"
        fi
        return 1
    fi
    
    echo ""
    print_info "Snapshots disponibles:"
    echo ""
    
    local i=1
    for snapshot in "$POETUX_BACKUP_DIR"/*; do
        if [[ -d "$snapshot" ]]; then
            local snapshot_name=$(basename "$snapshot")
            local snapshot_date=$(stat -c %y "$snapshot" 2>/dev/null | cut -d' ' -f1,2 | cut -d'.' -f1)
            echo "  $i) $snapshot_name - $snapshot_date"
            ((i++))
        fi
    done
    echo ""
}

show_backup_diff() {
    local snapshot_dir="$1"
    
    print_info "Comparing current system with snapshot..."
    echo ""
    
    # Comparar paquetes APT
    if [[ -f "${snapshot_dir}/dpkg_selections.txt" ]]; then
        local new_packages=$(comm -13 <(sort "${snapshot_dir}/dpkg_selections.txt") <(dpkg --get-selections | sort) | wc -l)
        local removed_packages=$(comm -23 <(sort "${snapshot_dir}/dpkg_selections.txt") <(dpkg --get-selections | sort) | wc -l)
        
        echo "APT Packages:"
        echo "  - New packages: $new_packages"
        echo "  - Removed packages: $removed_packages"
    fi
    
    # Comparar Flatpaks
    if [[ -f "${snapshot_dir}/flatpak_list.txt" ]] && command -v flatpak &> /dev/null; then
        local current_flatpaks=$(flatpak list --app --columns=application | wc -l)
        local snapshot_flatpaks=$(wc -l < "${snapshot_dir}/flatpak_list.txt")
        local diff_flatpaks=$((current_flatpaks - snapshot_flatpaks))
        
        echo "Flatpak Apps:"
        echo "  - Snapshot had: $snapshot_flatpaks"
        echo "  - Currently has: $current_flatpaks"
        echo "  - Difference: $diff_flatpaks"
    fi
    
    echo ""
}

################################################################################
# Búsqueda de Paquetes
################################################################################

search_packages() {
    local search_term="$1"
    
    print_info "Searching for: $search_term"
    echo ""
    
    # Buscar en repositorios APT
    print_info "APT Repositories:"
    apt-cache search "$search_term" | head -n 20
    echo ""
    
    # Buscar en Flatpak si está disponible
    if command -v flatpak &> /dev/null; then
        print_info "Flathub:"
        flatpak search "$search_term" | head -n 10
    fi
}

################################################################################
# Verificación de Integridad (SHA256)
################################################################################

verify_script_integrity() {
    local script_path="$1"
    
    # Esta función puede expandirse para verificar checksums
    # Por ahora, solo verifica que el script existe y es legible
    if [[ ! -f "$script_path" ]]; then
        print_error "Script not found: $script_path"
        return 1
    fi
    
    if [[ ! -r "$script_path" ]]; then
        print_error "Script not readable: $script_path"
        return 1
    fi
    
    return 0
}

################################################################################
# Dry Run Mode
################################################################################

DRY_RUN=false

set_dry_run() {
    DRY_RUN=true
    print_warning "DRY RUN MODE - No changes will be made"
    log_info "Dry run mode enabled"
}

execute_command() {
    local command="$*"
    
    if [[ "$DRY_RUN" == true ]]; then
        print_info "[DRY RUN] Would execute: $command"
        return 0
    else
        log_info "Executing: $command"
        eval "$command"
        return $?
    fi
}

################################################################################
# Exportar funciones
################################################################################

export -f print_success
export -f print_error
export -f print_warning
export -f print_info
export -f log_info
export -f log_error
export -f log_warning
export -f ask_yes_no
export -f is_package_installed
export -f is_flatpak_installed
export -f show_progress
export -f t
export -f execute_command

