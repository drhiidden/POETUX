# Contributing to POETUX

Gracias por considerar contribuir a POETUX. Este documento describe cómo hacerlo de forma efectiva.

---

## 🎯 Tipos de Contribuciones

### 🐛 Bug Reports
- Usa el [issue tracker](https://github.com/drhiidden/POETUX/issues)
- Incluye: OS version, perfil usado, logs (`~/.poetux/logs/`)
- Reproduce el bug antes de reportarlo

### ✨ Feature Requests
- Abre un issue describiendo el caso de uso
- Explica por qué sería útil para la comunidad
- Propón una implementación si tienes ideas

### 🔧 Pull Requests
- Fork el repo → Crea una branch → Haz cambios → Abre PR
- Sigue las convenciones de código (ver abajo)
- Actualiza docs si es necesario
- Prueba en una VM antes de hacer PR

---

## 🏗️ Setup de Desarrollo

```bash
# Fork y clonar
git clone https://github.com/<tu-usuario>/POETUX.git
cd POETUX

# Crear branch para tu feature
git checkout -b feature/nueva-funcionalidad

# Hacer cambios y testear
./poet.sh --dry-run  # Testing sin instalar

# Commit y push
git add .
git commit -m "feat: descripción de tu feature"
git push origin feature/nueva-funcionalidad
```

---

## 📝 Convenciones de Código

### Bash Style
- **Indentación**: 2 espacios (no tabs)
- **Variables**: `snake_case` para locales, `UPPER_CASE` para globales
- **Funciones**: `function nombre_funcion() { ... }`
- **Comentarios**: `#` para explicar *por qué*, no *qué*

### Ejemplo:
```bash
# ✅ CORRECTO
install_gaming_profile() {
  local packages="steam lutris"
  log_info "Installing gaming profile..."
  apt_install "$packages"
}

# ❌ INCORRECTO (sin local, sin logs)
InstallGaming() {
  packages="steam lutris"
  sudo apt install -y $packages
}
```

### Commit Messages
Seguir [Conventional Commits](https://www.conventionalcommits.org/):
- `feat:` Nueva funcionalidad
- `fix:` Corrección de bug
- `docs:` Cambios en documentación
- `refactor:` Refactoring sin cambio de comportamiento
- `test:` Añadir tests

---

## 🧪 Testing

### Testing Manual (VM recomendada)
```bash
# Crear VM con Pop!_OS 22.04
# Clonar tu branch
git clone https://github.com/<tu-usuario>/POETUX.git -b feature/tu-branch
cd POETUX

# Probar en dry-run
./poet.sh --dry-run

# Probar instalación real
./poet.sh

# Verificar logs
tail -50 ~/.poetux/logs/poetux_$(date +%Y%m%d).log
```

### Checklist antes de PR
- [ ] Código funciona en Pop!_OS 22.04
- [ ] Código funciona en Ubuntu 22.04 (opcional pero recomendado)
- [ ] Dry-run pasa sin errores
- [ ] Logs son claros y descriptivos
- [ ] Documentación actualizada (README, docs/)
- [ ] Commit messages siguen Conventional Commits

---

## 📦 Añadir Nuevos Módulos

Si quieres añadir un nuevo perfil (ej: "Data Science"):

1. **Crear módulo**: `modules/datascience.sh`
   ```bash
   #!/bin/bash
   
   install_datascience() {
     log_info "Installing Data Science tools..."
     
     local packages="python3-pip jupyter-notebook pandas numpy"
     apt_install "$packages"
     
     log_success "Data Science profile installed"
   }
   ```

2. **Actualizar menú**: Editar `poet.sh` para añadir opción "7) Data Science"

3. **Actualizar docs**: Añadir sección en `docs/profiles.md`

4. **Probar en VM**: Verificar que funciona

5. **Abrir PR**: Con descripción clara del nuevo módulo

---

## 🤝 Code Review Process

1. Abres PR → Revisión automática (linting básico si existe CI)
2. Maintainer revisa en 3-7 días
3. Se piden cambios si es necesario
4. Una vez aprobado → Merge a `main`
5. Nueva release en el próximo ciclo

---

## 📜 Licencia

Al contribuir, aceptas que tus cambios se publiquen bajo la [Licencia MIT](LICENSE).

---

## 💬 Contacto

- **Issues**: https://github.com/drhiidden/POETUX/issues
- **Discussions**: https://github.com/drhiidden/POETUX/discussions

---

**Gracias por contribuir a POETUX!** 🎉
