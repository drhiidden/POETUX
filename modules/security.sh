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
    
    # Crear directorio de sandbox para navegadores
    log_security INFO "Creando directorio de sandbox para navegadores..."
    mkdir -p "$HOME/sandbox-browser"
    chmod 700 "$HOME/sandbox-browser"
    
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
        "brave-browser"
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
    
    # Configuración avanzada para navegadores
    if ask_yes_no "¿Configurar aislamiento avanzado para navegadores?"; then
        configure_browser_isolation
    fi
    
    log_security SUCCESS "Aliases de Firejail configurados en $FIREJAIL_ALIASES"
    print_info "Ejecuta 'source ~/.bash_aliases' para activar los aliases"
}

configure_browser_isolation() {
    log_security INFO "Configurando aislamiento avanzado de navegadores..."
    
    # Crear perfil personalizado para navegador aislado
    local custom_profile="${HOME}/.config/firejail/browser-isolated.profile"
    mkdir -p "${HOME}/.config/firejail"
    
    cat > "$custom_profile" << 'EOF'
# Perfil de Firejail para navegador completamente aislado
# Uso: firejail --profile=browser-isolated.profile firefox

include /etc/firejail/firefox.profile

# Deshabilitar acceso a red local
blacklist /etc/hosts
blacklist /etc/hostname

# Directorio home restringido - solo acceso a sandbox
private ${HOME}/sandbox-browser

# Sin acceso a dispositivos
nodvd
noprinters
nosound
notv
nou2f

# Protecciones adicionales
nogroups
noroot
caps.drop all
seccomp
protocol unix,inet,inet6,netlink
shell none

# Protección contra X11 keylogging
x11 xvfb

# Deshabilitar dbus
nodbus
EOF

    log_security SUCCESS "Perfil de aislamiento creado en $custom_profile"
    print_info "Uso: firejail --profile=browser-isolated.profile <navegador>"
}

################################################################################
# === SECCIÓN 4B: DNS Seguros ===
################################################################################

configure_secure_dns() {
    echo ""
    print_info "═══════════════════════════════════════════════════════════"
    print_info "  Configurando DNS Seguros"
    print_info "═══════════════════════════════════════════════════════════"
    echo ""
    
    # Obtener lista de conexiones NetworkManager
    log_security INFO "Detectando conexiones de red..."
    local connections=$(nmcli -t -f NAME connection show --active 2>/dev/null)
    
    if [ -z "$connections" ]; then
        log_security WARNING "No se detectaron conexiones activas"
        return 1
    fi
    
    echo ""
    print_info "Conexiones activas detectadas:"
    echo "$connections" | nl
    echo ""
    
    # Preguntar qué conexión configurar
    local conn_list=()
    while IFS= read -r conn; do
        conn_list+=("$conn")
    done <<< "$connections"
    
    if [ ${#conn_list[@]} -eq 1 ]; then
        local selected_conn="${conn_list[0]}"
        print_info "Usando conexión: $selected_conn"
    else
        echo "Selecciona la conexión a configurar (1-${#conn_list[@]}):"
        read -r conn_num
        local selected_conn="${conn_list[$((conn_num-1))]}"
    fi
    
    # Seleccionar proveedor DNS
    echo ""
    print_info "Proveedores DNS disponibles:"
    echo "  1) Quad9 (9.9.9.9, 149.112.112.112) - Seguridad y privacidad"
    echo "  2) Cloudflare (1.1.1.1, 1.0.0.1) - Velocidad"
    echo "  3) NextDNS (45.90.28.0, 45.90.30.0) - Control parental"
    echo "  4) Personalizado"
    echo ""
    read -p "Selecciona (1-4): " dns_choice
    
    local dns_servers=""
    case "$dns_choice" in
        1)
            dns_servers="9.9.9.9 149.112.112.112"
            log_security INFO "Usando Quad9 DNS"
            ;;
        2)
            dns_servers="1.1.1.1 1.0.0.1"
            log_security INFO "Usando Cloudflare DNS"
            ;;
        3)
            dns_servers="45.90.28.0 45.90.30.0"
            log_security INFO "Usando NextDNS"
            ;;
        4)
            read -p "Introduce DNS primario: " dns1
            read -p "Introduce DNS secundario (opcional): " dns2
            dns_servers="$dns1${dns2:+ $dns2}"
            ;;
        *)
            log_security ERROR "Opción inválida"
            return 1
            ;;
    esac
    
    # Aplicar configuración
    log_security INFO "Aplicando DNS: $dns_servers a '$selected_conn'..."
    
    if sudo nmcli connection modify "$selected_conn" ipv4.dns "$dns_servers" ipv4.ignore-auto-dns yes; then
        log_security SUCCESS "DNS configurados correctamente"
        
        # Reactivar conexión
        log_security INFO "Reactivando conexión..."
        sudo nmcli connection down "$selected_conn" 2>/dev/null || true
        sleep 1
        sudo nmcli connection up "$selected_conn"
        
        echo ""
        print_success "DNS seguros configurados exitosamente"
        print_info "Verifica con: nmcli connection show '$selected_conn' | grep ipv4.dns"
    else
        log_security ERROR "Error al configurar DNS"
        return 1
    fi
}

