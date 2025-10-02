# 🚀 Guía de Instalación - POETUX

## Instalación Rápida

```bash
# 1. Clonar repositorio
git clone https://github.com/drhiidden/poetux.git
cd poetux

# 2. Dar permisos de ejecución
chmod +x poet.sh modules/*.sh

# 3. Ejecutar
./poet.sh
```

## Requisitos

- Pop!_OS 22.04+ (o Ubuntu/Debian derivado)
- Conexión a internet
- Permisos de sudo

## Uso

Ejecuta el script principal y selecciona los módulos que necesitas:

```bash
./poet.sh
```

### Ejecutar un módulo específico directamente

También puedes ejecutar módulos individuales:

```bash
./modules/gaming.sh
./modules/dev.sh
```

## Desinstalación

POETUX no modifica archivos del sistema de forma permanente (excepto las instalaciones que tú apruebes). Para "desinstalar":

1. Elimina el directorio de POETUX
2. Si quieres revertir cambios, desinstala los paquetes con `sudo apt remove <paquete>`

## Problemas Comunes

### Error de permisos

```bash
chmod +x poet.sh modules/*.sh
```

### "No se encuentra el directorio modules"

Asegúrate de estar en el directorio correcto:
```bash
cd poetux
./poet.sh
```

### Módulo no funciona

Verifica que tenga permisos de ejecución:
```bash
ls -l modules/
chmod +x modules/<nombre>.sh
```

## Soporte

- Issues: https://github.com/drhiidden/poetux/issues
- Documentación: Ver README.md

