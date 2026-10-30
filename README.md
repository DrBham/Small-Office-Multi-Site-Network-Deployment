# Small Office Multi-Site Network Deployment

**MikroTik RouterOS | GNS3 | Network Design & Implementation**

A simulated network deployment for **PT Nusa Digital Solusi**, a fictional IT services company operating a headquarters (HQ) and a branch office. This project demonstrates a practical, MTCNA-level small-office network: IPv4 addressing, DHCP services, routed WAN connectivity, basic firewall policy, and access to an internal HTTP server.

> **Project state (30 October 2026):** LAN addressing, DHCP, directly connected WAN links, and local HTTP service have been verified. Inter-site static routing, firewall policy verification, and branch-to-HQ service access are planned and **not yet validated**.

## Business Requirements

| Location | Planning capacity | Required services |
| --- | ---: | --- |
| Headquarters | 25 users | LAN, DHCP, internal HTTP server, branch connectivity |
| Branch Office | 10 users | LAN, DHCP, access to HQ resources |

Four VPCS nodes (two per office) represent the users during testing; they do not simulate all 35 employees.

## Network Topology

![GNS3 Small Office Multi-Site Network Topology](assets/network-topology.png)

*Logical deployment in GNS3: HQ and Branch LANs communicate through a simulated ISP transit router. The VirtualBox Host-Only management network is separate from the business LAN/WAN links.*

### Infrastructure

| Device | Quantity | Role |
| --- | ---: | --- |
| MikroTik CHR | 3 | HQ router, simulated ISP transit router, Branch router |
| Ethernet switch | 2 | Local Layer 2 connectivity |
| VPCS | 4 | Client addressing and connectivity tests |
| Docker container (Nginx) | 1 | Internal HTTP service at HQ |

**Tools:** GNS3, VirtualBox, MikroTik RouterOS, WinBox, Docker/Nginx.

## IP Addressing

### LANs and DHCP

| Parameter | HQ | Branch |
| --- | --- | --- |
| Subnet | `172.22.10.0/26` | `172.22.20.0/27` |
| Router / default gateway | `172.22.10.1` | `172.22.20.1` |
| DHCP pool | `172.22.10.20–172.22.10.59` | `172.22.20.10–172.22.20.29` |
| Router LAN interface | `ether3` | `ether3` |
| Subnet usable addresses | 62 | 30 |

**Internal web server:** `SRV-HQ-01` — `172.22.10.10/26`, gateway `172.22.10.1`, HTTP on TCP port `80`. Its static address is excluded from the HQ DHCP pool.

### Router Interfaces and WAN Links

| Router | Interface | IP address | Connection |
| --- | --- | --- | --- |
| `NDS-CHR-HQ` | `ether2` | `10.255.10.1/30` | ISP `ether2` |
| `NDS-CHR-HQ` | `ether3` | `172.22.10.1/26` | SW-HQ |
| `NDS-CHR-ISP` | `ether2` | `10.255.10.2/30` | HQ `ether2` |
| `NDS-CHR-ISP` | `ether3` | `10.255.10.5/30` | Branch `ether2` |
| `NDS-CHR-BRANCH` | `ether2` | `10.255.10.6/30` | ISP `ether3` |
| `NDS-CHR-BRANCH` | `ether3` | `172.22.20.1/27` | SW-BRANCH |

- **HQ–ISP transit:** `10.255.10.0/30`
- **ISP–Branch transit:** `10.255.10.4/30`
- **Management:** each router's `ether1` uses the separate VirtualBox Host-Only network `192.168.56.0/24` for WinBox access. These management addresses are obtained dynamically and may change.

## Inter-Site Routing Design

Static routes are planned for bidirectional communication between the two office LANs:

| Router | Destination | Next hop |
| --- | --- | --- |
| HQ | `172.22.20.0/27` | `10.255.10.2` |
| ISP | `172.22.10.0/26` | `10.255.10.1` |
| ISP | `172.22.20.0/27` | `10.255.10.6` |
| Branch | `172.22.10.0/26` | `10.255.10.5` |

**Status:** these inter-site routes are part of the approved design and have **not yet been deployed or verified**. NAT is not required for communication between the two private LANs over this controlled routed transit; appropriate firewall handling must still be validated.

## Implemented Services and Verification

| Component / check | Verified result |
| --- | --- |
| Router interface addressing | HQ, ISP, and Branch interface IPs match the addressing plan |
| Connected routes | Management, LAN, and directly attached WAN networks active |
| Direct WAN neighbor connectivity | Four ping tests, each `10/10` received with `0%` loss |
| HQ DHCP service | Two client leases `bound`, within the HQ pool |
| Branch DHCP service | Two client leases `bound`, within the Branch pool |
| Local gateway connectivity | All four clients successfully pinged their local gateway |
| HQ internal server | Static `172.22.10.10/26` and default gateway verified |
| Server local connectivity | HQ client-to-server ICMP and server-to-gateway ICMP successful |
| HTTP service | Nginx returned HTTP `200 OK` locally and through HTTP Fetch from the HQ router |

The following **remain to be verified**: end-to-end HQ–Branch LAN communication, Branch access to the HQ HTTP server, and firewall policy behavior. Successful ping does not by itself establish that an HTTP service is reachable from the other office.

## Network Design Scope and Limitations

This is a **controlled educational simulation**, not a production deployment. The ISP node represents a private transit network, not secure connectivity across the public Internet.

The project intentionally excludes VPN, OSPF/BGP, VLAN segmentation, high availability, enterprise authentication, and public Internet access. Any real-world inter-office Internet deployment would require additional WAN and security design.

## Repository Contents

```text
Small-Office-Multi-Site-Network-Deployment/
├── README.md
└── assets/
    └── network-topology.png
```

Future configuration exports or test evidence may be added after verification. Before publishing exports, remove passwords, tokens, sensitive addresses, and other secrets.

---

*Portfolio lab project · Fictional organization · GNS3 / MikroTik RouterOS*
