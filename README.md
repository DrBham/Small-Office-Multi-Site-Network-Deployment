<div align="center">

# 🌐 Small Office Multi-Site Network Deployment

**PT Nusa Digital Solusi (NDS) · MikroTik RouterOS · GNS3**

![Project](https://img.shields.io/badge/Project-NDS--NET--001-2563eb?style=flat-square)
![Progress](https://img.shields.io/badge/Progress-4%20of%207%20Phases-16a34a?style=flat-square)
![Status](https://img.shields.io/badge/Current%20Stage-Firewall%20Review%20Pending-f59e0b?style=flat-square)
![Platform](https://img.shields.io/badge/Platform-GNS3%20%7C%20RouterOS-0f766e?style=flat-square)

*A simulated two-site business network with centralized HQ resources, routed inter-office connectivity, and a dedicated management network.*

</div>

---

## 🧭 Project at a Glance

<table>
<tr>
<td width="50%" valign="top">

<h3>🏢 Business Scenario</h3>
<p><strong>Headquarters (HQ)</strong> supports a planned 25 users, local DHCP, and an internal HTTP service.</p>
<p><strong>Branch Office</strong> supports a planned 10 users and requires access to HQ resources.</p>
<p><strong>4 representative VPCS clients</strong> (2 per site) are used for validation, not as a simulation of all 35 employees.</p>

</td>
<td width="50%" valign="top">

<h3>🎯 Network Objectives</h3>
<ul>
<li>Separate IPv4 LANs with DHCP allocation</li>
<li>Bidirectional HQ ↔ Branch connectivity</li>
<li>Static routing through a simulated ISP</li>
<li>Internal HTTP service at HQ</li>
<li>Firewall policy review and traffic validation</li>
</ul>

</td>
</tr>
<tr>
<td width="50%" valign="top">

<h3>🧰 Infrastructure</h3>
<ul>
<li><strong>3</strong> MikroTik CHR routers</li>
<li><strong>2</strong> Ethernet switches</li>
<li><strong>4</strong> VPCS clients</li>
<li><strong>1</strong> Docker Nginx server</li>
</ul>

</td>
<td width="50%" valign="top">

<h3>🛠️ Technology Stack</h3>
<ul>
<li><strong>Emulation:</strong> GNS3 + VirtualBox</li>
<li><strong>Routing:</strong> MikroTik RouterOS (WinBox / CLI)</li>
<li><strong>Services:</strong> DHCP + Nginx HTTP</li>
<li><strong>Network:</strong> IPv4 / Static Routing</li>
</ul>

</td>
</tr>
</table>

## 🗺️ Network Topology

<div align="center">

![GNS3 topology — HQ, ISP transit, Branch and HQ HTTP server](assets/network-topology.png)

<sub>HQ and Branch are connected through a simulated private ISP transit. Router <code>ether1</code> interfaces use an isolated VirtualBox Host-Only management network.</sub>

</div>

## 🗓️ Project Phase Timeline

```mermaid
flowchart LR
    P1["01 · Network Design"] --> P2["02 · Infrastructure"]
    P2 --> P3["03 · DHCP & HTTP"]
    P3 --> P4["04 · Static Routing"]
    P4 --> P5["05 · Firewall & NAT Review"]
    P5 --> P6["06 · Validation & Troubleshooting"]
    P6 --> P7["07 · Final Documentation"]
    classDef complete fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:2px;
    classDef pending fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:2px;
    classDef planned fill:#e2e8f0,stroke:#64748b,color:#334155;
    class P1,P2,P3,P4 complete;
    class P5 pending;
    class P6,P7 planned;
```

| Phase | Focus | Status |
|:--:|---|:--:|
| 01 | Network design & IP addressing baseline | ✅ Completed |
| 02 | GNS3 deployment, interfaces & WAN neighbor connectivity | ✅ Completed |
| 03 | LAN DHCP, client connectivity & HQ HTTP service | ✅ Completed |
| 04 | Inter-site static routing & service connectivity | ✅ Completed |
| 05 | Firewall policy and NAT requirement review | 🟠 Not started |
| 06 | End-to-end validation & controlled troubleshooting | ⚪ Not started |
| 07 | Final evidence and technical documentation | ⚪ Not started |

<sub>Milestone dates: design approved 29 October 2026; infrastructure and LAN services verified 30 October 2026; inter-site routing verified 31 October 2026. Remaining phases have no scheduled dates.</sub>

## 🌐 Network Addressing

<table>
<tr>
<td width="50%" valign="top">
<h3>🔵 Headquarters</h3>
<table>
<tr><td><strong>LAN</strong></td><td><code>172.22.10.0/26</code></td></tr>
<tr><td><strong>Gateway</strong></td><td><code>172.22.10.1</code></td></tr>
<tr><td><strong>DHCP Pool</strong></td><td><code>172.22.10.20–59</code></td></tr>
<tr><td><strong>Capacity</strong></td><td>62 usable IPs</td></tr>
<tr><td><strong>HTTP Server</strong></td><td><code>172.22.10.10</code></td></tr>
</table>
</td>
<td width="50%" valign="top">
<h3>🟢 Branch Office</h3>
<table>
<tr><td><strong>LAN</strong></td><td><code>172.22.20.0/27</code></td></tr>
<tr><td><strong>Gateway</strong></td><td><code>172.22.20.1</code></td></tr>
<tr><td><strong>DHCP Pool</strong></td><td><code>172.22.20.10–29</code></td></tr>
<tr><td><strong>Capacity</strong></td><td>30 usable IPs</td></tr>
<tr><td><strong>Access</strong></td><td>HQ resources via ISP</td></tr>
</table>
</td>
</tr>
</table>

### WAN Transit & Interface Mapping

| Router | Interface | IPv4 Address | Role |
|---|---|---|---|
| `NDS-CHR-HQ` | `ether2` | `10.255.10.1/30` | WAN → ISP |
| `NDS-CHR-HQ` | `ether3` | `172.22.10.1/26` | HQ LAN |
| `NDS-CHR-ISP` | `ether2` | `10.255.10.2/30` | WAN → HQ |
| `NDS-CHR-ISP` | `ether3` | `10.255.10.5/30` | WAN → Branch |
| `NDS-CHR-BRANCH` | `ether2` | `10.255.10.6/30` | WAN → ISP |
| `NDS-CHR-BRANCH` | `ether3` | `172.22.20.1/27` | Branch LAN |

> **WANs:** `10.255.10.0/30` (HQ–ISP) and `10.255.10.4/30` (ISP–Branch). **Management:** `ether1` on each CHR uses dynamic addressing within VirtualBox Host-Only `192.168.56.0/24`; management is separate from business traffic.

## 🔀 Inter-Site Static Routing

| Router | Destination Network | Next Hop | Status |
|---|---|---|---|
| HQ | `172.22.20.0/27` | `10.255.10.2` | ✅ Active |
| ISP | `172.22.10.0/26` | `10.255.10.1` | ✅ Active |
| ISP | `172.22.20.0/27` | `10.255.10.6` | ✅ Active |
| Branch | `172.22.10.0/26` | `10.255.10.5` | ✅ Active |

All four static routes were verified in the RouterOS `main` routing table. **Inter-site NAT is not required** for this controlled, privately routed design. Firewall policy evaluation remains part of Phase 05.

## ✅ Implemented Services & Verification

<table>
<tr>
<td width="50%" valign="top">
<h3>📡 LAN & DHCP</h3>
<ul>
<li>HQ DHCP leases: <strong>2 bound</strong></li>
<li>Branch DHCP leases: <strong>2 bound</strong></li>
<li>Local gateway ping: <strong>4/4 clients passed</strong></li>
<li>Direct WAN neighbor tests: <strong>4 × 10/10</strong></li>
<li>Active connected and static routes verified</li>
</ul>
</td>
<td width="50%" valign="top">
<h3>🔁 Inter-Site Connectivity</h3>
<ul>
<li>HQ → Branch gateway: <strong>5/5</strong></li>
<li>Branch → HQ gateway: <strong>5/5</strong></li>
<li>PC-HQ-01 → PC-BR-01: <strong>5/5</strong></li>
<li>PC-BR-01 → PC-HQ-01: <strong>5/5</strong></li>
<li>Router-originated tests used LAN source IPs</li>
</ul>
</td>
</tr>
<tr>
<td width="50%" valign="top">
<h3>🌍 Internal HTTP Service</h3>
<ul>
<li><strong>Host:</strong> <code>SRV-HQ-01</code></li>
<li><strong>Address:</strong> <code>172.22.10.10/26</code></li>
<li><strong>Service:</strong> Nginx, TCP <code>80</code></li>
<li>HQ router HTTP Fetch: <strong>200 OK</strong></li>
<li>Branch router HTTP Fetch: <strong>200 OK</strong></li>
</ul>
</td>
<td width="50%" valign="top">
<h3>🔐 Pending Security Validation</h3>
<ul>
<li>Review existing RouterOS firewall filter rules</li>
<li>Define permitted <code>input</code> and <code>forward</code> traffic</li>
<li>Verify NAT requirements and existing rules</li>
<li>Test permitted and restricted traffic</li>
<li>Document controlled troubleshooting results</li>
</ul>
</td>
</tr>
</table>

> **Validation boundary:** Branch HTTP success was measured using RouterOS Fetch from the **Branch router** with source IP `172.22.20.1`; direct HTTP testing from a Branch VPCS client has not been performed. ICMP tests from VPCS clients were verified separately.

## 🛡️ Scope & Deployment Notes

<table>
<tr>
<td width="50%" valign="top">
<h3>✅ Included</h3>
<ul>
<li>Two IPv4 LANs and DHCP services</li>
<li>Private WAN transit with three routers</li>
<li>Static inter-site routing</li>
<li>HQ internal HTTP service</li>
<li>Firewall and NAT requirement review</li>
<li>Technical connectivity verification</li>
</ul>
</td>
<td width="50%" valign="top">
<h3>🚫 Excluded</h3>
<ul>
<li>Public Internet or production WAN access</li>
<li>Site-to-site VPN and encryption</li>
<li>VLAN segmentation</li>
<li>OSPF / BGP</li>
<li>High availability</li>
<li>Enterprise authentication</li>
</ul>
</td>
</tr>
</table>

> **Lab limitation:** The ISP router is a simulated private transit device, **not** the public Internet. Successful traffic exchange here does not imply secure connectivity between geographically separated offices. A production design would require additional WAN and security controls.

---

<div align="center">
<sub>Network Design v1.0 · Interface Mapping v1.1 · MTCNA-oriented portfolio lab · Fictional company</sub>
</div>
