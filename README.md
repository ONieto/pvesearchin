# pvesearchin

**Proxmox VM/CT Search** — Herramienta de línea de comandos para buscar máquinas virtuales y contenedores (LXC) por nombre o VMID en múltiples nodos Proxmox VE desde una sola terminal.

```
 _ ____   _____  ___  __ _ _ __ ___| |__ (_)_ __
| '_ \ \ / / _ \/ __|/ _` | '__/ __| '_ \| | '_ \
| |_) \ V /  __/\__ \ (_| | | | (__| | | | | | | |
| .__/ \_/ \___||___/\__,_|_|  \___|_| |_|_|_| |_|
|_|
```

---

## Características

- Busca VMs y CTs simultáneamente en todos los nodos configurados
- Tabla de resultados con servidor, VMID, nombre, tipo y estado
- Gestión del listado de servidores: `add`, `remove`, `edit`, `list`
- Exportación e importación de listados de servidores
- Conexión vía SSH con llaves automáticas (sin contraseña)
- Ayuda integrada por subcomando (`pvesearchin help <cmd>`)
- Compatible con Proxmox VE 5, 6, 7 y 8

---

## Instalación

### Con curl (recomendado)

```bash
curl -fsSL https://raw.githubusercontent.com/ONieto/pvesearchin/main/install.sh | bash
```

El instalador detecta automáticamente el directorio adecuado:
- `/usr/local/bin` si se ejecuta como **root**
- `~/.local/bin` o `~/bin` si se ejecuta como **usuario normal**

### Manual

```bash
curl -fsSL https://raw.githubusercontent.com/ONieto/pvesearchin/main/pvesearchin \
  -o /usr/local/bin/pvesearchin
chmod +x /usr/local/bin/pvesearchin
```

### Verificar instalación

```bash
pvesearchin version
pvesearchin --help
```

---

## Requisitos

| Herramienta | Dónde se necesita  |
|-------------|--------------------|
| `bash` 4+   | Máquina local      |
| `ssh`       | Máquina local      |
| `qm`        | Nodo Proxmox (VMs) |
| `pct`       | Nodo Proxmox (CTs) |

> `qm` y `pct` están incluidos en toda instalación de Proxmox VE.

---

## Configuración SSH

`pvesearchin` usa las llaves SSH disponibles en `~/.ssh/` de forma automática (mismo comportamiento que `ssh` estándar con `BatchMode`). No se requiere contraseña.

### Copiar llave al nodo Proxmox

```bash
ssh-copy-id root@pve1.empresa.com
# o con puerto personalizado
ssh-copy-id -p 2222 root@pve2.empresa.com
```

### Verificar acceso

```bash
ssh root@pve1.empresa.com qm list
```

---

## Uso

### Búsqueda

```bash
# Atajo directo (sin subcomando)
pvesearchin miservidor.com
pvesearchin 105
pvesearchin web

# Con subcomando explícito
pvesearchin search miservidor.com
pvesearchin search 105 --verbose
pvesearchin search web --timeout 5
```

**Opciones de `search`:**

| Opción | Default | Descripción |
|--------|---------|-------------|
| `-t, --timeout SEC` | `10` | Timeout SSH por servidor (segundos) |
| `-v, --verbose` | — | Muestra detalles de conexión |
| `-h, --help` | — | Ayuda del subcomando |

**Ejemplo de salida:**

```
 _ ____   _____  ___  __ _ _ __ ___| |__ (_)_ __
...
       Proxmox VM/CT Search — v1.0.0

 🔍 Búsqueda:  webserver
 🗓  2026-03-19 10:45:01
────────────────────────────────────────────────────────────────────────
 ℹ Consultando 3 servidor(es)...

   [1/3] pve1.empresa.com
   [2/3] pve2.empresa.com
   [3/3] pve3.empresa.com

────────────────────────────────────────────────────────────────────────
 ✔ 2 resultado(s) para: "webserver"

   SERVIDOR           VMID  NOMBRE          TIPO  ESTADO
   ─────────────────  ────  ──────────────  ────  ───────
   pve1.empresa.com   101   webserver-prod  VM    running
   pve3.empresa.com   205   webserver-dev   CT    stopped

────────────────────────────────────────────────────────────────────────
 ✔ FIN  (servidores: 3 | errores: 0 | resultados: 2)
```

---

## Gestión de servidores

### Agregar

```bash
pvesearchin add pve1.empresa.com
pvesearchin add pve2.empresa.com --user admin --port 2222
```

| Opción | Default | Descripción |
|--------|---------|-------------|
| `-u, --user USER` | `root` | Usuario SSH |
| `-p, --port PORT` | `22` | Puerto SSH |

### Eliminar

```bash
pvesearchin remove pve1.empresa.com
```

### Editar

```bash
pvesearchin edit pve1.empresa.com --user root --port 22
```

### Listar

```bash
pvesearchin list
```

```
 📋 Servidores Proxmox configurados
────────────────────────────────────────────────────────────────────────
   #  HOSTNAME            PUERTO  USUARIO
   ─  ──────────────────  ──────  ───────
   1  pve1.empresa.com    22      root
   2  pve2.empresa.com    2222    admin
   3  pve3.empresa.com    22      root

 ✔ Total: 3 servidor(es)
```

---

## Exportar e importar servidores

### Exportar a archivo

```bash
pvesearchin export ~/mis_servidores.txt
```

### Exportar a stdout (para pipelines)

```bash
pvesearchin export
```

### Importar

```bash
pvesearchin import ~/mis_servidores.txt
```

**Formato del archivo:**

```
# pvesearchin server list
pve1.empresa.com:22:root
pve2.empresa.com:2222:admin
pve3.empresa.com:22:root
```

> Las líneas que comienzan con `#` son ignoradas. El puerto y usuario son opcionales (se usan los defaults si se omiten).

---

## Ayuda integrada

```bash
pvesearchin --help            # ayuda general
pvesearchin help              # ayuda general
pvesearchin help search       # ayuda del subcomando search
pvesearchin help add          # ayuda del subcomando add
pvesearchin help edit         # ayuda del subcomando edit
pvesearchin help import       # ayuda del subcomando import
pvesearchin search --help     # también funciona por subcomando
pvesearchin add --help
```

---

## Archivo de configuración

Los servidores se guardan en:

```
~/.config/pvesearchin/servers
```

Puedes editarlo directamente con cualquier editor de texto. Cada línea sigue el formato:

```
hostname:puerto:usuario
```

---

## Referencia rápida de comandos

| Comando | Descripción |
|---------|-------------|
| `pvesearchin <query>` | Búsqueda directa |
| `pvesearchin search <query>` | Búsqueda (con opciones) |
| `pvesearchin add <host>` | Agregar servidor |
| `pvesearchin remove <host>` | Eliminar servidor |
| `pvesearchin edit <host>` | Modificar servidor |
| `pvesearchin list` | Listar servidores |
| `pvesearchin export [archivo]` | Exportar listado |
| `pvesearchin import <archivo>` | Importar listado |
| `pvesearchin version` | Ver versión |
| `pvesearchin help [cmd]` | Ayuda general o por subcomando |

---

## Licencia

MIT — libre para uso personal y comercial.
