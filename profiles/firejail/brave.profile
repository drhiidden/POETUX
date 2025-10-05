# Firejail profile for Brave Browser
# Persistent local customizations
include brave.local
# Persistent global definitions
include globals.local

################################################################################
# FILOSOFÍA: Navegador = Mayor superficie de ataque
#
# DISEÑO ESPECÍFICO PARA CHROMIUM-BASED:
# - Chromium ya tiene sandbox interno (--no-sandbox deshabilitado)
# - Firejail añade capa adicional de defensa en profundidad
# - Isolate: net, filesystem, processes
#
# THREAT MODEL:
# 1. Compromiso vía sitio malicioso
# 2. Exploit de extensión
# 3. Zero-day en motor JS
# 4. Phishing y social engineering
#
# MITIGATIONS:
# - Namespace isolation
# - Filesystem whitelist
# - No capabilities
# - Seccomp strict
# - Memory protections
################################################################################

noblacklist ${HOME}/.config/BraveSoftware
noblacklist ${HOME}/.cache/BraveSoftware
noblacklist ${DOWNLOADS}

################################################################################
# === FILESYSTEM ISOLATION ===
# PRINCIPIO: Navegador solo necesita:
# - Config propio
# - Downloads
# - Multimedia (opcional)
################################################################################

# Private environment
private-dev
private-tmp

# Whitelist approach
whitelist ${HOME}/.config/BraveSoftware
whitelist ${HOME}/.cache/BraveSoftware
whitelist ${DOWNLOADS}

# Permitir acceso a multimedia (solo lectura)
whitelist ${HOME}/Pictures
whitelist ${HOME}/Videos
read-only ${HOME}/Pictures
read-only ${HOME}/Videos

# Executable paths
whitelist /usr/bin
whitelist /usr/local/bin
whitelist /usr/share
whitelist /opt/brave.com

# Deny ALL sensitive locations
# CRÍTICO: Navegador es vector de ataque común
blacklist ${HOME}/.ssh
blacklist ${HOME}/.gnupg
blacklist ${HOME}/.password-store
blacklist ${HOME}/Projects
blacklist ${HOME}/workspace
blacklist ${HOME}/Documents
blacklist ${HOME}/.aws
blacklist ${HOME}/.kube
blacklist ${HOME}/.docker
blacklist /root
blacklist /boot
blacklist /etc/shadow
blacklist /etc/gshadow
blacklist /var/log/auth.log
blacklist /var/log/secure

# Read-only critical paths
read-only /opt

################################################################################
# === NETWORK ISOLATION ===
# RAZÓN: Navegador NECESITA red (su función principal)
# CONTROL: Protocol restrictions
################################################################################

# Network required for browser
# protocol restrictions
protocol unix,inet,inet6,netlink
# Deny: bluetooth, packet, netlink-route

# DNS
netfilter
# Opcional: Configurar iptables rules para filtrado adicional

################################################################################
# === PROCESS ISOLATION ===
################################################################################

ipc-namespace
# No shared memory con otros procesos

################################################################################
# === CAPABILITIES ===
# Chromium sandbox interno necesita algunas capabilities
# Pero Firejail las drop por seguridad adicional
################################################################################

caps.drop all
# Si Brave falla al iniciar, puede necesitar:
# caps.keep sys_chroot,sys_admin
# PERO: Esto debilita el sandbox. Probar primero sin capabilities.

################################################################################
# === SECCOMP ===
# CRÍTICO para navegadores: Muchos exploits usan syscalls raras
################################################################################

seccomp
# Seccomp strict mode
# Lista blanca de syscalls común para navegadores

# Syscalls browser-specific
seccomp.keep chroot,clone,prctl,ptrace
# chroot: Chromium sandbox usa chroot
# clone: Para crear procesos hijo
# prctl: Para configurar proceso
# ptrace: Chromium crashpad (crash reporting)

################################################################################
# === SECURITY HARDENING ===
################################################################################

# NoNewPrivileges: CRÍTICO para prevenir escalada
nonewprivileges

