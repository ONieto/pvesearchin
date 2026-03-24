# pvesearchin

**Proxmox VM/CT Search** — Herramienta de línea de comandos para buscar, inspeccionar y auditar máquinas virtuales y contenedores (LXC) en múltiples nodos Proxmox VE desde una sola terminal.

```
 _ ____   _____  ___  __ _ _ __ ___| |__ (_)_ __
| '_ \ \ / / _ \/ __|/ _` | '__/ __| '_ \| | '_ \
| |_) \ V /  __/\__ \ (_| | | | (__| | | | | | | |
| .__/ \_/ \___||___/\__,_|_|  \___|_| |_|_|_| |_|
|_|
       Proxmox VM/CT Search — v1.2.0
```

---

## Características

| Funcionalidad | Descripción |
|---|---|
| `search` | Busca VMs/CTs por nombre o VMID con filtros de tipo y estado |
| `nodes` | Inventario completo de todos los nodos (con filtros) |
| `status` | Resumen de CPU, RAM, disco y versión PVE por nodo |
| `orphans` | Detecta VMs/CTs apagadas sin cambios en N días |
| `check-access` | Verifica conectividad SSH y muestra la llave usada por nodo |
| Gestión de servidores | `add`, `remove`, `edit`, `list`, `export`, `import` |
| Ayuda por subcomando | `pvesearchin help <cmd>` o `pvesearchin <cmd> --help` |
| Compatible con PVE 5, 6, 7, 8 y 9 | Usa `qm` y `pct` disponibles en toda instalación Proxmox |

---

## Instalación

### Con curl (recomendado)

```bash
curl -fsSL https://raw.githubusercontent.com/ONieto/pvesearchin/main/install.sh | bash
```

El instalador detecta automáticamente el directorio adecuado:
- `/usr/local/bin` si se ejecuta como **root**
- `~/.local/bin` o `~/bin` si se ejecuta como usuario normal

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

| Herramienta | Dónde se necesita |
|---|---|
| `bash` 4+ | Máquina local |
| `ssh` | Máquina local |
| `qm` | Nodo Proxmox (VMs QEMU) |
| `pct` | Nodo Proxmox (CTs LXC) |
| `pveversion` | Nodo Proxmox (para mostrar versión PVE) |

> `qm`, `pct` y `pveversion` están incluidos en toda instalación de Proxmox VE.

---

## Configuración SSH

`pvesearchin` usa las llaves SSH disponibles en `~/.ssh/` de forma automática (mismo comportamiento que `ssh` estándar con `BatchMode`). No se requiere contraseña.

### Copiar llave al nodo Proxmox

```bash
ssh-copy-id root@pve1.empresa.com
# Con puerto personalizado
ssh-copy-id -p 2222 root@pve2.empresa.com
```

### Verificar acceso previo a usar la herramienta

```bash
pvesearchin check-access
```

---

## Comandos

### Búsqueda — `search`

```bash
# Atajo directo
pvesearchin webserver
pvesearchin 105

# Con subcomando
pvesearchin search webserver
pvesearchin search web --type vm
pvesearchin search prod --status running
pvesearchin search db --type ct --status stopped -v
```

| Opción | Valores | Descripción |
|---|---|---|
| `-T, --type` | `vm` \| `ct` | Filtrar por tipo (default: ambos) |
| `-s, --status` | `running` \| `stopped` | Filtrar por estado (default: todos) |
| `-t, --timeout SEC` | número | Timeout SSH por servidor (default: 10) |
| `-v, --verbose` | — | Mostrar detalles de conexión |

**Ejemplo de salida:**
```
 🔍 Búsqueda:  web  tipo=vm  estado=running
────────────────────────────────────────────────────────────────────────
 ✔ 2 resultado(s) para: "web"

   SERVIDOR           VMID  NOMBRE        TIPO  ESTADO
   ─────────────────  ────  ────────────  ────  ───────
   pve1.empresa.com   101   web-prod      VM    running
   pve3.empresa.com   204   web-staging   VM    running
