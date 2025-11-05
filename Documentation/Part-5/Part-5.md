<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../../Assets/Viper-Logo_White.png">
  <source media="(prefers-color-scheme: light)" srcset="../../Assets/Viper-Logo_Black.png">
  <img src="../../Assets/Viper-Logo_Black.png" alt="Logo von V1P3R" width="200">
</picture>

<br>

# `Part 5` Wazuh Short Guide

**TL;DR:** Wazuh is a free HIDS that watches your Windows laptop for risky changes (files, registry, users, services), finds known CVEs, and can auto-respond. You get readable alerts in a web dashboard and clear proof your hardening actually works.

## What is it?

Wazuh is an **endpoint security platform** (agent + manager + dashboard) that:

* **Collects & parses logs** (Windows Event Logs, Sysmon, etc.)
* **Monitors integrity** (files, registry)
* **Detects vulnerabilities** (CVE matching)
* **Alerts & responds** (rules + optional Active Response)

## Why do you need it?

* **Visibility:** See what changed, when, and by whom.
* **Verification:** Prove your hardening holds over time.
* **Early warning:** Catch privilege adds, stopped defenses, and known-bad software versions.
* **Action:** Optionally react automatically (block IP, restart Defender, disable account).

## Core features at a glance

* **File Integrity Monitoring (FIM):** Detect file add/modify/delete on critical paths.
* **Registry Monitoring:** Watch startup keys and policy areas (Defender, Firewall).
* **Windows Events (Security/System):** Surface user creation, admin adds, service stops.
* **Vulnerability Detector:** Match installed software/OS against CVE feeds.
* **Sysmon (optional, recommended):** Deep process/network visibility (Event IDs 1/3/11/13).
* **Active Response (optional):** Auto-run safe actions on matched alerts (e.g., restart WinDefend).

## Quick configuration

### 1) Manager & Dashboard (single node, Docker)

* Launch the official single-node stack (Manager + Indexer + Dashboard).
* Confirm **Dashboard** loads locally and shows “no agents connected” yet.

### 2) Windows Agentm log sources

Edit `C:\Program Files (x86)\ossec-agent\ossec.conf` and ensure these **event channels** are collected:

```xml
<localfile>
  <log_format>eventchannel</log_format>
  <location>Security</location>
</localfile>
<localfile>
  <log_format>eventchannel</log_format>
  <location>System</location>
</localfile>
```

### 3) Windows Agent, FIM (files)

```xml
<syscheck>
  <disabled>no</disabled>
  <frequency>3600</frequency> <!-- full scan every hour -->
  <directories realtime="yes">C:\Program Files</directories>
  <directories realtime="yes">C:\Users\Public</directories>
  <ignore>*.tmp</ignore>
  <ignore>C:\Windows\Temp</ignore>
</syscheck>
```

### 4) Windows Agent, Registry (keys)

```xml
<registry>
  <entry type="realtime">HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run</entry>
  <entry type="realtime">HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run</entry>
  <entry type="realtime">HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\WindowsFirewall</entry>
  <entry type="realtime">HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows Defender</entry>
</registry>
```

### 5) Manager, Vulnerability Detector (enable)

Edit `/var/ossec/etc/ossec.conf` on the **manager**:

```xml
<wodle name="vulnerability-detector">
  <enabled>yes</enabled>
  <interval>1h</interval>
  <run_on_start>yes</run_on_start>
  <feed><type>cpe</type><enabled>yes</enabled></feed>
  <feed><type>msu</type><enabled>yes</enabled></feed>
  <os>Windows</os>
</wodle>
```

### 6) (Optional) Sysmon + agent collector

* Install **Sysmon** with a sane config (e.g., SwiftOnSecurity).
* Add to agent:

```xml
<localfile>
  <log_format>eventchannel</log_format>
  <location>Microsoft-Windows-Sysmon/Operational</location>
</localfile>
```

### 7) Restart & link

* **Restart agent:** `Restart-Service Wazuh` (Windows)
* **Restart manager** (inside container/host as appropriate).
* **Enroll agent** with the manager key; verify **Dashboard → Agents = Connected**.

## Quick tests (safe, fast)

> Keep screenshots for your report.

**FIM:**

```powershell
"$([datetime]::Now) test" | Out-File "$env:USERPROFILE\Documents\fim-test.txt" -Append
```

*Dashboard → Security Events → File Integrity Monitoring* → “File modified”.

**User/Admin change:**

```powershell
net user demoUser "Demo!123" /add
net localgroup Administrators demoUser /add
net localgroup Administrators demoUser /del
net user demoUser /del
```

*Dashboard → Windows Events* → Event IDs **4720/4732/4733/4726**.

**Service tamper (Defender/Firewall):**

```powershell
# TEST ONLY, revert after
Stop-Service -Name WinDefend -Force
Start-Service -Name WinDefend
```

*Dashboard → System Monitoring* → Event IDs **7036/7040**.

**Vulnerabilities:**
*Dashboard → Modules → Vulnerabilities* (after feed sync).

**Sysmon (if enabled):**

```powershell
Start-Process notepad.exe
```

*Dashboard → Sysmon Monitoring* → Event ID **1** (process creation).

> [!WARNING]
> Only stop security services for a few seconds during testing, then **start them again**.

## (Optional) Active Response

Enable on manager/agent and tie to specific rules, e.g., **restart Defender** when stopped:

```xml
<command>
  <name>restart-defender</name>
  <executable>net</executable>
  <extra_args>start WinDefend</extra_args>
</command>
<active-response>
  <command>restart-defender</command>
  <location>local</location>
  <rules_id>7036</rules_id>
</active-response>
```

## Use cases (quick map)

* **Hardening proof:** Show that critical files/keys don’t change silently.
* **Account hygiene:** Alert on new users/admin adds outside change windows.
* **Defense health:** Catch Defender/Firewall stops or start-type changes.
* **Patch posture:** List CVEs per host; focus on High/Critical first.
* **Threat hunting:** Use Sysmon lines (proc, net, file) to see suspicious chains.
* **Auto-mitigation:** Restart stopped protections or block noisy IPs.

## Done when

* Agent is **Connected**; FIM/Events arrive; a **test alert** is visible.
* Vulnerability page shows data after feeds sync.
* (Optional) Sysmon events appear.
* You have **3-4 screenshots** as before/after proof.

That’s the compact version you can keep next to your Windows hardening steps. If you want, I can turn this into a printable one-pager or split per feature for your repo.

<br>

---

> [⮝ **Go to the Next Part** ⮝](Part-6.md)

---

> [⮝ **Go to the Overview Page** ⮝](../)

---
