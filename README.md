# Small Office Multi-Site Network Deployment

> **MikroTik MTCNA Home Lab — Final Project**  
> **Status:** Phase 01 Completed · Phase 02 Completed (30 October 2026) · Phase 03 Not Started · **Design baseline:** Network Design v1.0 — Approved (29 October 2026), interface mapping revision v1.1 · **Environment:** GNS3 / MikroTik RouterOS

## Project Overview

This project simulates the design, deployment, validation, and troubleshooting of a small company's network across two offices: **Headquarters (HQ)** and **Branch Office**. It is the capstone project of a MikroTik MTCNA-oriented home lab learning journey and is intended to demonstrate practical **Junior Network Engineer** skills.

The scenario is fictional and runs in a controlled lab environment. The Phase 01 design review has been completed and Network Design v1.0 has been approved. The GNS3 topology has been deployed using dedicated Final Project CHR nodes and an internal server container. RouterOS identity, management interface connectivity, WAN/LAN interface addressing, active connected routes, and directly connected WAN communication have been verified during Phase 02. DHCP, inter-site static routes, client-to-client communication, and HTTP service validation have not yet been implemented or verified.

## Business Scenario

**PT Nusa Digital Solusi** is a fictional IT services company with two sites:

| Site | Planned users | Key needs |
| --- | ---: | --- |
| Headquarters (HQ) | 25 | Local connectivity, DHCP, internal HTTP server, branch access |
| Branch Office | 10 | Local connectivity, DHCP, access to HQ resources |

The offices communicate through a **simulated ISP transit router**, not a real public Internet connection. This lab does **not** represent secure site-to-site communication over the public Internet; a production deployment would require a separate WAN/security design.

## Project Objectives

- Translate business requirements into a logical network topology and IP addressing plan.
- Configure MikroTik RouterOS interfaces, IP addressing, and DHCP services.
- Establish bidirectional inter-site communication using static routes.
- Apply and verify appropriate firewall rules; use NAT only where a defined requirement calls for it.
- Provide branch access to an internal HTTP service hosted at HQ.
- Validate connectivity, investigate controlled failures, and document the findings.
- Publish reproducible topology, configuration evidence, and test results.

## Scope

**In scope:** Two office LANs, three MikroTik routers (HQ, ISP simulation, Branch), two Ethernet switches, four representative client PCs, one internal HTTP server, IPv4 subnetting, DHCP, static routing, firewall filtering, basic service testing, troubleshooting, and documentation.

**Out of scope:** Production Internet connectivity, VPN, VLAN segmentation, OSPF/BGP, high availability, enterprise authentication, and other advanced features beyond the selected MTCNA-level learning objectives.

> **Capacity note:** The 25 HQ and 10 Branch users are planning assumptions. Only two representative test clients per office will be instantiated in GNS3.

## Network Topology — GNS3 Deployment (Interface Mapping v1.1)

![Small Office Multi-Site Network Topology](assets/network-topology.png)

*Figure 1 — GNS3 topology showing Headquarters, Branch Office, simulated ISP transit, two client PCs per office, and the internal HTTP server at HQ. Network labels show the approved design; WAN/LAN router interface addressing was subsequently verified in Phase 02.*

The network is divided into HQ (`172.22.10.0/26`), Branch (`172.22.20.0/27`), and transit links (`10.255.10.0/30`, `10.255.10.4/30`). Router `ether1` is reserved for the separate VirtualBox Host-Only management network (`192.168.56.0/24`) and is not part of the simulated business traffic paths. The screenshot records physical/logical node placement and cabling. Router interface IP addresses and directly connected WAN communication were verified separately during Phase 02; inter-site LAN routing and application services remain untested.

## Approved IP Addressing Plan — v1.0

The following addressing is the **approved Phase 01 design baseline**. Router interface addressing was verified during Phase 02. DHCP pools and internal server settings remain planned for Phase 03; any necessary design changes will be documented.

### LANs

| Segment | Network | Gateway | Usable hosts | DHCP allocation |
| --- | --- | --- | ---: | --- |
| HQ LAN | `172.22.10.0/26` | `172.22.10.1` | 62 | `172.22.10.20–172.22.10.59` |
| Branch LAN | `172.22.20.0/27` | `172.22.20.1` | 30 | `172.22.20.10–172.22.20.29` |

The internal web server is planned at **`172.22.10.10` (static)**, outside the HQ DHCP pool.

### WANs and Router Interfaces — Mapping Revision v1.1

