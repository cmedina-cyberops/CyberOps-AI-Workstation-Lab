# BATCH 4D — Daily Desktop Applications — RESULTS

**Date:** 2026-08-28
**Scope:** Install only the three authorized daily desktop applications (ChatGPT Desktop, Claude Desktop, Google Chrome) while preserving the clean Windows security baseline.
**Concurrency rule honored:** `Recovered-Desktop` was NOT scanned, moved, renamed, reorganized, deleted, or touched. No Defender custom scan was run. Batch 4C file-recovery work left on HOLD.

**Overall verdict: PASS**

---

## 1. Summary Table

| Application | Prior state | Action | Version installed | Publisher | Source | Signature | Login |
|---|---|---|---|---|---|---|---|
| ChatGPT Desktop | Not installed | Installed | 26.825.4187.0 | OpenAI | Microsoft Store (`9PLM9XGG6VKS`) via winget `msstore` | Store-signed (MSIX, SignatureKind = Store) | HOLD — user interactive login |
| Claude Desktop | Not installed (only Claude Code CLI present) | Installed | 1.30096.1 | Anthropic, PBC | winget `Anthropic.Claude` → installer from `downloads.claude.ai` | Authenticode **Valid**, signer `CN="Anthropic, PBC"` (EV) | HOLD — user interactive login |
| Google Chrome | Not installed | Installed | 152.0.7977.65 | Google LLC | winget `Google.Chrome` → MSI from `dl.google.com` | Authenticode **Valid**, signer `CN=Google LLC` (EV) | HOLD — user sign-in optional, clean profile |

No application profiles, extensions, settings, cookies, sessions, tokens, passwords, or app data were imported. No credentials, MFA codes, or recovery codes were requested, captured, displayed, or logged.

---

## 2. Already Installed (pre-existing, not modified)

- **Claude Code** (CLI) — v2.1.248, Anthropic PBC. This is the command-line tool, distinct from Claude Desktop. Left untouched.

---

## 3. Installed / Updated — Detail

### 3.1 ChatGPT Desktop
- **Determined not installed** (no matching Uninstall registry entry, no AppX package).
- **Installed from Microsoft Store**, product ID `9PLM9XGG6VKS`, listing name "ChatGPT", `winget show` publisher = **OpenAI**, Privacy URL `openai.com/policies/privacy-policy/`.
- Installed package identity: `OpenAI.Codex_26.825.4187.0_x64__<store-hash>` (the official OpenAI desktop app; AppxManifest `DisplayName = ChatGPT`, `PublisherDisplayName = OpenAI`).
- Version: **26.825.4187.0** · Architecture: x64 · Install location: `C:\Program Files\WindowsApps\OpenAI.Codex_...`
- **SignatureKind: Store** (Microsoft Store package signing).
- winget exit code 0, "Successfully installed".
- No old app data restored.
- **Login state: HOLD** — user performs interactive login; user handles credentials/MFA directly.

### 3.2 Claude Desktop
- **Determined not installed** (only "Claude Code" CLI present — not confused with the desktop app).
- **Installed via winget** package `Anthropic.Claude`; winget downloaded the vendor installer from `https://downloads.claude.ai/releases/win32/x64/1.30096.1/Claude-<hash>.exe`; **"Successfully verified installer hash"** reported by winget (expected SHA256 published in the manifest); exit code 0.
- Registry: DisplayName **Claude**, DisplayVersion **1.30096.1**, Publisher **Anthropic PBC**, InstallLocation `%LOCALAPPDATA%\AnthropicClaude`.
- Binary `%LOCALAPPDATA%\AnthropicClaude\claude.exe`: ProductVersion 1.30096.1, **Authenticode Valid**, signer `CN="Anthropic, PBC", O="Anthropic, PBC", ... C=US` (EV / Private Organization), issuer DigiCert Trusted G4 Code Signing RSA4096 SHA384 2021 CA1.
- No old app data restored.
- **Login state: HOLD** — user performs interactive login; user handles credentials/MFA directly.

