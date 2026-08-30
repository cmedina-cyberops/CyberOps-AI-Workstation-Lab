# Post-Clean Windows 11 Workstation Audit

**Scope:** Comprehensive read-only post-clean-install audit of the primary Windows 11 host of the CyberOps & AI Workstation Lab.
**Date collected:** 2026-08-27 (local)
**Mode:** READ-ONLY. No configuration, registry, partition, boot, firmware, service, or account changes were made.
**Collector context:** Non-elevated PowerShell session. Items requiring administrative rights are explicitly marked **[NEEDS ELEVATION]** and are consolidated into the verification script in Appendix A.

> **Point-in-time snapshot.** This document records a security and configuration state observed in August 2026. The lab evolves; current settings may differ. Specific device model / component-brand strings have been generalized to a hardware class; capability and capacity detail is retained.

### Legend

**Severity:** Critical / High / Medium / Low / Informational
**Evidence type:**
- **[VERIFIED]** — directly observed from a command output in this pass.
- **[INFERENCE]** — technical conclusion drawn from observed data, not directly asserted by a tool.
- **[RECOMMENDATION]** — a proposed future action (never executed here).

**Authorization class** (per project Safety Policy), used in the remediation plan:
- **READ-ONLY** — diagnostic only.
- **LOW-RISK CHANGE** — easily reversible, no impact to boot/security architecture.
- **SYSTEM CHANGE** — affects OS configuration; reversible with defined rollback.
- **HIGH-RISK / BACKUP REQUIRED** — touches firmware, boot chain, partitions, or encryption; backup + explicit authorization required before execution.

---

## 1. Executive Summary

**Overall posture: GOOD.** The clean installation looks genuinely clean. No malware persistence indicators were found in startup locations, scheduled tasks, services, WMI subscriptions, registry Run keys, image-file-execution options, AppInit DLLs, the hosts file, or proxy configuration. All specific historical compromise indicators supplied for this audit are **absent** (Section 25). Installed software is minimal and entirely legitimate. Microsoft Defender is active with tamper protection on and current signatures. The Kali Linux partition is present and intact.

**No Critical findings. No confirmed malicious artifacts.**

The meaningful gaps are hardening and maintenance items, not compromise:

| Ref | Severity | Summary |
|-----|----------|---------|
| H1 | High | Secure Boot is disabled |
| H2 | High | Previous (suspected-compromised) OS retained on disk as `C:\Windows.old` |
| H3 | High | Pending HP firmware + Intel platform/ME/Wi-Fi updates not yet applied |
| M1 | Medium | Intel Wi-Fi AC 9560 on a 2018 inbox driver; 10 adapter-error events in 7 days |
| M2 | Medium | 4 chipset/platform devices failed driver install (Intel Chipset/DPTF/ME/GNA) |
| M3 | Medium | Defender hardening layers off (PUA=Audit, CFA off, ASR none, Network Protection off) |
| M4 | Medium | Fast Startup enabled on a Windows/Linux dual-boot host |
| M5 | Medium | System Restore protection state unconfirmed; no post-install restore point |
| M6 | Medium | Full antivirus scan never run since reinstall |
| M7 | Medium | TPM detailed state not verified; Credential Guard not enabled |

Low / Informational items are in the body and Section 25.

---

## 2. Windows Version, Activation, Build, Edition

| Property | Value | Evidence |
|----------|-------|----------|
| Edition | Windows 11 Pro (64-bit) | [VERIFIED] |
| Version / feature update | 25H2 | [VERIFIED] |
| Build | 26200.9168 (`CurrentBuild` 26200, `UBR` 9168) | [VERIFIED] |
| OS version string | 10.0.26200 | [VERIFIED] |
| Installation type | Client | [VERIFIED] |
| Install date (this OS) | 2026-08-28 ~01:01 local | [VERIFIED] |
| Last boot | 2026-08-27 ~22:30 local | [VERIFIED] |
| Activation | Licensed (`LicenseStatus=1`), OEM digital license (`OEM:DM` channel), 0 grace days | [VERIFIED] |

**Notes / [INFERENCE]:**
- `ProductName` in the registry reads "Windows 10 Pro" while the OS Caption correctly reads "Windows 11 Pro". This is a long-standing cosmetic registry quirk on Windows 11, not a misconfiguration.
- Activation via embedded OEM firmware license is expected for this HP machine; no product key was displayed or recorded.

---

## 3. Hardware

### 3.1 System

| Property | Value | Evidence |
|----------|-------|----------|
| Manufacturer / model | HP EliteBook-class business laptop | [VERIFIED] |
| Chassis type | Mobile / laptop | [VERIFIED] |
| Domain membership | Not domain-joined; WORKGROUP | [VERIFIED] |

### 3.2 CPU

| Property | Value | Evidence |
|----------|-------|----------|
| Model | Intel 6-core / 12-thread mobile CPU | [VERIFIED] |
| Cores / threads | 6 physical / 12 logical | [VERIFIED] |
| Max clock (rated) | 2592 MHz base | [VERIFIED] |

### 3.3 RAM

| Property | Value | Evidence |
|----------|-------|----------|
| Total installed | 32 GB (2 × 16 GB) | [VERIFIED] |
| Total visible to OS | ~31.8 GB (remainder reserved for iGPU/hardware) | [VERIFIED] |
| Type / speed | DDR4, 2667 MT/s configured (running at rated speed) | [VERIFIED] |
| Modules | 2 × 16 GB DDR4, both bottom slots populated | [VERIFIED] |

### 3.4 GPU

| Adapter | Driver version | Driver date | Status | Evidence |
|---------|----------------|-------------|--------|----------|
| Discrete NVIDIA GPU (4 GB) | 32.0.15.7371 (branded "573.71") | 2025-08-20 | OK | [VERIFIED] |
| Integrated Intel graphics (iGPU) | 31.0.101.2140 | 2025-11-04 | OK | [VERIFIED] |

**[INFERENCE]:** Both display drivers are relatively current (NVIDIA ~1 major branch behind latest; Intel recent). Not a security concern; optional refresh only.

### 3.5 Storage / SSD health

| Property | Value | Evidence |
|----------|-------|----------|
| System drive | ~1 TB NVMe SSD (value-tier), ~931.5 GB usable, GPT, **HealthStatus: Healthy / OK** | [VERIFIED] |
| Windows volume `C:` | NTFS, ~837.9 GB, ~783 GB free (~93% free) | [VERIFIED] |
| Removable | USB flash drive, ~14.7 GB, FAT32, label `ESD-USB` (a Windows installation USB) | [VERIFIED] |
| SMART detail (wear %, power-on hours, temperature, reallocated sectors) | **Not captured** — `Get-StorageReliabilityCounter` returned no data unprivileged | **[NEEDS ELEVATION]** |

**[INFERENCE]:** High-level health is good and free space is ample. Detailed NVMe endurance/wear data should be pulled in an elevated pass (Appendix A) to establish a baseline for this SSD (a value-tier NVMe drive; worth tracking wear).

### 3.6 Battery

| Property | Value | Evidence |
|----------|-------|----------|
| State | On AC power, ~95% charge, status "charging/AC" | [VERIFIED] |
| Chemistry | Lithium-ion | [VERIFIED] |
| Design vs. full-charge capacity / cycle count / wear % | **Not captured** — `powercfg /batteryreport` did not produce output in the non-interactive session | **[NEEDS ELEVATION]** (Appendix A runs it interactively) |

---

## 4. BIOS / UEFI

