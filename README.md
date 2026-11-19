# routeros-ripe-atlas

Español | [English](README.en.md)

Despliegue de la sonda de software [RIPE Atlas](https://atlas.ripe.net/docs/getting-started/what-is-ripe-atlas) como contenedor en MikroTik RouterOS v7, usando la imagen [`ghcr.io/vitokosk8/ripe-atlas-alpine`](https://github.com/vitokosk8/ripe-atlas-alpine).

Los contenedores de RouterOS se describen en la [documentación oficial de MikroTik](https://manual.mikrotik.com/docs/containers/).

## Requisitos

* RouterOS v7 con el paquete `container` instalado.
* Modo contenedor activado con `/system/device-mode/update container=yes`. Hay que confirmarlo en 5 minutos con el botón de reset o con un corte de energía; un reinicio normal lo cancela. Requiere acceso físico al equipo.
* Arquitectura compatible: el paquete soporta arm, arm64 y x86. La imagen se publica para arm/v6, arm/v7 y arm64/v8, entre otras.
* DNS configurado en el router o en el propio contenedor. Sin DNS, el contenedor no arranca.
* Disco externo (USB, SATA o NVMe). La documentación recomienda al menos 100 MB/s de lectura y escritura secuencial y 10K IOPS aleatorias.

## Modelos recomendados

* **Evita los equipos con CPU EN7562CT**, como el hEX Refresh: solo admiten imágenes `arm32v5`, y la imagen de esta sonda no es compatible.
* **Elige un modelo con puerto USB 3.0 o con SATA/M.2**, y con CPU arm64 o arm. Los equipos con 16 MB de memoria flash SPI necesitan forzosamente disco externo para las imágenes.
* Antes de comprar, revisa en la documentación de MikroTik la memoria interna de cada modelo. Los contenedores ocupan bastante espacio, así que el almacenamiento interno no es suficiente para ellos.

## Almacenamiento

Usa siempre disco externo para:

* `root-dir`: donde se guardan la imagen y el contenedor.
* `tmpdir`: donde se descomprime la imagen al descargarla.
* Los mounts de configuración (`/probe/etc/ripe-atlas`) y de estado (`/probe/var/run/ripe-atlas/status`).

La documentación de MikroTik recomienda evitar el almacenamiento interno para los volúmenes del contenedor.

## Instalación

1. Activa el modo contenedor con `/system/device-mode/update container=yes` y confírmalo físicamente.
2. Conecta el disco externo y comprueba su nombre con `/disk print`.
3. Crea el bridge, asigna la IP de gateway y añade la regla de NAT para la red del contenedor:

   ```
   /interface/bridge/add name=bridge-containers
   /ip/address/add address=172.16.76.1/24 interface=bridge-containers
   /ip/firewall/nat/add chain=srcnat src-address=172.16.76.0/24 action=masquerade
   ```

4. Sustituye los placeholders de `routeros/ripe-atlas.rsc` y ejecútalo con `/import`.
5. Añade el veth al bridge (`/interface/bridge/port/add bridge=bridge-containers interface=veth-ripe`) y arranca el contenedor.
6. Registra la sonda con la clave pública `probe_key.pub` en https://atlas.ripe.net/apply/swprobe/. La clave se genera la primera vez que arranca, dentro del mount de configuración.

## Anonimización

El script usa placeholders para los datos sensibles: el disco, el DNS, las MAC, el identificador de la sonda y el comentario RIPE. No subas valores reales al repositorio.

## Licencia

Este proyecto se distribuye bajo la [GNU General Public License v3.0](LICENSE), la misma licencia que el proyecto del que parte la imagen. Más información en la [web de la FSF](https://www.gnu.org/licenses/gpl-3.0.html).