```

---

### Inventario — `nodes`

Lista todas las VMs y CTs de los nodos, con filtros opcionales.

```bash
pvesearchin nodes                            # todos los nodos
pvesearchin nodes pve1.empresa.com           # un nodo específico
pvesearchin nodes --type vm                  # solo VMs en todos los nodos
pvesearchin nodes --status stopped           # todo lo apagado
pvesearchin nodes --status running           # todo lo encendido
pvesearchin nodes pve2.empresa.com --type ct # CTs de un nodo específico
pvesearchin nodes --names                    # solo nombres, sin tabla
pvesearchin nodes --status stopped --names   # nombres de VMs/CTs detenidas
```

| Opción | Descripción |
|---|---|
| `[host]` | Hostname de un nodo específico (primer argumento, opcional) |
| `-T, --type vm\|ct` | Filtrar por tipo |
| `-s, --status running\|stopped` | Filtrar por estado (`running` = encendidas, `stopped` = detenidas) |
| `-n, --names` | Mostrar únicamente los nombres, sin tabla |
| `-t, --timeout SEC` | Timeout SSH |
| `-v, --verbose` | Detalles de conexión |

---

### Resumen del clúster — `status`

Muestra CPU, RAM, disco, versión de PVE y uptime de cada nodo.

```bash
pvesearchin status                    # todos los nodos
pvesearchin status pve1.empresa.com   # un nodo específico
```

**Ejemplo de salida:**
```
 📊 Resumen del clúster Proxmox
────────────────────────────────────────────────────────────────────────
 ✔ Datos de 3 nodo(s)

   SERVIDOR           NODO  CORES  CARGA  RAM USADA        DISCO /           PVE       UPTIME    VMs  CTs
   ─────────────────  ────  ─────  ─────  ───────────────  ────────────────  ────────  ────────  ───  ───
   pve1.empresa.com   pve1  8      1.23   6144M/16384M     45G/200G (22%)    pve/8.1   15d 4h    12   5
   pve2.empresa.com   pve2  4      0.45   2048M/8192M      20G/100G (20%)    pve/8.1   30d 2h    4    2
   pve3.empresa.com   pve3  16     8.10   14000M/32768M    90G/500G (18%)    pve/7.4   5d 12h    20   8
```

> La columna CARGA se colorea en verde/amarillo/rojo según si supera la mitad o el total de cores.

---

### VMs/CTs huérfanas — `orphans`

Detecta VMs y CTs que están apagadas y cuya configuración no ha cambiado en N días. Útil para identificar recursos abandonados o que ya no se usan.

```bash
pvesearchin orphans                         # todos los nodos, umbral 30 días
pvesearchin orphans --days 14               # umbral de 14 días
pvesearchin orphans pve1.empresa.com        # un nodo específico
pvesearchin orphans pve2.empresa.com --days 7
```

| Opción | Default | Descripción |
|---|---|---|
| `[host]` | todos | Nodo específico (primer argumento) |
| `-d, --days N` | `30` | Días sin cambios para considerar huérfana |
| `-t, --timeout SEC` | `10` | Timeout SSH |

**Ejemplo de salida:**
```
 ⚠ 3 VM(s)/CT(s) candidata(s) a huérfana  (sin cambios ≥ 30 días)

   SERVIDOR           VMID  NOMBRE       TIPO  ESTADO   SIN CAMBIOS
   ─────────────────  ────  ───────────  ────  ───────  ───────────
   pve1.empresa.com   108   test-viejo   VM    stopped  47d
   pve2.empresa.com   210   backup-ct    CT    stopped  62d
   pve2.empresa.com   215   dev-old      VM    stopped  91d
```

> La columna **SIN CAMBIOS** refleja días desde la última modificación del archivo de configuración (`/etc/pve/qemu-server/<vmid>.conf` o `/etc/pve/lxc/<vmid>.conf`). No necesariamente indica cuándo se apagó la VM.

---

### Verificar acceso SSH — `check-access`

Prueba la conectividad SSH a cada servidor configurado y muestra el estado, la versión de PVE y la llave SSH utilizada.

```bash
pvesearchin check-access
pvesearchin check-access --timeout 5
```

**Ejemplo de salida:**
```
 🔑 Verificación de acceso SSH