| Router | Interface | Connects to | Approved address |
| --- | --- | --- | --- |
| NDS-CHR-HQ | `ether2` | NDS-CHR-ISP `ether2` | `10.255.10.1/30` |
| NDS-CHR-HQ | `ether3` | SW-HQ `ether1` | `172.22.10.1/26` |
| NDS-CHR-ISP | `ether2` | NDS-CHR-HQ `ether2` | `10.255.10.2/30` |
| NDS-CHR-ISP | `ether3` | NDS-CHR-BRANCH `ether2` | `10.255.10.5/30` |
| NDS-CHR-BRANCH | `ether2` | NDS-CHR-ISP `ether3` | `10.255.10.6/30` |
| NDS-CHR-BRANCH | `ether3` | SW-BRANCH `ether1` | `172.22.20.1/27` |

WAN-1: `10.255.10.0/30` · WAN-2: `10.255.10.4/30`.

> **Management plane:** `ether1` on each CHR is reserved for the VirtualBox Host-Only segment `192.168.56.0/24`. The segment is separate from the simulated WAN/LAN, and unique dynamic management addresses were verified during Phase 02 (HQ: `192.168.56.115/24`, ISP: `192.168.56.113/24`, Branch: `192.168.56.114/24`). These DHCP assignments may change. The Windows host address observed during preparation was `192.168.56.112/24`.

## Approved Static Routing Plan

| Router | Destination | Next hop |
| --- | --- | --- |
| R-HQ | `172.22.20.0/27` | `10.255.10.2` |
| R-ISP | `172.22.10.0/26` | `10.255.10.1` |
| R-ISP | `172.22.20.0/27` | `10.255.10.6` |
| R-BRANCH | `172.22.10.0/26` | `10.255.10.5` |

These are **approved planned routes**, not an exported or verified RouterOS configuration. NAT is not required for inter-site communication through this controlled routed transit network; firewall policy must permit the required traffic.

## Devices and Tools

| Item | Quantity | Purpose |
| --- | ---: | --- |
| MikroTik CHR / RouterOS | 3 | HQ, simulated ISP, Branch routing |
| Ethernet switches | 2 | LAN connectivity |
| VPCS clients | 4 | Representative endpoints and DHCP tests |
| Linux VM/container | 1 | Internal HTTP server |
| GNS3 | — | Network emulation |
| WinBox / RouterOS CLI | — | Configuration and verification |

**Total GNS3 network nodes: 10.** Three dedicated Final Project CHR nodes, two switches, four VPCS clients, and one Docker server node have been placed and linked. GNS3 VM was observed running server version 2.2.61; exact RouterOS versions remain to be recorded.

## Project Phases

| Phase | Description | Status |
| --- | --- | --- |
| 01 | Business requirements, topology, addressing, design review | **Completed — Design v1.0 Approved** |
| 02 | GNS3 topology deployment, RouterOS foundation and interface addressing | **Completed — 30 October 2026** |
| 03 | LAN and DHCP deployment, local server preparation | **Next — Not started** |
| 04 | Static routing integration | Not started |
| 05 | Firewall and NAT requirement review | Not started |
| 06 | Validation and controlled troubleshooting | Not started |
| 07 | Final evidence, documentation, and assessment | Not started |

## Planned Acceptance Tests

| ID | Verification | Expected outcome | Actual |
| --- | --- | --- | --- |
| T-01 | HQ client DHCP | Receives HQ address, mask and gateway | Not tested |
| T-02 | Branch client DHCP | Receives Branch address, mask and gateway | Not tested |
| T-03 | HQ client → HQ gateway | Reachable | Not tested |
| T-04 | Branch client → Branch gateway | Reachable | Not tested |
| T-05 | HQ client → Branch client | Reachable | Not tested |
| T-06 | Branch client → HQ client | Reachable | Not tested |
| T-07 | Branch client → HQ HTTP server | HTTP response received | Not tested |
| T-08 | Firewall policy checks | Traffic handled as designed | Not tested |
| T-09 | Simulated fault investigation | Root cause and fix documented | Not tested |

Evidence (screenshots, command outputs, and troubleshooting notes) will be linked once available.

## Deliverables

- GNS3 project topology and finalized addressing table.
- Device configuration backups/exports **sanitized to remove credentials and secrets**.
- DHCP, route, and firewall verification outputs.
- End-to-end testing evidence, including HTTP service access.
- Troubleshooting case notes: symptoms, hypothesis, checks, root cause, fix, and retest.
- Final design decisions, limitations, and lessons learned.

## Learning and Review Method

