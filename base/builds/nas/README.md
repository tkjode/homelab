# NAS Build

## Intro

This repository builds a NAS VM configured for the following:

- USB Passthru + Mounts the USB3.2 DAS storage that should be connected directly to the Proxmox server
- CIFS/SMB+Workgroup+Shares config that allows Windows users to browse and manage files
- NFS exports for:
  - USB3.2 Disks
  - 512GB of SSD - Used for Very Fast Storage over Network


```text
[ DAS ] ==> USBPass --\ VM NAS: mnt-nas/  ==> Exported as CIFS+NFS::/srv/nas/
[ SSD ] ==> Proxmox --/ VM NAS: mnt-ssd/  ==> Exported as NFS-Fast::/srv/ssd/
```

Regulus: Kubernetes StorageClasses will be configured for SSD NAS Mounts for high-speed utility, and the normal NAS mount will be used as final media storage location.

SSD NAS mounts may also be used for ElasticSearch ingest working folders to reduce IO on the DAS.

## Build

Winning combination of Terraform + Cloud-Init using Ubuntu Cloud Server will be used.

We will keep a separate unique ISO copy for this NAS build to allow de-coupling from the Regulus build, which also supplpies an Ubuntu Cloud Server image.

### Checklist

- [ ] Server builds and binds to static IP on home network, DNS configured and is accessible
- [ ] GitHub User ID imported, SSH accessible
- [ ] Storage folders for SSD and DAS created under mount and set immutable
- [ ] fstab customizations patched at boot time:
  - [ ] USB DAS mounted and available under `/mount`
  - [ ] SSD disk image mounted and storage available under `/mount`
- [ ] Links created under `/srv` to mounted storage under `/mount`
- [ ] samba.conf patched to share DAS from `/srv`
- [ ] nfs.conf patched to export both DAS and SSD from `/srv`

Some things to think about:
- SAMBA Configuration
  - legacy configuration of `xbmc` user with a static password?
  - Multi-user setup with better permissions?
- NFS Configuration
  - Replicate current flexo configuration
  - or improve on NFS/CIFS permissions bindings
