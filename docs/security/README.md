# 🔒 Documentación de Seguridad - POETUX

Esta sección contiene documentación técnica sobre los **componentes de seguridad** de POETUX.

---

## 📚 Índice de Documentación

### 1. [Seguridad de POETUX](../SECURITY.md)
**Archivo:** `docs/SECURITY.md`

Documenta la seguridad **del propio sistema POETUX**:
- Modo dry-run
- Sistema de logging
- Backups y snapshots
- Mejores prácticas de uso
- Reportar vulnerabilidades

**Para:** Usuarios que quieren usar POETUX de forma segura

---

### 2. [Módulo de Seguridad del Sistema](MODULE.md)
**Archivo:** `docs/security/MODULE.md`

Documenta el **módulo `security.sh`** - fortificación del sistema Pop!_OS:
- UFW (Firewall)
- AppArmor (MAC)
- AIDE (Detección de intrusiones)
- Firejail (Sandboxing)
- Herramientas opcionales (rkhunter, ClamAV, fail2ban, Lynis)

**Para:** Usuarios que quieren endurecer su sistema operativo

---

### 3. [Perfiles de Aplicaciones Reforzados](PROFILES.md)
**Archivo:** `docs/security/PROFILES.md`

Documenta **perfiles de ejecución para aplicaciones específicas**:
- Arquitectura de defensa en profundidad
- Subsistemas del kernel (namespaces, capabilities, seccomp, LSM)
- Perfiles: Cursor, Brave
- Herramientas: AppArmor, Firejail, Systemd hardening

**Para:** Usuarios avanzados que quieren máximo control sobre aplicaciones

---

## 🎯 ¿Qué debo leer?

### Si eres usuario nuevo de POETUX:
1. **Primero:** [`SECURITY.md`](../SECURITY.md)
2. **Después:** [`MODULE.md`](MODULE.md) (si quieres fortificar el sistema)

### Si quieres seguridad máxima:
1. [`MODULE.md`](MODULE.md) - Endurece el sistema base
2. [`PROFILES.md`](PROFILES.md) - Enjaulamiento de aplicaciones

### Si eres desarrollador/auditor:
- Lee los 3 documentos
- Revisa el código en `modules/security.sh`
- Revisa perfiles en `profiles/`, `tools/`

---

## 🔑 Conceptos Clave

### Niveles de Seguridad

```
NIVEL 1: POETUX base
  └─ Instalación segura de paquetes
  └─ Logging, backups

NIVEL 2: Módulo security.sh
  └─ Firewall, AppArmor, AIDE
  └─ Protección del sistema operativo

NIVEL 3: Perfiles de aplicaciones
  └─ Sandboxing avanzado
  └─ Defensa en profundidad kernel-level
```

---

## 📊 Comparación Rápida

| Aspecto | SECURITY.md | MODULE.md | PROFILES.md |
|---------|-------------|-----------|-------------|
| **Alcance** | POETUX tool | Sistema OS | Apps específicas |
| **Dificultad** | Básico | Intermedio | Avanzado |
| **Impacto** | Uso seguro | Sistema robusto | Máxima seguridad |
| **Requiere** | Nada | sudo | Conocimiento kernel |

---

## 🚀 Inicio Rápido

### Seguridad Básica (recomendado para todos)
```bash
# Leer primero
cat docs/SECURITY.md

# Usar POETUX con seguridad
./poet.sh --dry-run  # Revisar cambios
./poet.sh            # Ejecutar
```

### Fortificar Sistema (recomendado para desktop)
```bash
# Leer documentación
cat docs/security/MODULE.md

# Ejecutar módulo
./modules/security.sh
```

### Perfiles Avanzados (opcional, usuarios avanzados)
```bash
# Leer documentación técnica
cat docs/security/PROFILES.md

# Generar perfiles AppArmor
sudo ./tools/generate-apparmor.sh cursor

# Instalar perfiles Firejail
sudo cp profiles/firejail/*.profile /etc/firejail/
```

---

## 🔗 Enlaces Útiles

- [POETUX README](../README.md)
- [Instalación](../INSTALL.md)
- [Estructura del Proyecto](../STRUCTURE.md)

---

**Última actualización:** 5 de Octubre de 2025  
**Versión:** 1.2.0

