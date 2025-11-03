# Project: Local Hardening with Wazuh

## 1. Introduction

The goal of this project is to harden a local Windows system and make the effectiveness of the applied security measures measurable.  
For this purpose, the open-source security platform **Wazuh** is used as a **Host-based Intrusion Detection System (HIDS)**.  
Wazuh continuously monitors the system, detects suspicious activity or configuration changes, and provides transparent evidence of the system’s security state.

The project is divided into two main parts:

1. **Technical hardening** of the Windows client (deactivating insecure services, enforcing BitLocker, applying restrictive permissions, etc.)
2. **Integration of Wazuh** to detect and visualize system events, attacks, or misconfigurations in real time.

---

## 2. What is Wazuh

**Wazuh** is a free, open-source security monitoring platform that provides log analysis, file integrity checking, intrusion detection, vulnerability detection, and active response capabilities.

### Main Components
- **Wazuh Manager** – central analysis engine that processes data and applies detection rules  
- **Wazuh Agent** – runs on endpoints to collect logs, monitor files, and detect changes  
- **Wazuh Dashboard** – web interface for visualizing alerts and metrics  
- **OpenSearch / Elasticsearch** – database that indexes and stores collected data  

Wazuh monitors files, system logs, processes, and configurations to identify threats, misconfigurations, or attacks — making it a strong foundation for endpoint security and compliance.

---

## 3. Why Wazuh is Needed

Hardening a system once is not enough — configurations can change, updates may introduce new vulnerabilities, and users can modify settings.  
**Wazuh** ensures that these changes are detected immediately and that the system remains compliant with security policies.

### Examples of what Wazuh detects:
- Unauthorized file or registry modifications  
- New administrator accounts being created  
- Suspicious PowerShell or script activity  
- Outdated or vulnerable software (CVE matches)

Wazuh provides **visibility, traceability, and continuous verification** — proving that the system is truly hardened and remains secure over time.

---


## 4. Wazuh Features


# File Integrity Monitoring (FIM) - Wazuh


## What is File Integrity Monitoring (FIM)?

File Integrity Monitoring (FIM) is a security mechanism that detects and reports any change to files or directories on a system —
such as creation, modification, deletion, or permission changes.

It continuously checks the integrity of critical files by comparing their current state (hash, size, permissions, content)
to a known baseline stored by Wazuh.


## Why do you need FIM?

FIM is essential for detecting unauthorized or unexpected changes in your environment.
It helps maintain system integrity and supports compliance with major standards like CIS, PCI-DSS, HIPAA, GDPR.


| Purpose | Description |
|----------|--------------|
| **Security Detection** | Detects unauthorized or malicious modifications to critical files (e.g. `system32`, configuration files). |
| **Incident Response** | Identifies **what** changed, **when**, and **who** made the change. |
| **Compliance & Auditing** | Required by many security frameworks (e.g. CIS, PCI-DSS, HIPAA) for change-tracking and tamper detection. |
| **Hardening Validation** | Ensures that critical configuration files remain consistent after system hardening. |


## Real-World Use Cases

| Use Case | Description |
|-----------|--------------|
|  **System File Protection** | Detect unauthorized modification of OS files like `C:\Windows\System32\drivers\etc\hosts`. |
|  **Configuration File Monitoring** | Detect changes to system configuration or policy files (e.g. Windows Firewall rules, antivirus settings). |
|  **Log Tampering Detection** | Detect deletion or modification of security or audit logs. |
|  **Application Integrity** | Monitor application directories to ensure no unexpected or malicious files appear. |
|  **User Manipulation** | Detect unauthorized creation or modification of scripts, executables, or batch files. |
| **Ransomware Detection** | Detect sudden mass file modifications or encryption attempts in monitored folders. |


## How FIM Works in Wazuh

1. The Wazuh Agent scans defined directories and files.

2. It calculates checksums (hashes) for each file and keeps them in a database.

3. If a file changes, Wazuh recalculates the hash and detects the difference.

4. The Manager receives an event and triggers an alert in the Dashboard.


## Default Behavior


- The Wazuh agent already monitors critical system paths by default.

    - Windows: C:\Windows\System32, C:\Program Files, C:\Users\Public

    - Linux: /etc, /usr/bin, /var/log

- You can extend monitoring by adding your own folders (e.g. Documents, Desktop, custom configs).

## Configuration Example (Windows Agent)

You configure FIM on the Windows agent side in:


```md
C:\Program Files (x86)\ossec-agent\ossec.conf
````

Example Configuration Block


```md
<!-- File Integrity Monitoring Configuration -->
<syscheck>
  <disabled>no</disabled>
  
  <!-- Scan frequency (in seconds) -->
  <frequency>3600</frequency>

  <!-- Enable real-time monitoring -->
  <directories realtime="yes">C:\Users\Public\Documents</directories>
  <directories realtime="yes">C:\Program Files</directories>
  
  <!-- Exclude temporary files -->
  <ignore>*.tmp</ignore>
  <ignore>C:\Windows\Temp</ignore>
</syscheck>

````

## Explanation


| Tag | Meaning |
|------|----------|
| `<disabled>` | Enables or disables FIM (`no` = enabled). |
| `<frequency>` | Defines how often a full scan runs (in seconds). |
| `<directories realtime="yes">` | Monitors specified directories for changes instantly. |
| `<ignore>` | Excludes certain files or folders from monitoring. |

## Testing the Configuration

After editing ossec.conf, restart the Wazuh Agent:

```md
Restart-Service Wazuh
````

Then test FIM:

```md
$p="$env:USERPROFILE\Documents\fim-test.txt"
"Hello Wazuh" | Out-File $p
Add-Content $p "Another line"
````

