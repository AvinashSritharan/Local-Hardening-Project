<#
.SYNOPSIS
  Check-CodeExecution.ps1 — Finds user-executed or unusual code activity (lightweight, Wazuh-ready).

.DESCRIPTION
  Focuses on interactive/user context and non-standard locations. Emits single-line JSON by default.
  Exit codes: 0 OK, 1 WARN, 2 ALERT.

.PARAMETER LookbackMinutes
  How far back to look for new EXEs/autoruns/services and recent events. Default: 120.

.PARAMETER Output
  'json' (default) or 'text'

.PARAMETER FullScan
  Include extra directories and a larger command-pattern set (slower).

.PARAMETER AllowProcess
  Process names to allowlist (array). Example: -AllowProcess 'python','node'

.PARAMETER AllowPathRegex
  Regex of paths to allowlist. Example: -AllowPathRegex 'C:\\Projects\\Trusted.*'
#>

[CmdletBinding()]
param(
  [int]$LookbackMinutes = 120,
  [ValidateSet('json','text')] [string]$Output = 'json',
  [switch]$FullScan,
  [string[]]$AllowProcess = @(),
  [string]$AllowPathRegex
)

# ---------------- helpers ----------------
function New-Result { [ordered]@{
  ts = (Get-Date).ToString('o')
  hostname = $env:COMPUTERNAME
  user = $env:USERNAME
  lookback_minutes = $LookbackMinutes
  status = 'OK'
  summary = ''
  suspicious_processes = @()
  recent_events = @{
    security_4688 = @{ count = 0; hits = @() }
    ps_4104       = @{ count = 0; hits = @() }
  }
  new_executables = @()
  new_autoruns = @()
  new_services = @()
  errors = @()
} }

function Add-Error($r,$msg){ $r.errors += ($msg | Out-String) }

function Safe-Get($script, $default=@()){
  try { & $script } catch { $default }
}

# ---------------- catalog ----------------
# Suspicious interpreters/launchers often abused by attackers
$BadProcNames = @(
  'powershell','pwsh','cmd','wscript','cscript','mshta','rundll32','regsvr32',
  'installutil','msbuild','msxsl','regasm','regsvcs','msiexec','odbcconf',
  'wmic','bitsadmin','certutil','rclone','python','pythonw','node','ruby','perl','php'
)

# Command-line patterns to flag
$BadCli = @(
  '-enc','-encodedcommand','frombase64string','base64,',
  'invoke-expression','iex ',
  'invoke-webrequest','wget ','curl ','start-bitstransfer','bitsadmin ',
  'http://','https://',
  'regsvr32 /s /n /u /i:','rundll32 javascript:','mshta http',
  'Add-MpPreference','Set-MpPreference','-DisableRealtimeMonitoring'
)

if ($FullScan){
  $BadCli += @('downloadstring','downloadfile','-nop','-noni','-w hidden','-windowstyle hidden')
}

# User-writable locations we watch for newly created EXEs and autoruns
$UserDirs = @(
  "$env:TEMP",
  "$env:USERPROFILE\Downloads",
  "$env:APPDATA",
  "$env:LOCALAPPDATA",
  "$env:PROGRAMDATA"
)

# Startup folders
$StartupDirs = @(
  [Environment]::GetFolderPath('Startup'),
  "$env:PROGRAMDATA\Microsoft\Windows\Start Menu\Programs\StartUp"
)

# Registry Run keys
$RunKeys = @(
  'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run',
  'HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce',
  'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run',
  'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce'
)

# Known-good base paths (not absolute proof; used to reduce noise)
$GoodRoots = @(
  '^C:\\Windows(\\|$)','^C:\\Program Files(\\|$)','^C:\\Program Files \(x86\)(\\|$)'
)

# ---------------- utils ----------------
function Is-GoodPath($p){
  if (-not $p) { return $false }
  foreach($rx in $GoodRoots){ if ($p -match $rx) { return $true } }
  return $false
}

function Is-Allowed($procName,$path){
  if ($AllowProcess -and ($AllowProcess -contains $procName)) { return $true }
  if ($AllowPathRegex -and $path -match $AllowPathRegex) { return $true }
  return $false
}

