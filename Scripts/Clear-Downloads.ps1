param(
    [string]$DownloadsPath = (Join-Path $env:USERPROFILE 'Downloads'),
    [int]$Days = 14,
    [ValidateSet('CreationTime','LastWriteTime','LastAccessTime')]
    [string]$AgeProperty = 'CreationTime',  # << pick your intent
    [string]$KeepName = 'DO-NOT-STORE-FILES-HERE',
    [switch]$WhatIf
)

$ErrorActionPreference = 'Stop'
$cutoff = (Get-Date).AddDays(-$Days)
$logPath = Join-Path $env:USERPROFILE 'Downloads-Cleanup.log'

function Write-Log($msg) {
    "{0:yyyy-MM-dd HH:mm:ss}  {1}" -f (Get-Date), $msg |
      Out-File -FilePath $logPath -Encoding utf8 -Append
}

try {
    if (-not (Test-Path -LiteralPath $DownloadsPath -PathType Container)) {
        throw "Downloads folder '$DownloadsPath' does not exist (user/profile mismatch?)."
    }

    # Build a scriptblock to read the chosen time property
    $getAge = [scriptblock]::Create('$_.{0}' -f $AgeProperty)

    # 1) Remove files older than cutoff
    $filesToRemove = Get-ChildItem -LiteralPath $DownloadsPath -Recurse -Force -File -ErrorAction SilentlyContinue |
        Where-Object {
            (& $getAge) -lt $cutoff -and
            $_.BaseName -ne $KeepName -and
            $_.FullName -ne $logPath
        }

    $removed = 0; $failed = 0
    foreach ($f in $filesToRemove) {
        try {
            if ($f.Attributes -band [IO.FileAttributes]::ReadOnly) { attrib -r $f.FullName | Out-Null }
            Remove-Item -LiteralPath $f.FullName -Force -ErrorAction Stop -WhatIf:$WhatIf.IsPresent
            $removed++
        } catch { $failed++; Write-Log "FAILED file: $($f.FullName) -- $($_.Exception.Message)" }
    }

    # 2) Remove now-empty directories older than cutoff (optional tidy)
    $dirs = Get-ChildItem -LiteralPath $DownloadsPath -Recurse -Force -Directory -ErrorAction SilentlyContinue |
            Sort-Object FullName -Descending  # delete deeper first
    foreach ($d in $dirs) {
        try {
            if ((Get-ChildItem -LiteralPath $d.FullName -Force | Measure-Object).Count -eq 0) {
                # age check on directory too (based on chosen property)
                if ((& $getAge.InvokeWithContext(@{}, @{ $_ = $d })) -lt $cutoff -and $d.Name -ne $KeepName) {
                    Remove-Item -LiteralPath $d.FullName -Force -Recurse -ErrorAction Stop -WhatIf:$WhatIf.IsPresent
                }
            }
        } catch { Write-Log "FAILED dir: $($d.FullName) -- $($_.Exception.Message)" }
    }

    if ($WhatIf) { Write-Log "DRY RUN: would remove $removed file(s) older than $Days day(s) by $AgeProperty from '$DownloadsPath'. Failures: $failed." }
    else         { Write-Log "Removed $removed file(s) older than $Days day(s) by $AgeProperty from '$DownloadsPath'. Failures: $failed." }
}
catch {
    Write-Log ("ERROR: " + $_.Exception.Message)
    exit 1
}
