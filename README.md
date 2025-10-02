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

</div>

---

## 📖 ¿Qué es POETUX?

**POETUX** (Pop!_OS Extended Toolkit) es un conjunto de scripts modulares en Bash diseñado para configurar y optimizar tu sistema Pop!_OS de forma rápida, segura y personalizada.

### ✨ Características

- 🎮 **Perfil Gaming**: Steam, Lutris, Proton-GE, MangoHUD, GameMode
- 💻 **Perfil Dev**: Git, Python, Node.js, Rust, Docker, VSCode
- 🎨 **Perfil Creators**: OBS, GIMP, Krita, Kdenlive, Blender
- 🎙️ **Perfil Streamers**: OBS + plugins, Discord, audio tools
- 🔧 **Configuración Básica**: actualización de sistema, Flatpak, utilidades

### 🎯 Filosofía

- **Modularidad**: cada módulo es independiente y hace una cosa bien
- **Opcionalidad**: pregunta antes de instalar cualquier software opcional
- **Respeto al usuario**: no cambia configuraciones críticas sin confirmar
- **Compatibilidad**: funciona en cualquier derivada de Ubuntu/Debian
- **Transparencia**: código limpio, comentado y fácil de auditar

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
chmod +x poet.sh
chmod +x modules/*.sh

# Ejecutar
./poet.sh
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
  7) Información del sistema
  0) Salir

═══════════════════════════════════════════════════════════
```

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

## 🛠️ Estructura del Proyecto

```
poetux/
├── poet.sh                  # Script principal con menú interactivo
├── modules/
│   ├── basic.sh              # Configuración básica
│   ├── gaming.sh             # Gaming
│   ├── dev.sh                # Desarrollo
│   ├── creators.sh           # Creadores de contenido
│   └── streamers.sh          # Streamers
└── README.md                 # Este archivo
```

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

## 📋 Roadmap

- [ ] Módulo de productividad (LibreOffice, Thunderbird, etc.)
- [ ] Módulo de seguridad (firewall, VPN, etc.)
- [ ] Soporte para otras distros (Fedora, Arch)
- [ ] Interfaz gráfica (GUI) opcional
- [ ] Perfiles predefinidos (gaming pro, dev fullstack, etc.)
- [ ] Backup y restauración de configuración
- [ ] Integración con dotfiles

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

## 📞 Contacto

¿Preguntas? ¿Sugerencias? Abre un [issue](https://github.com/tu-usuario/poetux/issues) o un [pull request](https://github.com/tu-usuario/poetux/pulls).

---

<div align="center">

**Hecho con ❤️ por la comunidad de Pop!_OS**

</div>

