<# 
.SYNOPSIS
  Check-RemoteDesktop.ps1 — Detects RDP/remote-control access, risky policies, and recent events.

.DESCRIPTION
  Designed for scheduled execution (e.g., Wazuh). Produces single-line JSON (default) or human text.
  Scores status as OK/WARN/ALERT with exit codes 0/1/2.

.PARAMETER LookbackMinutes
  Event lookback window. Default: 120 minutes.

.PARAMETER Output
  'json' (default) or 'text'

.PARAMETER FullScan
  Adds collaboration/screen-capture apps to the report (Teams/Zoom/Discord/OBS, etc.).

.EXAMPLES
  .\Check-RemoteDesktop.ps1
  .\Check-RemoteDesktop.ps1 -LookbackMinutes 60 -Output json
  .\Check-RemoteDesktop.ps1 -FullScan -Output text

.NOTES
  Best-effort detection. Some tools spoof names or use custom services/ports.
#>

[CmdletBinding()]
param(
  [int]$LookbackMinutes = 120,
  [ValidateSet('json','text')] [string]$Output = 'json',
  [switch]$FullScan
)

# ---------- helpers ----------
function New-Result { [ordered]@{
    ts = (Get-Date).ToString('o')
    hostname = $env:COMPUTERNAME
    user = $env:USERNAME
    lookback_minutes = $LookbackMinutes
    status = 'OK'
    summary = ''
    rdp = @{
      enabled = $null
      firewall_rules_enabled = $null
      listeners = @()
      sessions = @()
      recent_events = @{
        security_4624_type10 = @{ count = 0; last = $null }
        tsvcm_1149 = @{ count = 0; last = $null } # RemoteConnectionManager
        tslm_21 = @{ count = 0; last = $null }    # LocalSessionManager logon
        tslm_24 = @{ count = 0; last = $null }    # LocalSessionManager logoff
      }
      shadow_policy = $null
    }
    remote_assistance = @{
      allowed = $null
      processes = @()
    }
    remote_tools = @{
      running = @()
      listening_ports = @()
    }
    capture_collab = @{
      running = @()
    }
    errors = @()
} }

function Add-Error($result, $msg) { $result.errors += $msg | Out-String }

function Try-GetValue($ScriptBlock, $default = $null) {
  try { & $ScriptBlock } catch { $default }
}

# ---------- RDP / policy ----------
function Get-RdpEnabled {
  Try-GetValue {
    $v = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' -ErrorAction Stop
    return ($v.fDenyTSConnections -eq 0)
  } $false
}

function Get-RdpFirewallEnabled {
  Try-GetValue {
    $rules = Get-NetFirewallRule -ErrorAction Stop | Where-Object { $_.DisplayGroup -eq 'Remote Desktop' -and $_.Enabled -eq 'True' }
    return ($rules.Count -gt 0)
  } $false
}

function Get-RdpListeners {
  $ports = 3389
  Try-GetValue {
    Get-NetTCPConnection -State Listen -ErrorAction Stop |
      Where-Object { $_.LocalPort -eq 3389 } |
      ForEach-Object {
        $p = Try-GetValue { Get-Process -Id $_.OwningProcess -ErrorAction Stop }
        [pscustomobject]@{
          localAddress = $_.LocalAddress
          localPort    = $_.LocalPort
          pid          = $_.OwningProcess
          process      = if ($p) { $p.ProcessName } else { $null }
        }
      }
  } @()
}

function Get-RdpSessions {
  $sessions = @()
  try {
    $quser = (quser 2>$null)
    if ($quser) {
      $lines = $quser | Select-Object -Skip 1
      foreach ($line in $lines) {
        if (-not $line.Trim()) { continue }
        # Normalize whitespace
        $t = $line -replace '^\s+','' -replace '\s+',' '
        # user SESSIONNAME ID STATE IDLE TIME LOGON TIME
        $parts = $t.Split(' ')
        if ($parts.Count -ge 4) {
          $user = $parts[0]
          $session = $parts[1]
          $id = $parts[2]
          $state = $parts[3]
          $sessions += [pscustomobject]@{
            user = $user
            session = $session
            id = $id
            state = $state
            isRdp = $session -like 'rdp-tcp*'
          }
        }
      }
    }
  } catch {}
  return $sessions
}