Within seconds, you’ll see in your Dashboard:
```md
Rule: File integrity monitoring event.
File modified: C:\Users\<User>\Documents\fim-test.txt
MD5 before: 9D3E...
MD5 after:  7A21...
````


## Where to See FIM Alerts in Dashboard

- Go to Dashboard → Security Events → File Integrity Monitoring

- Filter by your agent name (e.g. Laptop)

- You’ll see events like:

    - File added

    - File modified

    - File deleted

    - Permissions changed




## Advanced Options


| Option                                 | Description                                      |
| -------------------------------------- | ------------------------------------------------ |
| **realtime="yes"**                     | Detect changes instantly (via Windows API).      |
| **report_changes="yes"**               | Sends diff of changed content (text files only). |
| **frequency="3600"**                   | Performs full rescan every hour.                 |
| **ignore_directories_recursive="yes"** | Skips entire folders.                            |


Example:
````
<directories realtime="yes" report_changes="yes">C:\Windows\System32</directories>
````


## Typical FIM Events (you can show in video)


| Action | Dashboard Event | Example |
|---------|------------------|----------|
| **Create file** | `File added` | Created `fim-test.txt` |
| **Modify file** | `File modified` | Appended data to file |
| **Delete file** | `File deleted` | Removed `log.txt` |
| **Rename / move** | `File renamed` | Moved document |
| **Change permission** | `Permissions changed` | NTFS ACLs updated |

## Best Practice Recommendations

- Monitor only critical paths → too many folders = performance impact.

- Use realtime="yes" for fast detection.

- Enable report_changes="yes" for sensitive text configs (like .ini, .xml).

- Ignore cache or temp folders to avoid noise.

- Store alerts centrally and review changes regularly.


## Summary

| Aspect                | Description                                                                    |
| --------------------- | ------------------------------------------------------------------------------ |
| **Purpose**           | Detect and report unauthorized file changes                                    |
| **Configured on**     | Wazuh Agent (`ossec.conf`)                                                     |
| **Monitors**          | File create, modify, delete, rename, permissions                               |
| **Demo command**      | `echo "change" >> fim-test.txt`                                                |
| **Dashboard section** | *Security Events → File Integrity Monitoring*                                  |
| **Usefulness**        | High — visible, easy to test, essential for compliance and intrusion detection |
---------------------------




# Registry Monitoring



##  What is Registry Monitoring?

**Registry Monitoring** in Wazuh is a feature that tracks and reports **changes made to the Windows Registry** —  
such as when keys or values are **created, modified, or deleted**.

The Windows Registry is a core component of the operating system that stores:
- Configuration settings,
- Startup applications,
- Security policies,
- Software installation data, and
- System services.

In short: Wazuh can alert you whenever something or someone changes important registry entries —  
which is crucial for detecting malware persistence, policy tampering, or configuration abuse.

---

## Why Do You Need Registry Monitoring?

Monitoring registry activity is essential for maintaining system integrity and detecting suspicious behavior.

| Purpose | Description |
|----------|--------------|
| **Security Detection** | Detects malicious changes such as new autostart entries, altered policies, or disabled security controls. |
| **Persistence Detection** | Identifies registry keys often used by malware to survive reboots. |
| **Configuration Integrity** | Ensures important system and software settings remain unchanged. |
| **Hardening Validation** | Confirms that registry-based security configurations stay compliant with hardening standards. |
| **Compliance & Auditing** | Required by frameworks like PCI-DSS, CIS, and NIST to track configuration changes. |

---

##  Real-World Use Cases

| Use Case | Description |
|-----------|--------------|
|  **Autostart Key Modification** | Detects when a new application is added to `HKLM\Software\Microsoft\Windows\CurrentVersion\Run` (common persistence method). |
|  **Policy Tampering** | Alerts when someone modifies Windows Defender, Firewall, or RDP-related registry values. |
|  **Malware Persistence** | Detects when malware tries to insert itself into startup registry keys. |
| 🧑 **User Configuration Changes** | Tracks unauthorized edits to user policies under `HKCU`. |
|  **System Hardening Validation** | Ensures key registry policies (e.g. password complexity, SMBv1 disable) remain enforced. |

---

##  Configuration (Windows Agent)

Registry monitoring is configured in the **agent configuration file**:  
`C:\Program Files (x86)\ossec-agent\ossec.conf`

### Example Configuration

```xml
<registry>
  <!-- Monitors global startup entries -->
  <entry type="realtime">HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run</entry>

  <!-- Monitors user startup entries -->
  <entry type="realtime">HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run</entry>

  <!-- Monitors Windows Security Policies -->
  <entry type="realtime">HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\WindowsFirewall</entry>

  <!-- Optional: Watch Defender configuration -->
  <entry type="realtime">HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows Defender</entry>