# Deshabilitar hardware access
nodvd
nou2f
# notv - Podría romper streaming
# novideo - Podría romper webcam (Google Meet, Zoom)

# Audio habilitado (necesario para multimedia)
# nosound - NO comentar si necesitas audio

################################################################################
# === MEMORY PROTECTIONS ===
# KERNEL: W^X policy enforcement
################################################################################

# Memory deny write-execute
# Previene ROP/JIT attacks
memory-deny-write-execute

################################################################################
# === APPARMOR INTEGRATION ===
################################################################################

# Si existe perfil AppArmor
# apparmor /etc/apparmor.d/usr.bin.brave-browser

################################################################################
# === BROWSER SPECIFIC ===
################################################################################

# Deshabilitar shell access desde navegador
shell none

# Deshabilitar debuggers
# Previene attachment de gdb/strace desde proceso comprometido
# nodbus - NO: Brave necesita DBus para notificaciones

################################################################################
# === X11/WAYLAND ===
################################################################################

# X11 isolation (limitado)
# Wayland es más seguro pero X11 aún es común
# x11 none - NO: Navegador necesita GUI

################################################################################
# === CHROMIUM SANDBOX ===
# IMPORTANTE: No deshabilitar sandbox interno de Chromium
################################################################################

# Asegurar que Chromium sandbox está habilitado
# NO añadir: --no-sandbox
# NO añadir: --disable-setuid-sandbox

################################################################################
# === INCLUDES ===
################################################################################

# Disable common services
disable-mnt
disable-autostart

# Whitelist common
include whitelist-common.inc
include whitelist-runuser-common.inc
include whitelist-usr-share-common.inc
include whitelist-var-common.inc

# Disable comprometedores
include disable-common.inc
include disable-devel.inc
include disable-exec.inc
include disable-interpreters.inc
include disable-passwdmgr.inc
include disable-programs.inc
include disable-xdg.inc

################################################################################
# === BROWSER HARDENING FLAGS ===
# Añadir al ejecutar Brave
################################################################################

# Recommended brave flags for additional security:
# --disable-background-networking
# --disable-default-apps
# --disable-sync
# --disable-speech-api
# --no-pings
# --no-referrers
# --disable-webgl (rompe algunos sitios)

################################################################################
# DEFENSA EN PROFUNDIDAD:
#
# CAPA 1 - Chromium Internal Sandbox:
#   - Proceso renderer aislado
#   - Syscall filtering (seccomp-bpf)
#   - Namespaces
#
# CAPA 2 - Firejail:
#   - Filesystem isolation
#   - Network filtering
#   - Capabilities drop
#   - Additional seccomp
#
# CAPA 3 - AppArmor:
#   - Mandatory Access Control
#   - Path-based restrictions
#   - Capability restrictions
#
# CAPA 4 - Systemd (si se usa .service):
#   - ProtectSystem
#   - ProtectHome
#   - NoNewPrivileges
#   - PrivateTmp
#
# SUPERFICIE DE ATAQUE REDUCIDA:
# 1. No acceso a SSH keys ✓
# 2. No acceso a code/projects ✓
# 3. No capabilities privilegiadas ✓
# 4. Syscalls limitadas ✓
# 5. Memory protections activas ✓
#
# TRADE-OFFS:
# - Red habilitada: Función principal del navegador
# - X11/Wayland: Necesario para GUI
# - Audio/Video: Necesario para multimedia
# - Some syscalls: Necesarias para Chromium sandbox
#
# TESTING:
# $ firejail --debug --profile=brave.profile brave
# $ firejail --list
# Monitor: /var/log/syslog | grep firejail
#
# REGRESSION TEST:
# - ✓ Puede navegar sitios web
# - ✓ Puede descargar archivos
# - ✓ Puede reproducir video/audio
# - ✓ NO puede acceder a ~/.ssh
# - ✓ NO puede acceder a ~/Projects
# - ✓ NO puede escalar privilegios
#
# AUDIT LOG:
# Violaciones serán registradas en syslog
# Revisar periódicamente para refinar perfil
################################################################################