### 3.3 Google Chrome
- **Determined not installed** (no Chrome Uninstall entry, no `chrome.exe`).
- **Installed via winget** package `Google.Chrome` (stable, 64-bit); winget downloaded `googlechromestandaloneenterprise64.msi` from `https://dl.google.com/...`; **"Successfully verified installer hash"** reported by winget; exit code 0.
- Registry: DisplayName **Google Chrome**, DisplayVersion **152.0.7977.65**, Publisher **Google LLC**.
- Binary `C:\Program Files\Google\Chrome\Application\chrome.exe`: ProductVersion 152.0.7977.65, **Authenticode Valid**, signer `CN=Google LLC, O=Google LLC, L=Mountain View, S=California, C=US` (EV / Private Organization), issuer DigiCert Trusted G4 Code Signing RSA4096 SHA384 2021 CA1.
- **No import performed**: no old Chrome profile, passwords, cookies, extensions, startup pages, or browser settings were imported. Chrome starts with a clean profile.
- **Login state: HOLD** — user may sign in interactively if desired; not signed in by this batch.

---

## 4. Startup / Services / Scheduled Tasks Added

Method: pre-install baseline captured for Run keys, Startup folder, root scheduled tasks, pending-reboot markers, Defender, and firewall. Post-install re-check plus service-binary creation timestamps and scheduled-task definition file write times.

### 4.1 Registry Run keys / Startup folder
- **No new entries** in `HKCU\...\Run`, `HKLM\...\Run`, `HKLM\WOW6432Node\...\Run`, or the user Startup folder for ChatGPT, Claude Desktop, or Chrome.
- Pre-existing HKCU Run entries unchanged in content (OneDrive, KeePassXC, GoogleDriveFS, Mozilla Firefox auto-start, Microsoft Edge auto-launch). HKLM Run unchanged (`SecurityHealth` only).

### 4.2 Services
| Service | Origin | Created | Start | State | Assessment |
|---|---|---|---|---|---|
| `GoogleChromeElevationService` | **Added by this batch** (Chrome MSI) | 2026-08-28 22:08 (during install) | Manual | Stopped | Standard Chrome component for privileged operations; manual-start, not running. Legitimate. |
| `GoogleUpdaterService152.0.7933.0` | Pre-existing (binary dated 2026-08-28 21:07, before this session) — Google updater infrastructure already on host (Google Drive File Stream). Chrome MSI may re-register it. | 21:07 | Automatic | Stopped | Legitimate Google updater; not started. |
| `GoogleUpdaterInternalService152.0.7933.0` | Same as above | 21:07 | Automatic | Stopped | Legitimate Google updater; not started. |

- **Claude Desktop:** no Windows service added.
- **ChatGPT Desktop (MSIX):** no Windows service added.
- Note: a full service inventory was not captured in the pre-install baseline, so the Google Updater services are attributed as pre-existing based on binary creation time preceding this session. Only `GoogleChromeElevationService` is confirmed new to this batch.