function Get-ProcOwner($pid){
  try {
    $p = Get-CimInstance Win32_Process -Filter "ProcessId=$pid"
    $o = $p | Invoke-CimMethod -MethodName GetOwner
    if ($o.Domain -and $o.User){ return "$($o.Domain)\$($o.User)" }
  } catch {}
  return $null
}

# ---------------- collectors ----------------
function Find-SuspiciousProcesses {
  $hits = @()
  $now = Get-Date
  $cims = Safe-Get { Get-CimInstance Win32_Process | Select-Object ProcessId,Name,ExecutablePath,CommandLine,CreationDate,SessionId }
  foreach($p in $cims){
    $name = ($p.Name -replace '\.exe$','').ToLower()
    $cmd  = ($p.CommandLine | Out-String).ToLower()
    $path = $p.ExecutablePath
    $sess = $p.SessionId

    # We care about interactive/user sessions mostly
    if ($sess -eq $null -or $sess -lt 1) { continue }

    # Ownership (avoid SYSTEM/LOCAL/NTAUTHORITY noise)
    $owner = Get-ProcOwner $p.ProcessId
    if ($owner -match '^NT AUTHORITY\\' -or $owner -match '^LOCAL SERVICE' -or $owner -match '^NETWORK SERVICE'){ continue }

    $reason = @()
    if ($BadProcNames -contains $name){ $reason += "proc:$name" }
    foreach($tok in $BadCli){
      if ($cmd -like "*$tok*"){ $reason += "cli:$tok" }
    }
    # Non-standard path + recently created
    $created = $null
    if ($p.CreationDate){ $created = $p.CreationDate }
    $recent = $false
    if ($created){ $recent = ($created -ge (Get-Date).AddMinutes(-$LookbackMinutes)) }
    if ((-not (Is-GoodPath $path)) -and $recent){ $reason += "pathRecent" }

    if ($reason.Count -gt 0 -and -not (Is-Allowed $name $path)){
      $hits += [pscustomobject]@{
        pid = $p.ProcessId
        name = $p.Name
        owner = $owner
        session = $p.SessionId
        path = $path
        created_utc = if($created){ $created.ToUniversalTime().ToString('o') } else { $null }
        cmdline = $p.CommandLine
        reasons = $reason
      }
    }
  }
  $hits
}

function Find-NewExecutables {
  $list = @()
  $cut = (Get-Date).AddMinutes(-$LookbackMinutes)
  foreach($d in $UserDirs){
    if (-not (Test-Path $d)) { continue }
    $pat = @('*.exe')
    if ($FullScan){ $pat += @('*.dll','*.ps1','*.js','*.vbs','*.hta') }
    foreach($p in $pat){
      $files = Safe-Get { Get-ChildItem -Path $d -Recurse -Include $p -File -ErrorAction Stop }
      foreach($f in $files){
        if ($f.CreationTime -ge $cut -or $f.LastWriteTime -ge $cut){
          # Skip common legit install locations
          if (Is-GoodPath $f.FullName) { continue }
          # Optional allowlist
          if ($AllowPathRegex -and $f.FullName -match $AllowPathRegex) { continue }
          $sig = Safe-Get { Get-AuthenticodeSignature -FilePath $f.FullName } $null
          $list += [pscustomobject]@{
            path = $f.FullName
            created_utc = $f.CreationTimeUtc.ToString('o')
            modified_utc = $f.LastWriteTimeUtc.ToString('o')
            signed = if ($sig){ $sig.Status -eq 'Valid' } else { $null }
          }
        }
      }
    }
  }
  $list
}

