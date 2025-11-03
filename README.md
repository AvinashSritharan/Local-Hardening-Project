<div align="center">

   <picture>
      <source media="(prefers-color-scheme: dark)" srcset="Assets/Viper-Logo_White.png">
      <source media="(prefers-color-scheme: light)" srcset="Assets/Viper-Logo_Black.png">
      <img src="Assets/Viper-Logo_Black.png" alt="Project Logo" width="45%">
   </picture>

  [![Issues][issues-shield]][issues-url]
  [![Stars][stars-shield]][stars-url]
  [![Commits][commits-shield]][commits-url]
  [![License][license-shield]][license-url]

  <p>
    Welcome to our Local-Hardening Project!
    <br />
    <a href="#overview">Overview</a>
    ·
    <a href="#used-tools">Tools</a>
    ·
    <a href="Docs/Journal/">Journal</a>
    ·
    <a href="#license">License</a>
  </p>
  <br>
</div>

<div align="center">
  <h1>Architecture</h1>
</div>

Placeholder Iamge

Placeholder Image

## Overview

This project builds a clear, repeatable hardening setup for a local Windows Laptop or Computer. It starts with a simple baseline check (updates, firewall, services, startup apps, device encryption) and then raises the security level step by step: clean user accounts, remove unneeded admin rights, set a password manager, enforce strong passwords and 2FA, harden the browser (privacy settings and a few safe extensions), enable BitLocker for full-disk encryption and, if needed, use a small VeraCrypt container for sensitive files. Small PowerShell scripts keep the system tidy and consistent (clean the Downloads folder, rotate logs, back up key configs, check for new local admins) and a simple naming structure keeps files and folders organized.

Wazuh runs on the laptop to watch file changes, key security events, and common risks; rules and alerts make changes visible in plain language. Grafana shows live health data (CPU, RAM, disk, network) and a few important security counters; Power BI can be added later for a static "before vs after" report if needed. Focus stays on two things: clear steps any user can run without deep knowledge, and measurable results that prove the hardening worked. Deliverables are a short guide with screenshots, a small script pack and configs, and simple before/after checks—including a quick restore test—to show the improvement.

**Baseline check:** updates, firewall, services, startup apps, device encryption  
**Account & access hygiene:** clean users, remove unneeded admin rights, add a password manager, enforce strong passwords & 2FA  
**Browser & data protection:** privacy-focused settings, safe extensions, BitLocker FDE, optional VeraCrypt container for sensitive files  
**Maintenance scripts:** tidy Downloads, rotate logs, back up key configs, alert on new local admins; simple, consistent naming for files/folders  
**Monitoring & visibility:** Wazuh on-device rules/alerts that explain changes in plain language  
**Dashboards & reporting:** Grafana for live health + key security counters; optional Power BI “before vs after” report  
**Outcome focus:** clear steps non-experts can run; measurable proofs that hardening worked  
**Deliverables:** short guide with screenshots, small script pack & configs, before/after checks + quick restore test

## What You Will Learn

In this project, you'll set up a fully functional Active Directory lab, install and configure key services such as Splunk and Sysmon, and simulate cyber attacks.
You'll get hands-on experience in setting up a domain environment, configuring security monitoring, and performing attack simulations.

**You'll also learn how to...**

- Design and plan a network architecture
- Install and configure multiple virtual machines
- Set up Active Directory Domain Services
- Monitor and analyze security logs using Splunk
- Simulate cyber attacks and test your detection capabilities

## Used Tools

- [**`Draw.io`**](https://app.diagrams.net/) Create network diagrams easily.
- [**`VirtualBox`**](https://www.virtualbox.org/) Run multiple virtual machines on your computer.
- [**`Windows Server 2022`**](https://www.microsoft.com/en-us/windows-server) – Set up Active Directory services.
- [**`Kali Linux`**](https://www.kali.org/) A Linux system used for security testing.
- [**`Splunk`**](https://www.splunk.com/) Collect and analyze logs from your machines.
- [**`Sysmon`**](https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon) – Track detailed system events on Windows.
- [**`Atomic Red Team`**](https://atomicredteam.io/) Simulate attacks to test your security setup.

## Why You Should Do This

This project is great for anyone looking to level up their **IT admin or cybersecurity skills**, or both. If you're looking to **boost** your **technical expertise** and **gain real-world experience** in setting up and managing a domain environment, this hands-on project is perfect for you. It's also great preparation for interviews. You'll also get some great experience in monitoring and detecting attacks using industry-standard tools like Splunk and Sysmon.

By the time you're done with this project, you'll be ready to talk about Active Directory architecture and security monitoring in professional settings, including job interviews.

## Let's get Started

Ready to build your own Active Directory lab?

Follow the Parts below step by step to complete your project. You'll start by setting up a network, then move on to installing virtual machines, configuring Active Directory, and finally simulating attacks.

### Links to Each Part

1. **[`Part 1` Project Setup and Diagram Design](Project/Part-1.md/)**
2. **[`Part 2` Installing Virtual Machines](Project/Part-2.md/)**  
3. **[`Part 3` Wazuh Setup](Project/Part-3.md/)**  

## Our License

Creative Commons (CC BY-NC-SA 4.0)

This work is licensed under the [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-nc-sa/4.0/deed.de).

<!-- Stars Badge -->
[stars-shield]: https://img.shields.io/github/stars/AvinashSritharan/Local-Hardening-Project?style=flat&label=Stars&labelColor=111111&color=4C9AE8
[stars-url]: https://github.com/AvinashSritharan/Local-Hardening-Project/stargazers

<!-- Issues Badge -->
[issues-shield]: https://img.shields.io/github/issues/AvinashSritharan/Local-Hardening-Project?style=flat&label=Issues&labelColor=111111&color=F78A1D
[issues-url]: https://github.com/AvinashSritharan/Local-Hardening-Project/issues

<!-- Commits Badge (yearly activity) -->
[commits-shield]: https://img.shields.io/github/commit-activity/y/AvinashSritharan/Local-Hardening-Project?style=flat&label=Commits&labelColor=111111&color=FF007F
[commits-url]: https://github.com/AvinashSritharan/Local-Hardening-Project/commits/HEAD

<!-- License Badge -->
[license-shield]: https://img.shields.io/github/license/AvinashSritharan/Local-Hardening-Project?style=flat&label=License&labelColor=111111&color=FF5A5F
[license-url]: https://github.com/AvinashSritharan/Local-Hardening-Project/blob/HEAD/LICENSE

<!-- (Optional) Top Language Badge -->
[language-shield]: https://img.shields.io/github/languages/top/AvinashSritharan/Local-Hardening-Project?style=flat&label=Top%20language&labelColor=111111&color=8E44AD
