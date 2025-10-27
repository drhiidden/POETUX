# 🛡️ Documentación de Seguridad - POETUX

Esta carpeta contiene la documentación relacionada con los componentes de seguridad de POETUX.

## 📚 Contenido

### 📄 [MODULE.md](MODULE.md)
Documentación completa del **Módulo de Seguridad del Sistema** (`security.sh`).

**Incluye:**
- Configuración de UFW (Firewall)
- Hardening de AppArmor
- AIDE (Advanced Intrusion Detection Environment)
- Firejail para sandboxing de aplicaciones
- Herramientas opcionales (rkhunter, ClamAV, fail2ban, Lynis)
- Hardening adicional del sistema

**Audiencia:** Usuarios que quieren fortificar su sistema Pop!_OS.

---

### 📄 [PROFILES.md](PROFILES.md)
Documentación de **Perfiles de Seguridad Avanzados** para aplicaciones específicas.

**Incluye:**
- Perfil AppArmor reforzado para Cursor
- Perfil AppArmor reforzado para Brave Browser
- Creación de perfiles personalizados

**Audiencia:** Usuarios avanzados que desean aislamiento granular de aplicaciones críticas.

---

### 📄 [BROWSER_SECURITY.md](BROWSER_SECURITY.md) 🆕
Documentación de **Seguridad Avanzada para Navegación y Emulación**.

**Incluye:**
- DNS Seguros (Quad9, Cloudflare, NextDNS)
- Aislamiento avanzado de navegadores con Firejail
- VPN Killswitch para protección de privacidad
- VMs Desechables para máxima seguridad

**Audiencia:** Usuarios que necesitan navegación segura en entornos hostiles.

---

## 🎯 ¿Qué documento leer?

| Si quieres... | Lee... |
|---------------|--------|
| **Fortificar tu sistema completo** | [MODULE.md](MODULE.md) |
| **Aislar aplicaciones específicas** | [PROFILES.md](PROFILES.md) |
| **Navegación y privacidad segura** | [BROWSER_SECURITY.md](BROWSER_SECURITY.md) 🆕 |
| **Todo lo anterior** | Los tres documentos (complementarios) |

---

## 🔐 Niveles de Seguridad

### Nivel 1: Básico (Recomendado para todos)
```bash
./poet.sh → Módulo de Seguridad → Configuración Básica
```
Incluye:
- ✅ UFW (Firewall)
- ✅ AppArmor en modo enforce
- ✅ Firejail con aliases automáticos

### Nivel 2: Avanzado
```bash
./poet.sh → Módulo de Seguridad → Configuración Completa
```
Incluye Nivel 1 +
- ✅ AIDE (detección de intrusiones)
- ✅ DNS Seguros 🆕
- ✅ Herramientas opcionales (rkhunter, ClamAV, etc.)
- ✅ Hardening del sistema (sysctl, core dumps, etc.)

### Nivel 3: Navegación Segura 🆕
```bash
./poet.sh → Módulo de Seguridad → DNS + Browser Isolation + VMs
```
Incluye Nivel 2 +
- ✅ DNS Seguros configurados
- ✅ Aislamiento avanzado de navegadores
- ✅ VPN Killswitch (opcional)
- ✅ Entorno de VMs desechables

### Nivel 4: Paranoia Máxima
Configuración manual con:
- ✅ Todo lo anterior
- ✅ VM desechable con VPN + Tor
- ✅ Perfiles AppArmor personalizados ([PROFILES.md](PROFILES.md))
- ✅ Auditorías periódicas con Lynis
- ✅ Monitoreo continuo de logs

---

## 📖 Documentación Adicional

### En la Raíz del Proyecto

- **[`SECURITY.md`](../../SECURITY.md)**: Política de seguridad de POETUX (herramienta)
  - Cómo reportar vulnerabilidades
  - Prácticas seguras de uso
  - Auditoría del código

### Documentación Oficial

- 🔥 [UFW Documentation](https://help.ubuntu.com/community/UFW)
- 🛡️ [AppArmor Wiki](https://gitlab.com/apparmor/apparmor/-/wikis/home)
- 🔍 [AIDE Manual](https://aide.github.io/)
- 📦 [Firejail Documentation](https://firejail.wordpress.com/)
- 🌐 [WireGuard](https://www.wireguard.com/) 🆕
- 🖥️ [QEMU/KVM](https://www.qemu.org/documentation/) 🆕

---

## 🆘 Preguntas Frecuentes

### ¿Es seguro usar POETUX?
Sí. POETUX es código abierto y auditable. Todas las operaciones están logged y nunca ejecuta comandos privilegiados sin confirmación explícita.

### ¿Puedo usar solo algunas herramientas?
Sí. El módulo de seguridad es completamente modular. Puedes aplicar solo UFW, solo AppArmor, DNS seguros, etc.

### ¿Afectará el rendimiento de mi sistema?
- **UFW**: Impacto insignificante
- **AppArmor**: Impacto mínimo (< 1%)
- **AIDE**: Solo durante escaneos (programados fuera de horas pico)
- **Firejail**: Impacto mínimo (< 2-3%)
- **DNS Seguros**: Ningún impacto (puede ser más rápido) 🆕
- **VPN Killswitch**: Ningún impacto adicional 🆕
- **VMs**: Consume recursos (2-4 GB RAM recomendado) 🆕

### ¿Necesito conocimientos avanzados?
No para el Nivel 1, 2 y 3. POETUX automatiza todo. Para el Nivel 4, se recomienda experiencia con Linux.

### ¿Qué pasó con hidden-browser-security?
hidden-browser-security ha sido **integrado en POETUX v1.3.0**. Todas sus funcionalidades están ahora disponibles en el módulo de seguridad con mejor UX, logging y soporte bilingüe. Ver [BROWSER_SECURITY.md](BROWSER_SECURITY.md).

---

## 🤝 Contribuir

¿Tienes sugerencias de seguridad o encontraste un problema?

- 🐛 [Reportar bug de seguridad](https://github.com/drhiidden/poetux/issues) (marca como `security`)
- 💡 [Sugerir mejora](https://github.com/drhiidden/poetux/discussions)
- 📝 [Contribuir documentación](https://github.com/drhiidden/poetux/pulls)

---

**Última actualización:** Octubre 2025  
**Versión documentada:** POETUX v1.3.0 🆕
