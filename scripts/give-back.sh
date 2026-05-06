#!/bin/bash

# give-back.sh — Auto-star script para POETUX
# Si el setup fue exitoso, pregunta al usuario si quiere dar una estrella al repo

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🎁 POETUX — Give Back${NC}"
echo ""

# 1. Verificar que estamos en Pop!_OS/Ubuntu/Debian
if [[ ! -f /etc/os-release ]]; then
    echo -e "${RED}❌ No se puede detectar el sistema operativo.${NC}"
    exit 1
fi

source /etc/os-release

if [[ "$ID" != "pop" ]] && [[ "$ID" != "ubuntu" ]] && [[ "$ID_LIKE" != *"ubuntu"* ]] && [[ "$ID_LIKE" != *"debian"* ]]; then
    echo -e "${YELLOW}⚠️  POETUX está diseñado para Pop!_OS/Ubuntu/Debian.${NC}"
    echo "   Tu sistema: $NAME"
    echo ""
fi

echo "✅ Sistema compatible: $NAME"

# 2. Verificar que poet.sh existe y es ejecutable
if [[ ! -f "poet.sh" ]]; then
    echo "❌ poet.sh no encontrado. ¿Estás en el directorio correcto?"
    echo "   Ejecuta desde: cd /path/to/POETUX"
    exit 1
fi

if [[ ! -x "poet.sh" ]]; then
    echo "⚠️  poet.sh no es ejecutable. Ejecuta:"
    echo "   chmod +x poet.sh modules/*.sh lib/*.sh"
    exit 1
fi

echo "✅ poet.sh encontrado y ejecutable"

# 3. Verificar logs de instalación (opcional)
if [[ -d "$HOME/.poetux/logs" ]]; then
    LAST_LOG=$(ls -t $HOME/.poetux/logs/poetux_*.log 2>/dev/null | head -1)
    if [[ -n "$LAST_LOG" ]]; then
        echo "✅ Logs de instalación encontrados"
        
        # Verificar si hubo instalaciones exitosas
        if grep -q "apt install" "$LAST_LOG" 2>/dev/null; then
            echo "✅ POETUX ejecutó instalaciones correctamente"
        fi
    fi
fi

echo ""

# 4. Verificar que gh CLI está instalado
if ! command -v gh &> /dev/null; then
    echo "⚠️  gh CLI no encontrado. Necesitas instalarlo para dar estrella automáticamente."
    echo ""
    echo "Opciones:"
    echo "  1. Instalar gh: https://cli.github.com/"
    echo "  2. Dar estrella manualmente: https://github.com/drhiidden/POETUX"
    exit 0
fi

# 5. Verificar que gh está autenticado
if ! gh auth status &> /dev/null; then
    echo "⚠️  gh CLI no está autenticado."
    echo ""
    echo "Ejecuta: gh auth login"
    echo "Luego vuelve a ejecutar este script."
    exit 1
fi

# 6. Preguntar al usuario
echo "✅ POETUX está configurado y funcionando correctamente."
echo ""
echo "Si te gustó el toolkit y te ahorró tiempo, considera darle una estrella en GitHub."
echo "Ayuda a que más gente descubra POETUX."
echo ""
read -p "¿Quieres dar una estrella ahora? (s/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[SsYy]$ ]]; then
    echo ""
    echo "⭐ Dando estrella a drhiidden/POETUX..."
    
    if gh repo star drhiidden/POETUX 2>&1 | grep -q "already starred"; then
        echo -e "${YELLOW}Ya habías dado estrella antes. ¡Gracias!${NC}"
    else
        echo -e "${GREEN}✅ ¡Estrella dada! Gracias por tu apoyo.${NC}"
    fi
else
    echo ""
    echo "No hay problema. Si cambias de opinión:"
    echo "  → https://github.com/drhiidden/POETUX"
    echo ""
    echo "¡Gracias por usar POETUX!"
fi
