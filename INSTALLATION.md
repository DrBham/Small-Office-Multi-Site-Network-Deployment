# 🧰 Lab Setup & Reproduction Guide

**NDS-NET-001 · Small Office Multi-Site Network Deployment**

> This document explains how to prepare an environment for studying and rebuilding the simulated NDS network. It is **not** a one-click deployment guide. The repository provides a GNS3 topology definition and RouterOS configuration exports; it does not include virtual machine disks, RouterOS licenses, or a complete running lab.

[← Project Overview](README.md) · [Troubleshooting Cases](troubleshooting/)

---

## 🧭 Lab at a Glance

<table>
<tr><td width="50%" valign="top">

**Network Infrastructure**

- 3 MikroTik CHR routers: HQ, ISP, Branch
- 2 Ethernet switches
- 4 VPCS clients (2 per office)
- 1 Docker Nginx server at HQ

</td><td width="50%" valign="top">

**Reference Environment**

- GNS3 **2.2.61** and GNS3 VM
- Oracle VirtualBox
- MikroTik RouterOS CHR **7.23.8**
- Docker image `nginx:alpine`
- WinBox / RouterOS CLI / SSH

</td></tr>
</table>

## 📦 Repository Files

| File | Purpose |
|---|---|
| [`assets/network-topology.png`](assets/network-topology.png) | Visual reference for node placement and connections |
| [`assets/Small-Office-Multi-Site-Network-Deployment.gns3`](assets/Small-Office-Multi-Site-Network-Deployment.gns3) | GNS3 topology/project definition |
| [`configurations/NDS-CHR-HQ-FINAL.rsc`](configurations/NDS-CHR-HQ-FINAL.rsc) | Final HQ RouterOS text export |
| [`configurations/NDS-CHR-ISP-FINAL.rsc`](configurations/NDS-CHR-ISP-FINAL.rsc) | Final ISP RouterOS text export |
| [`configurations/NDS-CHR-BRANCH-FINAL.rsc`](configurations/NDS-CHR-BRANCH-FINAL.rsc) | Final Branch RouterOS text export |
| [`troubleshooting/`](troubleshooting/) | Three independently documented fault/recovery cases |

## 1 · Prepare the Host Environment

1. Install **GNS3**, **Oracle VirtualBox**, and the **GNS3 VM** appropriate to your host. Enable the GNS3 VM connection in GNS3 settings.
2. Prepare **three MikroTik CHR instances** compatible with RouterOS 7.23.8. Obtain CHR images and licensing directly through the appropriate MikroTik channels; they are **not distributed** here.
3. Ensure the GNS3 environment has **VPCS**, Ethernet switch nodes, and a Docker-capable server for `nginx:alpine`. Download the container image separately if required.
4. Configure a VirtualBox **Host-Only network** using `192.168.56.0/24` for management, with DHCP as required by the local setup. The original lab used dynamic management addressing, so actual IPs may differ.
5. Keep router management access available through **ether1** while configuring the WAN/LAN interfaces. Avoid exposing the lab management segment to an untrusted network.

**Prerequisite check:** CHR nodes boot, the management network is reachable, and GNS3 can start the required node types before applying network configuration.

## 2 · Open or Rebuild the Topology

1. Work in a **separate lab copy**, not the original operating project.
2. In GNS3, use **File → Open Project** and select the supplied `.gns3` file, if supported by your local GNS3 configuration.
3. Resolve missing templates or node references by mapping them to the locally installed MikroTik CHR, VPCS, switch, and Nginx resources. A `.gns3` file may reference existing VirtualBox VMs or templates that do not exist on another computer.
4. Compare the diagram with [`network-topology.png`](assets/network-topology.png). Confirm **3 routers, 2 switches, 4 VPCS, 1 HQ server**, with the HQ–ISP–Branch transit and both LANs connected correctly.
5. Verify **interface-to-link mappings before loading any router configuration**. The final exports assume the interface assignments shown below.

If the project cannot be opened directly because required resources or a project server are missing, **rebuild the nodes and links manually from the diagram**. A portable GNS3 archive or VM disk images are not provided in this repository.

## 3 · Network Addressing Reference

<table>
<tr><td width="50%" valign="top">

**HQ LAN**

- Network: `172.22.10.0/26`
- Gateway (`HQ ether3`): `172.22.10.1`
- DHCP pool: `172.22.10.20–172.22.10.59`
- Nginx HTTP server: `172.22.10.10/26` (gateway `172.22.10.1`), TCP 80

</td><td width="50%" valign="top">

**Branch LAN**

- Network: `172.22.20.0/27`
- Gateway (`BRANCH ether3`): `172.22.20.1`
- DHCP pool: `172.22.20.10–172.22.20.29`
- No Branch server

</td></tr>
</table>