</registry>
```



## 🧩 Explanation

| Tag | Meaning |
|------|----------|
| `<registry>` | Defines the registry monitoring configuration section. |
| `<entry>` | Specifies a key or path to watch in the registry. |
| `type="realtime"` | Enables real-time detection — Wazuh reacts immediately to changes. |

---

## 🔄 Restart the Agent After Changes

After editing the configuration file, restart the Wazuh agent service to apply changes:

```powershell
Restart-Service Wazuh
```




##  Testing the Configuration

###  Test Command (PowerShell)

You can simulate a registry modification by adding a new autostart entry:

```powershell
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v DemoStart /t REG_SZ /d "C:\Windows\System32\notepad.exe" /f
```


## Expected Result

In your Wazuh Dashboard → Security Events → Windows Registry Monitoring,

you should see an alert similar to:
```vbnet
Rule: Windows registry key added.
Registry key: HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run
Value: DemoStart
```


## Where to View the Alerts

- Go to Dashboard → Security Events → Windows Registry Monitoring

- Filter by your agent name (e.g. Laptop)

- You will see:

    - Registry key created

    - Registry key modified

    - Registry key deleted


## Typical Registry Monitoring Events

| Action                   | Dashboard Event                   | Example                                                                 |
| ------------------------ | --------------------------------- | ----------------------------------------------------------------------- |
| **Create key**        | `Registry key created`            | Added new entry in `HKLM\Software\Microsoft\Windows\CurrentVersion\Run` |
|  **Modify key**        | `Registry key modified`           | Changed value for startup application                                   |
|  **Delete key**        | `Registry key deleted`            | Removed registry value manually                                         |
|  **Policy tampering**  | `Security policy modified`        | Disabled Windows Defender via registry                                  |
|  **Permission change** | `Registry key permission changed` | Modified ACL on sensitive key                                           |


## Best Practices

| Recommendation                 | Reason                                                                     |
| ------------------------------ | -------------------------------------------------------------------------- |
| **Monitor only critical keys** | Avoid unnecessary alerts from non-security paths.                          |
| **Use `type="realtime"`**      | Detect registry changes instantly.                                         |
| **Protect agent config**       | Prevent attackers from disabling registry monitoring.                      |
| **Combine with FIM**           | Provides full visibility — files + registry = complete system integrity.   |
| **Review alerts regularly**    | Registry changes can indicate privilege escalation or malware persistence. |


## Summary

| Aspect                | Description                                                                             |
| --------------------- | --------------------------------------------------------------------------------------- |
| **Purpose**           | Detect and alert on registry key or value changes.                                      |
| **Configured on**     | Wazuh Agent (`ossec.conf`).                                                             |
| **Monitors**          | Creation, modification, and deletion of registry keys.                                  |
| **Demo command**      | `reg add "HKLM\...\Run" /v DemoStart /t REG_SZ /d "C:\Windows\System32\notepad.exe" /f` |
| **Dashboard section** | *Security Events → Windows Registry Monitoring*.                                        |
| **Usefulness**        | High — excellent for detecting persistence, policy tampering, and malware activity.     |




# User Creation & Privilege Escalation



---

##  What is it?

**User Creation & Privilege Escalation** monitoring detects when user accounts are created, deleted, or when existing accounts receive elevated privileges (e.g. being added to the Administrators group).  
Wazuh ingests Windows Security events and matches them against built-in rules to surface these actions as alerts.

---

##  Why do you need it?

| Purpose | Description |
|---------|-------------|
| **Early compromise detection** | Attackers often create accounts or escalate privileges to maintain access—detecting this early prevents lateral movement. |
| **Audit & compliance** | Required evidence for audits: who created/modified privileged accounts and when. |
| **Operational security** | Detects accidental or unauthorized admin additions (internal threats or misconfigurations). |
| **Incident response** | Provides data to trace the actor, time, and sequence of changes for forensic analysis. |

---

##  Real-World Use Cases

| Use Case | Description |
|----------|-------------|
| **New local user** | `net user newuser /add` — detects new account creation. |
| **Local admin added** | `net localgroup Administrators newuser /add` — detects privilege escalation. |
| **Domain user added to local admin** | Detect when domain accounts are granted local admin rights. |
| **Mass account creation** | Multiple accounts created in short time → suspicious automation or compromise. |
| **Account deletion** | Detect removal of users (may indicate cover-up). |
| **Password change for service/admin account** | Unusual changes to privileged accounts. |

---

##  Configuration (Windows Agent & System)

### 1) Ensure Wazuh Agent collects Windows Security events

Add / confirm in the agent config (`C:\Program Files (x86)\ossec-agent\ossec.conf`):

```xml
<localfile>
  <log_format>eventchannel</log_format>
  <location>Security</location>
</localfile>
```


After changes, restart the agent:
```ps
Restart-Service Wazuh
```

```ps
## Ensure Windows Audit Policy logs relevant events
Enable auditing for account management and privilege use (run as Administrator):

# Enable auditing for user account management
auditpol /set /subcategory:"User Account Management" /success:enable /failure:enable

# Enable auditing for privilege use (optional)
auditpol /set /subcategory:"Privilege Use" /success:enable /failure:enable

# Recommended: audit changes to groups
auditpol /set /subcategory:"Security Group Management" /success:enable /failure:enable
```

Verify settings:
```
auditpol /get /category:*
```

## Testing (Commands you can run in the demo)

Run each command in PowerShell as Administrator. Show the command, then switch to the Wazuh Dashboard to show the alert.

```
# 1) Create a new local user
net user demoUser "Demo!123" /add

# 2) Add the user to local Administrators (privilege escalation)
net localgroup Administrators demoUser /add

# 3) Remove the user (cleanup)
net user demoUser /del
```

Alternatively, create a domain-like test (if applicable):

```
# Add a domain user to local administrators (replace DOMAIN\User)
net localgroup Administrators "DOMAIN\User" /add
```

# Expected Alerts / Event Types

| Action                                      | Windows Event ID(s) | Wazuh Alert Example                                    |
| ------------------------------------------- | ------------------- | ------------------------------------------------------ |
| New local user created                      | **4720**            | *User account created*                                 |
| User account deleted                        | **4726**            | *User account deleted*                                 |
| Add user to local group (Administrators)    | **4732** / **4733** | *A member was added to a security-enabled local group* |
| Group membership change (e.g., admin added) | **4732**            | *User added to Administrators group*                   |
| Password change/reset                       | **4724**            | *An attempt was made to reset an account's password*   |
| Privilege use/change                        | **4670**, **4672**  | *Special privileges assigned to new logon*             |


# Where to View Alerts in the Dashboard

- Dashboard → Security Events → Windows Events (or use the Agents → select agent → Events)

- Use filters:

    - Agent name (e.g. Laptop)

    - Rule category: User management, Account management, or Privilege escalation

    - Event ID (e.g., 4720, 4732)

Example fields to show in the video: Rule name, Event ID, User, Target Account, Timestamp, Source IP (if available).


# Best Practices

| Recommendation                                     | Reason                                                                |
| -------------------------------------------------- | --------------------------------------------------------------------- |
| **Enable Security Event channel collection**       | Ensures user events are captured by Wazuh.                            |
| **Enable auditing for account & group management** | Without Windows audit events, Wazuh can't detect changes.             |
| **Minimize noise**                                 | Filter or tune rules for expected automated account operations.       |
| **Alert on unusual patterns**                      | E.g., account creation outside business hours or mass creations.      |
| **Automate response (optional)**                   | Use Active Response to disable newly created accounts pending review. |
| **Log retention & forensic storage**               | Keep logs for incident investigation and compliance.                  |



# Mitigation & Response Ideas (optional / advanced)

- Automatically disable new accounts until approved (Active Response script).

- Trigger an email/SMS/Slack notification on any addition to Administrators group.

- Correlate with login events and process creation (via Sysmon) to identify suspicious activity after account creation.



# Summary

| Aspect            | Description                                                               |
| ----------------- | ------------------------------------------------------------------------- |
| **Purpose**       | Detect creation/deletion of user accounts and privilege escalations.      |
| **Configured on** | Wazuh Agent + Windows Audit Policy.                                       |
| **Key tests**     | `net user ... /add`, `net localgroup Administrators ... /add`             |
| **Key events**    | Windows Event IDs: 4720, 4726, 4732, 4724, 4672, etc.                     |
| **Dashboard**     | Security Events → Windows Events / Agent → Events                         |
| **Usefulness**    | Critical — helps detect initial access, persistence, and insider threats. |



# Service Stop Monitoring (Defender / Firewall) — Wazuh

---

##  What is it?

**Service Stop Monitoring** in Wazuh detects when important Windows services —  
such as **Windows Defender**, **Firewall**, or **security-related agents** — are **stopped**, **disabled**, or **manipulated**.

Wazuh collects events from the Windows **System** and **Security Event Logs**.  
These logs contain service control manager (SCM) messages that indicate when a service changes its state (e.g., from *running* to *stopped*).

In simple terms: Wazuh alerts you if someone or something disables key system protections.

---

##  Why do you need it?

| Purpose | Description |
|----------|--------------|
| **Malware Detection** | Malware and attackers often disable antivirus, firewall, or monitoring services to stay undetected. |
| **System Hardening Verification** | Ensures that critical protection services remain enabled after system updates or reboots. |
| **Incident Response** | Provides early warning if defensive layers are turned off. |
| **Compliance & Auditing** | Many security frameworks (e.g., CIS, ISO 27001) require that AV and firewall protections are always active. |

---

##  Real-World Use Cases

| Use Case | Description |
|-----------|--------------|
|  **Windows Defender Disabled** | Detect when the `WinDefend` service is stopped (manual, malware, or user). |
|  **Firewall Service Stopped** | Detect when the `MpsSvc` (Windows Firewall) is stopped or disabled. |
|  **Third-Party AV Disabled** | Detect when other registered antivirus or EDR services are turned off. |
|  **Critical Service Crash** | Detect when a system or monitoring service unexpectedly stops running. |
|  **Insider Threat** | Detect intentional shutdown of protections to execute scripts or malware undetected. |

---

##  Configuration (Windows Agent)

Service monitoring relies on **Windows Event Logs**, not direct service polling.  
Ensure your agent collects events from both `System` and `Security` channels.

### 1 Enable Event Log Collection

Edit the agent config file:  
`C:\Program Files (x86)\ossec-agent\ossec.conf`

```xml
<localfile>
  <log_format>eventchannel</log_format>
  <location>System</location>
