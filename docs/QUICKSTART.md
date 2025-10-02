# ⚡ POETUX - Quick Start

```
    ____  ____  ___________
   / __ \/ __ \/ ____/_  __/
  / /_/ / / / / __/   / /   
 / ____/ /_/ / /___  / /    
/_/    \____/_____/ /_/     
```

## 🚀 Inicio Rápido (3 pasos)

```bash
# 1. Clonar (o ya lo tienes)
git clone https://github.com/drhiidden/poetux.git
cd poetux

# 2. Permisos de ejecución
chmod +x poet.sh modules/*.sh

# 3. Ejecutar
./poet.sh
```

## 📋 Menú Principal

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

## 🎯 Ejemplos de Uso

### Para Gamers
```bash
./poet.sh
# Selecciona: 1 (básico) → 2 (gaming)
```

### Para Developers
```bash
./poet.sh
# Selecciona: 1 (básico) → 3 (dev)
```

### Para Streamers
```bash
./poet.sh
# Selecciona: 1 (básico) → 5 (streamers)
```

### Setup Completo
```bash
./poet.sh
# Selecciona: 6 (todos los módulos)
```

## 📦 ¿Qué Instala Cada Módulo?

### 🔧 Básico
- Sistema actualizado
- Flatpak + Flathub
- curl, wget, htop, git, etc.

### 🎮 Gaming
- Steam, Lutris, Heroic
- GameMode, MangoHUD
- ProtonUp-Qt, Wine
- Optimizaciones gaming

### 💻 Desarrollo
- Python, Node.js, Rust
- Docker + Docker Compose
- VSCode
- Build tools

### 🎨 Creadores
- OBS Studio
- GIMP, Krita, Inkscape
- Kdenlive, Blender
- Audacity

### 🎙️ Streamers
- OBS + plugins
- Discord
- PipeWire + audio tools
- FFmpeg, yt-dlp

## ⚠️ Notas Importantes

1. **Sudo**: El script pedirá tu contraseña cuando necesite permisos
2. **Tiempo**: Cada módulo puede tardar 5-30 minutos (según conexión)
3. **Reiniciar**: Algunos cambios requieren reiniciar sesión/sistema
4. **Opcional**: Todas las instalaciones son opcionales (pregunta antes)

## 🆘 Problemas Comunes

### No funciona el script
```bash
# Verificar permisos
chmod +x poet.sh modules/*.sh
```

### Error de módulo no encontrado
```bash
# Verificar que estás en el directorio correcto
cd poetux
./poet.sh
```

### Error de sudo
```bash
# No ejecutar como root
./poet.sh  # ✅ Correcto
sudo ./poet.sh  # ❌ Incorrecto
```

## 📚 Más Información

- **Documentación completa**: `README.md`
- **Instalación detallada**: `INSTALL.md`
- **Estructura del proyecto**: `STRUCTURE.md`
- **Estado del proyecto**: `PROYECTO_COMPLETADO.md`

## 🌟 Características

✅ Interactivo y amigable  
✅ Modular y extensible  
✅ Seguro (pregunta antes de instalar)  
✅ Compatible con Pop!_OS, Ubuntu, Debian  
✅ 100+ paquetes configurables  

---

**¡Listo para empezar! 🚀**

```bash
./poet.sh
```