| Router | Interface | Address / Role |
|---|---|---|
| HQ | `ether1` | VirtualBox Host-Only management via DHCP |
| HQ | `ether2` | `10.255.10.1/30` → ISP |
| HQ | `ether3` | `172.22.10.1/26` → HQ LAN |
| ISP | `ether1` | VirtualBox Host-Only management via DHCP |
| ISP | `ether2` | `10.255.10.2/30` → HQ |
| ISP | `ether3` | `10.255.10.5/30` → Branch |
| BRANCH | `ether1` | VirtualBox Host-Only management via DHCP |
| BRANCH | `ether2` | `10.255.10.6/30` → ISP |
| BRANCH | `ether3` | `172.22.20.1/27` → Branch LAN |

### Static Route Reference

| Router | Destination | Next hop |
|---|---|---|
| HQ | `172.22.20.0/27` | `10.255.10.2` |
| ISP | `172.22.10.0/26` | `10.255.10.1` |
| ISP | `172.22.20.0/27` | `10.255.10.6` |
| BRANCH | `172.22.10.0/26` | `10.255.10.5` |
| BRANCH | `10.255.10.1/32` | `10.255.10.5` (HQ WAN HTTP demonstration) |

## 4 · RouterOS Configuration: Safe Approach

**The `.rsc` files are configuration snapshots, not changesets.** Importing them on an already configured router may duplicate objects, conflict with existing settings, or interrupt management access. A plain-text export also does not reproduce every operational state, account password, certificate, or VM setting.

Recommended process for a **disposable test VM only**:

1. Keep a private backup of any existing configuration and retain **GNS3 console access**.
2. Verify the target CHR version, physical interface numbering, and node identity match the export intended for **HQ**, **ISP**, or **BRANCH**. Review the file text before applying it.
3. Prepare a **new, otherwise unconfigured CHR** using the appropriate RouterOS configuration procedure; do not reset a working router merely to try this repository.
4. Inspect the corresponding final `.rsc` and review the import syntax. RouterOS supports a *dry run* in verbose mode for catching syntax issues, for example:

   ```routeros
   /import file-name=NDS-CHR-HQ-FINAL.rsc verbose=yes dry-run
   ```

   The file must first be uploaded to the router. Replace the filename with the file appropriate to the target router. A successful dry run **does not guarantee** that all dependencies or interfaces are correct.
5. If the fresh lab configuration is compatible, apply it using the documented RouterOS import process or configure its sections deliberately through WinBox/CLI. Validate interface mapping, DHCP, routes, firewall rule order, and NAT afterward. Do **not** import the troubleshooting fault snapshots as baseline configurations.
6. Configure the HQ Docker Nginx container with `172.22.10.10/26`, gateway `172.22.10.1`, and HTTP port 80 according to the local GNS3 Docker networking model. Docker addressing and persistence are not restored by a RouterOS `.rsc` file.

For exact RouterOS import and reset semantics, see [MikroTik Configuration Management](https://help.mikrotik.com/docs/spaces/ROS/pages/328155/Configuration%2BManagement). A reset clears the active configuration and must **not** be used on the functioning original NDS environment.

## 5 · Basic Verification

Run the following only **after** the topology and intended configurations are in place.

| Check | Expected result |
|---|---|
| HQ and Branch VPCS DHCP | Addresses in their respective configured pools, correct `/26` or `/27` gateway |
| HQ–ISP and ISP–Branch neighbor communication | WAN neighbors reachable |
| Static routing | Expected routes active in each relevant RouterOS route table |
| `PC-HQ-01` → `PC-BR-01` | ICMP replies (original lab: 5/5) |
| `PC-BR-01` → `PC-HQ-01` | ICMP replies (original lab: 5/5) |
| Router-originated direct HTTP from Branch | HTTP 200 at `http://172.22.10.10/` |
| Router-originated HQ WAN DST-NAT HTTP from Branch | HTTP 200 at `http://10.255.10.1:80/` |
| Firewall security controls | INPUT/FORWARD default-drop present; management limited to Host-Only network |

**Validation scope:** HTTP was tested using **RouterOS Fetch on the Branch router**, with source `172.22.20.1`. Direct HTTP requests from a Branch LAN client were **not** independently validated; this reproduction guide does not claim otherwise.

## 🔒 Scope, Safety & Limitations

- The ISP is a **private simulated transit router**, not the public Internet.
- No VPN, TLS-protected internal HTTP service, WAN redundancy, or public Internet deployment is included.
- Do not use the uploaded exports as a security-hardened production configuration.
- Do not publish RouterOS binary backups, VM disk images, credentials, private keys, or raw secret-bearing exports.
- VirtualBox VM identities, MAC addresses, DHCP management addresses, template references, and GNS3 runtime environment can differ between machines.
- Reproducing the topology and importing configuration on a new environment **has not been independently demonstrated** as a turnkey installation.

---

[← Project Overview](README.md) · [Explore Troubleshooting](troubleshooting/)
