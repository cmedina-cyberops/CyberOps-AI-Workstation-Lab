# Batch 4 — Essential Software Reinstallation — Results

- **Date:** 2026-08-28
- **Scope:** Install only approved essential software from official/trusted sources while preserving the clean Windows security baseline.
- **Overall status:** **PARTIAL** — Installed & verified: KeePassXC, VLC, Adobe Acrobat Reader (64-bit), Google Drive for desktop. OneDrive already current (unchanged). **HELD:** Microsoft Office (awaiting Valencia College portal sign-in), Epson WF-2950 (deferred to Batch 4C until printer connected), Google Drive sign-in (awaiting interactive user login).
- **Last updated:** 2026-08-28 — Batch 4B: Google Drive installed & verified (sign-in held); Office confirmed as Valencia College entitlement (held for portal sign-in); Epson deferred to Batch 4C. See section 9.

---

## 1. Environment / tooling

| Item | Value |
|------|-------|
| winget client | v1.29.290 |
| winget sources | `winget` (`https://cdn.winget.microsoft.com/cache`), `msstore`, `winget-font` — all default Microsoft-hosted, unmodified |
| Install method used | `winget install --exact --id <pkg> --source winget --accept-package-agreements --accept-source-agreements --silent` |

No third-party sources, mirrors, download portals, activators or optimizer tools were used.

---

## 2. Security baseline (before)

| Control | State |
|---------|-------|
| Defender real-time protection | On |
| Defender antivirus / antispyware | On |
| Behavior monitor | On |
| Tamper Protection | On |
| Network Inspection (NIS) | On |
| AM running mode | Normal |
| Signature version | 1.457.384.0 (updated 2026-08-28 09:52) |
| Firewall — Domain / Private / Public | Enabled / Enabled / Enabled |
| Pending reboot (CBS / WU / PendingFileRename) | None / None / None |

Startup baseline (pre-install): `OneDriveSetup` (x2 system SIDs), `OneDrive` (user), `MicrosoftEdgeAutoLaunch_*` (user), `SecurityHealth` (HKLM). All expected.

---

## 3. Software already present

| Product | Version | Publisher | Source | Action |
|---------|---------|-----------|--------|--------|
| Microsoft OneDrive | 26.150.0804.0011 | Microsoft Corporation | winget (`Microsoft.OneDrive`) | **Left unchanged** — installed version matches current winget/Microsoft release; `winget upgrade` reported nothing available. |
| Microsoft OneDriveSync (MSIX `Microsoft.OneDriveSync_26150.804.11.0`) | 26150.804.11.0 | Microsoft | Store/MSIX | Left unchanged (Store-managed component of OneDrive). |
| "Microsoft 365 Copilot" / Office Hub (MSIX `Microsoft.MicrosoftOfficeHub_19.2506.56051.0`) | 19.2506.56051.0 | Microsoft | Pre-installed Store stub | Not an Office suite — this is the Office/M365 launcher app that ships with Windows. See Phase B item 5. |

KeePassXC, VLC, Adobe Acrobat/Reader, and any Epson software: **not present** before this batch.

---

## 4. Software installed / updated

| Product | Version installed | Publisher (winget) | Authenticode signer | Sig status | Download origin (from winget log) |
|---------|------------------|--------------------|---------------------|-----------|----------------------------------|
| KeePassXC | 2.7.12 | KeePassXCTeam (`KeePassXCTeam.KeePassXC`) | `CN="DroidMonkey Apps, LLC", O="DroidMonkey Apps, LLC", S=Virginia, C=US` | **Valid** | `github.com/keepassxreboot/keepassxc/releases/download/2.7.12/KeePassXC-2.7.12-Win64.msi` — installer hash verified by winget |
| VLC media player | 3.0.23 (3.0.23.0) | VideoLAN (`VideoLAN.VLC`) | `CN=VideoLAN, O=VideoLAN, L=Paris, C=FR` | **Valid** | `download.videolan.org/pub/videolan/vlc/3.0.23/win64/vlc-3.0.23-win64.msi` — installer hash verified by winget |
| Microsoft Visual C++ 2015+ Redistributable (x64) | 14.51.36247.0 | Microsoft (`Microsoft.VCRedist.2015+.x64`) | Microsoft | (Microsoft-signed) | `download.visualstudio.microsoft.com/.../VC_redist.x64.exe` — pulled automatically as a declared KeePassXC dependency; installer hash verified by winget |
| Adobe Acrobat Reader (64-bit) | 26.001.21789 (file 26.1.21789.0) | Adobe (`Adobe.Acrobat.Reader.64-bit`) | `CN=Adobe Inc., OU=Acrobat DC, O=Adobe Inc., L=San Jose, S=ca, C=US` (EV cert) | **Valid** | `ardownload2.adobe.com/pub/adobe/acrobat/win/AcrobatDC/2600121789/AcroRdrDCx642600121789_MUI.exe` — installer hash verified by winget |