| Property | Value | Evidence |
|----------|-------|----------|
| Firmware type | **UEFI** (confirmed via `BiosFirmwareType` and environment) | [VERIFIED] |
| BIOS/UEFI firmware | current vendor BIOS/UEFI firmware; version verified (see `PRE_FIRMWARE_VALIDATION.md` for the exact level and firmware-package analysis) | [VERIFIED] |
| BIOS release date | 2024 vendor release | [VERIFIED] |
| **Secure Boot** | **DISABLED** — `HKLM\SYSTEM\CurrentControlSet\Control\SecureBoot\State\UEFISecureBootEnabled = 0` | [VERIFIED] — see finding **H1** |
| TPM present (detail) | Detailed `Get-Tpm` fields returned blank unprivileged; TPM chip is present in this platform and HVCI is running (which requires TPM-backed measured boot on this hardware class) | [INFERENCE] / **[NEEDS ELEVATION]** — see finding **M7** |
| Firmware boot entries / UEFI boot order | `bcdedit /enum firmware` — **Access denied** unprivileged | **[NEEDS ELEVATION]** — see Section 4.1 & finding H1/Section 4 |
| Pending firmware update | "HP Inc. – Firmware – 1.29.1.0" offered via Windows Update | [VERIFIED] — see finding **H3** |

### 4.1 Boot entries (partial)

- Full `bcdedit /enum all` and `/enum firmware` require elevation and could **not** be enumerated in this pass.
- **[INFERENCE]:** Windows Boot Manager is functional and is the current default — the machine booted into Windows 11 unattended for this audit, and `C:` is marked `IsSystem`/`IsBoot` on the only fixed disk. A definitive listing of every boot entry, the default entry, and the timeout is deferred to Appendix A.

---

## 5. Dual Boot

### 5.1 Partition layout — Disk 0 (NVMe SSD, GPT, ~931.5 GB)

| # | Role (GPT type) | Size | Drive letter | Notes | Evidence |
|---|-----------------|------|--------------|-------|----------|
| 1 | EFI System Partition | ~499 MB | (none) | Shared ESP for Windows Boot Manager **and** GRUB | [VERIFIED] |
| 2 | Microsoft Reserved (MSR) | ~128 MB | (none) | Standard | [VERIFIED] |
| 3 | Basic data — NTFS | ~837.9 GB | `C:` | Windows | [VERIFIED] |
| 4 | Windows Recovery | ~0.84 GB | (none) | WinRE partition | [VERIFIED] |
| 5 | **Linux filesystem data** | **~92.13 GB** | (none) | **Kali Linux root — PRESENT and INTACT** | [VERIFIED] |

- Removable Disk 1 (USB flash drive): MBR, FAT32, `D:` `ESD-USB` — a Windows installer stick, unrelated to dual boot.
- Two "Generic MassStorageClass" entries with **No Media** (empty multi-slot USB card reader) — not relevant.

### 5.2 Kali / GRUB integrity

| Check | Result | Evidence |
|-------|--------|----------|
| Kali root partition still present | **Yes** — Disk 0, Partition 5, GPT type `{0fc63daf-8483-4772-8e79-3d69d8477de4}` (Linux filesystem data), ~92.13 GB, HealthStatus Healthy | [VERIFIED] |
| Kali partition resized/shrunk/overwritten by the reinstall | No evidence of it — partition exists at full expected size and healthy state | [INFERENCE] |
| Separate Linux swap partition | **None visible** on Disk 0 | [VERIFIED] |
| GRUB / `\EFI\kali\grubx64.efi` present in ESP; GRUB menu entry for Kali; UEFI boot-order entry "kali" | **Not verifiable unprivileged** — ESP is not mounted and `bcdedit /enum firmware` is access-denied | **[NEEDS ELEVATION]** |
| Windows boots by default | Yes (observed) | [VERIFIED] |

**[INFERENCE]:** Kali's data partition survived the Windows reinstall unharmed. The absence of a dedicated swap partition implies Kali uses a swap **file** inside its root filesystem (normal for modern Kali installs) — nothing missing. The one real open question is whether the Windows clean install left the **GRUB EFI loader and its UEFI/NVRAM boot entry** intact, or whether only the raw Linux partition remains while the boot entry was dropped. This must be confirmed from an elevated session (Appendix A: mount ESP read-only, list `\EFI\`, run `bcdedit /enum firmware`). Until then, treat "Kali is still bootable" as **unverified** even though "Kali's data is still there" is verified.

> ⚠️ **Do not** run any partition, `bcdboot`, `bcdedit`, `bootrec`, `efibootmgr`, or GRUB repair operation based on this report. If the elevated check shows the Kali boot entry is missing, that is a separate HIGH-RISK / BACKUP REQUIRED task requiring its own proposal and authorization.

---

## 6. Microsoft Defender

### 6.1 Protection state — [VERIFIED]

| Control | State |
|---------|-------|
| Antivirus / antispyware enabled | Yes |
| Real-time protection | **On** |
| Behavior monitoring | **On** |
| On-access (IOAV) / downloaded-file scanning | **On** |
| Network Inspection System (NIS) | **On** |
| Cloud-delivered protection (MAPS) | **Advanced** |
| Automatic sample submission | Send safe samples |
| Tamper Protection | **On** (`IsTamperProtected = True`) |
| Running mode | Normal (Defender is the active AV; no third-party AV present) |
| Engine / platform / product | Engine 1.1.26080.3, platform 4.18.25080.5 |

### 6.2 Signatures — [VERIFIED]

| Item | Value |
|------|-------|
| AV signature version | 1.457.372.0, last updated 2026-08-27 |
| Antispyware / NIS signature | 1.457.372.0 |
| Signatures out of date | **No** |
| Quick scan age | 0 days (recent) |
| **Full scan age** | **Never run** (`FullScanAge = 4294967295`) — see finding **M6** |

### 6.3 Exclusions — [VERIFIED at registry level] / **[NEEDS ELEVATION to confirm]**

- `Get-MpPreference` reported exclusion lists as *"must be an administrator to view"* (expected unprivileged).
- Direct read of `HKLM\SOFTWARE\Microsoft\Windows Defender\Exclusions\{Paths,Processes,Extensions,TemporaryPaths,IpAddresses}` returned **no values in any subkey** — i.e. no path, process, extension, or IP exclusions are configured.
- No Defender settings are being forced by Group Policy (`HKLM\SOFTWARE\Policies\Microsoft\Windows Defender` has no values) — Defender is running its stock configuration.
- **[INFERENCE]:** The historical "old Defender exclusions" compromise indicator appears **absent**. Confirm authoritatively with elevated `Get-MpPreference` (Appendix A).

### 6.4 Additional Defender layers — [VERIFIED]

| Feature | State | Meaning |
|---------|-------|---------|
| PUA Protection | **2 = Audit** | Potentially-unwanted apps are logged but **not blocked** — see **M3** |
| Controlled Folder Access | **0 = Off** | Anti-ransomware folder guard disabled — see **M3** |
| Attack Surface Reduction rules | **0 rules configured** | No ASR rules active — see **M3** |
| Network Protection | **0 = Off** | No web/network C2 & malicious-domain blocking — see **M3** |
| SmartScreen (Explorer) | **1 = On** | App/file reputation checks active |
| LSASS protection (`RunAsPPL`) | **2** | LSASS runs as a Protected Process Light (credential-theft hardening) — good |

### 6.5 Detections — [VERIFIED]

- `Get-MpThreatDetection` and `Get-MpThreat` returned **no entries**. No current or historical threat detections recorded on this installation.

---

## 7. Firewall

| Profile | Enabled | Default inbound | Default outbound | Evidence |
|---------|---------|-----------------|------------------|----------|
| Domain | **Yes** | Not overridden (= block) | Not overridden (= allow) | [VERIFIED] |
| Private | **Yes** | Not overridden (= block) | Not overridden (= allow) | [VERIFIED] |
| Public | **Yes** | Not overridden (= block) | Not overridden (= allow) | [VERIFIED] |