function Find-Autoruns {
  $cut = (Get-Date).AddMinutes(-$LookbackMinutes)
  $hits = @()

  # Registry Run keys
  foreach($rk in $RunKeys){
    try{
      if (Test-Path $rk){
        $key = Get-Item $rk
        $last = $key.LastWriteTime
        $vals = Get-ItemProperty $rk
        foreach($pn in ($vals.PSObject.Properties | Where-Object { $_.Name -ne 'PSPath' -and $_.Name -ne 'PSParentPath' -and $_.Name -ne 'PSChildName' -and $_.Name -ne 'PSDrive' -and $_.Name -ne 'PSProvider' })){
          $val = [string]$pn.Value
          if ([string]::IsNullOrWhiteSpace($val)) { continue }
          # Try to extract path from quoted or unquoted command
          $path = $val
          if ($val -match '"([^"]+\.exe)"'){ $path = $Matches[1] }
          # Flag if key recently changed or path is suspicious
          $recent = ($last -ge $cut)
          $badPath = (-not (Is-GoodPath $path)) -and (-not ($AllowPathRegex -and $path -match $AllowPathRegex))
          if ($recent -or $badPath){
            $hits += [pscustomobject]@{
              source = $rk
              name = $pn.Name
              command = $val
              key_lastwrite_utc = $last.ToUniversalTime().ToString('o')
              suspicious_path = $badPath
              recent_change = $recent
            }
          }
        }
      }
    } catch { }
  }

  # Startup folders
  foreach($sd in $StartupDirs){
    if (-not (Test-Path $sd)) { continue }
    $files = Safe-Get { Get-ChildItem $sd -File -ErrorAction Stop }
    foreach($f in $files){
      if ($f.CreationTime -ge $cut -or $f.LastWriteTime -ge $cut){
        $hits += [pscustomobject]@{
          source = "StartupFolder"
          name = $f.Name
          path = $f.FullName
          created_utc = $f.CreationTimeUtc.ToString('o')
          modified_utc = $f.LastWriteTimeUtc.ToString('o')
          suspicious_path = (-not (Is-GoodPath $f.FullName))
          recent_change = $true
        }
      }
    }
  }

  $hits
}

function Find-NewServices {
  $cut = (Get-Date).AddMinutes(-$LookbackMinutes)
  $hits = @()
  $svc = Safe-Get { Get-CimInstance Win32_Service | Select-Object Name,DisplayName,State,PathName,StartMode,ProcessId,InstallDate }
  foreach($s in $svc){
    $path = $s.PathName
    if (-not $path) { continue }
    # extract exe path if quoted or with args
    $exe = $path
    if ($path -match '"([^"]+\.exe)"'){ $exe = $Matches[1] }
    elseif ($path -match '^(.*?\.exe)\s'){ $exe = $Matches[1] }

    $recent = $false
    if ($s.InstallDate){
      try{
        $id = [Management.ManagementDateTimeConverter]::ToDateTime($s.InstallDate)
        $recent = ($id -ge $cut)
      } catch {}
    } else {
      # fallback to file time
      if (Test-Path $exe){
        $fi = Get-Item $exe
        $recent = ($fi.CreationTime -ge $cut -or $fi.LastWriteTime -ge $cut)
      }
    }

    $badPath = (-not (Is-GoodPath $exe)) -and (-not ($AllowPathRegex -and $exe -match $AllowPathRegex))
    if ($recent -or $badPath){
      $hits += [pscustomobject]@{
        name = $s.Name
        display = $s.DisplayName
        state = $s.State
        start = $s.StartMode
        exe = $exe
        recent = $recent
        suspicious_path = $badPath
      }
    }
  }
  $hits
}

function Find-RecentEvents {
  $res4688 = @{ count = 0; hits = @() }
  $res4104 = @{ count = 0; hits = @() }
  $cut = (Get-Date).AddMinutes(-$LookbackMinutes)

  # 4688: Process creation (if Audit Process Creation enabled)
  try{
    $ev4688 = Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4688; StartTime=$cut} -ErrorAction Stop
    foreach($e in $ev4688){
      $xml = [xml]$e.ToXml()
      $cmd = ($xml.Event.EventData.Data | Where-Object {$_.Name -eq 'CommandLine'}).'#text'
      $sub = ($xml.Event.EventData.Data | Where-Object {$_.Name -eq 'SubjectUserName'}).'#text'
      $flag = $false
      foreach($tok in $BadCli){ if ($cmd -and $cmd.ToLower().Contains($tok)) { $flag = $true; break } }
      if ($flag){
        $res4688.hits += [pscustomobject]@{
          time_utc = $e.TimeCreated.ToUniversalTime().ToString('o')
          user = $sub
          commandLine = $cmd
        }
      }
    }
    $res4688.count = $res4688.hits.Count
  } catch {}

  # 4104: PowerShell script block logging (if enabled)
  try{
    $ev4104 = Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-PowerShell/Operational'; Id=4104; StartTime=$cut} -ErrorAction Stop
    foreach($e in $ev4104){
      $msg = $e.Message
      $flag = $false
      foreach($tok in $BadCli){ if ($msg -and $msg.ToLower().Contains($tok)) { $flag = $true; break } }
      if ($flag){
        $res4104.hits += [pscustomobject]@{
          time_utc = $e.TimeCreated.ToUniversalTime().ToString('o')
          snippet = ($msg.Substring(0,[Math]::Min(300,$msg.Length))).Trim()
        }
      }
    }
    $res4104.count = $res4104.hits.Count
  } catch {}

  return @{ security_4688 = $res4688; ps_4104 = $res4104 }
}

