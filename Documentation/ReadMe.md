<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../Assets/Viper-Logo_White.png">
  <source media="(prefers-color-scheme: light)" srcset="../Assets/Viper-Logo_Black.png">
  <img src="../Assets/Viper-Logo_Black.png" alt="Logo von V1P3R" width="200">
</picture>

<br>

# Overview

This guide walks you through every major part of the project, step by step. Project overview, setup instructions, and usage guidelines.

Here's a clean, consistent set that matches your project and style.

---

### :file_folder: `Part 1` Essential Windows Configuration

* Build a safe Windows baseline: updates, Defender, firewall, BitLocker, user accounts (least-privilege), UAC on, and tidy startup/services.

  > [Go to Part 1](Documentation/Part-1/Part-1.md)

---

### :file_folder: `Part 2` Browser Security & Privacy

* Harden Firefox for everyday privacy: strict tracking protection, HTTPS-Only, DNS-over-HTTPS, minimal trusted extensions, telemetry trim.

  > [Go to Part 2](Documentation/Part-2/Part-2.md)

---

### :file_folder: `Part 3` Proton Services Setup

* Set up Proton Mail, Pass, and Authenticator: strong passwords, aliases, 2FA, and simple backups for a clean daily workflow.

  > [Go to Part 3](Documentation/Part-3/Part-3.md)

---

### :file_folder: `Part 4` Grafana Monitoring

* See live system health: Windows Exporter → Prometheus → Grafana. Build a small CPU/RAM/Disk/Network dashboard with one alert.

  > [Go to Part 4](Documentation/Part-4/Part-4.md)

---

### :file_folder: `Part 5` Wazuh Use Cases (Theory)

* Understand Wazuh's role: agent vs. manager, rules and decoders, FIM, registry, vulnerabilities, Sysmon, and alert triage strategy.

  > [Go to Part 5](Documentation/Part-5/Part-5.md)

---

### :file_folder: `Part 6` Wazuh Threat Detection (Hands-On)

* Deploy Wazuh (single node), enroll the Windows agent, enable core checks, run a safe test, and confirm readable alerts end-to-end.

  > [Go to Part 6](Part-6/Part-6.md)

---
