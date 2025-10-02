# 📁 Estructura del Proyecto POETUX

> **Versión:** 1.2.0  
> **Última actualización:** 2 de Octubre de 2025

```
poetux/
│
├── 📄 poet.sh                      # Script principal (v1.2.0)
├── 📄 README.md                    # Documentación principal del proyecto
├── 📄 CHANGELOG.md                 # Historial de cambios
├── 📄 LICENSE                      # Licencia MIT
├── 📄 .gitignore                   # Archivos ignorados por Git
│
├── 📂 lib/                         # Bibliotecas compartidas 🆕 v1.1.0
│   ├── 📄 common.sh                # Funciones comunes, i18n, logging, colores
│   ├── 📄 installer.sh             # Sistema de instalación inteligente ⚡ v1.2.0
│   ├── 📄 backup.sh                # Sistema de snapshots y rollback
│   └── 📄 search.sh                # Búsqueda de paquetes APT/Flatpak
│
├── 📂 modules/                     # Módulos de configuración
│   ├── 📄 basic.sh                 # Configuración básica del sistema
│   ├── 📄 gaming.sh                # Perfil Gaming
│   ├── 📄 dev.sh                   # Perfil Desarrollo
│   ├── 📄 creators.sh              # Perfil Creadores de Contenido
│   └── 📄 streamers.sh             # Perfil Streamers
│
├── 📂 docs/                        # Documentación del proyecto 📚
│   ├── 📄 INSTALL.md               # Guía de instalación detallada
│   ├── 📄 QUICKSTART.md            # Inicio rápido en 3 pasos
│   ├── 📄 STRUCTURE.md             # Este archivo
│   └── 📄 SECURITY.md              # Guía de seguridad completa
│
└── 📂 .cursor/                     # Protocolo HCP y configuración
    ├── 📄 README.md                # Vibe Engineering - POETUX
    ├── 📄 idea_inicial_resumida.md # Idea original del proyecto
    │
    └── 📂 protocol_hcp/            # Protocolo HCP
        ├── 📄 spec.yaml            # Especificación del protocolo (v1.2)
        │
        ├── 📂 meta/                # Memoria del proyecto
        │   ├── 📄 README.md        # Guía de organización
        │   ├── 📄 mvp-limitations.md # Limitaciones conocidas (v1.2.0)
        │   │
        │   ├── 📂 core/            # Estado actual
        │   │   ├── 📄 context.md   # Contexto del proyecto
        │   │   ├── 📄 roadmap.md   # Planificación y timeline
        │   │   └── 📄 arquitectura.md
        │   │
        │   ├── 📂 milestones/      # Hitos completados
        │   │   ├── 📄 m1-mvp-core.md  # MVP v1.0.0
        │   │   └── 📄 m2-sistema-instalacion-inteligente.md  # v1.2.0
        │   │
        │   └── 📂 decisiones/      # ADRs (Architecture Decision Records)
        │       └── 📄 adr-001-arquitectura-modular.md
        │
        ├── 📂 prompts/             # Configuración HCP
        │   ├── 📄 roles-core.md    # Roles de personalidad IA
        │   ├── 📄 vibes-core.md    # Estados emocionales
        │   └── 📄 modos-core.md    # Modos de operación
        │
        └── 📂 pipeline-chats/      # Conversaciones técnicas
            └── 📄 README.md
```

## 🎯 Descripción de Componentes

### Scripts Principales

- **`poet.sh`**: Script principal (v1.2.0) con menú interactivo que orquesta todos los módulos
- **`lib/*.sh`**: Bibliotecas compartidas (common, installer, backup, search)
- **`modules/*.sh`**: Módulos independientes para cada perfil de usuario

### Bibliotecas (v1.1.0+)

- **`lib/common.sh`**: Funciones compartidas, sistema i18n (es/en), logging, colores
- **`lib/installer.sh`**: Sistema de instalación inteligente con staging y batch (v1.2.0)
- **`lib/backup.sh`**: Sistema de snapshots, comparación y exportación
- **`lib/search.sh`**: Búsqueda integrada de paquetes APT y Flatpak

### Documentación