################################################################################
# === SECCIÓN 4C: VPN Killswitch ===
################################################################################

configure_vpn_killswitch() {
    echo ""
    print_info "═══════════════════════════════════════════════════════════"
    print_info "  Configurando VPN Killswitch"
    print_info "═══════════════════════════════════════════════════════════"
    echo ""
    
    print_info "El killswitch bloqueará todo el tráfico si la VPN se desconecta"
    echo ""
    
    # Detectar interfaces VPN
    log_security INFO "Detectando interfaces VPN..."
    
    # Pedir nombre de interfaz VPN
    echo "Interfaces de red disponibles:"
    ip link show | grep -E "^[0-9]+" | awk '{print "  - " $2}' | sed 's/:$//'
    echo ""
    
    read -p "Introduce el nombre de tu interfaz VPN (ej: wg0, tun0): " vpn_interface
    
    if [ -z "$vpn_interface" ]; then
        log_security ERROR "No se proporcionó interfaz VPN"
        return 1
    fi
    
    log_security INFO "Configurando killswitch para interfaz: $vpn_interface"
    
    # Configurar UFW para killswitch
    echo ""
    print_info "Configurando reglas de firewall..."
    
    # Permitir tráfico local
    sudo ufw allow in on lo
    sudo ufw allow out on lo
    
    # Permitir tráfico solo a través de VPN
    sudo ufw allow out on "$vpn_interface" from any to any
    
    # Permitir conexión VPN (WireGuard usa puerto 51820 por defecto)
    if ask_yes_no "¿Tu VPN usa WireGuard?"; then
        read -p "Puerto WireGuard [51820]: " wg_port
        wg_port=${wg_port:-51820}
        sudo ufw allow out "$wg_port/udp" comment "WireGuard VPN"
        log_security INFO "Puerto WireGuard $wg_port permitido"
    fi
    
    if ask_yes_no "¿Tu VPN usa OpenVPN?"; then
        read -p "Puerto OpenVPN [1194]: " ovpn_port
        ovpn_port=${ovpn_port:-1194}
        sudo ufw allow out "$ovpn_port/udp" comment "OpenVPN"
        log_security INFO "Puerto OpenVPN $ovpn_port permitido"
    fi
    
    # Denegar todo lo demás por defecto
    sudo ufw default deny outgoing
    sudo ufw default deny incoming
    
    # Recargar UFW
    sudo ufw reload
    
    log_security SUCCESS "VPN Killswitch configurado"
    echo ""
    print_warning "⚠️  IMPORTANTE:"
    print_warning "  - El tráfico solo funcionará cuando la VPN esté activa"
    print_warning "  - Para desactivar: sudo ufw default allow outgoing"
    echo ""
}

################################################################################
# === SECCIÓN 4D: VM Desechables para Navegación Segura ===
################################################################################