### 4.3 Scheduled Tasks
- **No scheduled-task definition files were written today** (`C:\Windows\System32\Tasks` recursive check — zero results dated 2026-08-28).
- No Google / Chrome / Claude / ChatGPT / OpenAI / Codex scheduled tasks exist.
- Root-path (`\`) scheduled tasks unchanged from baseline: Adobe Acrobat Update Task, OneDrive Reporting / Standalone Update / Startup tasks (user-specific SIDs redacted). None added by this batch.
- **ChatGPT MSIX startup task:** none enabled — `StartupApproved` shows the ChatGPT package with no active startup task (auto-launch not configured).

### 4.4 Net new to the host from Batch 4D
- 1 new service: `GoogleChromeElevationService` (Manual / Stopped).
- 1 new MSIX package: `OpenAI.Codex` (ChatGPT), Store-signed.
- 2 new classic installs: Claude Desktop (per-user), Google Chrome (machine-wide).
- 0 new Run-key entries, 0 new Startup-folder items, 0 new scheduled tasks.

---

## 5. Security Baseline Verification (post-install)

| Control | Required | Observed | Result |
|---|---|---|---|
| Defender Real-Time Protection | On | `RealTimeProtectionEnabled = True` | PASS |
| Tamper Protection | On | `IsTamperProtected = True` | PASS |
| PUA Protection | Block | `PUAProtection = 1` | PASS |
| Network Protection | Enabled | `EnableNetworkProtection = 1` | PASS |
| ASR rules in Audit mode | 9 | 9 rule IDs present, all action `= 2` (AuditMode); 0 non-audit | PASS |
| Firewall — Domain | Enabled | `True` | PASS |
| Firewall — Private | Enabled | `True` | PASS |
| Firewall — Public | Enabled | `True` | PASS |
| Behavior Monitor | (informational) | `True` | OK |
| Unexpected startup entries / services | None | Only `GoogleChromeElevationService` (expected Chrome component, Manual/Stopped) | PASS |
| Unexpected scheduled tasks | None | None added | PASS |
| Pending reboot | None | `CBS RebootPending = False`, `WindowsUpdate RebootRequired = False` | PASS |

**ASR rule IDs (all AuditMode):**
`3b576869-a4ec-4529-8536-b80a7769e899`, `56a863a9-875e-4185-98a7-b882c64b5ce5`, `5beb7efe-fd9a-4556-801d-275e5ffc04cc`, `75668c1f-73b5-4cf0-bb93-3ecf5cb7cc84`, `7674ba52-37eb-4a4f-a9a1-f0f9a1619a2c`, `be9ba2d9-53ea-4cdc-84e5-9b1eeee46550`, `d3e037e1-3eb8-44c8-a917-57927947596d`, `d4f940ab-401b-4efc-aadc-ad5f3c50688a`, `e6db77e5-3df2-4cf1-b95a-636979351e5b`

### Note on `PendingFileRenameOperations`
- The `PendingFileRenameOperations` value is present (6 entries) but **this is not a true pending reboot** — the authoritative CBS `RebootPending` and Windows Update `RebootRequired` markers are both **False**.
- This value was **already present at the pre-install baseline**.
- Post-install, the entries are deferred versioned-folder cleanups for `C:\Program Files\Google\Chrome` (added by this batch's Chrome MSI) and `C:\Program Files\BraveSoftware` / `Brave-Browser` (pre-existing, unrelated to this batch).
- No reboot is required for Chrome, Claude Desktop, or ChatGPT to run. No automatic reboot was performed.

---

## 6. Defender / Firewall / System Controls — Not Modified

Consistent with the safety policy, this batch did **not** modify Microsoft Defender settings, Windows Firewall, Secure Boot, TPM, BitLocker, GRUB/EFI, partitions, BIOS/firmware, drivers, or system recovery configuration. All installs were performed with standard installer elevation only.

---

## 7. Login State — HOLD

All three applications are installed but **not signed in**. The user will complete interactive login for each, handling all credentials and MFA directly. No sign-in, token, cookie, or session data was created, captured, or stored by this batch.

- ChatGPT Desktop — HOLD for user login.
- Claude Desktop — HOLD for user login.
- Google Chrome — HOLD for optional user sign-in; running on a clean profile.

---

## 8. Verification Commands (read-only, for audit reproducibility)

```powershell
# App registration
Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
  'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
  'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*' |
  Where-Object DisplayName -match 'Claude|Chrome|ChatGPT|OpenAI'
Get-AppxPackage | Where-Object Name -match 'OpenAI|ChatGPT'

# Signatures
Get-AuthenticodeSignature 'C:\Program Files\Google\Chrome\Application\chrome.exe'
Get-AuthenticodeSignature "$env:LOCALAPPDATA\AnthropicClaude\claude.exe"

# Security baseline
Get-MpComputerStatus | Select RealTimeProtectionEnabled, IsTamperProtected, BehaviorMonitorEnabled
Get-MpPreference    | Select PUAProtection, EnableNetworkProtection, AttackSurfaceReductionRules_Ids, AttackSurfaceReductionRules_Actions
Get-NetFirewallProfile | Select Name, Enabled
Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'

# Startup / services / tasks
Get-CimInstance Win32_Service | Where-Object Name -match 'Google|Chrome|Claude|ChatGPT|OpenAI'
Get-ScheduledTask | Where-Object { $_.TaskName -match 'Google|Chrome|Claude|ChatGPT|OpenAI|Codex' }
```

---

## 9. Result

**PASS** — All three authorized applications (ChatGPT Desktop 26.825.4187.0, Claude Desktop 1.30096.1, Google Chrome 152.0.7977.65) installed from official/trusted sources with verified publishers and signatures. Installer hashes verified by winget for Claude and Chrome; ChatGPT delivered as a Store-signed MSIX. The clean Windows security baseline is fully intact (Defender RTP/Tamper/PUA/Network Protection, 9 ASR rules in Audit, firewall on all profiles, no pending reboot). The only net-new autostart-capable component is `GoogleChromeElevationService` (standard Chrome component, Manual start, currently stopped). No profiles or application data imported. All logins on HOLD for the user. `Recovered-Desktop` untouched; Batch 4C remains on HOLD.