</localfile>

<localfile>
  <log_format>eventchannel</log_format>
  <location>Security</location>
</localfile>

Restart the Wazuh agent after changes:
```PS
Restart-Service Wazuh
```

## Relevant Windows Event IDs

| Event ID | Description                                                     |
| -------- | --------------------------------------------------------------- |
| **7036** | Service entered a stopped or running state (from System log).   |
| **7035** | Service control sent (start/stop request).                      |
| **4697** | Service installed on the system (potential persistence method). |
| **7040** | Start type of a service changed (e.g., from Auto → Disabled).   |


## Testing the Configuration


Run the following commands in PowerShell (Administrator) to simulate service stops.


- Only for testing. Restart the services afterwards!
```PS
# Stop Windows Defender service
Stop-Service -Name WinDefend -Force

# Stop Windows Firewall service
Stop-Service -Name MpsSvc -Force
```

Check alerts in Dashboard → Security Events → Windows System Monitoring.


After testing, restart the services:
```
Start-Service -Name WinDefend
Start-Service -Name MpsSvc
```

## Expected Result (Example Alerts)

| Action            | Event ID | Example Alert in Wazuh                                       |
| ----------------- | -------- | ------------------------------------------------------------ |
| Stop Defender     | 7036     | *Windows Defender service entered the stopped state*         |
| Start Defender    | 7036     | *Windows Defender service entered the running state*         |
| Stop Firewall     | 7036     | *Windows Firewall service entered the stopped state*         |
| Change Start Type | 7040     | *Start type of Windows Defender service changed to disabled* |


## Where to View the Alerts


- Dashboard → Security Events → Windows System Monitoring

- Filter by:

- Agent name (e.g., Laptop)

- Rule group: windows, system, or service

- Search term: Defender, Firewall, WinDefend, MpsSvc


## Best Practices

| Recommendation                             | Reason                                                                                  |
| ------------------------------------------ | --------------------------------------------------------------------------------------- |
| **Monitor all security-critical services** | Defender, Firewall, Wazuh Agent, Sysmon, and third-party AV.                            |
| **Enable both System & Security logs**     | Service control events are logged in System, while privilege use is in Security.        |
| **Add Active Response (optional)**         | Automatically restart a stopped protection service.                                     |
| **Correlate with user actions**            | Combine service stop with user account or privilege escalation events for full context. |
| **Alert on configuration changes (7040)**  | Detect when services are set to "disabled" instead of being just stopped.               |



## Optional — Active Response Example (Auto Restart)

You can configure Wazuh to restart services automatically when critical ones stop.

In the Wazuh Manager’s ossec.conf:

```
<active-response>
  <command>net start WinDefend</command>
  <location>local</location>
  <rules_id>7036</rules_id>
</active-response>
```
This is an advanced option — test carefully.

## Summary



| Aspect                | Description                                                                            |
| --------------------- | -------------------------------------------------------------------------------------- |
| **Purpose**           | Detect and alert when key protection services (e.g., Defender, Firewall) stop running. |
| **Configured on**     | Wazuh Agent (`ossec.conf`) + Eventchannel (System/Security).                           |
| **Monitors**          | Service start/stop events, configuration changes, and crashes.                         |
| **Demo commands**     | `Stop-Service WinDefend -Force`, `Stop-Service MpsSvc -Force`                          |
| **Dashboard section** | *Security Events → Windows System Monitoring*.                                         |
| **Usefulness**        | High — detects malware tampering, insider abuse, and hardening violations.             |



# Vulnerability Detection Report — Wazuh



## What is it?

**Vulnerability Detection** in Wazuh is a built-in module that automatically scans your systems for **known software vulnerabilities (CVEs)**.  
It compares the list of installed software and operating system packages on each endpoint against a constantly updated database of Common Vulnerabilities and Exposures.

Wazuh pulls vulnerability feeds from official sources such as **Canonical, Debian, Microsoft, Red Hat, and NVD**.  
It then correlates version information to detect outdated or insecure software.

In short: Wazuh continuously checks your systems for known security holes and reports them in the dashboard.

---

##  Why do you need it?