- **`README.md`**: Documentación completa del proyecto (raíz)
- **`docs/INSTALL.md`**: Guía de instalación paso a paso
- **`docs/QUICKSTART.md`**: Inicio rápido en 3 pasos
- **`docs/STRUCTURE.md`**: Este archivo, describe la estructura del proyecto
- **`docs/SECURITY.md`**: Guía completa de seguridad
- **`CHANGELOG.md`**: Historial de cambios por versión

### Protocolo HCP

Sistema de gestión de proyectos guiados por IA:

- **`spec.yaml`**: Especificación del proyecto (stack, capas, roles)
- **`meta/`**: Memoria colectiva del proyecto (contexto, decisiones, roadmap)
- **`prompts/`**: Configuración de interacción con IA
- **`pipeline-chats/`**: Documentación de conversaciones técnicas

## 📊 Estadísticas (v1.2.0)

- **Scripts totales:** 10 archivos (1 main + 5 modules + 4 libs)
- **Módulos:** 5 perfiles (basic, gaming, dev, creators, streamers)
- **Bibliotecas:** 4 archivos (common, installer, backup, search)
- **Documentación:** 15+ archivos markdown
- **Líneas de código:** ~2,000 líneas Bash
- **Paquetes configurables:** 100+ paquetes
- **Idiomas soportados:** 2 (Español + Inglés)
- **Traducciones:** 60+ strings bilingües
- **Funciones:** 50+ funciones reutilizables

## 🔧 Archivos Ejecutables

Todos los scripts `.sh` deben tener permisos de ejecución:

```bash
chmod +x poet.sh modules/*.sh lib/*.sh
```

**Importante:** Los scripts en `lib/` son cargados mediante `source` desde otros scripts, pero también necesitan permisos de ejecución.

## 📝 Archivos de Configuración

- **`.gitignore`**: Excluye archivos temporales y de IDE
- **`LICENSE`**: Licencia MIT del proyecto

## 🎨 Filosofía de Organización

1. **Raíz del proyecto**: Script principal y documentación esencial (README, CHANGELOG, LICENSE)
2. **`lib/`**: Bibliotecas compartidas y funcionalidades comunes (DRY principle)
3. **`modules/`**: Código modular organizado por responsabilidad (perfiles de usuario)
4. **`docs/`**: Documentación detallada y guías específicas
5. **`.cursor/`**: Metadatos del proyecto y protocolo HCP (metodología)

### Principios de Diseño

✅ **Unix Philosophy**: Cada componente hace una cosa y la hace bien  
✅ **DRY (Don't Repeat Yourself)**: Código compartido en `lib/`  
✅ **Modularidad**: Módulos independientes y desacoplados  
✅ **Separación de Responsabilidades**: Scripts, bibliotecas y docs separados  
✅ **Documentación Clara**: Cada directorio tiene propósito definido

### Convenciones de Naming

- **Scripts principales**: `nombre.sh` (ej: `poet.sh`)
- **Módulos**: `perfil.sh` (ej: `gaming.sh`, `dev.sh`)
- **Bibliotecas**: `funcionalidad.sh` (ej: `common.sh`, `installer.sh`)
- **Documentación**: `NOMBRE.md` en MAYÚSCULAS (ej: `INSTALL.md`)

---

## 🔄 Evolución de la Estructura

### v1.0.0 (MVP)
```
poetux/
├── poet.sh
├── modules/
└── README.md
```

### v1.1.0 (Bibliotecas)
```
poetux/
├── poet.sh
├── lib/            # 🆕 Nuevo
│   ├── common.sh
│   ├── backup.sh
│   └── search.sh
├── modules/
└── README.md
```

### v1.2.0 (Actual)
```
poetux/
├── poet.sh
├── lib/            # Ampliado
│   ├── common.sh
│   ├── installer.sh    # 🆕 Nuevo
│   ├── backup.sh
│   └── search.sh
├── modules/
├── docs/           # 🆕 Nuevo (organización)
└── README.md
```

---

## 📝 Referencias

- **README principal**: [`../README.md`](../README.md)
- **Guía de instalación**: [`INSTALL.md`](INSTALL.md)
- **Inicio rápido**: [`QUICKSTART.md`](QUICKSTART.md)
- **Seguridad**: [`SECURITY.md`](SECURITY.md)
- **Changelog**: [`../CHANGELOG.md`](../CHANGELOG.md)