- **Active network category:** Wi-Fi is classified **Public** (internet-connected, IPv4 + IPv6). [VERIFIED]
- Firewall logging of dropped/allowed packets is **off** on all profiles (Windows default). [VERIFIED]
- Enabled inbound "allow" rules are all stock Windows rules (Core Networking, Network Discovery, Cast to Device, mDNS, Remote Assistance, Wi-Fi Direct, built-in app rules). **No custom / third-party / suspicious inbound allow rules.** [VERIFIED]
- **[INFERENCE]:** "Public" on the Wi-Fi is the more restrictive choice (network discovery and inbound app exposure minimized). Fine to leave as-is for a roaming laptop.

---

## 8. Accounts and Local Administrators

| Account | Enabled | Type | Notes | Evidence |
|---------|---------|------|-------|----------|
| Primary user (`<USER>`) | Yes | Microsoft account, **member of Administrators** | The day-to-day interactive account | [VERIFIED] |
| Built-in `Administrator` | **No (disabled)** | Local | Default disabled state — good | [VERIFIED] |
| `Guest` | **No (disabled)** | Local built-in | Good | [VERIFIED] |
| `DefaultAccount` | **No (disabled)** | System-managed | Normal | [VERIFIED] |
| `WDAGUtilityAccount` | **No (disabled)** | System-managed (App Guard) | Normal | [VERIFIED] |

- **Administrators group members:** built-in `Administrator` (disabled) and the primary user only. **No unexpected or extra administrators.** [VERIFIED]
- `Remote Desktop Users`, `Remote Management Users`, `Hyper-V Administrators`, `Backup Operators` groups are all **empty**. [VERIFIED]
- The audit shell ran **non-elevated** — the current token shows Medium integrity and `BUILTIN\Administrators` as *"used for deny only"*, confirming UAC admin-approval mode is functioning. [VERIFIED]
- **[INFERENCE]:** Account hygiene is good. The only reduction-of-privilege option would be to run day-to-day as a Standard user with a separate admin account, but a single-admin Microsoft-account setup on a personal laptop is a reasonable, common configuration.

---

## 9. Windows Update

| Item | Value | Evidence |
|------|-------|----------|
| Recent installed updates | `KB5122035` (2026-08-28), `KB5121003`, `KB5123304`, `KB5054156`, `KB5120708` (all 2026-08-09) | [VERIFIED] |
| `wuauserv` / `bits` | Stopped / Manual (normal — start on demand) | [VERIFIED] |
| `UsoSvc`, `dosvc` | Running / Automatic (normal) | [VERIFIED] |
| Update registry "last result" keys | Not present / not readable unprivileged | **[NEEDS ELEVATION]** |
| **Pending updates** | **10** (see below) | [VERIFIED] |

**Pending update queue [VERIFIED]:**

1. Microsoft Defender antimalware platform update — KB4052623 (platform 4.18.26080.3)
2. INTEL – System – 10.1.14.5
3. INTEL – System – 10.1.16.6 (×2)
4. INTEL – System – 10.1.7.3
5. Realtek Semiconductor – MTD (card/media) – 10.0.17763.21309
6. Synaptics – Biometric (fingerprint) – 5.5.28.1099
7. **Intel – net (Wi-Fi) – 22.250.1.2**
8. **HP Inc. – Firmware – 1.29.1.0**
9. 2026-08 Security Update KB5121003 (re-offer / component servicing)

**[INFERENCE]:** The clean install left several **platform drivers and firmware** unapplied. Items 2–8 map directly to the 4 failed devices (Section 9) and the aging Wi-Fi driver (M1). These are mostly delivered through Windows Update but some (Intel chipset/ME, HP firmware) are better sourced from HP's official support package for this model to get the complete set.

---

## 10. Drivers

### 10.1 Devices reporting an error — [VERIFIED]

| Device (as shown) | Problem | Likely identity [INFERENCE] |
|-------------------|---------|------------------------------|
| PCI Data Acquisition and Signal Processing Controller | `CM_PROB_FAILED_INSTALL` | Intel Dynamic Platform & Thermal Framework (DPTF) |
| SM Bus Controller | `CM_PROB_FAILED_INSTALL` | Intel chipset SMBus driver |
| PCI Device | `CM_PROB_FAILED_INSTALL` | Intel Management Engine interface / Intel GNA |
| PCI Device | `CM_PROB_FAILED_INSTALL` | Intel Management Engine interface / Intel GNA |

**Impact [INFERENCE]:** thermal management, power efficiency, and Intel ME/AMT interface features are degraded until the Intel chipset + ME + DPTF drivers are installed. Not a security exposure by itself, but ME firmware/driver currency matters for platform security (see H3). See finding **M2**.

### 10.2 Key hardware drivers — [VERIFIED]

| Device | Driver version | Driver date | Assessment [INFERENCE] |
|--------|----------------|-------------|------------------------|
| Intel Wireless-AC 9560 160MHz (Wi-Fi) | **21.80.2.3** | **2018-07-28** | **Very old Windows inbox driver.** Update 22.250.1.2 is pending. Correlates with 10× adapter-error events in 7 days (Section 23). Finding **M1**. |
| Intel Wireless Bluetooth | 21.110.0.3 | 2020-06-24 | Old; refresh with the Intel Wi-Fi/BT bundle |
| Discrete NVIDIA GPU | 32.0.15.7371 | 2025-08-20 | Current-ish (installed package "573.71") |
| Integrated Intel graphics | 31.0.101.2140 | 2025-11-04 | Recent |
| Intel Management Engine Interface | 2452.7.1.0 | 2024-12-21 | Present but see failed "PCI Device" entries above |
| Intel 300-Series SATA AHCI controller | 17.11.0.1000 | 2021-09-29 | Fine (no SATA drives, NVMe in use) |
| Synaptics touchpad / fingerprint | 19.5.9.50 / 5.5.27.1099 | 2021 / 2020 | Fingerprint update 5.5.28.1099 pending |
| HP hotkey / WLAN switching / mobile data protection (`hpdskflt`) | 8.10.52.464 / 7.0.22.11 | 2026 / 2025 | Present (installed by Windows Update); HP companion app not installed (see Section 23, `hpdskflt` boot event) |
| Bluetooth/HID stack entries dated "2006-06-20" | — | — | Microsoft placeholder inbox dates — **normal, not stale** |

- **All listed drivers are signed.** [VERIFIED]

### 10.3 HP drivers / firmware

- HP function drivers (hotkeys, WLAN switching, drive-protection sensor) are present via Windows Update. [VERIFIED]
- The vendor **firmware update "HP Inc. – Firmware – 1.29.1.0"** is pending (Section 8). It matches the currently-running BIOS level — the pending item may be a sub-component (e.g. ME firmware, EC, retimer) rather than the main BIOS. Confirm against the vendor's support page for this model. [INFERENCE] — finding **H3 / L5**. (Full analysis in `PRE_FIRMWARE_VALIDATION.md`.)
- No HP bloatware suite (HP Support Assistant, HP Wolf, etc.) is installed. [VERIFIED]

---

## 11. Startup Applications — [VERIFIED]

| Source | Entry | Assessment |
|--------|-------|------------|
| `HKLM\...\Run` | `SecurityHealth` → `%windir%\system32\SecurityHealthSystray.exe` | Legitimate (Windows Security tray) |
| `HKCU\...\Run` | `OneDrive` → `...\OneDrive.exe /background` | Legitimate |
| `HKCU\...\Run` | `MicrosoftEdgeAutoLaunch_...` → `msedge.exe --no-startup-window --win-session-start` | Legitimate (Edge startup boost) |
| Startup folders (user + common) | Only `desktop.ini` | Empty — good |
| `HKLM/HKCU RunOnce`, `WOW6432Node\Run` | Empty | Good |
| Winlogon `Shell` / `Userinit` | `explorer.exe` / `userinit.exe,` (defaults) | Unmodified — good |
| Image File Execution Options `Debugger` values | None | Good — no debugger-hijack persistence |
| `AppInit_DLLs` (native + WOW64) | Empty | Good — no DLL-injection persistence |
| Policy `Explorer\Run` (HKLM + HKCU) | Empty | Good |

