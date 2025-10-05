#!/bin/bash
################################################################################
# POET - Módulo de Seguridad
# Fortificación integral del sistema Pop!_OS
# Versión: 1.0.0
################################################################################

set -euo pipefail

# Cargar bibliotecas
SECURITY_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SECURITY_SCRIPT_DIR}/../lib/common.sh"
source "${SECURITY_SCRIPT_DIR}/../lib/installer.sh"

################################################################################
# Variables de Configuración
################################################################################

readonly SECURITY_LOG="/var/log/secure_popos.log"
readonly AIDE_CONFIG="/etc/aide/aide.conf"
readonly FIREJAIL_ALIASES="${HOME}/.bash_aliases"

################################################################################
# Funciones de Logging de Seguridad
################################################################################

log_security() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Log a archivo (requiere sudo)
    echo "[$timestamp] [$level] $message" | sudo tee -a "$SECURITY_LOG" >/dev/null
    
    # Log a terminal
    case "$level" in
        INFO)
            print_info "$message"
            ;;
        SUCCESS)
            print_success "$message"
            ;;
        WARNING)
            print_warning "$message"
            ;;
        ERROR)
            print_error "$message"
            ;;
    esac
}

################################################################################
# === SECCIÓN 1: UFW (Uncomplicated Firewall) ===
################################################################################

configure_ufw() {
    echo ""
    print_info "═══════════════════════════════════════════════════════════"
    print_info "  Configurando Firewall (UFW)"
    print_info "═══════════════════════════════════════════════════════════"
    echo ""
    
    # Verificar si ufw está instalado
    if ! command -v ufw &> /dev/null; then
        log_security INFO "Instalando UFW..."
        if sudo apt install -y ufw; then
            log_security SUCCESS "UFW instalado correctamente"
        else
            log_security ERROR "Fallo al instalar UFW"
            return 1
        fi
    else
        log_security INFO "UFW ya está instalado"
    fi
    
    # Configurar políticas por defecto
    log_security INFO "Configurando políticas por defecto..."
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    
    # Permitir SSH (si está instalado)
    if systemctl is-active --quiet ssh 2>/dev/null || systemctl is-active --quiet sshd 2>/dev/null; then
        log_security INFO "SSH detectado, permitiendo puerto 22..."
        sudo ufw allow 22/tcp comment "SSH"
    fi
    
    # Habilitar UFW si no está activo
    if ! sudo ufw status | grep -q "Status: active"; then
        log_security INFO "Activando UFW..."
        sudo ufw --force enable
        log_security SUCCESS "UFW activado correctamente"
    else
        log_security INFO "UFW ya está activo"
    fi
    
    # Mostrar estado
    echo ""
    sudo ufw status verbose
    echo ""
}

################################################################################
# === SECCIÓN 2: AppArmor ===
################################################################################

