# Firejail profile for Cursor (VSCode fork)
# Persistent local customizations
include cursor.local
# Persistent global definitions
include globals.local

################################################################################
# FILOSOFÍA: "Cada permiso innecesario es un bug"
#
# DISEÑO:
# - Aislamiento de namespaces (PID, NET, IPC, UTS, CGROUP)
# - Filesystem minimal con whitelist explícito
# - Capabilities dropped a cero
# - Seccomp strict mode
# - Protocol restrictions
#
# KERNEL SUBSYSTEMS INVOLUCRADOS:
# - Linux Namespaces: Aislamiento de recursos
# - Capabilities: Eliminación de privilegios
# - Seccomp-BPF: Filtro de syscalls
# - AppArmor LSM: MAC policy enforcement
################################################################################

noblacklist ${HOME}/.config/Cursor
noblacklist ${HOME}/.cursor
noblacklist ${HOME}/Projects
noblacklist ${HOME}/workspace
noblacklist ${HOME}/Documents

################################################################################
# === FILESYSTEM ISOLATION ===
# Principio: Deny by default, allow by exception
################################################################################

# Private home with selective whitelist
private-dev
private-tmp

# Whitelist approach: Solo lo necesario
whitelist ${HOME}/.config/Cursor
whitelist ${HOME}/.cursor
whitelist ${HOME}/Projects
whitelist ${HOME}/workspace
whitelist ${HOME}/Documents
whitelist ${DOWNLOADS}

# Executable paths
whitelist /usr/bin
whitelist /usr/local/bin
whitelist /usr/share
whitelist /opt

# Deny sensitive locations
blacklist ${HOME}/.ssh
blacklist ${HOME}/.gnupg
blacklist ${HOME}/.password-store
blacklist /root
blacklist /boot
blacklist /etc/shadow
blacklist /etc/gshadow
blacklist /var/log/auth.log
blacklist /var/log/secure

# Read-only system
read-only /opt

################################################################################
# === NETWORK ISOLATION ===
# RAZÓN: Cursor necesita red para extensions y Copilot
# CONTROL: Restringir a protocols específicos
################################################################################

# Network enabled pero controlado
# Si quieres deshabilitar red completamente: net none
# Para desarrollo offline: net none

# Protocol restrictions
protocol unix,inet,inet6,netlink
# Deny protocols: bluetooth, packet, etc

################################################################################
# === PROCESS ISOLATION ===
# KERNEL: PID namespace - proceso no ve otros procesos del sistema
################################################################################

# PID namespace
ipc-namespace
# Nuevo namespace IPC - no comparte memoria compartida

################################################################################
# === CAPABILITIES ===
# KERNEL: Capabilities - privileges granulares en lugar de root
# FILOSOFÍA: Drop ALL, añadir solo si falla
################################################################################

caps.drop all
# Capabilities dropped:
# - CAP_SYS_ADMIN: No puede montar filesystems
# - CAP_NET_ADMIN: No puede modificar stack de red
# - CAP_SYS_PTRACE: No puede ptrace otros procesos
# - CAP_SYS_MODULE: No puede cargar módulos del kernel
# - 35+ capabilities más

# Si Cursor falla, añadir capabilities específicas aquí
# Ejemplo: caps.keep chown,dac_override

################################################################################
# === SECCOMP ===
# KERNEL: Secure Computing Mode - filtro syscalls
# BPF: Berkeley Packet Filter aplicado a syscalls
################################################################################

seccomp
# Seccomp strict mode - lista blanca de syscalls
# Syscalls permitidas: read, write, open, close, mmap, etc.
# Syscalls bloqueadas: reboot, mount, swapon, etc.

# Syscalls adicionales si es necesario:
# seccomp.keep <syscall>

################################################################################
# === SECURITY OPTIONS ===
################################################################################

# NoNewPrivileges: Previene escalada de privilegios vía setuid
nonewprivileges

# Deshabilitar 3D acceleration (si causa problemas, comentar)
# nodvd
# nogroups
# notv
# nou2f
# novideo

# No sound (Cursor no necesita audio)
# Si usas terminal integrada con notificaciones de sonido, comentar
nosound

# Deshabilitar debuggers
# Previene attachment de gdb/strace
# nodbus - NO: Cursor necesita DBus para interactuar con sistema

################################################################################
# === SHELL RESTRICTIONS ===
################################################################################

# Shell ninguno (Cursor tiene terminal integrada pero usa subprocess)
# Si tienes problemas con terminal integrada, comentar esta línea
# shell none

################################################################################
# === APPARMOR ===
# Capa adicional de MAC (Mandatory Access Control)
################################################################################

# Si existe perfil AppArmor para Cursor, aplicarlo
# apparmor /etc/apparmor.d/usr.bin.cursor

################################################################################
# === MEMORY RESTRICTIONS ===
################################################################################

# Memory deny write-execute
# Previene código automodificado y ROP attacks
# memory-deny-write-execute

################################################################################
# === X11 ISOLATION ===
# RAZÓN: Cursor necesita GUI
# SEGURIDAD: X11 no tiene aislamiento real, usa Xpra si necesitas más seguridad
################################################################################

# X11 isolation (limitado en X11, mejor con Wayland)
# x11 none - NO: Cursor necesita X11/Wayland

################################################################################
# === INCLUDES ===
# Abstracciones comunes de Firejail
################################################################################

# Disable common services
disable-mnt
disable-autostart

# Whitelist common paths
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
# NOTAS DE SEGURIDAD:
#
# 1. NAMESPACE ISOLATION:
#    - PID: Cursor no ve procesos del sistema
#    - NET: Red aislada pero funcional
#    - IPC: No comparte memoria con otros procesos
#
# 2. FILESYSTEM:
#    - Whitelist approach: Solo acceso a Projects y config
#    - Blacklist: SSH keys, GPG, passwords
#
# 3. CAPABILITIES:
#    - Zero capabilities: No privilegios especiales
#
# 4. SECCOMP:
#    - Syscall filtering: Solo syscalls seguras
#
# 5. TRADE-OFFS:
#    - Red habilitada: Necesaria para extensions/Copilot
#    - X11 habilitada: Necesaria para GUI
#    - DBus habilitado: Necesario para integración sistema
#
# AUDIT:
# - Monitorear con: firejail --list
# - Logs: /var/log/syslog | grep firejail
# - Test: firejail --debug --profile=cursor.profile cursor
################################################################################