────────────────────────────────────────────────────────────────────────
 ℹ Verificando 3 servidor(es)...

   [1/3] pve1.empresa.com:22... ✔
   [2/3] pve2.empresa.com:22... ✔
   [3/3] pve3.empresa.com:22... ✖

 📋 Resultado

   SERVIDOR           PUERTO  USUARIO  ESTADO  PVE       LLAVE
   ─────────────────  ──────  ───────  ──────  ────────  ──────────────────────
   pve1.empresa.com   22      root     OK      pve/8.1   /home/user/.ssh/id_rsa
   pve2.empresa.com   22      root     OK      pve/7.4   /home/user/.ssh/id_rsa
   pve3.empresa.com   22      root     FALLO   N/D       —
```

---

## Gestión de servidores

### Agregar

```bash
pvesearchin add pve1.empresa.com
pvesearchin add pve2.empresa.com --user admin --port 2222
```

### Eliminar

```bash
pvesearchin remove pve1.empresa.com
```

### Editar

```bash
pvesearchin edit pve1.empresa.com --port 2222
pvesearchin edit pve1.empresa.com --user adminpve --port 22
```

### Listar

```bash
pvesearchin list
```

### Exportar e importar

```bash
pvesearchin export ~/servidores.txt      # a archivo
pvesearchin export                       # a stdout
pvesearchin import ~/servidores.txt
```

**Formato del archivo:**
```
# pvesearchin server list
pve1.empresa.com:22:root
pve2.empresa.com:2222:admin
pve3.empresa.com:22:root
```

> Las líneas con `#` son ignoradas. Puerto y usuario son opcionales (se usan los defaults si se omiten).

---

## Ayuda integrada

```bash
pvesearchin --help                # ayuda general
pvesearchin help                  # ayuda general
pvesearchin help search           # búsqueda
pvesearchin help nodes            # inventario
pvesearchin help status           # resumen del clúster
pvesearchin help orphans          # VMs huérfanas
pvesearchin help check-access     # verificar SSH
pvesearchin help add              # agregar servidor
pvesearchin help edit             # editar servidor
pvesearchin help import           # importar lista

# También funciona como flag en cada subcomando:
pvesearchin search --help
pvesearchin nodes --help
pvesearchin orphans --help
```

---

## Archivo de configuración

Los servidores se guardan en:

```
~/.config/pvesearchin/servers
```

Puedes editarlo directamente. Cada línea sigue el formato:

```
hostname:puerto:usuario
```

---

## Referencia rápida

| Comando | Descripción |
|---|---|
| `pvesearchin <query>` | Búsqueda directa (atajo) |
| `pvesearchin search <query> [--type vm\|ct] [--status running\|stopped]` | Búsqueda con filtros |
| `pvesearchin nodes [host] [--type] [--status] [--names]` | Inventario de VMs/CTs |
| `pvesearchin status [host]` | Resumen CPU/RAM/disco por nodo |
| `pvesearchin orphans [host] [--days N]` | Detectar VMs/CTs abandonadas |
| `pvesearchin check-access` | Verificar acceso SSH a todos los nodos |
| `pvesearchin add <host> [-u USER] [-p PORT]` | Agregar servidor |
| `pvesearchin remove <host>` | Eliminar servidor |
| `pvesearchin edit <host> [-u USER] [-p PORT]` | Modificar servidor |
| `pvesearchin list` | Listar servidores configurados |
| `pvesearchin export [archivo]` | Exportar listado |
| `pvesearchin import <archivo>` | Importar listado |
| `pvesearchin version` | Ver versión |
| `pvesearchin help [cmd]` | Ayuda general o por subcomando |

---

## Licencia

MIT — libre para uso personal y comercial.
