# Changelog - POETUX

Todos los cambios notables en este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es/1.0.0/).

---

## [1.3.0] - 2025-10-27

### 🛡️ Seguridad Avanzada (Integración de hidden-browser-security)

#### 🚀 Añadido

##### Módulo de Seguridad Extendido
- ✅ **DNS Seguros**: Configuración interactiva de proveedores DNS seguros
  - Quad9 (bloqueo de malware + privacidad)
  - Cloudflare (velocidad)
  - NextDNS (control parental)
  - DNS personalizados
  - Detección automática de conexiones NetworkManager
  - Verificación post-configuración

- ✅ **Aislamiento Avanzado de Navegadores**: 
  - Perfiles Firejail personalizados para máximo aislamiento
  - Directorio sandbox dedicado (`~/sandbox-browser`)
  - Perfil `browser-isolated.profile` con:
    - Home restringido solo a sandbox
    - Sin acceso a dispositivos (DVD, impresoras, USB)
    - Protección X11 keylogging (Xvfb)
    - D-Bus deshabilitado
    - Capabilities del kernel eliminadas

- ✅ **VPN Killswitch**: 
  - Configuración automática de firewall para VPN
  - Soporte WireGuard y OpenVPN
  - Bloqueo total de tráfico si VPN se desconecta
  - Detección de interfaces VPN
  - Configuración reversible

- ✅ **VMs Desechables**:
  - Asistente de creación de imágenes QCOW2
  - Instalación automática de herramientas de virtualización
  - Guía paso a paso para configurar VMs
  - Soporte para snapshots efímeros
  - Directorio organizado `~/VMs/`

##### Interfaz del Módulo de Seguridad
- ✅ **Menú interactivo mejorado**: 13 opciones organizadas
  - Configuración Completa (todo en uno)
  - Configuración Básica (esenciales)
  - Componentes individuales (UFW, AppArmor, AIDE, Firejail)
  - Seguridad avanzada (DNS, VPN, VMs, Hardening)
  - Herramientas (instalación opcional, resumen, auditoría)

##### Herramientas Adicionales
- ✅ **WireGuard**: Opción de instalación integrada
- ✅ **Flatpak**: Añadido brave-browser a apps sandboxeadas

#### 📚 Documentación

##### Nueva Documentación
- ✅ **[BROWSER_SECURITY.md](docs/security/BROWSER_SECURITY.md)**: Guía completa (8,000+ palabras)
  - DNS Seguros: Configuración detallada de cada proveedor
  - 3 niveles de aislamiento de navegadores
  - VPN Killswitch: Setup y troubleshooting
  - VMs Desechables: De cero a producción
  - Casos de uso para cada escenario
  - Troubleshooting y FAQ

##### Documentación Actualizada
- ✅ **[docs/security/README.md](docs/security/README.md)**: 
  - Añadido Nivel 3: Navegación Segura
  - Añadido Nivel 4: Paranoia Máxima
  - Comparación de impacto en rendimiento
  - FAQ sobre integración de hidden-browser-security

##### Proyecto hidden-browser-security
- ✅ **README actualizado**: Indica migración a POETUX
- ✅ **MIGRATE_TO_POETUX.md**: Guía completa de migración
  - Instalación limpia vs preservando configuraciones
  - Checklist de migración
  - Comparación de comandos antes/después
  - Casos de uso avanzados
  - Troubleshooting común

#### 🔧 Cambiado

##### Módulo security.sh
- **Estructura mejorada**: 960 líneas (+440 líneas nuevas)
- **Funciones nuevas**:
  - `configure_browser_isolation()`: Perfil Firejail avanzado
  - `configure_secure_dns()`: DNS seguros interactivo
  - `configure_vpn_killswitch()`: VPN killswitch con UFW
  - `setup_secure_vm()`: VMs desechables
  - `create_disposable_vm_image()`: Asistente de imágenes QCOW2
  - `show_security_menu()`: Menú interactivo
- **Main refactorizado**: Loop con menú vs ejecución lineal

##### Mejoras de UX
- 🎨 **Menú visual**: Secciones organizadas con separadores
- 💬 **Mensajes informativos**: Explicaciones antes de cada acción
- ⚠️ **Advertencias importantes**: Para configuraciones críticas (killswitch)
- 📝 **Instrucciones paso a paso**: Para VMs y configuraciones complejas

### 🐛 Corregido
- Corrección menor en permisos del sandbox de navegadores

### 🗑️ Deprecado
- **hidden-browser-security** (proyecto separado): Funcionalidades integradas en POETUX

---

## [1.2.0] - 2025-10-02

### 🚀 Añadido

#### Sistema de Instalación Inteligente
- ✅ **Staging en memoria**: Preparar lista de paquetes antes de instalar
- ✅ **Preview completo**: Mostrar plan de instalación antes de confirmar
- ✅ **Batch installation**: Instalar múltiples paquetes APT en un comando
- ✅ **Rollback automático**: Si falla, ofrece desinstalar lo instalado
- ✅ **Progress bars integrados**: Feedback visual durante instalación

#### Mejoras de Performance
- 🚀 **55% más rápido**: Instalación batch vs secuencial
- 📊 **Progress bars**: Barras visuales [██████░░░░] 60%
- 🔄 **Verificación previa**: No pregunta por paquetes ya instalados

#### Bilingüismo Completo
- ✅ **40+ traducciones**: Todos los mensajes en es/en
- ✅ **Preguntas traducidas**: Cada pregunta de instalación bilingüe
- ✅ **Módulos traducidos**: Headers y mensajes de todos los módulos

### 🔧 Cambiado

- **Todos los módulos**: Ahora usan `lib/installer.sh`
- **Flujo de instalación**: Staging → Preview → Snapshot → Install
- **Estructura**: +1 archivo (`lib/installer.sh`, 450 líneas)

