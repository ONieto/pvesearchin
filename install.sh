#!/usr/bin/env bash
# pvesearchin — Instalador / Actualizador
#
# Instala o actualiza pvesearchin en el sistema.
# Uso fresco:      curl -fsSL https://raw.githubusercontent.com/ONieto/pvesearchin/main/install.sh | bash
# Actualización:   pvesearchin update
#                  curl -fsSL https://raw.githubusercontent.com/ONieto/pvesearchin/main/install.sh | bash

set -euo pipefail

readonly REPO="ONieto/pvesearchin"
readonly SCRIPT_NAME="pvesearchin"
readonly RAW_URL="https://raw.githubusercontent.com/${REPO}/main/${SCRIPT_NAME}"
readonly VER_URL="https://raw.githubusercontent.com/${REPO}/main/version.txt"

# ── Helpers de color ──
bold()   { printf "\033[1m%s\033[0m" "$*"; }
dim()    { printf "\033[2m%s\033[0m" "$*"; }
green()  { printf "\033[32m%s\033[0m" "$*"; }
yellow() { printf "\033[33m%s\033[0m" "$*"; }
red()    { printf "\033[31m%s\033[0m" "$*"; }
hr()     { printf "%s\n" "────────────────────────────────────────────────────────"; }

echo
printf " %s — %s\n" "$(bold "pvesearchin")" "$(dim "Proxmox VM/CT Search")"
printf " %s\n"       "$(dim "https://github.com/${REPO}")"
hr

# ── Detectar versión remota ──
REMOTE_VERSION=""
if command -v curl >/dev/null 2>&1; then
  REMOTE_VERSION="$(curl -fsSL --max-time 10 "$VER_URL" 2>/dev/null | tr -d '[:space:]')" || true
elif command -v wget >/dev/null 2>&1; then
  REMOTE_VERSION="$(wget -qO- --timeout=10 "$VER_URL" 2>/dev/null | tr -d '[:space:]')" || true
fi
[[ -z "$REMOTE_VERSION" ]] && REMOTE_VERSION="desconocida"

# ── Detectar si ya está instalado ──
IS_UPDATE=false
INSTALLED_VERSION=""
if command -v "$SCRIPT_NAME" >/dev/null 2>&1; then
  IS_UPDATE=true
  INSTALLED_VERSION="$("$SCRIPT_NAME" version 2>/dev/null | awk '{print $2}' || echo '')"
fi

if $IS_UPDATE; then
  printf " %s Actualización detectada\n" "$(yellow '↑')"
  [[ -n "$INSTALLED_VERSION" ]] && printf " → Versión instalada:   %s\n" "$(bold "$INSTALLED_VERSION")"
  printf " → Versión disponible:  %s\n" "$(bold "v${REMOTE_VERSION}")"
else
  printf " %s Instalación nueva\n" "$(green '+')"
  printf " → Versión:  %s\n" "$(bold "v${REMOTE_VERSION}")"
fi

# ── Detectar directorio de instalación ──
INSTALL_DIR=""

if [[ $EUID -eq 0 ]]; then
  INSTALL_DIR="/usr/local/bin"
elif [[ -d "${HOME}/.local/bin" ]] && [[ ":$PATH:" == *":${HOME}/.local/bin:"* ]]; then
  INSTALL_DIR="${HOME}/.local/bin"
elif [[ -d "${HOME}/bin" ]] && [[ ":$PATH:" == *":${HOME}/bin:"* ]]; then
  INSTALL_DIR="${HOME}/bin"
else
  INSTALL_DIR="${HOME}/.local/bin"
  mkdir -p "$INSTALL_DIR"
fi

INSTALL_PATH="${INSTALL_DIR}/${SCRIPT_NAME}"

printf " → Destino:     %s\n" "$(bold "$INSTALL_PATH")"
printf " → Descargando: %s\n" "$(dim "$RAW_URL")"

# ── Descargar a archivo temporal y validar ──
TMP_FILE="$(mktemp)"

if command -v curl >/dev/null 2>&1; then
  curl -fsSL --max-time 30 "$RAW_URL" -o "$TMP_FILE"
elif command -v wget >/dev/null 2>&1; then
  wget -qO "$TMP_FILE" --timeout=30 "$RAW_URL"
else
  printf " %s No se encontró curl ni wget.\n" "$(red '✖')"
  rm -f "$TMP_FILE"
  exit 1
fi

if ! bash -n "$TMP_FILE" 2>/dev/null; then
  printf " %s El archivo descargado no pasó la validación de sintaxis. Abortando.\n" "$(red '✖')"
  rm -f "$TMP_FILE"
  exit 1
fi

chmod +x "$TMP_FILE"
mv "$TMP_FILE" "$INSTALL_PATH"

# ── Verificar PATH ──
IN_PATH=false
if command -v "$SCRIPT_NAME" >/dev/null 2>&1; then
  IN_PATH=true
fi

echo
hr

if $IS_UPDATE; then
  printf " %s Actualización completa" "$(green '✔')"
  [[ -n "$INSTALLED_VERSION" ]] && printf ": %s → %s" \
    "$(bold "$INSTALLED_VERSION")" "$(green "v${REMOTE_VERSION}")"
  printf "\n"
else
  printf " %s Instalación completa.\n" "$(green '✔')"
fi

if ! $IN_PATH; then
  echo
  printf " %s %s no está en tu PATH. Agrega esto a tu ~/.bashrc o ~/.zshrc:\n" \
    "$(yellow '⚠')" "$SCRIPT_NAME"
  printf "\n   %s\n\n" "$(bold "export PATH=\"\$PATH:${INSTALL_DIR}\"")"
  printf "   Luego recarga con: %s\n" "$(bold "source ~/.bashrc")"
fi

echo
printf " → Prueba con:     %s\n" "$(bold "pvesearchin --help")"
printf " → Actualizar:     %s\n" "$(dim "pvesearchin update")"
echo