| Purpose | Description |
|----------|--------------|
| **Proactive Risk Management** | Identifies software with known security issues before attackers can exploit them. |
| **Continuous Compliance** | Many frameworks (CIS, ISO 27001, PCI DSS) require ongoing vulnerability assessment. |
| **Patch Prioritization** | Helps prioritize which systems or applications need urgent updates. |
| **Centralized Reporting** | Aggregates CVE data across all agents in one dashboard for easy analysis. |
| **Reduced Attack Surface** | Ensures endpoints remain up to date and resilient against common exploits. |

---

##  Real-World Use Cases

| Use Case | Description |
|-----------|--------------|
|  **Windows Patch Verification** | Detect missing security updates on Windows endpoints. |
|  **Software Version Scanning** | Find outdated third-party applications (e.g., Java, Chrome, Adobe). |
|  **Server Vulnerability Monitoring** | Track CVEs affecting server components (IIS, Apache, OpenSSL). |
|  **Compliance Reporting** | Generate vulnerability status reports for audits and security reviews. |
|  **Post-Hardening Validation** | Confirm that patching and hardening measures successfully reduced CVEs. |

---

##  Configuration (Wazuh Manager)

Vulnerability detection runs on the **Wazuh Manager**, not on agents directly.  
To enable it, edit the manager’s configuration file:

`/var/ossec/etc/ossec.conf`

Add or verify this block inside the `<ossec_config>` section:

```xml
<wodle name="vulnerability-detector">
  <enabled>yes</enabled>
  <interval>1h</interval>           <!-- Check every hour -->
  <ignore_time>6h</ignore_time>     <!-- Avoid rescan too frequently -->
  <run_on_start>yes</run_on_start>
  <feed>
    <type>cpe</type>
    <enabled>yes</enabled>
  </feed>
  <feed>
    <type>msu</type>                <!-- Microsoft updates -->
    <enabled>yes</enabled>
  </feed>
  <os>Windows</os>                  <!-- Specify OS family -->
  <update_interval>1h</update_interval>
</wodle>
```


Then restart the Wazuh manager service:
```
systemctl restart wazuh-manager
```


## Testing & Usage
After enabling and restarting, the manager begins scanning connected agents automatically.
Agents send their software inventory data to the manager, which then performs the vulnerability correlation.


Check status manually (inside manager container)
```
docker exec -it single-node-wazuh.manager-1 bash
/var/ossec/bin/wazuh-modulesd -dbquery vulnerabilities status
```


Example output
```
Vulnerability detector: enabled
Last scan: 2025-11-03 12:00
Total vulnerabilities found: 5
```

## Expected Result (Dashboard)

In the Wazuh Dashboard:

1. Go to Modules → Vulnerabilities

2. Select an agent (e.g., Laptop)

3. View the list of detected vulnerabilities

Each entry will show:

- CVE ID (e.g., CVE-2025-12345)

- Software name

- Installed version

- Fixed version

- Severity (Low / Medium / High / Critical)

- Published date

Example alert:

```
Software: Google Chrome
Version: 126.0.6478.51
CVE: CVE-2025-12345
Severity: High
Status: Vulnerable
```


## Where to View the Reports

- Dashboard → Modules → Vulnerabilities

- Dashboard → Security Events → Vulnerability Detection

- Filter by agent, CVE severity, or software name.


You can also export the report as CSV or JSON from the dashboard for compliance documentation.


## Typical Vulnerability Detection Events

| Event Type                            | Description                                              | Example                                        |
| ------------------------------------- | -------------------------------------------------------- | ---------------------------------------------- |
|  **New vulnerability found**        | Wazuh detected a CVE affecting installed software.       | `CVE-2024-5678` — affects Microsoft Edge 121.0 |
|  **Vulnerability resolved**         | Detected CVE no longer applies after software update.    | Chrome updated → CVE cleared                   |
|  **Critical vulnerability pending** | High-severity CVE found with known exploit.              | CVE-2025-0012 in OpenSSL                       |
|  **Feed update**                    | Vulnerability database updated from NVD/Microsoft feeds. | Feed synchronization successful                |


## Best Practices


| Recommendation                        | Reason                                                                     |
| ------------------------------------- | -------------------------------------------------------------------------- |
| **Keep Wazuh feeds updated**          | Ensures you detect the latest vulnerabilities.                             |
| **Scan at regular intervals**         | Use `<interval>` and `<update_interval>` appropriately (e.g., every hour). |
| **Correlate with patch management**   | Integrate findings into your patch workflow.                               |
| **Filter low-severity CVEs**          | Focus on critical and high-severity issues first.                          |
| **Document vulnerability resolution** | Track before-and-after states for compliance audits.                       |

## Advanced Tip (Optional)


Enable email or webhook alerts for critical vulnerabilities only by adjusting alert rules in 
```
/var/ossec/etc/rules/local_rules.xml
````


```
<rule id="100020" level="10">
  <if_sid>23503</if_sid>
  <field name="vulnerability.severity">Critical</field>
  <description>Critical vulnerability detected</description>
