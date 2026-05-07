# POETUX - Troubleshooting

Soluciones a problemas comunes.

---

## Error: "Permission denied" al ejecutar poet.sh

**Causa**: Falta permisos de ejecución.

**Solución**:
```bash
chmod +x poet.sh modules/*.sh lib/*.sh
./poet.sh
```

---

## Error: "sudo: command not found"

**Causa**: No tienes sudo instalado (poco común en Pop!_OS).

**Solución**:
```bash
# Ejecutar como root
su -
apt install sudo
adduser $USER sudo
# Logout y login de nuevo
```

---

## Error: "Package not found" durante instalación

**Causa**: Repositorios desactualizados.

**Solución**:
```bash
# Actualizar repositorios manualmente
sudo apt update

# Reintentar
./poet.sh
```

---

## Instalación se congela / progreso no avanza

**Causa**: Descarga lenta o paquete grande (ej: Steam, VSCode).

**Solución**:
```bash
# Verificar conexión
ping -c 3 google.com

# Ver logs en tiempo real (otro terminal)
tail -f ~/.poetux/logs/poetux_$(date +%Y%m%d).log

# Si persiste >10 min, Ctrl+C y reintentar
```

---

## Rollback automático no funciona

**Causa**: Lista de paquetes instalados no se guardó.

**Solución**:
```bash
# Desinstalar manualmente
sudo apt remove <paquete-que-fallo>

# O usar apt autoremove
sudo apt autoremove
```

---

## Quiero desinstalar todo lo que POETUX instaló

**Solución**:
```bash
# POETUX guarda logs de instalación en:
cat ~/.poetux/logs/poetux_$(date +%Y%m%d).log | grep "apt install"

# Desinstalar manualmente cada paquete
sudo apt remove steam lutris docker.io ...

# O restaurar snapshot (si usaste opción 7 antes del setup)
```

---

## Steam no se abre después de instalación

**Causa**: Falta inicialización o dependencias de 32-bit.

**Solución**:
```bash
# Reinstalar Steam
sudo apt remove steam -y
sudo apt install steam -y

# Si persiste, habilitar arquitectura 32-bit
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install steam -y
```

---

## Docker requiere sudo

**Causa**: Usuario no está en el grupo `docker`.

**Solución**:
```bash
# Añadir usuario al grupo docker
sudo usermod -aG docker $USER

# Logout y login de nuevo (o ejecutar)
newgrp docker

# Verificar
docker ps
```

---

## OBS no captura pantalla (todo negro)

**Causa**: Problema de permisos Wayland/X11.

**Solución Pop!_OS 22.04+**:
```bash
# Pop!_OS usa Wayland por defecto
# Cambiar a X11 temporalmente:

# Logout
# En login screen, click en tu usuario
# Abajo a la derecha, cambiar de "Pop on Wayland" a "Pop on Xorg"
# Login de nuevo

# Abrir OBS y probar captura
```

---

## Flatpak apps no se actualizan

**Causa**: Flathub no configurado correctamente.

**Solución**:
```bash
# Verificar remotes
flatpak remotes

# Si no aparece "flathub", añadirlo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Actualizar todo
flatpak update -y
```

---

## Error: "E: Could not get lock /var/lib/dpkg/lock-frontend"

**Causa**: Otro proceso apt está corriendo (GUI Software Center, actualizaciones automáticas).

**Solución**:
```bash
# Esperar 2-3 minutos a que termine el otro proceso

# Si persiste, identificar proceso
ps aux | grep apt

# Matar proceso (SOLO si estás seguro que está colgado)
sudo kill -9 <PID>

# Limpiar locks
sudo rm /var/lib/dpkg/lock-frontend
sudo rm /var/lib/dpkg/lock
sudo dpkg --configure -a
```

---

## VSCode no se abre / error "code: command not found"

**Causa**: VSCode instalado pero no en PATH.

**Solución**:
```bash
# Reinstalar desde Flatpak
flatpak install flathub com.visualstudio.code -y

# O desde snap
sudo snap install code --classic

# Verificar
code --version
```

---

## Logs de POETUX

Todos los logs se guardan en:
```
~/.poetux/logs/poetux_YYYYMMDD.log
```

Ver último log:
```bash
tail -f ~/.poetux/logs/poetux_$(date +%Y%m%d).log
```

---

## Reportar un Bug

Si ninguna solución funciona:

1. Busca en [Issues de GitHub](https://github.com/drhiidden/POETUX/issues)
2. Si no existe, crea uno nuevo con:
   - Comando que ejecutaste
   - Output del error
   - Contenido de `~/.poetux/logs/poetux_YYYYMMDD.log`
   - Salida de `lsb_release -a`

---

**Última actualización**: 2026-05-07
