<#
.SYNOPSIS
    Safe, bookmarks-only backup of the Brave browser.

.DESCRIPTION
    Copies ONLY the Chromium bookmark files ("Bookmarks" and, when present,
    "Bookmarks.bak") from every discovered Brave profile into a timestamped
    folder under a backup root (by default the current Google Drive account's
    "My Drive\Backups\Brave").

    For each file the script:
      * copies with an exact LiteralPath (no wildcards, no deletion of anything),
      * verifies the copied size matches the source,
      * computes SHA256 of source and of the copy and confirms they match,
      * re-reads the source hash after the copy to detect Brave rewriting the
        file mid-copy, and retries a few times if so,
      * reports a clear per-file PASS / WARN / FAIL and an overall result.

    It NEVER touches passwords, "Login Data", cookies, history, sessions, tokens,
    "Local State", extension data, autofill, or payment data, and it never
    modifies, moves, or deletes any Brave file. It does not close Brave.

    No administrator rights are required. PowerShell 7 compatible (also runs on
    Windows PowerShell 5.1).

.PARAMETER BackupRoot
    Destination root for backups. If omitted, the script resolves the CURRENT
    Google Drive account's mount point from
    HKCU:\Software\Google\DriveFS (CurrentAccountToken + PerAccountPreferences)
    and uses "<mount>\My Drive\Backups\Brave". If neither a -BackupRoot is given
    nor Google Drive can be resolved, the script STOPS without writing anywhere.

.PARAMETER BraveUserData
    Override for the Brave "User Data" directory. Defaults to
    $env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data.

.PARAMETER MaxAttempts
    Per-file copy attempts when the source appears to change during the copy
    (Brave writing bookmarks). Default 3.

.PARAMETER RetentionCount
    OPTIONAL, FUTURE USE. Number of most-recent timestamped backup folders to
    keep. 0 (default) = keep everything; no pruning happens. Pruning ALSO
    requires -ApplyRetention to be passed explicitly. This script performs no
    automatic deletion by default.

.PARAMETER ApplyRetention
    OPTIONAL, FUTURE USE. Must be supplied together with -RetentionCount >= 1 to
    enable pruning of old backup folders. Without it, RetentionCount is ignored.

.EXAMPLE
    pwsh -File .\Backup-BraveBookmarks.ps1
    Backs up to the current Google Drive account: <drive>\My Drive\Backups\Brave\<timestamp>\

.EXAMPLE
    pwsh -File .\Backup-BraveBookmarks.ps1 -BackupRoot 'D:\Backups\Brave'
    Backs up to an explicit local path.

.NOTES
    Backup layout:
        <BackupRoot>\
          YYYY-MM-DD_HHmmss\
            Default\
              Bookmarks
              Bookmarks.bak
            Profile 2\
              Bookmarks
          BACKUP_INFO.txt

    BACKUP_INFO.txt contains only: timestamp, profile name, source file name,
    size, SHA256, and result. It contains NO bookmark titles or URLs.

.LINK
    Restore principles are documented in the RESTORE block below.
#>

# =====================================================================
#  RESTORE PRINCIPLES  (documentation only — this script does NOT restore)
# =====================================================================
#  Restoring Brave bookmarks is a SEPARATE, explicitly authorized operation.
#  There is deliberately no restore function here. When a restore is
#  authorized, follow these principles:
#
#   1. CLOSE BRAVE COMPLETELY first (check Task Manager for brave.exe).
#      Brave overwrites "Bookmarks" on exit, so restoring while it runs
#      will be lost.
#   2. BACK UP THE CURRENT PROFILE'S "Bookmarks" (and "Bookmarks.bak")
#      before replacing them, so the restore itself is reversible.
#   3. RESTORE ONLY TO THE MATCHING PROFILE. A backup taken from "Default"
#      goes back to "Default"; "Profile 2" -> "Profile 2". Profile folder
#      names are not portable between machines/installs — confirm the
#      mapping first.
#   4. NEVER OVERWRITE BLINDLY. Compare timestamps and sizes; make sure the
#      backup is the version you actually want.
#   5. After copying the file back in, start Brave and verify the bookmark
#      bar / manager before deleting your safety copy.
#   6. If Brave shows no bookmarks after restore, close it again and check
#      that "Bookmarks.bak" was not the file Brave loaded; remove a stale
#      "Bookmarks.bak" only after the good "Bookmarks" is in place.
# =====================================================================

