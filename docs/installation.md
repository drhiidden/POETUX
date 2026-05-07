# POETUX - Instalación

Guía completa de instalación y configuración.

---

## Requisitos

### Sistema Operativo
- **Pop!_OS 22.04** o superior (recomendado)
- **Ubuntu 22.04+** (compatible)
- **Debian 11+** (compatible con ajustes menores)

### Hardware Mínimo
- **CPU**: 2 cores
- **RAM**: 4GB (8GB recomendado para perfil Dev o Creators)
- **Disco**: 20GB libres (más si instalas Gaming o Creators)
- **Red**: Conexión a internet estable

### Permisos
- Cuenta con permisos `sudo`
- Acceso a terminal

---

## Método 1: Instalación Estándar

```bash
# 1. Clonar repositorio
git clone https://github.com/drhiidden/POETUX.git
cd POETUX

# 2. Dar permisos de ejecución
chmod +x poet.sh modules/*.sh lib/*.sh

# 3. Ejecutar
./poet.sh
```

---

## Método 2: Quick Install (una línea)

```bash
git clone https://github.com/drhiidden/POETUX.git && cd POETUX && chmod +x poet.sh modules/*.sh lib/*.sh && ./poet.sh
```

---

## Opciones de Línea de Comandos

### Dry-run (Vista Previa)
```bash
./poet.sh --dry-run
```

Muestra qué haría sin ejecutar cambios reales.

### Forzar Idioma
```bash
./poet.sh --lang en  # Inglés
./poet.sh --lang es  # Español
```

### Ver Ayuda
```bash
./poet.sh --help
```

---

## Estructura del Proyecto

```
POETUX/
├── poet.sh              # Script principal
├── modules/             # 5 perfiles
│   ├── 01-basic.sh
│   ├── 02-gaming.sh
│   ├── 03-dev.sh
│   ├── 04-creators.sh
│   └── 05-streamers.sh
└── lib/                 # Librerías internas
    ├── colors.sh        # Colores terminal
    ├── logging.sh       # Sistema de logs
    ├── batch.sh         # Batch installation
    ├── rollback.sh      # Rollback automático
    └── progress.sh      # Progress bars
```

---

## Flujo de Instalación

### 1. Menú Principal

```
═══════════════════════════════════════════════════════════
  Menú Principal
═══════════════════════════════════════════════════════════

  1) Configuración Básica
  2) Gaming
  3) Desarrollo
  4) Creadores de Contenido
  5) Streamers
  6) Ejecutar todos los módulos

━━━ Herramientas ━━━
  7) Backup y Restauración
  8) Buscar paquetes
  9) Información del sistema

  L) Cambiar idioma (Actual: Español)
  0) Salir
```

### 2. Selección Interactiva

Cada perfil pregunta qué quieres instalar:

```bash
¿Instalar Git? (s/n): s
¿Instalar Python? (s/n): s
¿Instalar Node.js? (s/n): s
¿Instalar Rust? (s/n): n
...
```

### 3. Instalación Batch

Todos los paquetes seleccionados se instalan juntos (55% más rápido que uno por uno).

### 4. Post-Instalación

Configuraciones automáticas:
- Git: Configura user.name y user.email
- Docker: Añade usuario al grupo
- Python: Instala pip y venv

---

## Post-Instalación Manual

### Docker (requiere logout)
```bash
# Ya ejecutado por POETUX, pero necesitas logout:
sudo usermod -aG docker $USER
# Logout y login de nuevo
```

### Git (personalizar config)
```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tu@email.com"
```

### OBS (primera vez)
```bash
# Abrir OBS y configurar:
# 1. Settings → Stream → Conectar Twitch/YouTube
# 2. Settings → Video → Resolución y FPS
# 3. Settings → Output → Encoder (NVENC si tienes NVIDIA)
```

---

## Verificar Instalación

```bash
# Python
python3 --version

# Node.js
node --version
npm --version

# Rust
rustc --version
cargo --version

# Docker
docker --version
docker ps  # Debe funcionar sin sudo

# Git
git --version
git config --list
```

---

## Logs

POETUX guarda logs de cada sesión:

```
~/.poetux/logs/poetux_YYYYMMDD.log
```

Ver log actual:
```bash
tail -f ~/.poetux/logs/poetux_$(date +%Y%m%d).log
```

---

## Desinstalación

POETUX no incluye script de desinstalación automática, pero puedes:

### Opción 1: Desinstalar manualmente
```bash
# Ver qué instaló POETUX
cat ~/.poetux/logs/poetux_YYYYMMDD.log | grep "apt install"

# Desinstalar paquetes
sudo apt remove <paquete1> <paquete2> ...
sudo apt autoremove
```

### Opción 2: Usar snapshot (si creaste backup)
```bash
# Restaurar snapshot desde opción 7 del menú
./poet.sh
# Seleccionar opción 7 → Restaurar snapshot
```

---

## Configuración Avanzada

### Cambiar Directorio de Logs
```bash
# Editar poet.sh
export POETUX_LOG_DIR="/ruta/personalizada"
```

### Deshabilitar Progress Bars
```bash
# Editar lib/progress.sh
# Comentar todas las llamadas a show_progress()
```

### Añadir Paquetes Personalizados

Edita el módulo correspondiente (`modules/0X-nombre.sh`):

```bash
# Añadir al final de la función install_packages()
install_package "tu-paquete-personalizado"
```

---

**Última actualización**: 2026-05-07