# ---------------- main ----------------
$result = New-Result

try { $result.suspicious_processes = Find-SuspiciousProcesses } catch { Add-Error $result "proc scan failed: $_" }
try { $result.new_executables     = Find-NewExecutables } catch { Add-Error $result "file scan failed: $_" }
try { $result.new_autoruns        = Find-Autoruns } catch { Add-Error $result "autorun scan failed: $_" }
try { $result.new_services        = Find-NewServices } catch { Add-Error $result "service scan failed: $_" }
try { $result.recent_events       = Find-RecentEvents } catch { Add-Error $result "event scan failed: $_" }

# ---------------- score & summary ----------------
$active = ($result.suspicious_processes.Count -gt 0)
$redEvents = ($result.recent_events.security_4688.count -gt 0 -or $result.recent_events.ps_4104.count -gt 0)
$riskyCfg = ($result.new_executables.Count -gt 0 -or $result.new_autoruns.Count -gt 0 -or $result.new_services.Count -gt 0)

if ($active -or $redEvents) {
  $result.status = 'ALERT'
} elseif ($riskyCfg) {
  $result.status = 'WARN'
} else {
  $result.status = 'OK'
}

$flags = @()
if ($active)    { $flags += 'Suspicious process running' }
if ($redEvents) { $flags += "Recent red-flag events (4688/4104) in last $LookbackMinutes min" }
if ($result.new_executables.Count -gt 0) { $flags += "New executables in user-writable paths" }
if ($result.new_autoruns.Count -gt 0)    { $flags += "New/changed autoruns" }
if ($result.new_services.Count -gt 0)    { $flags += "New services in suspicious paths" }
if ($flags.Count -eq 0) { $flags = @('No unusual code execution signals found') }
$result.summary = ($flags -join '; ') + '.'

# ---------------- output ----------------
if ($Output -eq 'json'){
  try { ($result | ConvertTo-Json -Depth 6 -Compress) | Write-Output }
  catch { ($result | ConvertTo-Json -Depth 6) -replace '\r?\n',' ' | Write-Output }
} else {
  $procText = if ($result.suspicious_processes.Count -gt 0) {
    ($result.suspicious_processes | ForEach-Object { "  $($_.name) pid=$($_.pid) owner=$($_.owner) session=$($_.session) path=$($_.path) reasons=[$(($_.reasons -join ','))]" }) -join "`n"
  } else { "  none" }

  $exeText = if ($result.new_executables.Count -gt 0) {
    ($result.new_executables | ForEach-Object { "  $($_.path) signed=$($_.signed) created=$($_.created_utc)" }) -join "`n"
  } else { "  none" }

  $autorunText = if ($result.new_autoruns.Count -gt 0) {
    ($result.new_autoruns | ForEach-Object { "  $($_.source) :: $($_.name) -> $($_.command) (recent=$($_.recent_change) suspicious_path=$($_.suspicious_path))" }) -join "`n"
  } else { "  none" }

  $svcText = if ($result.new_services.Count -gt 0) {
    ($result.new_services | ForEach-Object { "  $($_.name) ($($_.display)) exe=$($_.exe) recent=$($_.recent) suspicious_path=$($_.suspicious_path)" }) -join "`n"
  } else { "  none" }

  $errText = if ($result.errors.Count -gt 0) {
    ($result.errors | ForEach-Object { "  " + $_.Trim() }) -join "`n"
  } else { "  none" }

@"
Status: $($result.status)
Summary: $($result.summary)

Suspicious processes:
$procText

New executables (last $LookbackMinutes min):
$exeText

Autoruns changed/new:
$autorunText

Services suspicious/recent:
$svcText

Events:
  4688 flagged: $($result.recent_events.security_4688.count)
  4104 flagged: $($result.recent_events.ps_4104.count)

Errors:
$errText
"@ | Write-Output
}

switch ($result.status) { 'ALERT' { exit 2 } 'WARN' { exit 1 } default { exit 0 } }