</rule>
```


## Summary


| Aspect                | Description                                                                              |
| --------------------- | ---------------------------------------------------------------------------------------- |
| **Purpose**           | Identify and report known software vulnerabilities (CVEs) across all agents.             |
| **Configured on**     | Wazuh Manager (`ossec.conf`).                                                            |
| **Feeds used**        | Microsoft, Canonical, Debian, Red Hat, NVD.                                              |
| **Monitors**          | Software inventory from agents → correlated with CVE databases.                          |
| **Dashboard section** | *Modules → Vulnerabilities* or *Security Events → Vulnerability Detection*.              |
| **Usefulness**        | High — critical for proactive patching, compliance, and overall system security posture. |








# Sysmon Process Alerts (Optional) — Wazuh



##  What is it?

**Sysmon (System Monitor)** is a Windows system service and driver from Microsoft Sysinternals that logs detailed information about **process creation, network connections, file creation, registry changes, and command executions**.  
When combined with **Wazuh**, Sysmon provides **deep visibility** into endpoint activity, allowing you to detect suspicious or malicious behaviors that standard Windows Event Logs may miss.

Wazuh collects Sysmon logs through the **Event Channel**, parses them using built-in decoders, and triggers alerts for behaviors like:
- PowerShell abuse
- Suspicious process trees
- Command-line execution
- Network anomalies

In simple terms: Sysmon + Wazuh lets you “see inside” what processes are doing — great for malware detection and threat hunting.

---

##  Why do you need it?

| Purpose | Description |
|----------|--------------|
| **Advanced Threat Detection** | Detect malicious process executions, script abuse, and persistence mechanisms. |
| **Behavioral Analysis** | Track how processes spawn, interact, and communicate over the network. |
| **Incident Response** | Reconstruct attack chains (what process executed what, when, and how). |
| **Forensic Visibility** | Retain detailed logs for post-incident analysis. |
| **Compliance** | Helps meet security monitoring requirements in frameworks like CIS and NIST. |

---

## Real-World Use Cases

| Use Case | Description |
|-----------|--------------|
|  **PowerShell Abuse** | Detect PowerShell with encoded or downloaded scripts (`powershell.exe -enc` or `Invoke-WebRequest`). |
|  **Suspicious Process Spawning** | Alert when `cmd.exe` spawns from `Outlook.exe` or `Word.exe` (possible macro attack). |
|  **Unexpected Network Connections** | Identify processes making external connections (e.g., malware beaconing). |
|  **Executable Drop Detection** | Monitor `.exe` or `.dll` file creation in unusual locations. |
|  **Persistence Mechanisms** | Detect registry modifications or tasks created by Sysmon event types. |
|  **Command Line Visibility** | Capture the full command line of any executed process for investigation. |

---

##  Configuration Steps

###  Install Sysmon

Download Sysmon from the official Sysinternals page:  
🔗 [https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon](https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon)

Run as Administrator:

```
sysmon64.exe -accepteula -i sysmonconfig.xml
```


## Recommended Configuration (SwiftOnSecurity)

Download the community-maintained config file for best coverage:

```
Invoke-WebRequest -Uri https://github.com/SwiftOnSecurity/sysmon-config/raw/master/sysmonconfig-export.xml -OutFile sysmonconfig.xml
sysmon64.exe -c sysmonconfig.xml
```
This configuration logs the most relevant process, network, and file activity without too much noise.


## Configure Wazuh Agent to Collect Sysmon Logs

Edit the Wazuh agent configuration file:
```
C:\Program Files (x86)\ossec-agent\ossec.conf
```

Add the following block:

```
<localfile>
  <log_format>eventchannel</log_format>
  <location>Microsoft-Windows-Sysmon/Operational</location>
</localfile>
```

Restart the Wazuh agent:
```
Restart-Service Wazuh
```

## Testing the Configuration

Once Sysmon and the Wazuh agent are set up, generate test events.


### Example Tests

```
# Run a PowerShell encoded command
powershell -enc UwB0AGEAcgB0AC0AUwBMAEEAUAA=

# Download a harmless file (simulates malicious download)
powershell -Command "Invoke-WebRequest http://example.com -OutFile C:\Users\Public\demo.txt"

# Run Notepad from PowerShell (process creation chain)
Start-Process notepad.exe
```

## Expected Alerts (Dashboard)
| Event Type             | Description                 | Example                                   |
| ---------------------- | --------------------------- | ----------------------------------------- |
| **Sysmon Event ID 1**  | Process creation            | PowerShell started from cmd.exe           |
| **Sysmon Event ID 3**  | Network connection detected | Connection from PowerShell to external IP |
| **Sysmon Event ID 11** | File created                | `.exe` or `.dll` dropped in temp folder   |
| **Sysmon Event ID 13** | Registry value set          | New autorun key added                     |
| **Sysmon Event ID 10** | Process access              | Tool injecting into another process       |


Each event includes rich metadata:

- Process name

- Parent process

- Command line

- User

- Hash (MD5, SHA256)

- Network destination IP and port


Where to View the Alerts

- Dashboard → Security Events → Sysmon Monitoring

- Dashboard → Agents → Select Agent → Events

- Filter by:

    - Rule group: sysmon, process, or threat detection

    - Process name: powershell.exe, cmd.exe, notepad.exe

    - Event ID: 1, 3, 10, 11, 13

## Best Practices

| Recommendation                               | Reason                                                    |
| -------------------------------------------- | --------------------------------------------------------- |
| **Use a well-tuned Sysmon config**           | Avoid log overload while maintaining visibility.          |
| **Monitor Event IDs 1, 3, 11, 13**           | These cover most process, file, and registry changes.     |
| **Correlate with FIM & Registry Monitoring** | Combine to detect full attack chains.                     |
| **Limit log size**                           | Sysmon logs can grow quickly; set retention to 7–14 days. |
| **Test rules on non-production first**       | Prevent performance issues during tuning.                 |


## Optional: Active Response Idea


You can trigger an automated response for specific Sysmon events — for example, kill a suspicious process:

```
<active-response>
  <command>taskkill /F /IM powershell.exe</command>
  <location>local</location>
  <rules_group>sysmon</rules_group>
</active-response>
```
Only enable this after testing — false positives could terminate legitimate processes.


## Summary


| Aspect                | Description                                                                       |
| --------------------- | --------------------------------------------------------------------------------- |
| **Purpose**           | Monitor and alert on detailed process, file, and network activities using Sysmon. |
| **Configured on**     | Windows Agent (`ossec.conf`) + Sysmon installation.                               |
| **Monitors**          | Process creation, network connections, file and registry modifications.           |
| **Demo commands**     | `powershell -enc ...`, `Start-Process notepad.exe`                                |
| **Dashboard section** | *Security Events → Sysmon Monitoring*.                                            |
| **Usefulness**        | Very High — provides deep visibility and supports advanced threat detection.      |



# Active Response



---

##  What is it?

**Active Response** in Wazuh is a powerful feature that allows the system to **automatically react to security events** detected by its agents or the manager.  
Instead of just generating alerts, Wazuh can **execute pre-defined actions** (like blocking an IP, disabling a user, restarting a service, or running a custom script).

These responses are triggered by matching specific **alert rules** and can be configured to run **locally (on the affected agent)** or **remotely (from the manager)**.

In short: Active Response turns Wazuh from a passive monitoring system into an **automated defense mechanism**.

---

##  Why do you need it?

| Purpose | Description |
|----------|--------------|
| **Automated Threat Mitigation** | Reacts instantly to attacks like brute force or malware activity without waiting for human input. |
| **Reduced Response Time** | Minimizes the time between detection and mitigation. |
| **Prevents Recurring Attacks** | Blocks repeated offenders automatically based on rule correlation. |
| **Supports Custom Remediation** | Run custom PowerShell or Bash scripts for advanced use cases. |
| **Improves Security Posture** | Adds active defense capabilities to your monitoring setup. |

---

##  Real-World Use Cases

| Use Case | Description |
|-----------|--------------|
|  **Brute Force Protection** | Automatically block IP addresses performing repeated failed login attempts. |
|  **Malware Process Termination** | Detect malicious process creation (via Sysmon) and kill it automatically. |
|  **Firewall Rule Injection** | Add a temporary firewall rule to block suspicious outbound traffic. |
|  **Service Auto-Restart** | Restart security-critical services (Defender, Firewall) if they are stopped. |
|  **Custom Response Scripts** | Execute organization-specific remediation scripts for detected incidents. |

---

##  Configuration (Manager + Agent)

Active Response requires configuration on both the **Wazuh Manager** and **Wazuh Agents**.

###  Enable Active Response on Manager

Edit `/var/ossec/etc/ossec.conf` inside the manager container:

```xml
<ossec_config>
  <global>
    <active-response>yes</active-response>
  </global>

  <!-- Example: Block attacker IP -->
  <command>
    <name>firewalldrop</name>
    <executable>firewalldrop</executable>
    <timeout>600</timeout>
  </command>

  <active-response>
    <command>firewalldrop</command>
    <location>local</location>
    <rules_group>authentication_failures</rules_group>
  </active-response>

  <!-- Example: Restart Windows Defender service -->
  <command>
    <name>restart-defender</name>
    <executable>net</executable>
    <extra_args>start WinDefend</extra_args>
  </command>

  <active-response>
    <command>restart-defender</command>
    <location>local</location>
    <rules_id>7036</rules_id> <!-- Trigger when service stopped -->
  </active-response>