[CmdletBinding()]
param(
    [string]$BackupRoot,

    [string]$BraveUserData = (Join-Path $env:LOCALAPPDATA 'BraveSoftware\Brave-Browser\User Data'),

    [ValidateRange(1, 10)]
    [int]$MaxAttempts = 3,

    [ValidateRange(0, 10000)]
    [int]$RetentionCount = 0,

    [switch]$ApplyRetention
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# ---- tiny console helpers (no file paths with the user name are written to
#      the metadata file; console output is local only) --------------------
function Write-Tag {
    param([ValidateSet('INFO', 'PASS', 'WARN', 'FAIL')] [string]$Tag, [string]$Message)
    $color = @{ INFO = 'Gray'; PASS = 'Green'; WARN = 'Yellow'; FAIL = 'Red' }[$Tag]
    Write-Host ("[{0}] {1}" -f $Tag, $Message) -ForegroundColor $color
}

function Resolve-GoogleDriveBackupRoot {
    <# Returns "<mount>\My Drive\Backups\Brave" for the CURRENT Google Drive
       account, or $null if it cannot be determined reliably. Read-only. #>
    $key = 'HKCU:\Software\Google\DriveFS'
    if (-not (Test-Path $key)) { return $null }

    try { $props = Get-ItemProperty -Path $key -ErrorAction Stop } catch { return $null }

    $pnames = $props.PSObject.Properties.Name
    if ($pnames -notcontains 'CurrentAccountToken' -or $pnames -notcontains 'PerAccountPreferences') { return $null }

    $token = [string]$props.CurrentAccountToken
    if ([string]::IsNullOrWhiteSpace($token)) { return $null }

    $raw = ($props.PerAccountPreferences -join '')
    if ([string]::IsNullOrWhiteSpace($raw)) { return $null }

    try { $prefs = $raw | ConvertFrom-Json -ErrorAction Stop } catch { return $null }

    if ($prefs.PSObject.Properties.Name -notcontains 'per_account_preferences') { return $null }

    $entry = $prefs.per_account_preferences | Where-Object { $_.key -eq $token } | Select-Object -First 1
    if ($null -eq $entry) { return $null }

    $mount = $null
    if ($entry.PSObject.Properties.Name -contains 'value' -and
        $entry.value.PSObject.Properties.Name -contains 'mount_point_path') {
        $mount = [string]$entry.value.mount_point_path
    }
    if ([string]::IsNullOrWhiteSpace($mount)) { return $null }

    if ($mount -match '^[A-Za-z]$') { $mount = "$mount`:\" }

    $myDrive = Join-Path $mount 'My Drive'
    if (Test-Path -LiteralPath $myDrive) { return (Join-Path $myDrive 'Backups\Brave') }
    if (Test-Path -LiteralPath $mount)  { return (Join-Path $mount  'Backups\Brave') }
    return $null
}

function Copy-BookmarkFile {
    <# Copies one bookmark file with hash verification and mid-copy-change
       detection. Returns a result object; never throws for expected cases. #>
    param(
        [Parameter(Mandatory)][string]$SourcePath,
        [Parameter(Mandatory)][string]$DestPath,
        [int]$Attempts = 3
    )

    for ($i = 1; $i -le $Attempts; $i++) {
        $srcHashBefore = (Get-FileHash -LiteralPath $SourcePath -Algorithm SHA256).Hash
        $srcLenBefore  = (Get-Item   -LiteralPath $SourcePath).Length

        Copy-Item -LiteralPath $SourcePath -Destination $DestPath -Force

        $dstHash      = (Get-FileHash -LiteralPath $DestPath -Algorithm SHA256).Hash
        $dstLen       = (Get-Item   -LiteralPath $DestPath).Length
        $srcHashAfter = (Get-FileHash -LiteralPath $SourcePath -Algorithm SHA256).Hash

        if ($srcHashBefore -ne $srcHashAfter) {
            # Brave rewrote the source while we copied — wait briefly and retry.
            Start-Sleep -Milliseconds 500
            continue
        }

        if ($dstHash -eq $srcHashBefore -and $dstLen -eq $srcLenBefore) {
            return [pscustomobject]@{
                Result   = 'PASS'
                Size     = $dstLen
                Sha256   = $dstHash
                Attempts = $i
                Detail   = 'size match; source SHA256 == backup SHA256; source stable'
            }
        }

        Start-Sleep -Milliseconds 500
    }

    if (Test-Path -LiteralPath $DestPath) {
        $dstHash = (Get-FileHash -LiteralPath $DestPath -Algorithm SHA256).Hash
        $dstLen  = (Get-Item   -LiteralPath $DestPath).Length
        return [pscustomobject]@{
            Result   = 'WARN'
            Size     = $dstLen
            Sha256   = $dstHash
            Attempts = $Attempts
            Detail   = 'source kept changing during copy; copy saved but not hash-consistent with a single source state'
        }
    }

    return [pscustomobject]@{
        Result   = 'FAIL'
        Size     = $null
        Sha256   = $null
        Attempts = $Attempts
        Detail   = 'no backup file produced'
    }
}

# =====================================================================
#  1. Resolve backup root
# =====================================================================
if ([string]::IsNullOrWhiteSpace($BackupRoot)) {
    Write-Tag INFO 'No -BackupRoot supplied; resolving the current Google Drive account...'
    $BackupRoot = Resolve-GoogleDriveBackupRoot
    if ([string]::IsNullOrWhiteSpace($BackupRoot)) {
        Write-Tag FAIL 'Google Drive could not be reliably identified and no -BackupRoot was given. Stopping. Nothing was written.'
        exit 2
    }
    Write-Tag INFO ("Resolved backup root: {0}" -f $BackupRoot)
}
else {
    Write-Tag INFO ("Using supplied backup root: {0}" -f $BackupRoot)
}

# Verify the destination drive/root is reachable before doing anything.
$backupDrive = [System.IO.Path]::GetPathRoot($BackupRoot)
if (-not (Test-Path -LiteralPath $backupDrive)) {
    Write-Tag FAIL ("Backup destination drive '{0}' is not available. Stopping. Nothing was written." -f $backupDrive)
    exit 2
}

# =====================================================================
#  2. Discover Brave + profiles
# =====================================================================
if (-not (Test-Path -LiteralPath $BraveUserData)) {
    Write-Tag FAIL ("Brave 'User Data' not found. Brave does not appear to be installed for this user. Stopping.")
    exit 3
}
Write-Tag PASS 'Brave installation found.'

$braveRunning = [bool](Get-Process -Name 'brave' -ErrorAction SilentlyContinue)
if ($braveRunning) {
    Write-Tag WARN 'Brave is currently running. The script will NOT close it. If a bookmark file is being written, that file may be reported WARN — re-run when Brave is closed for a guaranteed-consistent copy.'
}
else {
    Write-Tag PASS 'Brave is not running (consistent copy expected).'
}

$profileDirs = Get-ChildItem -LiteralPath $BraveUserData -Directory |
    Where-Object { $_.Name -eq 'Default' -or $_.Name -match '^Profile \d+$' } |
    Sort-Object Name

$targets = [System.Collections.Generic.List[object]]::new()
foreach ($pd in $profileDirs) {
    foreach ($name in @('Bookmarks', 'Bookmarks.bak')) {
        $src = Join-Path $pd.FullName $name
        if (Test-Path -LiteralPath $src) {
            $targets.Add([pscustomobject]@{
                Profile    = $pd.Name
                FileName   = $name
                SourcePath = $src
                SourceSize = (Get-Item -LiteralPath $src).Length
            })
        }
    }
}

Write-Tag INFO ("Profiles discovered: {0}" -f @($profileDirs).Count)
Write-Tag INFO ("Bookmark files to back up: {0}" -f $targets.Count)
foreach ($t in $targets) {
    Write-Tag INFO ("  [{0}] {1}  ({2} bytes)" -f $t.Profile, $t.FileName, $t.SourceSize)
}

if ($targets.Count -eq 0) {
    Write-Tag FAIL 'No "Bookmarks" or "Bookmarks.bak" files were found in any Brave profile. Nothing to back up.'
    exit 4
}

# =====================================================================
#  3. Create timestamped backup folder
# =====================================================================
$timestamp   = Get-Date -Format 'yyyy-MM-dd_HHmmss'
$runFolder   = Join-Path $BackupRoot $timestamp
New-Item -ItemType Directory -Path $runFolder -Force | Out-Null
Write-Tag PASS ("Backup folder created: {0}" -f $runFolder)

# =====================================================================
#  4. Copy + verify each file
# =====================================================================
$results = [System.Collections.Generic.List[object]]::new()
foreach ($t in $targets) {
    $destProfileDir = Join-Path $runFolder $t.Profile
    New-Item -ItemType Directory -Path $destProfileDir -Force | Out-Null
    $destPath = Join-Path $destProfileDir $t.FileName

    $r = Copy-BookmarkFile -SourcePath $t.SourcePath -DestPath $destPath -Attempts $MaxAttempts

    $srcSha = (Get-FileHash -LiteralPath $t.SourcePath -Algorithm SHA256).Hash

    $line = [pscustomobject]@{
        Profile    = $t.Profile
        FileName   = $t.FileName
        SourceSize = $t.SourceSize
        BackupSize = $r.Size
        SourceSha  = $srcSha
        BackupSha  = $r.Sha256
        HashMatch  = ($r.Sha256 -and ($r.Sha256 -eq $srcSha))
        Attempts   = $r.Attempts
        Result     = $r.Result
        Detail     = $r.Detail
    }
    $results.Add($line)

    $tag = switch ($r.Result) { 'PASS' { 'PASS' } 'WARN' { 'WARN' } default { 'FAIL' } }
    Write-Tag $tag ("[{0}] {1}: {2}  (size {3} -> {4}; hash match: {5}; attempts {6})" -f `
        $t.Profile, $t.FileName, $r.Result, $t.SourceSize, $r.Size, $line.HashMatch, $r.Attempts)
}

# =====================================================================
#  5. Overall result
# =====================================================================
$anyFail = @($results | Where-Object Result -eq 'FAIL').Count -gt 0
$anyWarn = @($results | Where-Object Result -eq 'WARN').Count -gt 0
$overall = if ($anyFail) { 'FAIL' } elseif ($anyWarn) { 'WARN' } else { 'PASS' }

# =====================================================================
#  6. Metadata file (NO titles, NO URLs — only the allowed fields)
# =====================================================================
$infoPath = Join-Path $runFolder 'BACKUP_INFO.txt'
$sb = [System.Text.StringBuilder]::new()
[void]$sb.AppendLine('Brave Bookmarks Backup - BACKUP_INFO')
[void]$sb.AppendLine('===================================')
[void]$sb.AppendLine("Timestamp (local) : $timestamp")
[void]$sb.AppendLine("Brave running     : " + ($(if ($braveRunning) { 'YES' } else { 'NO' })))
[void]$sb.AppendLine("Overall result    : $overall")
[void]$sb.AppendLine('')
[void]$sb.AppendLine('Profile        | Source file    | Size (bytes) | SHA256                                                           | Result')
[void]$sb.AppendLine('-------------- | -------------- | ------------ | ---------------------------------------------------------------- | ------')
foreach ($r in $results) {
    $shaText = if ($r.BackupSha) { $r.BackupSha } else { '(none)' }
    [void]$sb.AppendLine( ('{0,-14} | {1,-14} | {2,12} | {3,-64} | {4}' -f `
        $r.Profile, $r.FileName, $r.BackupSize, $shaText, $r.Result) )
}
[void]$sb.AppendLine('')
[void]$sb.AppendLine('Only bookmark files were copied. No passwords, cookies, history, sessions,')
[void]$sb.AppendLine('tokens, Local State, extension, autofill or payment data is included.')
Set-Content -LiteralPath $infoPath -Value $sb.ToString() -Encoding UTF8
Write-Tag PASS ("Metadata written: {0}" -f $infoPath)

# =====================================================================
#  7. OPTIONAL retention (disabled by default; needs BOTH switches)
# =====================================================================
if ($ApplyRetention.IsPresent -and $RetentionCount -ge 1) {
    Write-Tag INFO ("Retention requested: keep newest {0} backup folder(s)." -f $RetentionCount)
    $allRuns = Get-ChildItem -LiteralPath $BackupRoot -Directory |
        Where-Object { $_.Name -match '^\d{4}-\d{2}-\d{2}_\d{6}$' } |
        Sort-Object Name -Descending
    $toRemove = $allRuns | Select-Object -Skip $RetentionCount
    foreach ($old in $toRemove) {
        Remove-Item -LiteralPath $old.FullName -Recurse -Force
        Write-Tag WARN ("Pruned old backup folder: {0}" -f $old.Name)
    }
    if (-not $toRemove) { Write-Tag INFO 'Nothing to prune.' }
}
else {
    Write-Tag INFO 'Retention disabled (default). No old backups were deleted.'
}

# =====================================================================
#  8. Final line
# =====================================================================
Write-Host ''
Write-Tag $overall ("OVERALL: {0}  ({1} file(s); folder: {2})" -f $overall, $results.Count, $runFolder)

switch ($overall) {
    'PASS' { exit 0 }
    'WARN' { exit 10 }
    default { exit 1 }
}