function Get-ShadowPolicy {
  # 0=Disable, 1=User OK, 2=No Consent/Full control, 3=No Consent/View, 4=User OK/View
  Try-GetValue {
    $k = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'
    (Get-ItemProperty -Path $k -Name 'Shadow' -ErrorAction Stop).Shadow
  }
}

function Get-RemoteAssistancePolicy {
  Try-GetValue {
    $k = 'HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance'
    $v = Get-ItemProperty -Path $k -Name 'fAllowToGetHelp' -ErrorAction Stop
    return ($v.fAllowToGetHelp -eq 1)
  } $false
}

# ---------- Event logs ----------
function Get-RecentSecurity4624Type10($minutes) {
  $res = @{ count = 0; last = $null }
  try {
    $ms = [int]($minutes * 60000)
    $q = @"
<QueryList>
  <Query Id="0" Path="Security">
    <Select Path="Security">
      *[System[EventID=4624 and TimeCreated[timediff(@SystemTime) &lt;= $ms]]]
      and
      *[EventData[Data[@Name='LogonType']='10']]
    </Select>
  </Query>
</QueryList>
"@
    $events = Get-WinEvent -FilterXml $q -ErrorAction Stop
    if ($events) {
      $res.count = $events.Count
      $res.last  = ($events | Sort-Object TimeCreated -Descending | Select-Object -First 1).TimeCreated.ToString('o')
    }
  } catch {}
  return $res
}

function Get-RecentGeneric($logName, $eventId, $minutes) {
  $res = @{ count = 0; last = $null }
  try {
    $start = (Get-Date).AddMinutes(-$minutes)
    $events = Get-WinEvent -FilterHashtable @{LogName=$logName; Id=$eventId; StartTime=$start} -ErrorAction Stop
    if ($events) {
      $res.count = $events.Count
      $res.last  = ($events | Sort-Object TimeCreated -Descending | Select-Object -First 1).TimeCreated.ToString('o')
    }
  } catch {}
  return $res
}

# ---------- Processes / listeners ----------
function Get-RemoteControlProcesses {
  # Known remote-control tools
  $catalog = @(
    @{ tool='TeamViewer';        match=@('TeamViewer','TeamViewer_Service','tv_w32','tv_x64') },
    @{ tool='AnyDesk';           match=@('AnyDesk','AnyDeskMSI','AnyDeskService') },
    @{ tool='ChromeRemoteDesktop';match=@('remoting_host') },
    @{ tool='VNC';               match=@('winvnc','tvnserver','VNCServer','VNCService') },
    @{ tool='Radmin';            match=@('radmin','r_server') },
    @{ tool='ScreenConnect';     match=@('ScreenConnect Client*','ScreenConnect*') },
    @{ tool='Splashtop';         match=@('SRServer','Splashtop','SOS','SRUpdate') },
    @{ tool='LogMeIn';           match=@('LogMeIn','LMIGuardianSvc','LMIDataSvc','LogMeInSystray') },
    @{ tool='QuickAssist/RA';    match=@('quickassist','msra') }
  )
  $procs = Get-Process -ErrorAction SilentlyContinue
  $hits = @()
  foreach ($item in $catalog) {
    foreach ($pat in $item.match) {
      $m = $procs | Where-Object { $_.ProcessName -like $pat }
      if ($m) {
        $hits += $m | Select-Object @{n='tool';e={$item.tool}}, @{n='process';e={$_.ProcessName}}, Id, StartTime
      }
    }
  }
  $hits | Sort-Object tool, process, Id -Unique
}

