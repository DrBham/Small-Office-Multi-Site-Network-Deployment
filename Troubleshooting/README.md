<div align="center">

# 🛠️ Network Troubleshooting

### NDS-NET-001 · Small Office Multi-Site Network Deployment

![Phase](https://img.shields.io/badge/Phase-06%20%7C%20Validation%20%26%20Troubleshooting-2563eb?style=flat-square)
![Cases](https://img.shields.io/badge/Cases-3%20of%203%20Completed-16a34a?style=flat-square)
![Status](https://img.shields.io/badge/Case%20Investigations-Completed-16a34a?style=flat-square)

**Three controlled failure investigations covering WAN connectivity, firewall policy, and static route configuration across the NDS HQ–ISP–Branch topology.**

</div>

---

## 🧭 Overview

This section contains the Phase 06 troubleshooting case studies for NDS-NET-001. Each investigation uses the established network baseline, documents a deliberately introduced fault, identifies its root cause, and validates recovery. No additional permanent network devices were added.

<table><tr><td width="50%" valign="top">

### 🎯 Objectives

- Isolate WAN, firewall, and routing faults
- Gather evidence from RouterOS and VPCS tests
- Identify a verifiable root cause
- Restore the baseline and retest connectivity

</td><td width="50%" valign="top">

### 🧰 Environment

- **Emulation:** GNS3 + VirtualBox
- **Routers:** 3 MikroTik CHR (RouterOS 7.23.8)
- **Clients:** 4 VPCS (2 per site)
- **Service:** Nginx HTTP at HQ only
- **Management:** WinBox and RouterOS CLI

</td></tr></table>

## 🗺️ Network Context

<div align="center">

![NDS network topology](../assets/network-topology.png)

<sub>HQ <code>172.22.10.0/26</code> · ISP private WAN transit · Branch <code>172.22.20.0/27</code></sub>

</div>

## 📂 Troubleshooting Cases

| Case | Category | Fault & Verified Outcome | Status |
|:--:|---|---|:--:|
| **01** | [WAN Link Failure](scenario-01-wan-link-failure/) | ISP HQ-facing `ether2` disabled; interface and route restored; ICMP recovered **5/5 each direction** | ✅ Completed |
| **02** | [Firewall Policy Failure](scenario-02-firewall-policy-failure/) | ISP FORWARD ICMP DROP rule placed before ACCEPT rules; 10 packets matched; rule removed; ICMP recovered **5/5 each direction** | ✅ Completed |
| **03** | [Static Route Failure](scenario-03-static-route-failure/) | ISP HQ route next-hop changed to `10.255.10.9`; route inactive; next-hop restored to `10.255.10.1`; ICMP recovered **5/5 each direction** | ✅ Completed |

## 🔎 Investigation Workflow

```mermaid
flowchart LR
    A[Known-Good Baseline] --> B[Introduce Fault]
    B --> C[Observe Symptoms]
    C --> D[Investigate]
    D --> E[Restore Configuration]
    E --> F[Retest & Document]
    classDef baseline fill:#dbeafe,stroke:#2563eb,color:#1e40af;
    classDef fault fill:#fee2e2,stroke:#dc2626,color:#991b1b;
    classDef verify fill:#dcfce7,stroke:#16a34a,color:#166534;
    class A baseline;
    class B,C,D,E fault;
    class F verify;
```

## ✅ Recovery Summary

<table><tr><td width="50%" valign="top">

### 🌐 Network Recovery

- WAN interface and route restoration verified in Case 01
- Firewall FORWARD policy restored in Case 02
- Static route next-hop and active status restored in Case 03
- Final bidirectional ICMP tests passed in all three cases

</td><td width="50%" valign="top">

### 📷 Evidence & Configurations

- Each case includes a dedicated `README.md`
- Six sequential evidence screenshots per case
- Pre-fault baseline and faulty-state `.rsc` exports per case
- RouterOS binary backups remain private

</td></tr></table>

## 🗂️ Repository Structure

```text
troubleshooting/
├── README.md
├── scenario-01-wan-link-failure/
│   ├── README.md
│   ├── CASE01-BASELINE.rsc
│   ├── CASE01-FAULT-INJECTION.rsc
│   └── [six PNG evidence files]
├── scenario-02-firewall-policy-failure/
│   ├── README.md
│   ├── CASE02-BASELINE.rsc
│   ├── CASE02-FAULT-INJECTION.rsc
│   └── [six PNG evidence files]
└── scenario-03-static-route-failure/
    ├── README.md
    ├── CASE03-BASELINE.rsc
    ├── CASE03-FAULT-INJECTION.rsc
    └── [six PNG evidence files]
```

> Configuration snapshots are provided for review and reproducibility. Full `.rsc` exports must be checked for sensitive values before public release and must not be treated as incremental scripts suitable for importing onto an already configured router.

---

<div align="center"><sub>Part of <a href="../README.md">NDS-NET-001 · Small Office Multi-Site Network Deployment</a></sub></div>
