# HomeLab Router

## Introduction

This project is mainly for testing cloud-init router configurations in a quickly buildable and destroyable environment, separate from the more advanced projects like Regulus Kubernetes.

## Bill of Materials

- A specific `Proxmox Virtual Network Bridge` for this project
- Two Virtual Machines:
  - A router VM that hooks into the HomeLab Network `10.0.0.0/16` or `10.0.0.0/24`
    - Interface 1 will live on 10.0.0.0 and get a DHCP address
    - Interface 2 will live on the bridge network `192.168.128.0/24`
  - A Private VM sitting behind the bridge, configured with an address on `192.168.128.0/24`

## Things to test

- Cloud-Init `optional: true` on interfaces that have no DHCP
  - [x] This worked when adding optional:true on EVERY interface on the router.
- ~~Early Hacking of `network-wait-online.service` - is it possible?~~ Not Required
- ~~Start system up with the interface in a `disconnected` state, then bring online post-boot.~~ Not Required

## Log

| Date | Log |
| --- | --- |
| 2026-06-02 | Testing recreating assets using reusable workflows - Assessment 2 |
| 2026-06-02 | Decommissioning resources for now using a `decom/homelab-router` branch |