function Get-ListeningPorts {
  $watch = @()
  $watch += 3389                 # RDP
  $watch += 5900..5910           # VNC range (common)
  $watch += 4899                 # Radmin
  $watch += 5939                 # TeamViewer service
  $watch += 5985,5986            # WinRM (legit but interesting)
  $watch += 6568                 # AnyDesk
  $watch += 17600..17604         # Splashtop
  Try-GetValue {
    Get-NetTCPConnection -State Listen -ErrorAction Stop |
      Where-Object { $watch -contains $_.LocalPort } |
      ForEach-Object {
        $p = Try-GetValue { Get-Process -Id $_.OwningProcess -ErrorAction Stop }
        [pscustomobject]@{
          localAddress = $_.LocalAddress
          localPort    = $_.LocalPort
          pid          = $_.OwningProcess
          process      = if ($p) { $p.ProcessName } else { $null }
        }
      }
  } @()
}

function Get-CollabProcesses {
  if (-not $FullScan) { return @() }
  $names = @('obs64','obs32','XSplit.Core','bandicam','CamtasiaStudio','GameBar','ScreenClippingHost',
             'Teams','ms-teams','Zoom','zoom','Discord','Slack','Skype')
  $procs = Get-Process -ErrorAction SilentlyContinue | Where-Object { $names -contains $_.ProcessName }
  $procs | Select-Object ProcessName, Id, StartTime
}

# ---------- main ----------
$result = New-Result

try { $result.rdp.enabled = Get-RdpEnabled } catch { Add-Error $result "RDP enabled check failed: $_" }
try { $result.rdp.firewall_rules_enabled = Get-RdpFirewallEnabled } catch { Add-Error $result "Firewall check failed: $_" }
try { $result.rdp.listeners = Get-RdpListeners } catch { Add-Error $result "RDP listeners check failed: $_" }
try { $result.rdp.sessions = Get-RdpSessions } catch { Add-Error $result "Session query failed: $_" }
try { $result.rdp.shadow_policy = Get-ShadowPolicy } catch { Add-Error $result "Shadow policy read failed: $_" }
try { $result.remote_assistance.allowed = Get-RemoteAssistancePolicy } catch { Add-Error $result "RA policy read failed: $_" }

# Events
$result.rdp.recent_events.security_4624_type10 = Get-RecentSecurity4624Type10 $LookbackMinutes
$result.rdp.recent_events.tsvcm_1149          = Get-RecentGeneric 'Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational' 1149 $LookbackMinutes
$result.rdp.recent_events.tslm_21             = Get-RecentGeneric 'Microsoft-Windows-TerminalServices-LocalSessionManager/Operational' 21 $LookbackMinutes
$result.rdp.recent_events.tslm_24             = Get-RecentGeneric 'Microsoft-Windows-TerminalServices-LocalSessionManager/Operational' 24 $LookbackMinutes

# Processes and listeners
try { $result.remote_tools.running = Get-RemoteControlProcesses } catch { Add-Error $result "Process scan failed: $_" }
try { $result.remote_tools.listening_ports = Get-ListeningPorts } catch { Add-Error $result "Port scan failed: $_" }
try { $result.capture_collab.running = Get-CollabProcesses } catch { Add-Error $result "Collab scan failed: $_" }

# ---------- score ----------
$activeRdpSession = ($result.rdp.sessions | Where-Object { $_.isRdp -and $_.state -match 'Active|Disc' }).Count -gt 0
$recentRdpLogon   = ($result.rdp.recent_events.security_4624_type10.count -gt 0) -or ($result.rdp.recent_events.tsvcm_1149.count -gt 0)
$remoteToolRunning= ($result.remote_tools.running.Count -gt 0)

$rdpOpenConfig    = ($result.rdp.enabled -or $result.rdp.firewall_rules_enabled -or ($result.rdp.listeners.Count -gt 0))
$portsInteresting = ($result.remote_tools.listening_ports.Count -gt 0)
$raAllowed        = ($result.remote_assistance.allowed -eq $true)

