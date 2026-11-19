# ripe-atlas-alpine on RouterOS v7 (anonymized template)
#
# Replace every <PLACEHOLDER> before running. Do not commit real values.
#   <DISK>           external disk name, e.g. disk1
#   <DNS_SERVER>     DNS resolver reachable from the container network
#   <HOST_MAC>       MAC of the veth on the router side
#   <CONTAINER_MAC>  MAC seen by the container
#   <PROBE_ID>       your RIPE Atlas probe id
#
# Requires: container package installed and device-mode container=yes already confirmed.

# --- Storage: keep image extraction and container data off internal memory
/container/config/set tmpdir=<DISK>/tmp

# --- Network: veth for the container, gateway is the bridge address below
/interface/veth/add name=veth-ripe address=172.16.76.4/24 gateway=172.16.76.1 \
    container-mac-address=<CONTAINER_MAC> mac-address=<HOST_MAC> dhcp=no \
    comment=ripe-atlas-probe

# --- Mounts: persistent probe configuration and status on external disk
/container/mounts/add list=atlas-probe-etc src=<DISK>/ripe-atlas/etc dst=/probe/etc/ripe-atlas
/container/mounts/add list=atlas-probe-status src=<DISK>/ripe-atlas/status dst=/probe/var/run/ripe-atlas/status

# --- Container: no entrypoint/cmd override, so the image's tini + init logic runs
/container/add remote-image=ghcr.io/vitokosk8/ripe-atlas-alpine:latest \
    name=ripe-atlas interface=veth-ripe root-dir=<DISK>/images/ripe-atlas \
    mountlists=atlas-probe-etc,atlas-probe-status \
    tmpfs=/tmp:64MiB:01777 workdir=/probe dns=<DNS_SERVER> \
    logging=yes start-on-boot=yes comment="RIPE-ID-<PROBE_ID>"
