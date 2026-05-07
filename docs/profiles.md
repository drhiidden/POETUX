# POETUX - Perfiles de Instalación

Cada perfil instala un conjunto curado de herramientas para un caso de uso específico.

---

## 1. Configuración Básica

**Qué hace**:
- Actualización completa del sistema (`apt update && apt upgrade`)
- Instalación de Flatpak + Flathub
- Herramientas esenciales: curl, wget, git, build-essential, vim, htop

**Tiempo estimado**: 5-10 minutos

**Recomendado para**: Todos (ejecutar siempre primero)

**Comandos equivalentes**:
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install flatpak -y
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo apt install curl wget git build-essential vim htop -y
```

---

## 2. Perfil Gaming

**Qué instala**:
- **Steam**: Cliente oficial de Steam
- **Lutris**: Gestor de juegos (Epic, GOG, Battle.net)
- **Proton-GE**: Mejora compatibilidad de juegos Windows
- **MangoHUD**: Overlay de FPS/CPU/GPU
- **GameMode**: Optimización de CPU/GPU para gaming

**Tiempo estimado**: 10-15 minutos

**Recomendado para**: Gamers de PC

**Post-instalación**:
- Steam se abre automáticamente para login
- Lutris: Añadir cuentas (Epic, Battle.net) desde el menú
- MangoHUD: Activar con `mangohud %command%` en Steam launch options

---

## 3. Perfil Desarrollo

**Qué instala**:
- **Git** + configuración inicial (user.name, user.email)
- **Python 3.11+**: pip, venv, virtualenv
- **Node.js 20+**: npm, nvm (node version manager)
- **Rust**: cargo, rustc (última stable)
- **Docker + Docker Compose**: Contenedores
- **VSCode**: Editor de código

**Tiempo estimado**: 15-20 minutos

**Recomendado para**: Developers

**Post-instalación**:
```bash
# Verificar instalaciones
python3 --version
node --version
rustc --version
docker --version
code --version

# Añadir usuario a grupo docker (para no usar sudo)
sudo usermod -aG docker $USER
# Logout y login de nuevo
```

---

## 4. Perfil Creadores de Contenido

**Qué instala**:
- **OBS Studio**: Streaming y grabación de pantalla
- **GIMP**: Edición de imágenes
- **Krita**: Dibujo digital y pintura
- **Kdenlive**: Edición de vídeo
- **Blender**: Modelado 3D y animación

**Tiempo estimado**: 15-20 minutos

**Recomendado para**: Creadores, artistas, editores de vídeo

**Post-instalación**:
- OBS: Configurar escenas y fuentes
- Kdenlive: Configurar proxy para vídeos 4K (Settings → Proxy)

---

## 5. Perfil Streamers

**Qué instala**:
- **OBS Studio** + plugins:
  - obs-websocket (control remoto via API)
  - obs-browser-source (integrar widgets web)
- **Discord**: Comunicación con comunidad
- **Audio tools**: pavucontrol, pulseaudio-utils

**Tiempo estimado**: 10-15 minutos

**Recomendado para**: Streamers de Twitch/YouTube

**Post-instalación**:
- OBS: Conectar con Twitch/YouTube (Settings → Stream)
- Discord: Login y configurar audio (Input/Output devices)
- pavucontrol: Ajustar volumen por aplicación

---

## Ejecutar Múltiples Perfiles

Puedes ejecutar varios perfiles en secuencia:

```bash
./poet.sh
# Selecciona 1 (Basic) → Completa
# Selecciona 3 (Dev) → Completa
# Selecciona 0 (Salir)
```

O ejecutar todos de una vez:

```bash
./poet.sh
# Selecciona 6 (Ejecutar todos los módulos)
```

**⚠️ Advertencia**: Ejecutar todos toma ~40 minutos y ocupa ~15GB de disco.

---

## Personalización

Si quieres modificar qué instala cada perfil:

1. Edita el módulo correspondiente: `modules/0X-nombre.sh`
2. Busca la sección de instalaciones
3. Comenta/descomenta paquetes según necesites

**Ejemplo**: No quieres Blender en el perfil Creators:

```bash
# Editar modules/04-creators.sh
# Comentar la línea:
# install_package "blender"
```

---

**Última actualización**: 2026-05-07