harden_apparmor() {
    echo ""
    print_info "═══════════════════════════════════════════════════════════"
    print_info "  Fortaleciendo AppArmor"
    print_info "═══════════════════════════════════════════════════════════"
    echo ""
    
    # Verificar que AppArmor esté activo
    if ! systemctl is-active --quiet apparmor; then
        log_security WARNING "AppArmor no está activo, intentando iniciar..."
        sudo systemctl start apparmor
        sudo systemctl enable apparmor
    fi
    
    # Instalar perfiles adicionales
    log_security INFO "Instalando perfiles adicionales de AppArmor..."
    sudo apt install -y apparmor-profiles apparmor-utils
    
    # Aplicar perfiles en modo enforce
    log_security INFO "Aplicando perfiles en modo enforce..."
    
    # Obtener lista de perfiles
    local profiles=$(sudo aa-status --profiled 2>/dev/null | grep -v "^profiles" | wc -l || echo "0")
    
    if [ "$profiles" -gt 0 ]; then
        # Poner perfiles en modo enforce (uno por uno para evitar errores)
        for profile in /etc/apparmor.d/*; do
            if [ -f "$profile" ] && [ ! -L "$profile" ]; then
                local profile_name=$(basename "$profile")
                # Saltar ciertos archivos
                [[ "$profile_name" =~ ^(abstractions|tunables|local|README) ]] && continue
                
                sudo aa-enforce "$profile" 2>/dev/null || true
            fi
        done
        log_security SUCCESS "Perfiles de AppArmor en modo enforce"
    fi
    
    # Mostrar estado
    echo ""
    sudo aa-status --verbose 2>/dev/null | head -20
    echo ""
}

################################################################################
# === SECCIÓN 3: AIDE (Advanced Intrusion Detection Environment) ===
################################################################################

setup_aide() {
    echo ""
    print_info "═══════════════════════════════════════════════════════════"
    print_info "  Configurando AIDE (Detección de Intrusiones)"
    print_info "═══════════════════════════════════════════════════════════"
    echo ""
    
    # Instalar AIDE
    if ! command -v aide &> /dev/null; then
        log_security INFO "Instalando AIDE..."
        sudo apt install -y aide aide-common
        log_security SUCCESS "AIDE instalado"
    else
        log_security INFO "AIDE ya está instalado"
    fi
    
    # Inicializar base de datos si no existe
    if [ ! -f /var/lib/aide/aide.db ]; then
        log_security INFO "Inicializando base de datos AIDE (puede tardar varios minutos)..."
        print_warning "Esto puede tardar 5-10 minutos dependiendo del tamaño del sistema..."
        
        if ask_yes_no "¿Deseas inicializar AIDE ahora? (Recomendado)"; then
            sudo aideinit
            
            # Copiar la base de datos
            if [ -f /var/lib/aide/aide.db.new ]; then
                sudo mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
                log_security SUCCESS "Base de datos AIDE inicializada"
            fi
        else
            log_security WARNING "AIDE no inicializado. Ejecuta 'sudo aideinit' manualmente"
        fi
    else
        log_security INFO "Base de datos AIDE ya existe"
    fi
    
    # Configurar cron para chequeos semanales
    local cron_file="/etc/cron.weekly/aide-check"
    if [ ! -f "$cron_file" ]; then
        log_security INFO "Configurando chequeo semanal automático..."
        
        sudo tee "$cron_file" > /dev/null << 'EOF'
#!/bin/bash
# AIDE weekly check
/usr/bin/aide --check | mail -s "AIDE Report - $(hostname)" root
EOF
        
        sudo chmod +x "$cron_file"
        log_security SUCCESS "Chequeo semanal configurado"
    else
        log_security INFO "Chequeo semanal ya configurado"
    fi
}

################################################################################
# === SECCIÓN 4: Firejail (Sandboxing) ===
################################################################################

setup_firejail() {
    echo ""
    print_info "═══════════════════════════════════════════════════════════"
    print_info "  Configurando Firejail (Sandboxing)"
    print_info "═══════════════════════════════════════════════════════════"
    echo ""
    
    # Instalar Firejail
    if ! command -v firejail &> /dev/null; then
        log_security INFO "Instalando Firejail..."
        sudo apt install -y firejail firejail-profiles
        log_security SUCCESS "Firejail instalado"
    else
        log_security INFO "Firejail ya está instalado"
    fi
    
    # Crear aliases seguros
    log_security INFO "Configurando aliases seguros para aplicaciones..."
    
    # Backup del archivo de aliases si existe
    if [ -f "$FIREJAIL_ALIASES" ]; then
        cp "$FIREJAIL_ALIASES" "${FIREJAIL_ALIASES}.backup"
    fi
    
    # Aplicaciones comunes para sandbox
    local apps=(
        "firefox"
        "chromium-browser"
        "google-chrome"
        "cursor"
        "code"
        "thunderbird"
        "transmission-gtk"
        "vlc"
    )
    
    # Crear aliases solo para apps instaladas
    for app in "${apps[@]}"; do
        if command -v "$app" &> /dev/null; then
            # Verificar si ya existe el alias
            if ! grep -q "alias $app='firejail $app'" "$FIREJAIL_ALIASES" 2>/dev/null; then
                echo "alias $app='firejail $app'" >> "$FIREJAIL_ALIASES"
                log_security INFO "Alias creado para $app"
            fi
        fi
    done
    
    log_security SUCCESS "Aliases de Firejail configurados en $FIREJAIL_ALIASES"
    print_info "Ejecuta 'source ~/.bash_aliases' para activar los aliases"
}

################################################################################
# === SECCIÓN 5: Herramientas Adicionales Opcionales ===
################################################################################

install_optional_tools() {
    echo ""
    print_info "═══════════════════════════════════════════════════════════"
    print_info "  Herramientas de Seguridad Opcionales"
    print_info "═══════════════════════════════════════════════════════════"
    echo ""
    
    # rkhunter
    if ask_yes_no "¿Instalar rkhunter (Rootkit Hunter)?"; then
        log_security INFO "Instalando rkhunter..."
        sudo apt install -y rkhunter
        
        # Actualizar base de datos
        sudo rkhunter --update
        
        if ask_yes_no "¿Ejecutar primer análisis con rkhunter? (puede tardar 5-10 min)"; then
            log_security INFO "Ejecutando análisis con rkhunter..."
            sudo rkhunter --check --skip-keypress
        fi
        
        log_security SUCCESS "rkhunter instalado"
    fi
    
    # ClamAV
    if ask_yes_no "¿Instalar ClamAV (Antivirus)?"; then
        log_security INFO "Instalando ClamAV..."
        sudo apt install -y clamav clamav-daemon
        
        # Actualizar base de datos
        print_info "Actualizando base de datos de virus..."
        sudo systemctl stop clamav-freshclam 2>/dev/null || true
        sudo freshclam
        sudo systemctl start clamav-freshclam
        
        log_security SUCCESS "ClamAV instalado"
    fi
    
    # Fail2ban
    if ask_yes_no "¿Instalar fail2ban (Protección contra ataques por fuerza bruta)?"; then
        log_security INFO "Instalando fail2ban..."
        sudo apt install -y fail2ban
        
        # Habilitar y iniciar
        sudo systemctl enable fail2ban
        sudo systemctl start fail2ban
        
        log_security SUCCESS "fail2ban instalado y activo"
    fi
    
    # Lynis (Auditoría de seguridad)
    if ask_yes_no "¿Instalar Lynis (Auditoría de seguridad)?"; then
        log_security INFO "Instalando Lynis..."
        sudo apt install -y lynis
        log_security SUCCESS "Lynis instalado - Ejecuta 'sudo lynis audit system' para auditar"
    fi
}

################################################################################
# === SECCIÓN 6: Configuraciones Adicionales del Sistema ===
################################################################################

harden_system() {
    echo ""
    print_info "═══════════════════════════════════════════════════════════"
    print_info "  Configuraciones Adicionales de Seguridad"
    print_info "═══════════════════════════════════════════════════════════"
    echo ""
    
    # Deshabilitar core dumps
    if ask_yes_no "¿Deshabilitar core dumps (archivos de volcado de memoria)?"; then
        log_security INFO "Deshabilitando core dumps..."
        echo "* hard core 0" | sudo tee -a /etc/security/limits.conf
        echo "fs.suid_dumpable = 0" | sudo tee -a /etc/sysctl.conf
        sudo sysctl -p
        log_security SUCCESS "Core dumps deshabilitados"
    fi
    
    # Protección contra SYN flood
    if ask_yes_no "¿Habilitar protección contra SYN flood?"; then
        log_security INFO "Habilitando protección SYN flood..."
        echo "net.ipv4.tcp_syncookies = 1" | sudo tee -a /etc/sysctl.conf
        echo "net.ipv4.tcp_syn_retries = 5" | sudo tee -a /etc/sysctl.conf
        sudo sysctl -p
        log_security SUCCESS "Protección SYN flood habilitada"
    fi
    
    # Deshabilitar IPv6 si no se usa
    if ask_yes_no "¿Deshabilitar IPv6? (solo si no lo usas)"; then
        log_security INFO "Deshabilitando IPv6..."
        echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
        echo "net.ipv6.conf.default.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
        sudo sysctl -p
        log_security SUCCESS "IPv6 deshabilitado"
    fi
}

################################################################################
# === SECCIÓN 7: Resumen de Seguridad ===
################################################################################

show_security_summary() {
    echo ""
    echo ""
    print_info "═══════════════════════════════════════════════════════════"
    print_info "  RESUMEN DE SEGURIDAD DEL SISTEMA"
    print_info "═══════════════════════════════════════════════════════════"
    echo ""
    
    # UFW
    if sudo ufw status | grep -q "Status: active"; then
        print_success "[✔] Firewall (UFW): Activo"
        local ufw_rules=$(sudo ufw status numbered | grep -c "^\[" || echo "0")
        echo "    └─ Reglas activas: $ufw_rules"
    else
        print_warning "[✗] Firewall (UFW): Inactivo"
    fi
    
    # AppArmor
    if systemctl is-active --quiet apparmor; then
        print_success "[✔] AppArmor: Activo"
        local profiles=$(sudo aa-status --profiled 2>/dev/null | wc -l || echo "0")
        echo "    └─ Perfiles cargados: $profiles"
    else
        print_warning "[✗] AppArmor: Inactivo"
    fi
    
    # AIDE
    if command -v aide &> /dev/null; then
        print_success "[✔] AIDE: Instalado"
        if [ -f /var/lib/aide/aide.db ]; then
            echo "    └─ Base de datos: Inicializada"
        else
            echo "    └─ Base de datos: Pendiente"
        fi
    else
        print_warning "[✗] AIDE: No instalado"
    fi
    
    # Firejail
    if command -v firejail &> /dev/null; then
        print_success "[✔] Firejail: Instalado"
        local aliases_count=$(grep -c "firejail" "$FIREJAIL_ALIASES" 2>/dev/null || echo "0")
        echo "    └─ Aliases configurados: $aliases_count"
    else
        print_warning "[✗] Firejail: No instalado"
    fi
    
    # Herramientas opcionales
    echo ""
    print_info "Herramientas opcionales:"
    
    if command -v rkhunter &> /dev/null; then
        print_success "  [✔] rkhunter (Rootkit Hunter)"
    fi
    
    if command -v clamscan &> /dev/null; then
        print_success "  [✔] ClamAV (Antivirus)"
    fi
    
    if systemctl is-active --quiet fail2ban 2>/dev/null; then
        print_success "  [✔] fail2ban (Protección brute-force)"
    fi
    
    if command -v lynis &> /dev/null; then
        print_success "  [✔] Lynis (Auditoría)"
    fi
    
    echo ""
    print_info "═══════════════════════════════════════════════════════════"
    echo ""
    
    # Ubicación del log
    print_info "Log de seguridad: $SECURITY_LOG"
    echo ""
}

################################################################################
# === SECCIÓN 8: Auditoría Instantánea ===
################################################################################

run_security_audit() {
    echo ""
    print_info "═══════════════════════════════════════════════════════════"
    print_info "  AUDITORÍA DE SEGURIDAD INSTANTÁNEA"
    print_info "═══════════════════════════════════════════════════════════"
    echo ""
    
    if command -v aide &> /dev/null && [ -f /var/lib/aide/aide.db ]; then
        if ask_yes_no "¿Ejecutar chequeo de integridad con AIDE? (puede tardar varios minutos)"; then
            print_info "Ejecutando AIDE..."
            sudo aide --check || true
        fi
    else
        print_warning "AIDE no está configurado completamente"
    fi
    
    if command -v lynis &> /dev/null; then
        if ask_yes_no "¿Ejecutar auditoría completa con Lynis?"; then
            print_info "Ejecutando Lynis..."
            sudo lynis audit system --quick
        fi
    fi
    
    echo ""
}

################################################################################
# Función Principal
################################################################################

main() {
    # Verificar que no se ejecute como root
    check_root
    
    echo ""
    print_info "═══════════════════════════════════════════════════════════"
    print_info "  Módulo de Seguridad - POETUX"
    print_info "  Fortificación integral de Pop!_OS"
    print_info "═══════════════════════════════════════════════════════════"
    echo ""
    
    # Crear log de seguridad
    sudo touch "$SECURITY_LOG"
    sudo chmod 640 "$SECURITY_LOG"
    
    log_security INFO "Iniciando módulo de seguridad..."
    
    # Parsear argumentos
    if [[ $# -gt 0 ]] && [[ "$1" == "--audit" ]]; then
        show_security_summary
        run_security_audit
        exit 0
    fi
    
    # Menú principal
    echo ""
    print_info "Este módulo configurará:"
    echo "  • Firewall (UFW) con políticas seguras"
    echo "  • AppArmor en modo enforce"
    echo "  • AIDE para detección de intrusiones"
    echo "  • Firejail para sandboxing de aplicaciones"
    echo "  • Herramientas adicionales opcionales"
    echo ""
    
    if ! ask_yes_no "¿Deseas continuar con la configuración de seguridad?"; then
        print_info "Operación cancelada"
        exit 0
    fi
    
    # Ejecutar configuraciones
    configure_ufw
    harden_apparmor
    setup_aide
    setup_firejail
    install_optional_tools
    harden_system
    
    # Resumen final
    show_security_summary
    
    # Ofrecer auditoría
    if ask_yes_no "¿Deseas ejecutar una auditoría de seguridad ahora?"; then
        run_security_audit
    fi
    
    echo ""
    log_security SUCCESS "Módulo de seguridad completado"
    echo ""
    print_success "¡Sistema Pop!_OS fortificado correctamente!"
    echo ""
    print_info "Recomendaciones:"
    echo "  • Reinicia el sistema para aplicar todos los cambios"
    echo "  • Ejecuta 'source ~/.bash_aliases' para activar aliases de Firejail"
    echo "  • Ejecuta './security.sh --audit' periódicamente"
    echo "  • Revisa el log en: $SECURITY_LOG"
    echo ""
}

# Ejecutar función principal
main "$@"