</ossec_config>
```


Restart the manager after saving:
```
systemctl restart wazuh-manager
```

## Enable on the Agent (Windows)

In the agent configuration file:
```
C:\Program Files (x86)\ossec-agent\ossec.conf
```
Ensure the following block exists:
```
<ossec_config>
  <global>
    <active-response>yes</active-response>
  </global>
</ossec_config>
```

Then restart the agent:
```
Restart-Service Wazuh
```


## Example Built-in Active Responses

| Command           | Description                              | Action                                    |
| ----------------- | ---------------------------------------- | ----------------------------------------- |
| `firewalldrop`    | Built-in command for IP blocking         | Adds firewall rule to block malicious IP. |
| `host-deny`       | Linux-only, adds IP to `/etc/hosts.deny` | Denies network access.                    |
| `disable-account` | Disables Windows user accounts           | Prevents further login attempts.          |
| `restart-service` | Restarts specified Windows service       | Restores protection automatically.        |
| `delete-file`     | Deletes specified file                   | Removes detected malware.                 |
| `custom-script`   | Executes user-defined script             | Flexible custom responses.                |



## Testing Active Response (Demo)

### Brute Force Simulation (for IP blocking)

You can simulate repeated failed logins (e.g., RDP or SSH).
Wazuh’s default rule set will trigger the firewalldrop command automatically.

To test manually from the manager:
```
/var/ossec/active-response/bin/firewalldrop 192.168.0.55 add
```

You can verify the rule in the Windows firewall (on the agent):

```
netsh advfirewall firewall show rule name=all | findstr 192.168.0.55
```


## Defender Auto-Restart Simulation

Defender Auto-Restart Simulation:
```
Stop-Service -Name WinDefend -Force
```

If configured properly, Wazuh will detect the service stop (Event ID 7036) and automatically run:
```
net start WinDefend
```

You will see an alert in the Dashboard:

"Active Response executed: restarted WinDefend service”



## Where to View the Alerts

- Dashboard → Security Events → Active Responses

- Dashboard → Agents → (Select Agent) → Events

- Look for messages like:

    - “Active response executed”

    - “Firewall rule applied”

    - “Service restarted automatically”


## Best Practices


| Recommendation                           | Reason                                                                  |
| ---------------------------------------- | ----------------------------------------------------------------------- |
| **Use Active Response sparingly**        | Prevent accidental disruptions due to false positives.                  |
| **Test all responses in a lab first**    | Avoid system-wide side effects.                                         |
| **Use rule IDs or groups for targeting** | Ensures specific triggers (e.g., only for Defender or Firewall events). |
| **Combine with Sysmon or FIM alerts**    | Build multi-layered defense logic.                                      |
| **Log every response**                   | Keep an audit trail for automated actions.                              |
| **Add timeouts**                         | Automatically undo temporary IP blocks after a set time.                |



## Example: Custom PowerShell Script Response

You can create your own script for advanced remediation.


Create a PowerShell script 
```
(C:\Program Files (x86)\ossec-agent\active-response\scripts\KillMalicious.ps1):
```


```
# Kill a suspicious process (example)
$process = "malware.exe"
Get-Process $process -ErrorAction SilentlyContinue | Stop-Process -Force
```

Register it in ossec.conf:

```
<command>
  <name>kill-malware</name>
  <executable>powershell.exe</executable>
  <extra_args>-ExecutionPolicy Bypass -File "C:\Program Files (x86)\ossec-agent\active-response\scripts\KillMalicious.ps1"</extra_args>
</command>

<active-response>
  <command>kill-malware</command>
  <location>local</location>
  <rules_group>sysmon</rules_group>
