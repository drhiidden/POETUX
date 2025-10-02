# 🔒 Seguridad en POETUX

> **Última actualización:** 2 de Octubre de 2025  
> **Versión:** 1.2.0

Este documento describe las medidas de seguridad implementadas en POETUX y las mejores prácticas para su uso seguro.

---

## 📋 Tabla de Contenidos

1. [Medidas de Seguridad Implementadas](#medidas-de-seguridad-implementadas)
2. [Modo Dry Run](#modo-dry-run)
3. [Sistema de Logging](#sistema-de-logging)
4. [Backup y Recuperación](#backup-y-recuperación)
5. [Verificación de Integridad](#verificación-de-integridad)
6. [Mejores Prácticas](#mejores-prácticas)
7. [Reportar Vulnerabilidades](#reportar-vulnerabilidades)

---

## 🛡️ Medidas de Seguridad Implementadas

### 1. No Ejecución como Root

```bash
✗ Error: No ejecutes este script como root. Usará sudo cuando sea necesario.
```

POETUX **rechaza la ejecución como root** para evitar cambios accidentales con privilegios elevados. El script usa `sudo` solo cuando es absolutamente necesario.

### 2. Confirmación Explícita

Cada instalación requiere confirmación explícita del usuario:

```bash
¿Instalar Steam? (s/n): _
```

- ✅ No instala nada sin permiso
- ✅ El usuario tiene control total
- ✅ Puede cancelar en cualquier momento

### 3. Modo Dry Run

```bash
./poet.sh --dry-run
```

Vista previa de **todos los cambios** sin ejecutarlos realmente:

```
[DRY RUN] Would execute: sudo apt install steam
[DRY RUN] Would execute: flatpak install com.heroicgameslauncher.hgl
```

**Beneficios:**
- Ver qué hará el script antes de ejecutarlo
- Ideal para auditorías y revisión de seguridad
- Sin riesgo de cambios no deseados

### 4. Sistema de Logging Completo

Todas las operaciones se registran automáticamente:

```
~/.local/share/poetux/logs/poetux_20251002_143052.log
```

**Contenido del log:**
```
[2025-10-02 14:30:52] [INFO] User confirmed: Install Steam?
[2025-10-02 14:30:55] [INFO] Executing: sudo apt install steam
[2025-10-02 14:31:10] [SUCCESS] Package installed: steam
```

**Uso:**
- Auditoría completa de cambios
- Debugging de problemas
- Historial de instalaciones

### 5. Snapshots Automáticos

POETUX crea un **snapshot inicial automáticamente**:

```
Creating initial system snapshot...
✓ Backup snapshot created: initial_20251002
```

**Contiene:**
- Lista de paquetes APT instalados
- Lista de aplicaciones Flatpak
- PPAs configurados
- Información del sistema

### 6. Verificación de Paquetes Instalados

Antes de instalar, POETUX verifica si el paquete ya existe:

```bash
if is_package_installed "steam"; then
    print_info "Steam ya está instalado"
fi
```

**Beneficios:**
- Evita reinstalaciones innecesarias
- Ahorra tiempo y ancho de banda
- Reduce riesgo de conflictos

### 7. Código Abierto y Auditable

```bash
# Todo el código es visible y auditable
cat poet.sh
cat modules/gaming.sh
cat lib/common.sh
```

- ✅ Código abierto en GitHub
- ✅ Sin ofuscación
- ✅ Comentarios explicativos
- ✅ Fácil de revisar

---

## 🧪 Modo Dry Run

### ¿Qué es?

El modo **Dry Run** ejecuta el script completo pero **sin hacer cambios reales** en el sistema.

### Cómo Usarlo

```bash
./poet.sh --dry-run
```

### Ejemplo de Salida

```
[DRY RUN MODE ENABLED - No changes will be made]

═══════════════════════════════════════
  Menú Principal
═══════════════════════════════════════
  1) Configuración Básica
  ...
  
Selecciona una opción: 2

[DRY RUN] Would execute: sudo apt install steam
[DRY RUN] Would execute: sudo apt install lutris
[DRY RUN] Would execute: flatpak install com.heroicgameslauncher.hgl
```

### Casos de Uso

1. **Auditoría de seguridad**
   ```bash
   ./poet.sh --dry-run | tee audit.log
   ```

2. **Revisión antes de instalación**
   ```bash
   # Primero revisar
   ./poet.sh --dry-run
   
   # Si todo está bien, ejecutar
   ./poet.sh
   ```

3. **Documentación de cambios**
   ```bash
   ./poet.sh --dry-run > cambios_planeados.txt
   ```

---

## 📝 Sistema de Logging

### Ubicación de Logs

```
~/.local/share/poetux/logs/
├── poetux_20251002_143052.log
├── poetux_20251002_150320.log
└── poetux_20251003_091545.log
```

### Formato de Log

```
[TIMESTAMP] [LEVEL] MESSAGE
```

**Niveles:**
- `INFO`: Información general
- `WARNING`: Advertencias no críticas
- `ERROR`: Errores que requieren atención
- `SUCCESS`: Operaciones exitosas

### Ver Logs

```bash
# Último log
tail -f ~/.local/share/poetux/logs/poetux_*.log

# Buscar errores
grep ERROR ~/.local/share/poetux/logs/*.log

# Ver logs de una fecha específica
cat ~/.local/share/poetux/logs/poetux_20251002_*.log
```

---

## 💾 Backup y Recuperación

### Snapshots Automáticos

POETUX crea snapshots automáticamente:

1. **Snapshot inicial**: Al primer uso
2. **Snapshots manuales**: Opción 7 del menú

### Crear Snapshot Manual

```
Menú Principal → 7) Backup y Restauración → 1) Crear snapshot
```

### Contenido del Snapshot

```
~/.local/share/poetux/backups/manual_20251002/
├── dpkg_selections.txt      # Paquetes APT
├── apt_auto.txt             # Paquetes automáticos
├── apt_manual.txt           # Paquetes manuales
├── flatpak_list.txt         # Aplicaciones Flatpak
├── ppas.txt                 # Repositorios PPA
└── system_info.txt          # Info del sistema
```

### Comparar con Snapshot

Ver diferencias entre el sistema actual y un snapshot:

```
Menú Principal → 7) Backup y Restauración → 3) Ver diferencias
```

**Salida:**
```
APT Packages:
  - New packages: 15
  - Removed packages: 2

Flatpak Apps:
  - Snapshot had: 10
  - Currently has: 12
  - Difference: +2
```

### Exportar Lista de Paquetes

```
Menú Principal → 7) Backup y Restauración → 4) Exportar lista
```

Genera: `~/poetux_packages_20251002.txt`

---

## 🔍 Verificación de Integridad

### Verificación Manual

Puedes verificar manualmente la integridad de los scripts:

```bash
# Verificar checksums (si están disponibles)
sha256sum -c checksums.txt

# Comparar con repositorio oficial
git diff origin/main
```

### Firma GPG (Futuro)

**Planificado para v1.2.0:**

```bash
# Verificar firma GPG del release
gpg --verify poetux-1.2.0.tar.gz.asc
```

---

## ✅ Mejores Prácticas

### 1. Usar Dry Run Primero

```bash
# Siempre revisar antes de ejecutar
./poet.sh --dry-run

# Si todo está bien
./poet.sh
```

### 2. Crear Snapshots Regulares

```bash
# Antes de instalar muchos paquetes
Menú → 7) Backup → 1) Crear snapshot
```

### 3. Revisar Logs Después de Instalación

```bash
tail -n 50 ~/.local/share/poetux/logs/poetux_*.log
```

### 4. No Ejecutar como Root

```bash
# ❌ INCORRECTO
sudo ./poet.sh

# ✅ CORRECTO
./poet.sh
```

### 5. Mantener POETUX Actualizado

```bash
git pull origin main
./poet.sh --help  # Verificar nueva versión
```

### 6. Revisar Código Antes de Ejecutar

```bash
# Especialmente si clonaste de fuente no oficial
cat poet.sh
cat modules/*.sh
```

### 7. Usar Solo Repositorios Oficiales

POETUX usa solo:
- ✅ Repositorios oficiales de Pop!_OS/Ubuntu
- ✅ Flathub oficial
- ✅ PPAs oficiales y conocidos (OBS, Docker, NodeSource)

---

## 🚨 Reportar Vulnerabilidades

### Proceso de Reporte

Si encuentras una vulnerabilidad de seguridad:

1. **NO la hagas pública** inmediatamente
2. Envía un reporte privado a: [tu-email@ejemplo.com]
3. Incluye:
   - Descripción detallada
   - Pasos para reproducir
   - Impacto potencial
   - Sugerencias de solución (opcional)

### Respuesta Esperada

- **< 48 horas**: Confirmación de recepción
- **< 7 días**: Evaluación inicial
- **< 30 días**: Solución o plan de mitigación

### Reconocimiento

Los reportadores de vulnerabilidades serán reconocidos en:
- CHANGELOG.md
- SECURITY.md
- README.md (si lo desean)

---

## 🔐 Limitaciones de Seguridad Conocidas

### 1. Scripts No Firmados (v1.2.0)

**Problema:** Los scripts no están firmados digitalmente

**Mitigación Actual:**
- Código abierto y auditable
- Disponible en GitHub con historial completo
- Sistema de rollback automático

**Solución Futura:** Firmas GPG en v1.3.0

### 2. Requiere Privilegios Sudo

**Problema:** Instalación de paquetes requiere sudo

**Mitigación Actual:**
- Pregunta antes de cada instalación
- Modo dry-run para preview
- Logging completo

**Limitación Inherente:** Necesario para instalación de software

### 3. Sin Sandbox

**Problema:** Scripts ejecutan directamente en el sistema

**Mitigación Actual:**
- `set -euo pipefail` para detener en errores
- Verificaciones previas
- Logging completo

**Solución Futura:** Testing en contenedores (v1.3.0)

### 4. Dependencias de Terceros

**Problema:** Instalación desde PPAs externos

**Mitigación Actual:**
- Solo PPAs oficiales y reconocidos
- Lista explícita en documentación

**Mejora Futura:** Validación de checksums de repositorios

---

## 📚 Referencias

- [OWASP Shell Injection](https://owasp.org/www-community/attacks/Command_Injection)
- [Bash Security Best Practices](https://mywiki.wooledge.org/BashGuide/Practices)
- [Linux Security Hardening](https://www.cisecurity.org/cis-benchmarks/)

---

## 📞 Contacto de Seguridad

- **Email:** [tu-email-seguridad@ejemplo.com]
- **PGP Key:** [fingerprint]
- **GitHub Security:** https://github.com/drhiidden/poetux/security

---

**Última revisión:** 2 de Octubre de 2025  
**Próxima revisión:** Q1 2026  
**Versión de documento:** 1.2.0

