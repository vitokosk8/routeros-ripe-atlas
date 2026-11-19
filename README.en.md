# routeros-ripe-atlas

[Español](README.md) | English

Deploys the [RIPE Atlas](https://atlas.ripe.net/docs/getting-started/what-is-ripe-atlas) software probe as a container on MikroTik RouterOS v7, using the image [`ghcr.io/vitokosk8/ripe-atlas-alpine`](https://github.com/vitokosk8/ripe-atlas-alpine).

RouterOS containers are documented in the [official MikroTik manual](https://manual.mikrotik.com/docs/containers/).

## Requirements

* RouterOS v7 with the `container` package installed.
* Container mode enabled with `/system/device-mode/update container=yes`. You must confirm it within 5 minutes using the reset button or a power cycle; a regular reboot cancels it. Physical access to the device is required.
* Compatible architecture: the package supports arm, arm64 and x86. The image is published for arm/v6, arm/v7 and arm64/v8, among others.
* DNS configured on the router or on the container. Without DNS, the container will not start.
* External disk (USB, SATA or NVMe). The documentation recommends at least 100 MB/s sequential read/write and 10K random IOPS.

## Recommended models

* **Avoid devices with the EN7562CT CPU**, such as the hEX Refresh: they only support `arm32v5` images, which this probe image does not provide.
* **Choose a model with a USB 3.0 port or SATA/M.2**, with an arm64 or arm CPU. Devices with 16 MB of SPI flash must use an external disk for the images.
* Before buying, check the internal storage of each model in the MikroTik documentation. Containers take a lot of space, so internal storage is not enough for them.

## Storage

Always use external disk for:

* `root-dir`: where the image and container live.
* `tmpdir`: where the image is extracted during pull.
* The configuration mount (`/probe/etc/ripe-atlas`) and the status mount (`/probe/var/run/ripe-atlas/status`).

The MikroTik documentation recommends avoiding internal storage for container volumes.

## Installation

1. Enable container mode with `/system/device-mode/update container=yes` and confirm it physically.
2. Connect the external disk and check its name with `/disk print`.
3. Create the bridge, assign the gateway IP and add the NAT rule for the container network:

   ```
   /interface/bridge/add name=bridge-containers
   /ip/address/add address=172.16.76.1/24 interface=bridge-containers
   /ip/firewall/nat/add chain=srcnat src-address=172.16.76.0/24 action=masquerade
   ```

4. Replace the placeholders in `routeros/ripe-atlas.rsc` and run it with `/import`.
5. Add the veth to the bridge (`/interface/bridge/port/add bridge=bridge-containers interface=veth-ripe`) and start the container.
6. Register the probe using the public key `probe_key.pub` at https://atlas.ripe.net/apply/swprobe/. The key is generated on first start, inside the configuration mount.

## Anonymization

The script uses placeholders for sensitive data: the disk, the DNS server, MAC addresses, the probe ID and the RIPE comment. Do not push real values to the repository.

## License

This project is distributed under the [GNU General Public License v3.0](LICENSE), the same license as the project the image is based on. More information at the [FSF website](https://www.gnu.org/licenses/gpl-3.0.html).