**No suspicious autostart entries.**

---

## 12. Scheduled Tasks — [VERIFIED]

- **Non-Microsoft tasks:** only OneDrive tasks (Reporting, Standalone Update, Startup) and Windows "SoftLanding" tasks (Windows Spotlight / suggested-content, published by Microsoft `ContentDeliveryManager`). All signed/authored by Microsoft Corporation.
- **Root (`\`) tasks:** the three OneDrive tasks only.
- Task actions that launch executables outside `C:\Windows`: only the OneDrive updater/launcher under the user's `AppData\Local\Microsoft\OneDrive`. Expected.
- **No** task named or pathed with `audio`, `perform`, `netframework`, `system`, or similar. **No** task action references `Netframework.4*`, `\Perform`, `audio system`, `system.lnk`, `\Users\Public\`, or `\Temp\`.

**No malicious or unexplained scheduled tasks.**

---

## 13. Third-Party / Automatic Services — [VERIFIED]

- Services whose binary path is **outside** `C:\Windows`: `edgeupdate` / `edgeupdatem` (Microsoft Edge updater, currently stopped), `MicrosoftEdgeElevationService` (stopped), Defender components (`WinDefend`, `WdNisSvc`, `MDCoreSvc` running; `Sense` stopped), `WMPNetworkSvc` (stopped), and `NVDisplay.ContainerLocalSystem` (NVIDIA, running — binary in the signed DriverStore, logs to `C:\ProgramData\NVIDIA`).
- **No** services running from user-writable locations (`\Users\`, `\Temp\`, `\Downloads\`, `\Desktop\`, `\AppData\`, `\Public\`).
- **No** services with unquoted executable paths containing spaces (no unquoted-path privilege-escalation surface).
- **No** third-party antivirus, remote-access, tunneling, or "optimizer" services.
- Running kernel drivers outside `System32\drivers` / `DriverStore`: only `CDD` (Canonical Display Driver — a Windows component). 

**Service inventory is clean and minimal.**

---

## 14. Installed Software — [VERIFIED]

**Desktop applications (registry uninstall data + winget):**

| Name | Version | Publisher | Installed |
|------|---------|-----------|-----------|
| Bang & Olufsen Audio | 9.0.278.150 | OEM audio driver | (with OS) |
| Claude Code | 2.1.248 | Anthropic PBC | 2026-08-27 |
| Git | 2.55.0.3 | Git Development Community | 2026-08-27 |
| Microsoft Edge + WebView2 Runtime | 151.0.4129.107 | Microsoft | 2026-08-27 |
| Microsoft OneDrive | 26.150.0804.0011 | Microsoft | — |
| Microsoft Visual Studio Code (User) | 1.135.0 | Microsoft | 2026-08-27 |
| Microsoft Teams | 26213.1006.5014.9784 | Microsoft | — |
| NVIDIA Graphics Driver | 573.71 (+ NVIDIA Install Application) | NVIDIA | 2026-08-27 |
| Outlook for Windows (new) | 1.2026.818.100 | Microsoft | (inbox) |

- Store/UWP packages are the standard Windows 11 in-box set plus Clipchamp.
- **winget** reports minor updates available for **App Installer** (1.26 → 1.29) and **Windows Terminal** (1.23 → 1.24), plus a duplicate `Microsoft.UI.Xaml.2.8` runtime — all cosmetic.

**[INFERENCE]:** The software set is exactly what you would expect on a freshly rebuilt engineering workstation: shell, editor, Git, browser, collaboration, GPU driver. **No cracked/pirated software, no torrent clients, no keygens, no "activators", no unknown vendors.** This is the strongest single indicator that the clean install was done correctly.

**Informational:** several Microsoft-signed Store *stub* packages with machine-generated names (`MicrosoftWindows.61869720.Voiess`, `...Livtop`, `...Speion`, `...InpApp`, and GUID-named entries). These are legitimate Microsoft-signed placeholder/advertising stubs that ship on Windows 11 24H2/25H2. Not malware. They can optionally be removed later for tidiness (Section 25, Informational).

---

## 15. Listening TCP Ports — [VERIFIED]

| Port | Bound to | Process | Identity |
|------|----------|---------|----------|
| 135 | all | `svchost` | RPC Endpoint Mapper (Windows) |
| 139 | interface | `System` | NetBIOS Session (SMB legacy) |
| 445 | all | `System` | SMB |
| 5040 | all | `svchost` | Connected Devices Platform service (CDPSvc) |
| 7680 | all | `svchost` | Delivery Optimization (peer update cache) |
| 49664–49690 | all | `lsass`, `wininit`, `services`, `svchost`, `spoolsv` | Dynamic RPC (standard Windows) |
| 59140 | **localhost only** | `jhi_service` | Intel Dynamic Application Loader Host Interface (Intel ME component) — local only |

**UDP:** 137/138 (NetBIOS), 1900 (SSDP), 5353 (mDNS), 5355 (LLMNR), 5050 (CDPSvc), plus dynamic — all Windows defaults.

**[INFERENCE]:** No unexpected listeners. Nothing is listening for a remote-access agent, reverse shell, RAT, or web service. The only non-Windows listener (`jhi_service`) is an Intel platform component bound to loopback. `spoolsv` (Print Spooler) is listening on a dynamic RPC port — see finding **L1**.

---

## 16. Remote Access Software / Services — [VERIFIED]

- **No** third-party remote-access products installed or running: no AnyDesk, TeamViewer, RustDesk, Chrome Remote Desktop, VNC (TightVNC/UltraVNC/RealVNC/TigerVNC), LogMeIn, GoToMyPC, Splashtop, ScreenConnect/ConnectWise, Atera, ngrok, Tailscale/ZeroTier, or SSH server.
- **OpenSSH Client** is on `PATH` (`C:\Windows\System32\OpenSSH\`) — the optional **OpenSSH Server** feature state was not verifiable unprivileged; confirm in Appendix A (no process is listening on TCP 22, so it is at minimum not running). [VERIFIED that nothing listens on 22] / **[NEEDS ELEVATION to confirm feature not installed]**
- **Quick Assist** (Microsoft Store app) is present as an in-box app but is not a service and requires interactive launch + a code — normal.
- Windows **Remote Assistance** firewall rules exist in the Domain/Private groups (in-box, enabled group) but there is no listener and the feature is not in use. [VERIFIED]
- **Windows Remote Management (WinRM)** — `Remote Management Users` group is empty and no listener was observed; confirm `winrm` service/listener state in Appendix A. **[NEEDS ELEVATION]**

---

## 17. SMB / Remote Desktop — [VERIFIED]

### SMB

| Setting | Value | Assessment |
|---------|-------|------------|
| SMB1 protocol | **Disabled** | Good |
| SMB2/3 protocol | Enabled | Normal |
| Require security signature (server) | **True** | Good (SMB signing enforced) |
| Insecure guest logons | Not set (Windows 11 default = disabled) | OK; confirm elevated |
| SMB encryption of all traffic | Off | Default; only relevant if hosting shares |
| Shares | `ADMIN$`, `C$`, `IPC$` (default administrative shares only) — **no custom shares** | Good |

### Remote Desktop

| Setting | Value | Assessment |
|---------|-------|------------|
| `fDenyTSConnections` | **1 (RDP disabled)** | Good |
| `TermService`, `UmRdpService`, `SessionEnv` | Stopped / Manual | Good |
| "Remote Desktop" firewall rules | **Disabled** | Good |

**RDP is fully disabled. SMB is at a sane hardened baseline.**

---

## 18. VBS / Device Guard / Virtualization — [VERIFIED]

| Property | Value | Meaning |
|----------|-------|---------|
| Virtualization-Based Security status | **2 = running** | VBS active |
| Security services configured / running | `2` / `2` | **HVCI (Memory Integrity) configured AND running** |
| Credential Guard | **Not enabled** (not in configured/running list) | See finding **M7** |
| Code Integrity policy enforcement | `2` = enforced (kernel-mode CI) | Good |
| User-mode CI enforcement | `1` = audit | Default |
| Available security properties | Base virtualization, Secure Boot for VBS, SMM protection, Mode-Based Execution Control, APIC virtualization | Platform supports more than is enabled |
| Hypervisor present | **True** | Windows hypervisor is loaded (required for VBS/HVCI) |

**[INFERENCE]:** VBS + HVCI running is a strong Windows 11 security baseline and is already in place. Credential Guard is the notable unused capability (M7). Note: the running hypervisor means nested virtualization / some third-party hypervisors (e.g. older VMware/VirtualBox without Hyper-V compatibility) may be affected — not a problem for WSL2, Hyper-V, or Windows Sandbox.

---

## 19. Windows Optional Features — **[NEEDS ELEVATION]**

`Get-WindowsOptionalFeature -Online` and `Get-WindowsCapability -Online` require elevation and returned nothing usable in this pass.

**[INFERENCE]** from indirect evidence:
- SMB1 protocol is disabled (Section 17) → "SMB 1.0/CIFS" feature is effectively off.
- OpenSSH **Client** capability is installed (on `PATH`).
- A definitive list (to rule out Telnet Client, TFTP, legacy components, .NET 3.5, "Windows Subsystem for Linux", "Virtual Machine Platform", "Hyper-V", IIS, etc.) is deferred to Appendix A. `C:\inetpub` exists on disk but this is created by a Windows servicing mitigation (see Section 25) and does **not** imply the IIS feature is enabled — confirm in Appendix A.

---

## 20. Windows Recovery Environment — **[NEEDS ELEVATION]**

- A dedicated **Recovery partition (~0.84 GB)** exists on Disk 0 (Section 5). [VERIFIED]
- `reagentc /info` requires an elevated prompt — **WinRE enabled/disabled state, and the WinRE image location, were not verified.** Deferred to Appendix A. **[NEEDS ELEVATION]**

---

## 21. System Restore / VSS — partial

| Check | Result | Evidence |
|-------|--------|----------|
| System Restore session interval registry value | `RPSessionInterval = 1` (suggests SR is configured) | [VERIFIED] |
| System Restore disabled by policy | No policy values present | [VERIFIED] |
| Existing restore points | **None enumerated** (`SystemRestore` WMI class returned nothing; may be unprivileged limitation or genuinely none) | [VERIFIED / ambiguous] |
| Shadow copies present | **None** (`Win32_ShadowCopy` empty) | [VERIFIED] |
| `vssadmin list shadowstorage` / protection % per volume | Requires elevation | **[NEEDS ELEVATION]** |

**[INFERENCE]:** There is likely **no usable restore point** and possibly System Restore protection is not actually turned on for `C:` (Windows 11 does not enable it by default). This should be confirmed and a **baseline restore point created** now that the machine is known-clean — finding **M5**.

---

## 22. DISM Health — **[NEEDS ELEVATION]**

`DISM /Online /Cleanup-Image /CheckHealth` (read-only flag-check) requires elevation and was **not run**. Deferred to Appendix A. No component-store corruption is *indicated* by any other signal in this audit, but this is unverified.

---

## 23. SFC Verify-Only — **[NEEDS ELEVATION]**

`sfc /verifyonly` requires an elevated console and was **not run**. Deferred to Appendix A (takes several minutes, read-only, makes no repairs).

---

## 24. Recent Critical / Error Events (last 7 days) — [VERIFIED]

**System log — Critical/Error, grouped:**

| Count | Event / Source | Interpretation [INFERENCE] |
|-------|----------------|----------------------------|
| 24 | `20` WindowsUpdateClient — install failure `0x80073D02` for `MicrosoftWindows.Client.WebExperience` (Widgets) | Stuck Store/optional component update. Cosmetic but noisy — finding **L3** |
| 10 | `5010` `Netwtw08` — "Intel Wireless-AC 9560 returned an invalid value to the driver" | Wi-Fi driver instability — supports finding **M1** |
| 6 | `10005` DistributedCOM — error `1115` starting `wuauserv` | Side-effect of the update-service churn above — low significance |
| 1 | `7030` SCM — Printer Extensions service marked interactive | Benign Windows quirk |
| 1 | `7023` SCM — `netprofm` terminated: "device is not ready" | Transient at boot/network-init — benign |
| 1 | `10010` DistributedCOM — null-GUID server timeout | Benign, common |
| 1 | `7043` SCM — Windows Update service did not stop cleanly on preshutdown | Related to update churn — low |

**Application log — Critical/Error:** 1 event — `16` SecurityCenter "Error while updating Windows Defender status to SECURITY_PRODUCT_STATE_ON" — a transient Security Center race at boot; Defender is confirmed on (Section 6). Benign.

**Stability check (14 days):** `Get-WinEvent` for IDs 41 / 6008 / 1001 → only one entry, `hpdskflt` event `1001` at the last boot with *"Cannot retrieve event message text"* (the HP Drive-Protection filter driver is loaded but the HP companion app that provides its message strings is not installed). **No Kernel-Power 41, no dirty shutdowns, no bugchecks/BSODs.** [VERIFIED]

**[INFERENCE]:** The machine is **stable**. The only recurring noise is (a) the aging Wi-Fi driver and (b) a stuck Widgets component update. Nothing points to instability, hardware failure, or malicious activity.

---

## 25. Compromise Indicator Checklist

All indicators supplied for this audit were checked **read-only**. Result: **ALL ABSENT.**

| # | Indicator | Result | Evidence |
|---|-----------|--------|----------|
| 1 | `C:\Netframework.4.5.10.5.1` | **Absent** — path does not exist (also checked `C:\Windows\Netframework*`) | [VERIFIED] |
| 2 | `C:\Perform` | **Absent** — also checked `C:\Perform.exe`, `C:\Windows\Perform`; and no service named/pathed `Perform` (`reg query ...\Services /f Perform` → 0 matches) | [VERIFIED] |
| 3 | `system.lnk` persistence | **Absent** — not in the common Startup folder, the user's Startup folder, or `C:\Users\Public`; no task/Run entry references `system.lnk` | [VERIFIED] |
| 4 | "audio system" scheduled task | **Absent** — no task named `*audio*` anywhere; checked `\`, `\Microsoft\Windows\*`, and legacy `System32\Tasks\...` paths | [VERIFIED] |
| 5 | Old Defender exclusions | **None found** — all `HKLM\SOFTWARE\Microsoft\Windows Defender\Exclusions` subkeys empty; no Defender GPO policy. Recommend elevated `Get-MpPreference` to confirm authoritatively | [VERIFIED at registry level] / **[NEEDS ELEVATION]** |

**Additional persistence sweeps performed (all clean) — [VERIFIED]:**

| Vector | Result |
|--------|--------|
| Registry `Run` / `RunOnce` (HKLM, HKCU, WOW6432Node) | Only `SecurityHealth`, `OneDrive`, Edge auto-launch |
| Policy `Explorer\Run` (HKLM + HKCU) | Empty |
| Winlogon `Shell` / `Userinit` | Defaults, unmodified |
| Image File Execution Options `Debugger` | None |
| `AppInit_DLLs` (native + WOW64) | Empty |
| WMI persistence (`root\subscription`: `__EventFilter`, `CommandLineEventConsumer`, `ActiveScriptEventConsumer`) | Only the built-in "SCM Event Log Filter"; **no consumers** |
| `hosts` file | Default — no custom entries |
| System proxy / PAC (`AutoConfigURL`) | None (`ProxyEnable = 0`) |
| Services from user-writable paths | None |
| Unquoted service paths | None |
| Machine `PATH` | Only system dirs + `C:\Program Files\Git\cmd` — no writable/anomalous entries |
| Non-Microsoft scheduled tasks | Only OneDrive + Microsoft "SoftLanding" (Spotlight) |
| Non-Microsoft services | None (Edge updater, Defender, NVIDIA container only) |

**Residual-risk note (finding H2):** `C:\Windows.old` (the previous, suspected-compromised installation) is **still on the disk**. It is inert (not executing), but it contains the old system and user trees. Its size could not be measured unprivileged (directory ACLs). It should be reviewed for any needed personal data and then removed via the supported mechanism (Disk Cleanup / Storage Sense / `DISM /Online /Cleanup-Image /StartComponentCleanup`), **not** by manual deletion.

---

## 26. Power Plan and Performance Configuration — [VERIFIED]

| Setting | Value | Assessment [INFERENCE] |
|---------|-------|------------------------|
| Active power scheme | **Balanced** (and it is the only scheme present) | Fine for a laptop |
| Other schemes (High performance / Power saver / Ultimate) | Not present | Normal on modern Windows 11 (Modern Standby platforms often expose only Balanced) |
| Start-menu power button / "power button" sub-group | Default (index 0) | Normal |
| **Fast Startup** (`HiberbootEnabled`) | **1 = ON** | **Not ideal for a Windows/Linux dual-boot host** — see finding **M4** |
| Hibernate | Enabled — `hiberfil.sys` present (~12.7 GB) | Consistent with Fast Startup being on |
| Page file | `pagefile.sys` ~5 GB (system-managed), `swapfile.sys` 16 MB | Normal |
| Delivery Optimization download mode | **LAN (peer-to-peer on local network)** | Low-risk; optional to restrict — finding **L2** |

---

## 27. Findings Register with Benefit / Risk / Rollback / Authorization

> Every item below is a **[RECOMMENDATION]** for a *future* change. Nothing here has been executed.

### HIGH

#### H1 — Secure Boot is disabled
- **Evidence:** [VERIFIED] `SecureBoot\State\UEFISecureBootEnabled = 0`.
- **Benefit of enabling:** Restores firmware-enforced boot-chain integrity (blocks unsigned/tampered bootloaders and rootkits at the pre-OS stage). Particularly valuable immediately after a compromise recovery. Prerequisite for Credential Guard hardening (M7) and for a fully-attested VBS.
- **Risk:** If Kali's GRUB/shim is not enrolled for Secure Boot, Kali will fail to boot after enabling. Kali 2026.2 ships a Microsoft-signed `shim` and supports Secure Boot, so this is usually a non-issue — **but must be validated first**. Some older custom kernel modules / unsigned DKMS drivers in Kali may need MOK enrollment.
- **Rollback:** Re-enter UEFI setup (HP: F10 at boot) and set Secure Boot back to Disabled. Fully reversible in firmware; no data impact.
- **Authorization class:** **HIGH-RISK / BACKUP REQUIRED** (touches Secure Boot + boot chain). Requires: BitLocker recovery key on hand if BitLocker is active (verify in Appendix A), confirmation that Kali boots with Secure Boot, and explicit authorization.

#### H2 — Previous (suspected-compromised) OS retained as `C:\Windows.old`
- **Evidence:** [VERIFIED] directory exists (dated 2026-08-28). Size unverified.
- **Benefit of removal:** Eliminates a large dormant copy of the old, potentially-malicious system and user data; reclaims disk; removes a data-exposure surface.
- **Risk:** Any not-yet-recovered personal files in the old profile would be lost. Removal is irreversible.
- **Rollback:** None after deletion — therefore review first. (Mitigation: image the drive or copy `Windows.old\Users\<name>` to reviewed cold storage before cleanup.)
- **Authorization class:** **SYSTEM CHANGE** (use Disk Cleanup / Storage Sense / `DISM ... /StartComponentCleanup`; never manual `rd`). Requires explicit authorization + confirmation that personal-data recovery from the old profile is complete.

#### H3 — Pending HP firmware + Intel platform/ME/Wi-Fi updates
- **Evidence:** [VERIFIED] 10 pending updates including "HP Inc. – Firmware – 1.29.1.0", multiple "INTEL – System", "Intel – net 22.250.1.2".
- **Benefit:** Firmware/microcode/ME updates deliver platform security fixes (privilege escalation, DMA, ME vulnerabilities); Intel chipset/ME drivers clear the 4 failed devices (M2); the Wi-Fi driver fixes M1.
- **Risk:** Firmware flashing carries a small bricking risk if interrupted (power loss). Driver updates can occasionally regress device behavior.
- **Rollback:** Drivers — Device Manager "Roll Back Driver" or reinstall prior package. Firmware — HP typically allows reflash of a prior BIOS from HP's site (BIOS rollback may be restricted by HP policy; verify). Create a restore point (M5) first.
- **Authorization class:** Drivers = **LOW-RISK CHANGE**. HP firmware = **HIGH-RISK / BACKUP REQUIRED** (AC power mandatory, BitLocker suspended during flash if active, full image backup recommended).

### MEDIUM

#### M1 — Intel Wi-Fi AC 9560 on a 2018 inbox driver (+ 10 error events/7 days)
- **Benefit of update:** Stability (stops the `Netwtw08` 5010 errors), security fixes accumulated 2018→2025, better throughput/roaming.
- **Risk:** Minor — a new WLAN driver could change power-save behavior; rare adapter-not-found until reboot.
- **Rollback:** Device Manager → Roll Back Driver, or reinstall the inbox driver.
- **Authorization class:** **LOW-RISK CHANGE.**

#### M2 — Four chipset/platform devices failed driver install (Intel Chipset / DPTF / ME / GNA)
- **Benefit:** Restores thermal/power management and the Intel ME interface; removes the "!" devices; improves battery life and thermals.
- **Risk:** Low. Installing Intel Chipset INF + ME + DPTF from HP's package for this model is well-tested.
- **Rollback:** Uninstall the specific driver / roll back; devices simply revert to the "not installed" state.
- **Authorization class:** **LOW-RISK CHANGE.**

#### M3 — Defender hardening layers off (PUA=Audit, CFA off, ASR none, Network Protection off)
- **Benefit:** PUA=Block stops bundleware/"activators"/coin-miners (directly relevant to the prior compromise vector). Network Protection blocks known-malicious domains/IPs and C2 at the network layer. ASR rules block common initial-access and living-off-the-land techniques. Controlled Folder Access adds anti-ransomware protection for user folders.
- **Risk:** ASR rules and CFA **can break legitimate tooling** — highly relevant on a security-lab machine (script interpreters, custom binaries, offensive tooling). CFA can block editors/build tools from writing to Documents/Desktop.
- **Rollback:** `Set-MpPreference` — set `PUAProtection 0`, `EnableControlledFolderAccess Disabled`, `EnableNetworkProtection Disabled`, remove ASR rule IDs. Fully reversible per-setting, instantly.
- **Authorization class:** **SYSTEM CHANGE.** Recommended sequencing: PUA=Block and Network Protection first (low breakage); ASR rules in **Audit mode** first, review logs, then enforce selectively; CFA last and only if lab workflow tolerates it.

#### M4 — Fast Startup enabled on a dual-boot host
- **Benefit of disabling:** Windows performs a true full shutdown, so the NTFS volume and the shared ESP are left in a clean state for Kali; avoids "read-only / dirty volume" and rare filesystem-inconsistency issues when switching OSes; makes behavior predictable.
- **Risk:** Cold boot into Windows is a few seconds slower. No security downside.
- **Rollback:** `powercfg /h on` (or re-enable "Turn on fast startup" in Control Panel). Trivial and instant. (Note: turning hibernation fully off also removes `hiberfil.sys` / the "Hibernate" option; keeping hibernate but disabling *fast startup* via the Control Panel checkbox or `HiberbootEnabled=0` is the targeted change.)
- **Authorization class:** **SYSTEM CHANGE** (power/boot behavior; explicitly listed as sensitive — propose before executing).

#### M5 — System Restore protection unconfirmed; no clean-state baseline
- **Benefit:** A restore point captured now (known-good) gives a fast rollback path for the driver/firmware/hardening work in Batches 1–3.
- **Risk:** System Restore consumes some disk (cap configurable, e.g. 2–5%). It is **not** a backup and does not protect user files.
- **Rollback:** `Disable-ComputerRestore -Drive "C:\"` and delete points via `vssadmin`/UI.
- **Authorization class:** **LOW-RISK CHANGE** (enable SR on `C:` + create one restore point).

#### M6 — Full antivirus scan never run since reinstall
- **Benefit:** Confirms no dormant malicious files were carried in via restored personal data or the install media; completes the "post-clean" assurance.
- **Risk:** None (CPU/disk load for the scan duration).
- **Rollback:** N/A (read-only operation).
- **Authorization class:** **READ-ONLY** (`Start-MpScan -ScanType FullScan`).

#### M7 — TPM detail unverified; Credential Guard not enabled
- **Benefit:** Confirming TPM 2.0 present/ready underpins BitLocker and measured boot. Credential Guard isolates domain/cached credentials and NTLM secrets from a compromised OS (defense against credential theft — again, relevant post-compromise).
- **Risk:** Credential Guard can block some VPN plugins, older SSO/credential providers, and third-party hypervisors; needs Secure Boot (H1) for full value. On a non-domain personal machine the marginal benefit is smaller than in an enterprise.
- **Rollback:** Disable via registry/`mountvol`+group policy or the Device Guard readiness tool; reversible with a reboot.
- **Authorization class:** TPM check = **READ-ONLY** (Appendix A). Enabling Credential Guard = **SYSTEM CHANGE**.

### LOW

| Ref | Finding | Benefit of change | Risk | Rollback | Auth class |
|-----|---------|-------------------|------|----------|-----------|
| L1 | Print Spooler running with no printer in use | Removes a historically-exploited RPC service and its listener | Loss of all printing / some PDF "printers" until re-enabled | `Set-Service Spooler -StartupType Automatic; Start-Service Spooler` | SYSTEM CHANGE |
| L2 | Delivery Optimization = LAN peer mode | Restricting to HTTP-only reduces LAN peer exposure on untrusted networks | Slightly higher WAN bandwidth for updates | Set DO `DownloadMode` back to `LAN`/default | LOW-RISK CHANGE |
| L3 | 24× stuck Widgets/`WebExperience` update failures (`0x80073D02`) | Stops recurring error-log noise; healthy component servicing | Minimal; may require re-registering or removing the Widgets package | Reinstall the package from Store | LOW-RISK CHANGE |
| L4 | Wi-Fi network category = Public | (No change recommended — this is the safer setting) | — | Set-NetConnectionProfile -NetworkCategory Private | LOW-RISK CHANGE |
| L5 | Confirm whether a newer vendor BIOS than the current level exists | Latest platform security fixes | See H3 | See H3 | HIGH-RISK / BACKUP REQUIRED |
| L6 | Optional-features inventory not captured | Verify no legacy/insecure feature (Telnet, TFTP, SMB1, etc.) is enabled | — (read-only) | — | READ-ONLY (Appendix A) |
| L7 | WinRE state unverified | Ensure recovery environment is present & healthy | — (read-only) | — | READ-ONLY (Appendix A) |

### INFORMATIONAL

- **I1** Microsoft-signed Store stub packages with machine-generated names — legitimate on Windows 11 25H2; optional cleanup only. Auth class: LOW-RISK CHANGE.
- **I2** `C:\inetpub` exists without IIS — created by a Windows servicing hardening mitigation (symlink-protection for a prior IIS-path vulnerability), applied even on machines without IIS. Benign. Leaving it in place is fine and recommended.
- **I3** SSD SMART/endurance and battery wear not captured — capture in Appendix A to establish baselines. Auth class: READ-ONLY.
- **I4** OpenSSH **Client** present on PATH; no SSH server listening. Confirm the Server feature is not installed (Appendix A).
- **I5** Kali data partition and shared ESP present; GRUB loader + UEFI boot entry not yet verified (Section 5.2) — verify in Appendix A **before** assuming Kali is bootable.

---

## 28. Prioritized Remediation Plan (3 batches)

### Batch 1 — Verify gaps + safe maintenance
*Goal: close the elevation-gated blind spots and apply only low-risk, well-understood updates. Do this first; it also informs Batch 2.*

| Step | Action | Addresses | Authorization class |
|------|--------|-----------|--------------------|
| 1.1 | Run the elevated **read-only** verification script (Appendix A): Secure Boot, TPM 2.0 state, `bcdedit` boot entries + default + timeout, ESP `\EFI\` contents (Kali/GRUB), Defender exclusions (authoritative), optional features & capabilities, `reagentc /info`, `vssadmin` protection, NVMe SMART, battery report, `winrm`/OpenSSH-Server state, `DISM /CheckHealth`, `sfc /verifyonly`, Security event log (4720/4726/4732/1102/4624 type 10). | H1 verify, M7, L6, L7, I3, I4, I5, §4.1, §5.2, §6.3, §19–23, §25(#5) | **READ-ONLY** |
| 1.2 | Enable System Restore on `C:` and create a restore point labelled "post-clean baseline". | M5 | LOW-RISK CHANGE |
| 1.3 | Run `Start-MpScan -ScanType FullScan`; review results. | M6 | READ-ONLY |
| 1.4 | Apply the pending **driver** updates: Intel chipset / ME / DPTF / GNA, Intel Wi-Fi 22.250.1.2, Realtek media, Synaptics fingerprint — preferably from the vendor's official driver pack for this model, then Windows Update for the rest. Reboot; re-check Device Manager. | M1, M2, part of H3 | LOW-RISK CHANGE |
| 1.5 | Apply the pending **Defender platform** update (KB4052623) and the re-offered quality update; update App Installer + Windows Terminal via winget. | §9 | LOW-RISK CHANGE |
| 1.6 | Investigate/clear the stuck Widgets (`WebExperience`) update. | L3 | LOW-RISK CHANGE |

### Batch 2 — Boot integrity & firmware
*Goal: restore pre-OS security guarantees and platform firmware currency. Every step here needs a backup and explicit authorization; do not proceed until Batch 1.1 confirms the Kali boot path and BitLocker state.*

| Step | Action | Addresses | Authorization class |
|------|--------|-----------|--------------------|
| 2.1 | Full drive image / verified backup of `C:` and of any needed data in `C:\Windows.old`. Record BitLocker recovery key offline if BitLocker is active. | prerequisite | — |
| 2.2 | Apply HP firmware update 1.29.1.0 (and newer BIOS if one exists) on AC power, BitLocker suspended if active. Verify version afterward. | H3, L5 | HIGH-RISK / BACKUP REQUIRED |
| 2.3 | Validate Kali 2026.2 boots with Secure Boot enabled (test in UEFI menu), then **enable Secure Boot** in HP UEFI. Verify both Windows and Kali boot; verify `Confirm-SecureBootUEFI` = True. | H1 | HIGH-RISK / BACKUP REQUIRED |
| 2.4 | After confirming personal-data recovery, remove `C:\Windows.old` via Disk Cleanup / `DISM /Online /Cleanup-Image /StartComponentCleanup /ResetBase`. | H2 | SYSTEM CHANGE |
| 2.5 | Disable Fast Startup (`HiberbootEnabled = 0` via Control Panel power-button settings; keep hibernate if wanted). Verify a Windows→Kali→Windows cycle leaves volumes clean. | M4 | SYSTEM CHANGE |

### Batch 3 — Defender & attack-surface hardening
*Goal: raise the security baseline. All steps reversible per-setting; stage the higher-breakage ones in audit mode first, mindful of lab tooling.*

| Step | Action | Addresses | Authorization class |
|------|--------|-----------|--------------------|
| 3.1 | Set `PUAProtection = Block`; enable `EnableNetworkProtection = Enabled`. | M3 | SYSTEM CHANGE |
| 3.2 | Enable a curated set of ASR rules in **Audit** mode; review logs for 1–2 weeks; then move non-disruptive rules to Block. | M3 | SYSTEM CHANGE |
| 3.3 | Decide on Controlled Folder Access (enable only if lab write-patterns tolerate it; add allowed apps as needed). | M3 | SYSTEM CHANGE |
| 3.4 | Confirm TPM 2.0 ready; if desired and after Secure Boot (2.3), enable Credential Guard; validate VPN/SSO still work. | M7 | SYSTEM CHANGE |
| 3.5 | Set Print Spooler to Disabled (or Manual) if no printing is needed. | L1 | SYSTEM CHANGE |
| 3.6 | Optionally set Delivery Optimization to HTTP-only; optionally remove Store stub packages (I1). | L2, I1 | LOW-RISK CHANGE |

---

## Appendix A — Elevated Read-Only Verification Script

Run in an **elevated** PowerShell (`Run as administrator`). **Read-only:** it queries state, generates two report files under the project folder, and runs `DISM /CheckHealth` and `sfc /verifyonly` (neither repairs anything). It makes **no** configuration, registry, boot, or firmware changes.

```powershell
# POST-CLEAN AUDIT - elevated read-only gap-fill. Makes no changes.
$ErrorActionPreference = 'SilentlyContinue'
$proj = 'C:\Users\<user>\Documents\CyberOps-AI-Workstation-Lab'
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'

Write-Host "`n=== SECURE BOOT ===" -ForegroundColor Cyan
try { "Confirm-SecureBootUEFI : " + (Confirm-SecureBootUEFI) } catch { "ERROR: $($_.Exception.Message)" }

Write-Host "`n=== TPM ===" -ForegroundColor Cyan
Get-Tpm | Format-List TpmPresent,TpmReady,TpmEnabled,TpmActivated,TpmOwned,ManufacturerIdTxt,ManufacturerVersion,LockoutCount
(Get-CimInstance -Namespace root\cimv2\security\microsofttpm -ClassName Win32_Tpm).SpecVersion

Write-Host "`n=== BOOT ENTRIES (Windows Boot Manager + OS loaders) ===" -ForegroundColor Cyan
bcdedit /enum '{fwbootmgr}'
bcdedit /enum '{bootmgr}'
bcdedit /enum osloader
bcdedit /enum firmware | Select-String 'identifier|description|path'

Write-Host "`n=== SHARED ESP CONTENTS (Kali / GRUB check) ===" -ForegroundColor Cyan
mountvol S: /S 2>$null
if (Test-Path S:\EFI) { Get-ChildItem -Recurse S:\EFI | Select-Object FullName,Length }
mountvol S: /D 2>$null

Write-Host "`n=== DEFENDER EXCLUSIONS (authoritative) ===" -ForegroundColor Cyan
$mp = Get-MpPreference
'ExclusionPath      :'; $mp.ExclusionPath
'ExclusionProcess   :'; $mp.ExclusionProcess
'ExclusionExtension :'; $mp.ExclusionExtension
'ExclusionIpAddress :'; $mp.ExclusionIpAddress
'CFA allowed apps   :'; $mp.ControlledFolderAccessAllowedApplications
'ASR rule IDs       :'; $mp.AttackSurfaceReductionRules_Ids
'ASR rule actions   :'; $mp.AttackSurfaceReductionRules_Actions

Write-Host "`n=== OPTIONAL FEATURES / CAPABILITIES ===" -ForegroundColor Cyan
Get-WindowsOptionalFeature -Online | Where-Object State -eq 'Enabled' | Select-Object FeatureName | Sort-Object FeatureName
Get-WindowsCapability -Online | Where-Object State -eq 'Installed' |
  Where-Object Name -match 'OpenSSH|Telnet|TFTP|SNMP|RSAT|NetFx|SMB1|WMIC' | Select-Object Name

Write-Host "`n=== REMOTE MGMT / SSH SERVER STATE ===" -ForegroundColor Cyan
Get-Service sshd,winrm,TermService | Select-Object Name,Status,StartType
winrm enumerate winrm/config/listener 2>&1

Write-Host "`n=== WINDOWS RECOVERY ENVIRONMENT ===" -ForegroundColor Cyan
reagentc /info

Write-Host "`n=== SYSTEM RESTORE / VSS ===" -ForegroundColor Cyan
Get-ComputerRestorePoint | Select-Object SequenceNumber,Description,CreationTime
vssadmin list shadowstorage
vssadmin list shadows

Write-Host "`n=== BITLOCKER (status only) ===" -ForegroundColor Cyan
Get-BitLockerVolume | Select-Object MountPoint,VolumeStatus,ProtectionStatus,EncryptionMethod,EncryptionPercentage,KeyProtector

Write-Host "`n=== NVMe SMART / ENDURANCE ===" -ForegroundColor Cyan
Get-PhysicalDisk | Get-StorageReliabilityCounter |
  Select-Object DeviceId,Wear,Temperature,PowerOnHours,ReadErrorsTotal,WriteErrorsTotal,StartStopCycleCount

Write-Host "`n=== BATTERY REPORT + ENERGY (read-only) ===" -ForegroundColor Cyan
powercfg /batteryreport /output "$proj\battery-report-$stamp.html"

Write-Host "`n=== WINDOWS.OLD SIZE ===" -ForegroundColor Cyan
$w = Get-ChildItem C:\Windows.old -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum
"Windows.old : {0:N2} GB across {1} files" -f ($w.Sum/1GB), $w.Count

Write-Host "`n=== SECURITY EVENT LOG (account & log-clear activity, 30d) ===" -ForegroundColor Cyan
Get-WinEvent -FilterHashtable @{LogName='Security';Id=1102,4720,4722,4724,4726,4728,4732,4670;StartTime=(Get-Date).AddDays(-30)} |
  Select-Object TimeCreated,Id,@{n='Msg';e={($_.Message -split "`n")[0]}}

Write-Host "`n=== DISM COMPONENT STORE (CheckHealth - read-only) ===" -ForegroundColor Cyan
DISM /Online /Cleanup-Image /CheckHealth

Write-Host "`n=== SFC VERIFY-ONLY (read-only, several minutes) ===" -ForegroundColor Cyan
sfc /verifyonly
```

---

## Appendix B — Data Handling

This report was sanitized before saving. The following were **collected during the audit but deliberately excluded** from this document: machine hostname, the primary account's login name and SID, Wi-Fi SSID, all MAC addresses, all IPv4/IPv6 addresses and the DNS server address, disk/BIOS serial numbers, and the product key / activation ID. No passwords, tokens, keys, or personal file contents were accessed or recorded. Where a value was needed for context it is shown generically (e.g. `<USER>`, `<HOSTNAME>`, "external(redacted)").

In a later pass, specific device model, CPU model, RAM/SSD brand and exact BIOS build strings were **generalized to a hardware class** (e.g. "HP EliteBook-class business laptop", "Intel 6-core / 12-thread mobile CPU", "~1 TB NVMe SSD") to reduce device fingerprinting. Capability, capacity, driver-version and security-posture detail is unchanged. The exact BIOS level and full firmware-package analysis remain in `PRE_FIRMWARE_VALIDATION.md`, where they are load-bearing for the HOLD decision.

*End of report.*