Notes:
- "DroidMonkey Apps, LLC" is the recognised code-signing identity used for official KeePassXC Windows releases (maintainer's company). Not a third-party repack.
- File metadata confirms identity: KeePassXC.exe → ProductName "KeePassXC", CompanyName "KeePassXC Team", 2.7.12; vlc.exe → "VLC media player", "VideoLAN", 3.0.23; Acrobat.exe → ProductName "Adobe Acrobat", CompanyName "Adobe Systems Incorporated", 26.1.21789.0.
- The Acrobat Reader package registers in the registry as **"Adobe Acrobat (64-bit)"** — this is Adobe's current unified DC client, which runs as the **free Reader** unless a Pro/Standard licence is activated. No licence was entered. This is the free Reader as requested, not licensed Acrobat Pro/Standard.
- No old KeePassXC database was opened or imported. No VLC or Acrobat settings restored.

---

## 5. Startup entries / services / tasks added

| Type | Entry | Detail | Assessment |
|------|-------|--------|------------|
| Startup (HKCU `...\Run`) | `KeePassXC` | Value: `"C:\Program Files\KeePassXC\KeePassXC.exe"` (no switches) | **Expected** — added by the KeePassXC MSI. Points to the signed binary in Program Files. Benign; can be removed via KeePassXC → Settings → "Automatically launch KeePassXC at system startup" or Task Manager → Startup if autostart is not wanted. |
| Service | `AdobeARMservice` — "Adobe Acrobat Update Service" | StartType Automatic, Running | **Expected** — Adobe's auto-update service, installed with Reader. Keeps Reader security-patched; recommend leaving enabled. Signed Adobe binary. |
| Scheduled task | `Adobe Acrobat Update Task` | State: Ready | **Expected** — companion updater task for Reader. Benign. |
| Services (KeePassXC / VLC) | none | `Get-Service` filtered for keepass/vlc/videolan → no results | Clean |
| Scheduled tasks (KeePassXC / VLC) | none | filtered for keepass/vlc/videolan → no results | Clean |
| VC++ Redistributable | no startup/service entries | — | Clean |

No `Run`-key startup entry was added by Acrobat Reader. No other new `Run` keys, services, or scheduled tasks appeared. Edge/OneDrive/SecurityHealth entries unchanged from baseline.

---

## 6. Items HELD for user confirmation

### Adobe Acrobat — RESOLVED
User confirmed the free **Adobe Acrobat Reader** is wanted (not licensed Pro/Standard). Installed — see section 4.

### Microsoft Office
- **Installed?** No licensed Office suite is installed. No `HKLM\SOFTWARE\Microsoft\Office\ClickToRun\Configuration` key exists; `WINWORD.EXE` not present under `Program Files\...\Office16` or `Program Files (x86)\...\Office16`.
- Only the pre-installed **Office Hub / "Microsoft 365 Copilot" launcher app** (MSIX stub) is present — this is not Word/Excel/etc.
- **Cannot determine licensed edition locally.** **HOLD.**
- **User confirmation needed:** which product to install —
  - Microsoft 365 (subscription — Personal / Family / Business) vs. one-time **Office 2021** or **Office 2024**; and edition (Home & Student / Home & Business / Professional / Standard).
  - Whether the license is tied to the user's Microsoft account (install via account portal / `winget install Microsoft.Office`) or a volume/OEM key.
  - Architecture preference (64-bit recommended) and update channel.

### Epson printer / scanner — HELD (user instruction)
- **Model confirmed by user:** **Epson WorkForce WF-2950**.
- **Device state (read-only, re-checked):** printer **not connected** — no Epson device in the PnP tree (no USB VID `04B8`), no Epson print queue, no Epson driver, no Epson software in the registry. Not onboarded to Wi-Fi.
- **User instruction:** hold all Epson installation/changes until the printer is physically connected. **Nothing installed or changed.**
- **Availability found (for the eventual install):**
  - No model-specific "WF-2950" package on winget. The **print driver** must come from Windows Update (once connected) or the "WF-2950 Series" **basic Printer Driver** from `epson.com` support for Windows 11 (not the Drivers-and-Utilities combo).
  - Scanning: `EPSON.EpsonScan2` (Seiko Epson Corporation, `ftp.epson.com`, SHA256-pinned in winget) covers core scanning. `EPSON.ScanSmart` optional modern UI (declares `EpsonScan2` + `EventManager` as dependencies).
- **Excluded by policy:** firmware updates, Epson Software Updater, MyEpson Portal, Photo+, and other bundled/promotional utilities.

### Google Drive — SCOPE FLAG (not installed)
- Requested in a later message as an "already authorized Batch 4 item", but Google Drive was **not** in the original Batch 4 authorization (which listed **Microsoft OneDrive**).
- Per the standing "do not expand scope without authorization" rule, **not installed.** Awaiting explicit confirmation to install the official winget package `Google.GoogleDrive` (Google LLC, v130.0.2.0).

---

## 7. Post-check (after all installs: KeePassXC, VLC, Acrobat Reader)

| Control | State | Result |
|---------|-------|--------|
| Defender real-time protection | On | PASS |
| Defender behavior monitor | On | PASS |
| Tamper Protection | On | PASS |
| Defender antivirus enabled / running mode | On / Normal | PASS |
| Firewall — Domain / Private / Public | Enabled / Enabled / Enabled | PASS |
| Unexpected third-party startup entries | None — only expected entries (KeePassXC MSI autostart; Adobe updater service + task) | PASS |
| Unexpected services / scheduled tasks | None — only Adobe Acrobat Update Service/Task (expected) | PASS |
| Pending reboot (CBS / WU / PendingFileRename) | None / None / None | PASS |

No unexpected security prompts, no unsigned packages, no ambiguous product identity encountered. All installers were downloaded from official vendor/Microsoft endpoints with hashes verified by winget, and all installed binaries carry valid Authenticode signatures from the expected publishers.

---

## 8. Result summary

| Item | Outcome |
|------|---------|
| Microsoft OneDrive | **PASS** — already current (26.150.0804.0011), left unchanged. |
| KeePassXC | **PASS** — 2.7.12 installed, official winget package, signature valid. No database opened. |
| VLC | **PASS** — 3.0.23 installed, official winget package, signature valid. |
| Adobe Acrobat Reader (64-bit) | **PASS** — 26.001.21789 installed, official winget package, EV signature valid. Free Reader (no licence entered), as requested. |
| Microsoft Office | **HELD** — no suite installed; exact edition/licence must be confirmed by user. |
| Epson WF-2950 | **HELD** — model confirmed; printer not connected; no install performed per user instruction. |
| Google Drive | **HELD** — outside original Batch 4 authorization; awaiting explicit scope confirmation. |
| Security baseline | **PASS** — Defender, Tamper Protection, Firewall all intact; no unexpected startup/services; no pending reboot. |
| **Overall** | **PARTIAL** (all authorized-and-unambiguous items done; 3 items held) |

### Recommended next actions for the user
1. Confirm the exact **Office** product / edition / licence → then authorize its install.
2. **Connect the Epson WF-2950** (USB or Wi-Fi) and confirm scan components wanted → then authorize the driver install (Windows Update first; epson.com basic driver as fallback).
3. Confirm whether **Google Drive** is in scope → if yes, authorize install of `Google.GoogleDrive`.
4. Optional: decide whether to keep the KeePassXC launch-at-startup entry.
5. Optional: leave the Adobe Acrobat Update Service enabled (recommended for security patching).

> **Note:** items 1–3 above were subsequently authorized/actioned in **Batch 4B** (section 9). Google Drive installed; Office held for Valencia College portal; Epson deferred to Batch 4C.

---

## 9. Batch 4B — Google Drive + Valencia College Office

- **Date:** 2026-08-28
- **Authorization:** "Batch 4B — authorized pending essential software." Google Drive explicitly authorized; Office scoped to the Valencia College Microsoft 365 entitlement; Epson explicitly deferred to Batch 4C.
- **Not touched (already passed, per instruction):** KeePassXC, VLC, Adobe Acrobat Reader, OneDrive — no reinstall, no modification.

### 9.1 Google Drive for desktop — **PASS** (install) / **HOLD** (sign-in)

| Field | Value |
|-------|-------|
| Product | Google Drive for desktop |
| Version | 130.0.2.0 |
| winget package / source | `Google.GoogleDrive` — `winget` source only |
| Publisher (winget manifest) | Google LLC (`https://www.google.com/`) |
| Installer origin | `https://dl.google.com/release2/drive-file-stream/acx3t3hyxtsch7palda755pv7gpq_130.0.2.0/setup.exe` |
| Installer hash | SHA256 pinned in manifest (`3fcdf80d…72aa`); **verified by winget** ("Successfully verified installer hash") |
| Install result | "Successfully installed" (exit 0) |
| Registry entry | DisplayName "Google Drive", DisplayVersion 130.0.2.0, Publisher "Google LLC" |
| Install location | `C:\Program Files\Google\Drive File Stream\130.0.2.0\` |
| Authenticode signature | **Valid** — `CN=Google LLC, O=Google LLC, L=Mountain View, S=California, C=US` (EV cert, Private Organization) on `GoogleDriveFS.exe` |
| File metadata | ProductName "Google Drive", CompanyName "Google LLC.", FileVersion 130.0.2.0 |

**Post-install footprint (all expected for Google Drive for desktop):**

| Type | Entry | Assessment |
|------|-------|------------|
| Startup — single entry, `HKCU\…\Run` | `GoogleDriveFS` → `"C:\Program Files\Google\Drive File Stream\130.0.2.0\GoogleDriveFS.exe" --startup_mode` | Expected. Points to the signed binary. (Win32_StartupCommand lists it several times as a per-SID enumeration quirk; the actual value exists once, in HKCU.) |
| Service | `GoogleUpdaterService152.0.7933.0` | Expected — Google auto-updater. State: **Stopped** (on-demand/triggered). |
| Service | `GoogleUpdaterInternalService152.0.7933.0` | Expected — Google updater helper. State: **Stopped**. |
| Scheduled task | `GoogleUpdaterTaskSystem152.0.7933.0{…}` | Expected — updater scheduled check. State: Ready, Author `NT AUTHORITY\SYSTEM`. |

No other new services, tasks, or Run keys. No old Google Drive settings imported. No `.exe/.msi/.bat/.cmd/.ps1/.vbs/.js/.scr/.lnk` from prior backups were restored or executed.

**HELD:** application is installed but **not signed in**. Per instruction, the interactive Google sign-in (and choice of **Stream files** vs Mirror — recommend **Stream files** initially) is left entirely to the user. No Google password or MFA code was requested, captured, logged, or handled.

### 9.2 Microsoft Office (Valencia College entitlement) — **HOLD**

| Check | Result |
|-------|--------|
| Office ClickToRun configuration (`HKLM\…\Office\ClickToRun\Configuration`) | **Absent** |
| `WINWORD.EXE` under `Program Files\Microsoft Office\root\Office16` | **Not present** |
| Any Office suite in uninstall registry | **None** (only the pre-installed Store "Office Hub" launcher stub) |

- **No Office suite is installed.** **HOLD** for the user to sign in to the official **Valencia College / Microsoft 365 portal** (portal.office.com / Valencia's Office 365 ProPlus benefit) and start the Microsoft-provided "Install Office" desktop download from there.
- Not done and will not be done: purchasing/installing Office Home & Business 2024; KMS/activators/unofficial ISOs/volume-license workarounds/third-party installers; guessing the edition or licensing channel.
- **After the portal install completes**, record here: exact edition (e.g. "Microsoft 365 Apps for enterprise"), architecture (32/64-bit), build/version, and activation/licensing channel (`Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration` + `cscript ospp.vbs /dstatus`). No credentials or MFA codes to be captured.

### 9.3 Epson WF-2950 — **HOLD** (deferred to Batch 4C)

No Epson software or firmware installed or modified in this batch, per instruction. Remains held until the printer is physically connected.

### 9.4 Batch 4B post-check

| Control | State | Result |
|---------|-------|--------|
| Defender real-time protection | On | PASS |
| Defender behavior monitor | On | PASS |
| Tamper Protection | On | PASS |
| Defender antivirus / running mode | On / Normal | PASS |
| Firewall — Domain / Private / Public | Enabled / Enabled / Enabled | PASS |
| Unexpected third-party startup entries | None beyond expected `GoogleDriveFS` autostart | PASS |
| Unexpected services / scheduled tasks | None beyond expected Google updater service/task (stopped) | PASS |
| Pending reboot (CBS / WU / PendingFileRename) | None / None / None | PASS |
| BIOS / firmware / Secure Boot / BitLocker / GRUB / EFI / partitions | Not touched — no changes of any kind | PASS |

### 9.5 Batch 4B classification

| Item | Status |
|------|--------|
| Google Drive — installation & verification | **PASS** |
| Google Drive — interactive sign-in | **HOLD** (user action) |
| Microsoft Office (Valencia College) | **HOLD** (awaiting portal sign-in / confirmation of official desktop install) |
| Epson WF-2950 | **HOLD** (Batch 4C) |
| Security baseline (post-check) | **PASS** |
| **Batch 4B overall** | **PARTIAL** — Google Drive PASS; Office & Epson HOLD; no FAIL |