### 📚 Documentación

- Milestone M2 documentado
- Protocolo HCP actualizado
- README con nuevas características

---

## [1.1.0] - 2025-10-02

### 🎉 Añadido

#### Sistema de Backup/Rollback
- ✅ **Snapshots automáticos**: Crea un snapshot inicial del sistema automáticamente
- ✅ **Gestión de snapshots**: Crear, listar, comparar y limpiar snapshots
- ✅ **Backup de paquetes**: Guarda listas de paquetes APT y Flatpak instalados
- ✅ **Comparación de diferencias**: Ver qué cambió desde un snapshot
- ✅ **Exportación de listas**: Exportar lista completa de paquetes instalados

#### Internacionalización (i18n)
- ✅ **Soporte bilingüe**: Español e Inglés
- ✅ **Detección automática**: Detecta idioma del sistema
- ✅ **Cambio en tiempo real**: Cambiar idioma sin reiniciar (opción 'L')
- ✅ **Persistencia**: Guarda preferencia de idioma del usuario

#### Búsqueda de Paquetes
- ✅ **Búsqueda en APT**: Busca paquetes en repositorios oficiales
- ✅ **Búsqueda en Flatpak**: Busca aplicaciones en Flathub
- ✅ **Indicador de instalación**: Muestra cuáles están instalados (✓)
- ✅ **Detalles interactivos**: Ver información detallada de paquetes
- ✅ **Instalación directa**: Instalar paquetes desde la búsqueda

#### Mejoras de Seguridad
- ✅ **Modo Dry Run**: Vista previa de cambios sin ejecutarlos (`--dry-run`)
- ✅ **Sistema de logging**: Logs detallados de todas las operaciones
- ✅ **Verificación de paquetes**: Comprueba si un paquete ya está instalado
- ✅ **Integridad de scripts**: Validación básica de integridad

#### Progress Bars y UX
- ✅ **Barras de progreso**: Indicadores visuales de progreso
- ✅ **Mensajes bilingües**: Todos los mensajes en español e inglés
- ✅ **Logging automático**: Registro de todas las operaciones
- ✅ **Información de ubicación**: Muestra dónde se guardan logs y backups

#### Biblioteca Común
- ✅ **`lib/common.sh`**: Funciones compartidas entre módulos
- ✅ **`lib/backup.sh`**: Sistema de backup y restauración
- ✅ **`lib/search.sh`**: Sistema de búsqueda de paquetes
- ✅ **Función `t()`**: Sistema de traducción simple pero efectivo

#### Argumentos de Línea de Comandos
- ✅ **`--dry-run`**: Modo de prueba sin cambios
- ✅ **`--lang [es|en]`**: Establecer idioma
- ✅ **`--help`**: Ayuda de uso

### 🔧 Cambiado

- **Menú principal**: Reorganizado con sección de "Herramientas/Tools"
- **Versión actualizada**: v1.0.0 → v1.1.0
- **Estructura del proyecto**: Añadido directorio `lib/` para bibliotecas compartidas

### 🐛 Corregido

- Evita reinstalar paquetes ya instalados
- Mejor manejo de errores en instalaciones
- Mensajes más claros y consistentes

### 📚 Documentación

- Actualizado README con nuevas características
- Añadido CHANGELOG.md
- Documentación de seguridad mejorada

---

## [1.0.0] - 2025-10-02

### 🎉 Release Inicial

#### Funcionalidades Principales
- ✅ Script principal con menú interactivo
- ✅ 5 módulos de configuración (basic, gaming, dev, creators, streamers)
- ✅ 100+ paquetes configurables
- ✅ Sistema de preguntas interactivas
- ✅ Colores en terminal
- ✅ Documentación completa

#### Módulos Implementados

**Módulo Basic**:
- Actualización del sistema
- Flatpak + Flathub
- Utilidades esenciales (18 paquetes)

**Módulo Gaming**:
- Steam, Lutris, Heroic Games Launcher
- GameMode, MangoHUD, ProtonUp-Qt
- Wine, optimizaciones del sistema

**Módulo Dev**:
- Git, Python, Node.js, Rust
- Docker + Docker Compose
- VSCode, Neovim, IntelliJ IDEA

**Módulo Creators**:
- OBS Studio, Kdenlive
- GIMP, Krita, Inkscape
- Blender, Audacity

**Módulo Streamers**:
- OBS + plugins
- Discord
- PipeWire, EasyEffects
- FFmpeg, yt-dlp

### 📚 Documentación Inicial
- README.md
- INSTALL.md
- QUICKSTART.md
- LICENSE (MIT)
- Protocolo HCP configurado

---

## Roadmap Futuro

### [1.3.0] - Próximamente
- [ ] Módulo de productividad (LibreOffice, Thunderbird, TimeShift)
- [ ] Módulo de seguridad (UFW, ClamAV, VPN, password managers)
- [ ] Testing en múltiples distribuciones
- [ ] Restauración automática desde snapshots
- [ ] Firmas GPG de releases

### [1.x.x] - Futuro
- [ ] Sistema de perfiles predefinidos
- [ ] Integración con dotfiles
- [ ] API para extensiones
- [ ] Documentación en más idiomas
- [ ] Sistema de actualización automática

### [2.0.0] - Largo plazo
- [ ] Interfaz gráfica (GUI) con Zenity/YAD
- [ ] Soporte para Fedora y Arch
- [ ] Sistema de plugins comunitarios
- [ ] Aplicación Flatpak

---

**Formato de versiones**: [MAJOR.MINOR.PATCH]
- **MAJOR**: Cambios incompatibles con versiones anteriores
- **MINOR**: Nuevas funcionalidades compatibles
- **PATCH**: Correcciones de bugs