setup_secure_vm() {
    echo ""
    print_info "═══════════════════════════════════════════════════════════"
    print_info "  Configurando VMs Desechables"
    print_info "═══════════════════════════════════════════════════════════"
    echo ""
    
    print_info "Las VMs desechables permiten navegar de forma segura"
    print_info "usando snapshots que puedes revertir después de cada sesión"
    echo ""
    
    # Verificar/instalar herramientas de virtualización
    log_security INFO "Verificando herramientas de virtualización..."
    
    local packages_needed=()
    
    if ! command -v virt-manager &> /dev/null; then
        packages_needed+=("virt-manager")
    fi
    
    if ! command -v qemu-img &> /dev/null; then
        packages_needed+=("qemu-utils")
    fi
    
    if ! dpkg -l | grep -q "qemu-kvm"; then
        packages_needed+=("qemu-kvm" "libvirt-daemon-system" "bridge-utils" "virtinst")
    fi
    
    if [ ${#packages_needed[@]} -gt 0 ]; then
        log_security INFO "Instalando herramientas de virtualización..."
        sudo apt install -y "${packages_needed[@]}"
        
        # Añadir usuario al grupo libvirt
        sudo usermod -aG libvirt "$USER"
        log_security INFO "Usuario añadido al grupo libvirt (requiere logout/login)"
    else
        log_security INFO "Herramientas de virtualización ya instaladas"
    fi
    
    # Ofrecer crear imagen QCOW2
    echo ""
    if ask_yes_no "¿Deseas crear una imagen QCOW2 para VM desechable ahora?"; then
        create_disposable_vm_image
    else
        print_info "Puedes crear imágenes manualmente con:"
        print_info "  qemu-img create -f qcow2 <nombre>.qcow2 <tamaño>G"
    fi
    
    log_security SUCCESS "Entorno de VMs desechables configurado"
}

create_disposable_vm_image() {
    echo ""
    read -p "Nombre de la imagen [browser-vm.qcow2]: " vm_name
    vm_name=${vm_name:-browser-vm.qcow2}
    
    read -p "Tamaño en GB [20]: " vm_size
    vm_size=${vm_size:-20}
    
    # Directorio para VMs
    local vm_dir="${HOME}/VMs"
    mkdir -p "$vm_dir"
    
    local vm_path="${vm_dir}/${vm_name}"
    
    if [ -f "$vm_path" ]; then
        print_warning "La imagen $vm_path ya existe"
        if ! ask_yes_no "¿Sobrescribir?"; then
            return 0
        fi
    fi
    
    log_security INFO "Creando imagen QCOW2: $vm_path (${vm_size}G)"
    
    if qemu-img create -f qcow2 "$vm_path" "${vm_size}G"; then
        log_security SUCCESS "Imagen creada: $vm_path"
        echo ""
        print_info "Pasos siguientes:"
        echo "  1) Abre virt-manager"
        echo "  2) Nueva VM > Importar disco existente"
        echo "  3) Selecciona: $vm_path"
        echo "  4) Instala el OS (recomendado: Debian/Ubuntu minimal)"
        echo "  5) Crea un snapshot 'limpio' tras la instalación"
        echo "  6) Usa ese snapshot como base desechable"
        echo ""
        print_info "Para snapshots: Click derecho en VM > Snapshots"
    else
        log_security ERROR "Error al crear imagen"
        return 1
    fi
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
    
    # WireGuard Tools
    if ask_yes_no "¿Instalar WireGuard (VPN)?"; then
        log_security INFO "Instalando WireGuard..."
        sudo apt install -y wireguard wireguard-tools
        log_security SUCCESS "WireGuard instalado"
        print_info "Configura con: sudo wg-quick up <config>"
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

show_security_menu() {
    echo ""
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════${RESET}"
    echo -e "${CYAN}  Módulo de Seguridad - POETUX${RESET}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════${RESET}"
    echo ""
    echo "  1) Configuración Completa (Recomendado para nuevos usuarios)"
    echo "  2) Configuración Básica (UFW + AppArmor + Firejail)"
    echo ""
    echo -e "${YELLOW}━━━ Componentes Individuales ━━━${RESET}"
    echo "  3) Configurar Firewall (UFW)"
    echo "  4) Fortalecer AppArmor"
    echo "  5) Configurar AIDE (Detección de intrusiones)"
    echo "  6) Configurar Firejail (Sandboxing)"
    echo ""
    echo -e "${YELLOW}━━━ Seguridad Avanzada ━━━${RESET}"
    echo "  7) Configurar DNS Seguros"
    echo "  8) Configurar VPN Killswitch"
    echo "  9) Configurar VMs Desechables"
    echo " 10) Hardening del Sistema"
    echo ""
    echo -e "${YELLOW}━━━ Herramientas ━━━${RESET}"
    echo " 11) Instalar Herramientas Opcionales"
    echo " 12) Ver Resumen de Seguridad"
    echo " 13) Ejecutar Auditoría"
    echo ""
    echo "  0) Volver al menú principal"
    echo ""
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════${RESET}"
    echo -n "Selecciona una opción: "
}

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
    
    # Menú interactivo
    while true; do
        show_security_menu
        read -r option
        
        case $option in
            1)
                # Configuración completa
                echo ""
                print_info "Iniciando configuración completa de seguridad..."
                echo ""
                configure_ufw
                harden_apparmor
                setup_aide
                setup_firejail
                
                if ask_yes_no "¿Configurar DNS seguros?"; then
                    configure_secure_dns
                fi
                
                install_optional_tools
                harden_system
                
                show_security_summary
                
                if ask_yes_no "¿Deseas ejecutar una auditoría de seguridad ahora?"; then
                    run_security_audit
                fi
                
                log_security SUCCESS "Configuración completa finalizada"
                ;;
            2)
                # Configuración básica
                echo ""
                print_info "Iniciando configuración básica..."
                echo ""
                configure_ufw
                harden_apparmor
                setup_firejail
                show_security_summary
                log_security SUCCESS "Configuración básica finalizada"
                ;;
            3)
                configure_ufw
                ;;
            4)
                harden_apparmor
                ;;
            5)
                setup_aide
                ;;
            6)
                setup_firejail
                ;;
            7)
                configure_secure_dns
                ;;
            8)
                configure_vpn_killswitch
                ;;
            9)
                setup_secure_vm
                ;;
            10)
                harden_system
                ;;
            11)
                install_optional_tools
                ;;
            12)
                show_security_summary
                ;;
            13)
                run_security_audit
                ;;
            0)
                echo ""
                log_security INFO "Saliendo del módulo de seguridad"
                print_info "Recomendaciones finales:"
                echo "  • Reinicia el sistema para aplicar todos los cambios"
                echo "  • Ejecuta 'source ~/.bash_aliases' para activar aliases de Firejail"
                echo "  • Ejecuta './security.sh --audit' periódicamente"
                echo "  • Revisa el log en: $SECURITY_LOG"
                echo ""
                exit 0
                ;;
            *)
                print_error "Opción inválida"
                ;;
        esac
        
        echo ""
        read -p "Presiona Enter para continuar..."
    done
}

# Ejecutar función principal
main "$@"