The project uses a **KILLCRITIC mentoring workflow**: theory → design reasoning → implementation → verification → troubleshooting → assessment. Progression requires explaining *why* a change is needed and demonstrating the expected result—not merely copying commands or obtaining a successful ping.

## Phase 02 — Verified Deployment Results

The following findings were verified on **30 October 2026**; they are separate from future acceptance tests involving client DHCP, inter-site LAN access, or HTTP services.

### Router Identity and Interface Addressing

| Router identity | Management (ether1, DHCP) | Project WAN (ether2) | LAN / second WAN (ether3) |
| --- | --- | --- | --- |
| `NDS-CHR-HQ` | `192.168.56.115/24` | `10.255.10.1/30` | `172.22.10.1/26` |
| `NDS-CHR-ISP` | `192.168.56.113/24` | `10.255.10.2/30` | `10.255.10.5/30` |
| `NDS-CHR-BRANCH` | `192.168.56.114/24` | `10.255.10.6/30` | `172.22.20.1/27` |

Management addresses are dynamic VirtualBox Host-Only leases. Screenshots of `/ip address print` and `/ip route print` confirmed expected **active connected routes (`DAc`)** for the management, WAN, and LAN networks on each router.

### Directly Connected WAN Validation

| Test ID | Source | Destination | Result |
| --- | --- | --- | --- |
| WAN-01 | HQ | `10.255.10.2` (ISP) | 10/10 received, 0% loss |
| WAN-02 | ISP | `10.255.10.1` (HQ) | 10/10 received, 0% loss |
| WAN-03 | ISP | `10.255.10.6` (Branch) | 10/10 received, 0% loss |
| WAN-04 | Branch | `10.255.10.5` (ISP) | 10/10 received, 0% loss |

These checks prove basic IP connectivity only between directly connected WAN neighbors. They **do not** prove inter-site LAN reachability, which will require additional routing and permitted traffic.

### Infrastructure Troubleshooting Note

During topology deployment, creation of the Docker server node initially failed due to GNS3 VM compute connectivity. Subsequent verification confirmed reachability of the GNS3 VM management IP, successful Web UI and API access, an online compute server, and successful server node creation. The precise initial root cause was **not established**.

## Phase 03 — Planned LAN & DHCP Services

**Status: Not started.** No DHCP server, LAN client lease, or internal HTTP service result is claimed complete.

| Parameter | Headquarters (HQ) | Branch Office |
| --- | --- | --- |
| LAN subnet | `172.22.10.0/26` | `172.22.20.0/27` |
| Default gateway | `172.22.10.1` | `172.22.20.1` |
| Planned DHCP pool | `172.22.10.20–172.22.10.59` | `172.22.20.10–172.22.20.29` |
| DHCP server interface | `ether3` | `ether3` |
| Test clients | `PC-HQ-01`, `PC-HQ-02` | `PC-BR-01`, `PC-BR-02` |

`SRV-HQ-01` is planned to use **static IPv4 `172.22.10.10/26`** with gateway `172.22.10.1`, outside the DHCP range.

The phase will cover DHCP fundamentals (DORA, pools, networks, gateway, DNS, and leases), design verification, HQ and Branch DHCP deployment, client lease and gateway validation, local HTTP server preparation, troubleshooting, and a KILLCRITIC assessment. Configuration has not started.

## Design Approval Record

| Item | Value |
| --- | --- |
| Design reference | `NDS-NET-001` |
| Baseline | Network Design v1.0 |
| Approval date | 29 October 2026 |
| Approval scope | Business requirements, logical topology, IP plan, routing plan, acceptance criteria |
| Mapping amendment | v1.1 — ether1 reserved for Host-Only management; project WAN/LAN links moved to ether2/ether3 |
| Phase 02 closure | 30 October 2026 — initial RouterOS setup, active connected routes, and four direct WAN ping tests verified |

## Current Progress

**Phase 01: Completed (29 October 2026).** Design B (two offices with an internal server at HQ) passed KILLCRITIC design review. Network Design v1.0 is approved with interface mapping amendment v1.1.

**Phase 02: Completed (30 October 2026).** Dedicated Final Project CHR instances, GNS3 topology cabling, management connectivity, device identities, WAN/LAN interface addresses, active connected routes, and direct WAN neighbor ping tests were completed and verified. The initial cause of the earlier GNS3 VM connectivity fault remains unconfirmed.

**Phase 03: Not started.** Next: implement and validate local DHCP services for both offices and prepare the internal HTTP server. Inter-site static routing, firewall policy validation, and end-to-end client/service testing remain future work.

---

*Portfolio project | Fictional organization | For educational and lab demonstration purposes only.*