if ($activeRdpSession -or $recentRdpLogon -or $remoteToolRunning) {
  $result.status = 'ALERT'
} elseif ($rdpOpenConfig -or $portsInteresting -or $raAllowed) {
  $result.status = 'WARN'
} else {
  $result.status = 'OK'
}

# Build summary
$flags = @()
if ($activeRdpSession) { $flags += 'Active RDP session' }
if ($recentRdpLogon)   { $flags += "Recent RDP logon (last $LookbackMinutes min)" }
if ($remoteToolRunning){ $flags += 'Remote-control tool running' }
if ($result.rdp.listeners.Count -gt 0) { $flags += 'RDP listener' }
if ($result.remote_tools.listening_ports.Count -gt 0) { $flags += 'Other remote ports listening' }
if ($raAllowed) { $flags += 'Remote Assistance allowed' }
if ($flags.Count -eq 0) { $flags = @('No signs of remote access in window') }
$result.summary = ($flags -join '; ') + '.'

# ---------- output ----------
if ($Output -eq 'json') {
  try {
    $json = ($result | ConvertTo-Json -Depth 6 -Compress)
    Write-Output $json
  } catch {
    # Fallback if ConvertTo-Json fails for DateTime
    $safe = $result | ConvertTo-Json -Depth 6
    $safe -replace '\r?\n',' '
  }
} else {
  $listenersText = if ($result.rdp.listeners.Count -gt 0) {
    ($result.rdp.listeners | ForEach-Object { "$($_.localAddress):$($_.localPort) pid=$($_.pid) $($_.process)" }) -join ', '
  } else { 'none' }

  $sessionsText = if ($result.rdp.sessions.Count -gt 0) {
    ($result.rdp.sessions | ForEach-Object { "$($_.user) $($_.session) $($_.state)" }) -join ', '
  } else { 'none' }

  $raProcessesText = if ($result.remote_assistance.processes.Count -gt 0) {
    ($result.remote_assistance.processes | ForEach-Object { $_ }) -join ', '
  } else { '(scan within remote tools)' }

  $remoteToolsText = if ($result.remote_tools.running.Count -gt 0) {
    ($result.remote_tools.running | ForEach-Object { "$($_.tool): $($_.process) (pid $($_.Id))" }) -join ', '
  } else { 'none' }

  $portsText = if ($result.remote_tools.listening_ports.Count -gt 0) {
    ($result.remote_tools.listening_ports | ForEach-Object { "$($_.localAddress):$($_.localPort) pid=$($_.pid) $($_.process)" }) -join ', '
  } else { 'none' }

  $collabText = if ($result.capture_collab.running.Count -gt 0) {
    ($result.capture_collab.running | ForEach-Object { "$($_.ProcessName) (pid $($_.Id))" }) -join ', '
  } else { 'none' }

  $errorsText = if ($result.errors.Count -gt 0) {
    ($result.errors | ForEach-Object { $_.Trim() }) -join ' | '
  } else { 'none' }

@"
Status: $($result.status)
Summary: $($result.summary)

RDP:
  Enabled: $($result.rdp.enabled) | Firewall group enabled: $($result.rdp.firewall_rules_enabled)
  Listeners: $listenersText
  Sessions: $sessionsText
  Events (last $LookbackMinutes min): 4624(type10)=$($result.rdp.recent_events.security_4624_type10.count), 1149=$($result.rdp.recent_events.tsvcm_1149.count), 21=$($result.rdp.recent_events.tslm_21.count), 24=$($result.rdp.recent_events.tslm_24.count)
  Shadow policy: $($result.rdp.shadow_policy)

Remote Assistance:
  Allowed: $($result.remote_assistance.allowed)
  Processes: $raProcessesText

Remote-control tools running:
  $remoteToolsText

Other remote/listening ports:
  $portsText

Collab/Screen-capture (FullScan=$FullScan):
  $collabText

Errors:
  $errorsText
"@ | Write-Output
}

# exit code
switch ($result.status) {
  'ALERT' { exit 2 }
  'WARN'  { exit 1 }
  default { exit 0 }
}
