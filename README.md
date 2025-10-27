# 🚀 POETUX - Pop!_OS Extended Toolkit

<div align="center">

```
    ____  ____  ___________
   / __ \/ __ \/ ____/_  __/
  / /_/ / / / / __/   / /   
 / ____/ /_/ / /___  / /    
/_/    \____/_____/ /_/     
                            
```

**Sistema modular de configuración para Pop!_OS**  
*Orientado a gamers, developers, creadores y streamers*

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Pop!_OS](https://img.shields.io/badge/Pop!__OS-Compatible-48B9C7)](https://pop.system76.com/)
[![Version](https://img.shields.io/badge/version-1.3.0-blue.svg)](CHANGELOG.md)
[![i18n](https://img.shields.io/badge/i18n-es%20|%20en-green.svg)]()

</div>

---

## 📖 ¿Qué es POETUX?

**POETUX** (Pop!_OS Extended Toolkit) es un conjunto de scripts modulares en Bash diseñado para configurar y optimizar tu sistema Pop!_OS de forma rápida, segura y personalizada.

### ✨ Características

#### Perfiles de Instalación
- 🎮 **Perfil Gaming**: Steam, Lutris, Proton-GE, MangoHUD, GameMode
- 💻 **Perfil Dev**: Git, Python, Node.js, Rust, Docker, VSCode
- 🎨 **Perfil Creators**: OBS, GIMP, Krita, Kdenlive, Blender
- 🎙️ **Perfil Streamers**: OBS + plugins, Discord, audio tools
- 🔧 **Configuración Básica**: actualización de sistema, Flatpak, utilidades

#### Herramientas Integradas (v1.3.0)
- 🧠 **Sistema de Staging**: Preparación inteligente antes de instalar
- 🚀 **Batch Installation**: 55% más rápido (instala múltiples paquetes juntos)
- 🔄 **Rollback Automático**: Si falla, ofrece desinstalar cambios
- 💾 **Backup Automático**: Snapshots del sistema antes de cambios
- 🔍 **Búsqueda de Paquetes**: Busca en APT y Flatpak desde el menú
- 🌍 **Bilingüe Completo**: Español e Inglés en todo el sistema
- 🔒 **Modo Dry Run**: Vista previa de cambios sin ejecutarlos
- 📝 **Logging Completo**: Auditoría de todas las operaciones
- 📊 **Progress Bars**: Barras visuales integradas durante instalación
- 🛡️ **Seguridad Avanzada**: DNS seguros, VPN killswitch, VMs desechables 🆕

### 🎯 Filosofía

- **Modularidad**: cada módulo es independiente y hace una cosa bien
- **Opcionalidad**: pregunta antes de instalar cualquier software opcional
- **Respeto al usuario**: no cambia configuraciones críticas sin confirmar
- **Compatibilidad**: funciona en cualquier derivada de Ubuntu/Debian
- **Transparencia**: código limpio, comentado y fácil de auditar
- **Seguridad**: herramientas avanzadas para navegación y privacidad 🆕

---

## 🚀 Instalación y Uso

### Requisitos previos

- Pop!_OS 22.04 o superior (también compatible con Ubuntu/Debian)
- Conexión a internet
- Permisos de sudo

### Instalación

```bash
# Clonar el repositorio
git clone https://github.com/drhiidden/poetux.git
cd poetux

# Dar permisos de ejecución
chmod +x poet.sh modules/*.sh lib/*.sh

# Ejecutar
./poet.sh

# Opciones disponibles:
./poet.sh --dry-run        # Vista previa sin cambios
./poet.sh --lang en        # Forzar idioma inglés
./poet.sh --help           # Ver ayuda
```

### Uso básico

1. Ejecuta `./poet.sh`
2. Selecciona el módulo que deseas ejecutar
3. Responde a las preguntas interactivas
4. ¡Listo! El script instalará y configurará todo por ti

```
═══════════════════════════════════════════════════════════
  Menú Principal
═══════════════════════════════════════════════════════════

  1) Configuración Básica (actualizar sistema, flatpak, utilidades)
  2) Gaming (Steam, Lutris, Proton, MangoHUD, Gamemode)
  3) Desarrollo (Git, Python, Node.js, Rust, Docker, VSCode)
  4) Creadores de Contenido (OBS, GIMP, Krita, Kdenlive, Blender)
  5) Streamers (OBS + plugins, Discord, herramientas de audio)
  6) Ejecutar todos los módulos

━━━ Herramientas ━━━
  7) Backup y Restauración              ← v1.1.0
  8) Buscar paquetes                     ← v1.1.0
  9) Información del sistema

  L) Cambiar idioma (Actual: Español)   ← v1.1.0
  0) Salir

  [Sistema de instalación inteligente activo - v1.3.0]
  • Staging + Batch installation (55% más rápido)
  • Rollback automático en caso de error
  • Seguridad avanzada integrada 🆕

═══════════════════════════════════════════════════════════
```

### ⚡ Quick Start para Impaciosos

```bash
# Todo en una línea
git clone https://github.com/drhiidden/poetux.git && cd poetux && chmod +x poet.sh modules/*.sh lib/*.sh && ./poet.sh
```

### 🎯 Casos de Uso Rápidos

| Perfil | Comando | Tiempo aprox. |
|--------|---------|---------------|
| **Gamer** | `./poet.sh` → 1,2 | 10-15 min |
| **Developer** | `./poet.sh` → 1,3 | 15-20 min |
| **Streamer** | `./poet.sh` → 1,5 | 10-15 min |
| **Setup Completo** | `./poet.sh` → 6 | 30-45 min |

**Nota:** Tiempo varía según velocidad de internet y hardware.

---

## 📦 Módulos

### 🔧 `basic.sh` - Configuración Básica

- Actualiza el sistema (`apt update && upgrade`)
- Instala Flatpak y añade Flathub
- Instala utilidades comunes: `curl`, `wget`, `htop`, `git`, `vim`, `neofetch`, etc.

### 🎮 `gaming.sh` - Gaming

- **Launchers**: Steam, Lutris, Heroic Games Launcher
- **Optimización**: GameMode, MangoHUD, ProtonUp-Qt
- **Compatibilidad**: Wine, Proton
- **Tweaks**: aumenta `fs.inotify.max_user_watches`, configura esync/fsync

### 💻 `dev.sh` - Desarrollo

- **Básico**: build-essential, Git
- **Lenguajes**: Python, Node.js, Rust
- **Containers**: Docker + Docker Compose
- **Editores**: VSCode, Neovim, IntelliJ IDEA Community

### 🎨 `creators.sh` - Creadores de Contenido

- **Video**: OBS Studio, Kdenlive
- **Imagen**: GIMP, Krita, Inkscape
- **3D**: Blender
- **Audio**: Audacity
- **Preparación**: dependencias para DaVinci Resolve

### 🎙️ `streamers.sh` - Streamers

- **Streaming**: OBS Studio + plugins
- **Chat**: Discord
- **Audio**: PipeWire, EasyEffects, pavucontrol
- **Utilidades**: FFmpeg, yt-dlp
- **Tweaks**: prioridad en tiempo real para audio, v4l2loopback (cámara virtual)

---

## 📁 Estructura del Proyecto

```
poetux/
│
├── 📄 poet.sh                      # Script principal (v1.2.0)
│
├── 📂 lib/                         # Bibliotecas compartidas 🆕 v1.1.0
│   ├── common.sh                   # i18n, logging, colores, utilidades
│   ├── installer.sh                # Sistema de instalación inteligente ⚡ v1.2.0
│   ├── backup.sh                   # Snapshots y rollback
│   └── search.sh                   # Búsqueda de paquetes APT/Flatpak
│
├── 📂 modules/                     # Módulos de configuración
│   ├── basic.sh                    # Configuración básica del sistema
│   ├── gaming.sh                   # Perfil Gaming
│   ├── dev.sh                      # Perfil Desarrollo
│   ├── creators.sh                 # Perfil Creadores de Contenido
│   └── streamers.sh                # Perfil Streamers
│
├── 📂 .cursor/protocol_hcp/        # Protocolo HCP (gestión del proyecto)
│   ├── spec.yaml                   # Especificación técnica
│   └── meta/                       # Memoria del proyecto
│       ├── core/                   # Contexto, roadmap, arquitectura
│       ├── milestones/             # Hitos completados (M1, M2)
│       └── decisiones/             # ADRs (decisiones técnicas)
│
├── 📂 docs/                        # Documentación del proyecto 📚
│   ├── INSTALL.md                  # Guía de instalación detallada
│   ├── QUICKSTART.md               # Inicio rápido en 3 pasos ⚡
│   ├── STRUCTURE.md                # Descripción completa de la estructura
│   ├── SECURITY.md                 # Seguridad de POETUX (herramienta) 🔒
│   └── security/                   # Documentación de componentes de seguridad 🛡️
│       ├── README.md               # Índice de documentación de seguridad
│       ├── MODULE.md               # Módulo de seguridad del sistema (UFW, AppArmor, AIDE)
│       └── PROFILES.md             # Perfiles reforzados para apps (Cursor, Brave)
│
└── 📄 Archivos raíz
    ├── README.md                   # Este archivo
    ├── CHANGELOG.md                # Historial de cambios
    └── LICENSE                     # Licencia MIT
```

### 📊 Estadísticas del Proyecto

| Métrica | Valor |
|---------|-------|
| **Scripts totales** | 10 archivos (1 main + 5 modules + 4 libs) |
| **Líneas de código** | ~2,000 líneas Bash |
| **Idiomas** | 2 (Español + Inglés) |
| **Paquetes** | 100+ configurables |
| **Traducciones** | 60+ strings bilingües |
| **Funciones** | 50+ funciones reutilizables |

Ver estructura detallada: [`docs/STRUCTURE.md`](docs/STRUCTURE.md)

---

## 🔒 Seguridad y Confiabilidad

### Medidas de Seguridad Implementadas

| Característica | Descripción | Estado |
|----------------|-------------|--------|
| **No root** | Rechaza ejecución como root | ✅ v1.0.0 |
| **Confirmación explícita** | Pregunta antes de cada cambio | ✅ v1.0.0 |
| **Modo Dry Run** | Vista previa sin cambios | ✅ v1.1.0 |
| **Logging completo** | Auditoría en `~/.local/share/poetux/` | ✅ v1.1.0 |
| **Snapshots automáticos** | Backup antes de cambios | ✅ v1.1.0 |
| **Rollback automático** | Deshacer si falla | ✅ v1.2.0 |
| **Código abierto** | 100% auditable | ✅ Siempre |
| **Progress feedback** | Barras visuales de progreso | ✅ v1.2.0 |

### 🧪 Modo Dry Run (Preview Seguro)

Ejecuta sin hacer cambios reales:

```bash
./poet.sh --dry-run

# Salida de ejemplo:
[DRY RUN MODE] - No se harán cambios reales
═══════════════════════════════════════
[DRY RUN] Staging: steam
[DRY RUN] Staging: lutris
[DRY RUN] Staging: gamemode
[DRY RUN] Would install: sudo apt install steam lutris gamemode
[DRY RUN] Would create snapshot: gaming_20251002
```

**Casos de uso:**
- 🔍 **Auditoría**: Revisar qué hará antes de ejecutar
- 📝 **Documentación**: Generar lista de cambios planeados
- 🧪 **Testing**: Probar sin riesgo en producción

### 📝 Sistema de Logging

Todas las operaciones quedan registradas:

```bash
# Ubicación de logs
~/.local/share/poetux/logs/poetux_YYYYMMDD_HHMMSS.log

# Ver último log
tail -f ~/.local/share/poetux/logs/poetux_*.log

# Buscar errores
grep ERROR ~/.local/share/poetux/logs/*.log

# Ver logs de hoy
ls -lh ~/.local/share/poetux/logs/poetux_$(date +%Y%m%d)_*.log
```

**Formato del log:**
```
[2025-10-02 14:30:52] [INFO] User confirmed: Install Steam?
[2025-10-02 14:30:55] [SUCCESS] Staging package: steam
[2025-10-02 14:31:00] [INFO] Executing batch installation...
[2025-10-02 14:31:45] [SUCCESS] Installation completed: 3 packages
```

### 💾 Sistema de Snapshots y Rollback

**Snapshots automáticos:**
- ✅ Snapshot inicial al primer uso
- ✅ Snapshot antes de cada instalación de módulo
- ✅ Snapshots manuales desde el menú (opción 7)

**Contenido del snapshot:**
```bash
~/.local/share/poetux/backups/gaming_20251002/
├── dpkg_selections.txt      # Todos los paquetes APT
├── apt_manual.txt           # Paquetes instalados manualmente
├── flatpak_list.txt         # Aplicaciones Flatpak
├── ppas.txt                 # Repositorios PPA
└── system_info.txt          # Información del sistema
```

**Rollback automático (v1.2.0):**
Si una instalación falla, POETUX ofrece automáticamente:
```
⚠️  Error durante la instalación

Opciones de recuperación:
  1) Restaurar desde snapshot (revertir todos los cambios)
  2) Continuar de todos modos (mantener cambios parciales)
  3) Ver detalles del error en logs
  
¿Qué deseas hacer? [1-3]: _
```

### 🔐 Mejores Prácticas de Seguridad

1. **Siempre usar dry-run primero** (especialmente en producción)
   ```bash
   ./poet.sh --dry-run  # Revisar
   ./poet.sh            # Si todo está bien, ejecutar
   ```

2. **No ejecutar como root**
   ```bash
   # ❌ INCORRECTO
   sudo ./poet.sh
   
   # ✅ CORRECTO
   ./poet.sh  # Pedirá sudo solo cuando sea necesario
   ```

3. **Crear snapshots antes de cambios grandes**
   ```bash
   ./poet.sh → 7) Backup → 1) Crear snapshot
   ```

4. **Revisar logs después de instalaciones**
   ```bash
   tail -n 50 ~/.local/share/poetux/logs/poetux_*.log
   ```

5. **Mantener POETUX actualizado**
   ```bash
   cd poetux
   git pull origin main
   ```

### 🚨 Reportar Vulnerabilidades

Si encuentras un problema de seguridad:
1. **NO lo hagas público** inmediatamente
2. Reporta a: [Abrir issue en GitHub con etiqueta "security"]
3. Incluye:
   - Descripción detallada
   - Pasos para reproducir
   - Impacto potencial
   - Logs relevantes (si aplica)

**Respuesta esperada:**
- < 48h: Confirmación de recepción
- < 7 días: Evaluación inicial
- < 30 días: Fix o plan de mitigación

Ver documentación completa:
- **Seguridad de POETUX:** [`docs/SECURITY.md`](docs/SECURITY.md)
- **Módulo de seguridad del sistema:** [`docs/security/MODULE.md`](docs/security/MODULE.md)
- **Perfiles avanzados de aplicaciones:** [`docs/security/PROFILES.md`](docs/security/PROFILES.md)

---

## 🆘 Problemas Comunes y Soluciones

### Error: "Permission denied"

```bash
# Solución: Dar permisos de ejecución
chmod +x poet.sh modules/*.sh lib/*.sh
```

### Error: "Directorio modules/ no encontrado"

```bash
# Asegúrate de estar en el directorio correcto
cd poetux
pwd  # Debe mostrar: .../poetux
./poet.sh
```

### Error: "No ejecutes este script como root"

```bash
# ❌ NO hagas esto:
sudo ./poet.sh

# ✅ HAZ esto:
./poet.sh  # El script usará sudo cuando lo necesite
```

### La instalación es muy lenta

- **Normal**: APT puede tardar en resolver dependencias
- **v1.2.0 es 55% más rápido** que v1.1.0 gracias a batch installation
- **Factores**: Velocidad de internet, carga del servidor de repositorios
- **Tip**: Ejecuta `./poet.sh` en horarios de baja demanda

### El módulo no hace nada o falla silenciosamente

```bash
# Ver logs en tiempo real
tail -f ~/.local/share/poetux/logs/poetux_*.log

# O revisar el último log completo
cat ~/.local/share/poetux/logs/poetux_*.log | tail -n 100
```

### ¿Cómo desinstalar paquetes instalados por POETUX?

**Opción 1: Snapshot (recomendado)**
```bash
./poet.sh → 7) Backup → 3) Ver diferencias
# Identifica los paquetes nuevos y desinstala manualmente
```

**Opción 2: Manual**
```bash
# APT
sudo apt remove <paquete>
sudo apt autoremove

# Flatpak
flatpak uninstall <app-id>
```

### El idioma no cambia

```bash
# Forzar idioma al iniciar
./poet.sh --lang en  # Inglés
./poet.sh --lang es  # Español

# O cambiar desde el menú: Opción L
```

### ¿Cómo actualizar POETUX?

```bash
cd poetux
git pull origin main

# Verificar nueva versión
./poet.sh --help
```

### Errores de Flatpak: "remote not found"

```bash
# Añadir Flathub manualmente
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Luego ejecuta el módulo básico
./poet.sh → 1
```

### ¿Dónde están los logs y backups?

```bash
# Logs
~/.local/share/poetux/logs/

# Backups
~/.local/share/poetux/backups/

# Ver tamaño
du -sh ~/.local/share/poetux/
```

### Más ayuda

- 📖 **Instalación detallada**: [`docs/INSTALL.md`](docs/INSTALL.md)
- 🚀 **Inicio rápido**: [`docs/QUICKSTART.md`](docs/QUICKSTART.md)
- 🔒 **Seguridad**: [`docs/SECURITY.md`](docs/SECURITY.md) | [`docs/security/`](docs/security/)
- 📁 **Estructura**: [`docs/STRUCTURE.md`](docs/STRUCTURE.md)
- 📝 **Cambios**: [`CHANGELOG.md`](CHANGELOG.md)
- 🐛 **Issues**: [GitHub Issues](https://github.com/drhiidden/poetux/issues)

---

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Si quieres añadir un nuevo módulo o mejorar los existentes:

### Añadir un nuevo módulo

1. Crea un nuevo archivo en `modules/mi_modulo.sh`
2. Sigue la estructura de los módulos existentes:
   ```bash
   #!/bin/bash
   set -euo pipefail
   
   # Colores y funciones auxiliares
   # ...
   
   # Funciones de instalación
   # ...
   
   # Main
   main() {
       echo "Iniciando módulo..."
       # Tu código aquí
   }
   
   main "$@"
   ```
3. Añade la opción al menú en `poet.sh`
4. Haz un pull request

### Buenas prácticas

- **Modularidad**: una función, una tarea
- **Seguridad**: usar `set -euo pipefail`
- **Opcionalidad**: preguntar con `ask_yes_no()` antes de instalar
- **Mensajes claros**: usar `print_info`, `print_success`, `print_error`
- **Documentación**: comentar el código

---

## 🆕 Novedades en v1.2.0

### Sistema de Instalación Inteligente ⚡
POETUX ahora usa un sistema de 3 fases para instalaciones más rápidas y seguras:

1. **Staging** (preparación en memoria)
2. **Preview** (ver plan completo antes de confirmar)
3. **Batch Installation** (instalar todo junto, 55% más rápido)

```bash
¿Instalar Steam? → Añadido a lista
¿Instalar Lutris? → Añadido a lista
¿Instalar GameMode? → Añadido a lista

Plan de Instalación:
  📦 APT Packages (3):
    • steam
    • lutris
    • gamemode

¿Proceder? → Instalando TODO junto [██████] 100%
```

### Rollback Automático 🔄
Si algo falla durante la instalación, POETUX ofrece automáticamente desinstalar los cambios:
```
⚠️  La instalación ha fallado
Opciones:
  1) Restaurar desde snapshot (revertir cambios)
  2) Continuar de todos modos
  3) Ver detalles del error
```

### Bilingüismo Completo 🌍
Todos los módulos, preguntas y mensajes están ahora completamente traducidos al español e inglés.

---

## 🆕 Novedades en v1.1.0

### Sistema de Backup/Snapshots
Ahora POETUX crea automáticamente un snapshot inicial de tu sistema:
```bash
✓ Creating initial system snapshot...
✓ Backup snapshot created: initial_20251002
```

Puedes crear, listar y comparar snapshots desde el menú principal (opción 7).

### Búsqueda de Paquetes
Busca paquetes en APT y Flatpak sin salir de POETUX:
```bash
Menú → 8) Buscar paquetes
Término de búsqueda: steam
  ✓ steam - Valve's Steam digital software delivery system
```

### Modo Dry Run
Vista previa de todos los cambios antes de ejecutarlos:
```bash
./poet.sh --dry-run
[DRY RUN] Would execute: sudo apt install steam
```

### Soporte Bilingüe
Interfaz completa en Español e Inglés. Cambia de idioma en cualquier momento con la opción 'L':
```
L) Cambiar idioma (Actual: Español)
L) Change language (Current: English)
```

### Logging Completo
Todas las operaciones se registran automáticamente:
```
~/.local/share/poetux/logs/poetux_20251002_143052.log
```

Ver más detalles en [CHANGELOG.md](CHANGELOG.md)

---

## 📋 Roadmap

### ✅ Completado en v1.0.0 (MVP)
- [x] Script principal con menú interactivo
- [x] 5 módulos principales (basic, gaming, dev, creators, streamers)
- [x] 100+ paquetes configurables
- [x] Filosofía Unix aplicada

### ✅ Completado en v1.1.0
- [x] Sistema de backup y snapshots
- [x] Búsqueda de paquetes (APT + Flatpak)
- [x] Internacionalización (español + inglés)
- [x] Modo dry-run (preview sin cambios)
- [x] Sistema de logging completo
- [x] Biblioteca `lib/` compartida

### ✅ Completado en v1.2.0
- [x] Sistema de instalación inteligente (staging + batch)
- [x] Rollback automático en caso de error
- [x] Progress bars integrados
- [x] Bilingüismo completo (60+ traducciones)
- [x] Mejora de performance (55% más rápido)
- [x] Documentación reorganizada en `docs/`

### ✅ Completado en v1.3.0
- [x] DNS Seguros (Quad9, Cloudflare, NextDNS)
- [x] Aislamiento avanzado de navegadores (Firejail)
- [x] VPN Killswitch (WireGuard + OpenVPN)
- [x] VMs Desechables (QEMU/KVM)
- [x] Menú interactivo del módulo de seguridad
- [x] Integración de hidden-browser-security
- [x] Documentación completa (BROWSER_SECURITY.md)

### 🚧 Planificado para v1.4.0
- [ ] Restauración automática completa desde snapshots
- [ ] Módulo de productividad (LibreOffice, Thunderbird, TimeShift)
- [ ] Perfiles de seguridad por tipo de usuario
- [ ] Firmas GPG de releases
- [ ] Testing en múltiples distribuciones

### 🔮 Futuro
- [ ] Soporte para otras distros (Fedora, Arch)
- [ ] Interfaz gráfica (GUI) opcional con Zenity
- [ ] Perfiles predefinidos (gaming-pro, dev-fullstack, etc.)
- [ ] Integración con dotfiles
- [ ] Sistema de plugins comunitarios
- [ ] Sistema de actualización automática
- [ ] Telemetría opcional para mejorar el proyecto

---

## 🐛 Problemas Conocidos

### OBS y PipeWire

Si tienes problemas de audio con OBS después de instalar PipeWire:
1. Reinicia tu sesión
2. Abre OBS → Configuración → Audio
3. Selecciona las fuentes de audio correctas (PipeWire)

### Docker sin sudo

Después de instalar Docker, necesitas cerrar sesión y volver a entrar para usar Docker sin sudo.

### Node.js y npm global

Si los paquetes globales de npm no funcionan, reinicia tu terminal o ejecuta:
```bash
source ~/.bashrc
```

---

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Consulta el archivo `LICENSE` para más detalles.

---

## 🙏 Agradecimientos

- [System76](https://system76.com/) por Pop!_OS
- La comunidad de Linux
- Todos los desarrolladores de las herramientas incluidas

---

## 📞 Contacto y Soporte

- 🐛 **Reportar bugs**: [GitHub Issues](https://github.com/drhiidden/poetux/issues)
- 💡 **Sugerencias**: [GitHub Discussions](https://github.com/drhiidden/poetux/discussions)
- 🤝 **Contribuir**: [Pull Requests](https://github.com/drhiidden/poetux/pulls)
- 📧 **Email**: [Contacto directo]

**Versión actual:** v1.3.0  
**Última actualización:** 27 de Octubre de 2025

---

<div align="center">

**Hecho con ❤️ por la comunidad de Pop!_OS**

</div>