</active-response>
```


## Summary

| Aspect                | Description                                                                |
| --------------------- | -------------------------------------------------------------------------- |
| **Purpose**           | Automatically respond to security threats by executing predefined actions. |
| **Configured on**     | Wazuh Manager and Wazuh Agent (`ossec.conf`).                              |
| **Monitors**          | Alerts triggered by FIM, Sysmon, registry, or service events.              |
| **Demo commands**     | `Stop-Service WinDefend`, or simulate brute force.                         |
| **Dashboard section** | *Security Events → Active Responses*.                                      |
| **Usefulness**        | Very High — enables automatic remediation and real-time defense.           |




# Scheduled Script (automation)



---

## 🧠 What is it?

**Scheduled Script Automation** allows you to run custom **PowerShell or batch scripts automatically** on a Windows system at fixed intervals or events.  
In the context of Wazuh, these scripts can be used to **simulate monitoring events**, **check agent health**, **run FIM or registry tests**, or **generate alerts** for demonstration and validation.

This automation uses the **Windows Task Scheduler** to trigger scripts that interact with Wazuh or the monitored system — ensuring consistent, repeatable security checks or alerts.

In short: It’s how you make your Wazuh monitoring hands-free — scheduled tests, checks, and actions run automatically without manual intervention.

---

##  Why do you need it?

| Purpose | Description |
|----------|--------------|
| **Automated Monitoring Validation** | Continuously test that Wazuh is detecting events correctly. |
| **Demonstration / Proof of Concept** | Automatically trigger file or registry changes for demos or reports. |
| **System Health Checks** | Run periodic checks for service status, agent connectivity, or log integrity. |
| **Incident Simulation** | Recreate alerts (like FIM or service stops) to verify detection rules. |
| **Maintenance Tasks** | Restart services, rotate logs, or clear temp data on schedule. |

---

## Real-World Use Cases

| Use Case | Description |
|-----------|--------------|
|  **Automatic FIM Test** | Every 6 hours, create or modify a test file to confirm File Integrity Monitoring works. |
|  **Agent Status Check** | Once a day, verify that the Wazuh service is running and log the result. |
|  **Service Restart** | Automatically restart Windows Defender or Firewall if stopped. |
|  **Scheduled Log Export** | Export Wazuh agent logs daily for audit and backup. |
|  **Demo Automation** | Create recurring test events so the dashboard always shows live alerts. |

---

##  Configuration (Windows Task Scheduler)

###  Create a Script

You can create a PowerShell script in `C:\Wazuh\Scripts` (for example):

####  Example 1 – File Integrity Test Script (`fim-test.ps1`)
```powershell
$p = "$env:USERPROFILE\Documents\fim-auto.txt"
$date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"[$date] FIM test event" | Out-File $p
Add-Content $p "changed line at $date"
```


#### Example 2 – Agent Health Check Script (agent-health.ps1)

```
$date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$status = (Get-Service Wazuh).Status
"[$date] Wazuh Agent status: $status" | Out-File "C:\Wazuh\agent-health.log" -Append
```

#### Example 3 – Service Restart Script (restart-defender.ps1)

```
$service = "WinDefend"
if ((Get-Service $service).Status -ne "Running") {
    Start-Service $service
    Write-Output "[$(Get-Date)] Restarted $service" | Out-File "C:\Wazuh\service-restart.log" -Append
}
```


## Create a Scheduled Task


1. Open Task Scheduler → Create Task
2. General Tab
    - Name: Wazuh_Automation_Scripts
    - Run with highest privileges
3. Triggers Tab
   - Choose Daily, At startup, or Every 6 hours (depending on your use case)
4. Actions Tab
    - Program/script: powershell.exe
    - Add arguments:
    ```
   -ExecutionPolicy Bypass -File "C:\Wazuh\Scripts\fim-test.ps1"
    ````
5. Conditions Tab
   - Disable “Start the task only if the computer is on AC power” (for laptops)
6. Settings Tab
- Enable “Run task as soon as possible after a missed start”
- Allow task to be run on demand

Save and close the Task Scheduler.



## Verify It Works

Run the task manually the first time:
```
Start-ScheduledTask -TaskName "Wazuh_Automation_Scripts"
```
Check results:
- File changes → appear in Wazuh Dashboard → Security Events → File Integrity Monitoring
- Logs → found under C:\Wazuh\agent-health.log
- Defender service → auto-started if stopped

## Example Combined Setup (Automation Suite)

| Script                 | Schedule       | Purpose                                 |
| ---------------------- | -------------- | --------------------------------------- |
| `fim-test.ps1`         | Every 6 hours  | Create/modify file for FIM verification |
| `agent-health.ps1`     | Daily at 08:00 | Check if Wazuh agent is running         |
| `restart-defender.ps1` | Every 12 hours | Restart Defender if stopped             |
| `generate-events.ps1`  | Every 4 hours  | Create log entries for dashboard demo   |


This ensures your demo system always has fresh alerts and remains functional without manual work.


## Where to View the Alerts

| Type              | Dashboard Section                           | Example                              |
| ----------------- | ------------------------------------------- | ------------------------------------ |
| FIM Events        | Security Events → File Integrity Monitoring | *File modified: fim-auto.txt*        |
| Service Actions   | Security Events → System Monitoring         | *Windows Defender service restarted* |
| Agent Status Logs | Security Events → Agent Logs                | *Agent status: Running*              |
| Custom Scripts    | Security Events → Command Execution         | *Script executed successfully*       |


## Best Practices
| Recommendation                           | Reason                                                                |
| ---------------------------------------- | --------------------------------------------------------------------- |
| **Use separate folders for scripts**     | Keep all automation scripts organized (e.g., `C:\Wazuh\Scripts`).     |
| **Use descriptive log outputs**          | Helps correlate script actions with dashboard alerts.                 |
| **Run scripts with elevated privileges** | Required for service restarts or system-level changes.                |
| **Schedule off-peak hours**              | Prevent interference with daily usage.                                |
| **Combine with Wazuh FIM**               | So script changes themselves trigger visible alerts for verification. |


## Optional — Schedule Multiple Scripts Together

You can create a batch file (C:\Wazuh\run-all.bat) to run multiple PowerShell scripts in sequence:

```
powershell.exe -ExecutionPolicy Bypass -File "C:\Wazuh\Scripts\fim-test.ps1"
powershell.exe -ExecutionPolicy Bypass -File "C:\Wazuh\Scripts\agent-health.ps1"
powershell.exe -ExecutionPolicy Bypass -File "C:\Wazuh\Scripts\restart-defender.ps1"
```

Then schedule just one task to run run-all.bat.



## Summary

| Aspect                | Description                                                                                  |
| --------------------- | -------------------------------------------------------------------------------------------- |
| **Purpose**           | Automate script execution to generate events, verify monitoring, and maintain system health. |
| **Configured on**     | Windows Task Scheduler (host system).                                                        |
| **Scripts used**      | PowerShell scripts (`.ps1`) performing checks or changes.                                    |
| **Triggers**          | Time-based (every X hours) or event-based (startup, login).                                  |
| **Dashboard section** | *Security Events → File Integrity Monitoring / System Monitoring*.                           |
| **Usefulness**        | High — provides automation for testing, demos, and maintenance.                              |

notice make your output in markdown clean so i can copy that into my vs code really appreciate that

what is it? 
why do you need it for? 


use cases and configuration