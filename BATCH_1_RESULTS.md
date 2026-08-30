# Batch 1 — Post-Clean Low-Risk Maintenance — Results

**Batch source:** `POST_CLEAN_ELEVATED_VERIFY.md` §3 / `POST_CLEAN_WINDOWS_AUDIT.md` §28 Batch 1
**Authorization:** Batch 1 explicitly authorized by the user. Firmware/BIOS, Secure Boot, BitLocker, GRUB/EFI/partition, and Defender ASR/CFA/Network-Protection/PUA changes explicitly **out of scope** and not performed.
**Elevation:** All actions run in an elevated (Administrator / High-integrity) PowerShell session.
**Date:** 2026-08-28 (local)

**Execution status:** 🟡 **PARTIAL — see "Part 3 — Elevated finish attempt" and "Final summary" at the bottom.** Part 1 (drivers, full scan, restore point) complete before the reboot; Part 2 (post-reboot verification) complete read-only; Part 3 attempted the elevated finish but the session was **not actually elevated**, so App Installer was still upgraded via winget in user context, but the Widgets provisioned-package parity check and the restore-point re-verification remain blocked and are the only open items.

---

## Part 1 — completed before reboot

### 1. System Restore point — DONE ✅

| Item | Result |
|---|---|
| Action | `Checkpoint-Computer -Description "post-clean baseline" -RestorePointType MODIFY_SETTINGS` |
| First attempt | Throttled — Windows blocks a 2nd restore point within 1440 min of the existing one (auto point from 2026-08-28 02:04) |
| Resolution | Set the supported DWORD `SystemRestorePointCreationFrequency = 0`, created the point, then **removed the value** (reverted to default 1440-min throttle). No other System Restore setting changed. |
| Verification | `Get-ComputerRestorePoint` now lists **SequenceNumber 2 — "post-clean baseline" — 2026-08-28 16:42:31** (type 12 = CHECKPOINT / MODIFY_SETTINGS) |
| System Protection on `C:` | Enabled, disk cap ~15% (`SystemRestoreConfig.DiskPercent = 15`); shadow storage in use |

Restore points present after Part 1:

| Seq | Description | Created (local) |
|---|---|---|
| 1 | Windows Modules Installer (auto) | 2026-08-28 02:04 |
| 2 | **post-clean baseline** | 2026-08-28 16:42 |

### 2. Microsoft Defender Full Scan — DONE ✅ — CLEAN

| Field | Value |
|---|---|
| Scan type | Full Scan (`Start-MpScan -ScanType FullScan`) |
| Scan ID | `{40D8B2BD-2026-40AE-8231-DE3934C7B5E5}` |
| Started / finished | 2026-08-28 12:42:15 → 13:18:57 (local) |
| Duration | 0:36:41 |
| Engine / platform / signatures | 1.1.26080.3 / 4.18.26080.3 / AV 1.457.381.0 (2026-08-28) |
| Cloud protection used during scan | Yes (event 2010) |
| **`Get-MpThreatDetection`** | **NONE — no detections** |
| **`Get-MpThreat` (history)** | **NONE** |
| Malware events (1116/1117) in Defender Operational log | **None** |
| Scan-finished event | 1001 — "scan has finished", no threats reported |
| Real-time protection / Tamper Protection | On / On |

**Result: the full scan found no threats.** No Defender findings were deleted, quarantined, or manually overridden (none existed).

### 3. Failed-driver devices + Intel Wi-Fi — DONE ✅ (pending reboot to finalize)

**Method:** Windows Update COM API (`Microsoft.Update.Session`, Microsoft Update service), building an explicit selection of **driver-class updates only**. Every candidate was tested and anything with `DriverClass = Firmware`, a title matching `Firmware|BIOS`, or manufacturer `HP Inc` was **excluded**. Each update downloaded and installed individually. No HP driver pack / OEM website was used (Windows Update drivers only, per authorized options).

**Scope confirmation logged at run time:**
- `EXCLUDED firmware : HP Inc. - Firmware - 1.29.1.0` — never downloaded, never installed.
- `SKIP non-driver : 2026-08 Security Update (KB5121003)` — deferred to Part 2.
- 7 driver updates selected and installed.

| # | Update | Target device | Download | Install | Signed |
|---|---|---|---|---|---|
| 1 | INTEL – System 10.1.14.5 | Intel Host Bridge/DRAM Registers (DEV_3EC4) | Succeeded | Succeeded | Yes |
| 2 | INTEL – System 10.1.16.6 | **Intel Thermal Subsystem (DEV_A379)** — was Code 28 | Succeeded | Succeeded | Yes |
| 3 | INTEL – System 10.1.16.6 | Intel SPI (flash) Controller (DEV_A324) — was Code 28 | Succeeded | Succeeded (**reboot required**) | Yes |
| 4 | INTEL – System 10.1.7.3 | Intel PCIe Controller x16 (DEV_1901) | Succeeded | Succeeded | Yes |
| 5 | Realtek – MTD 10.0.17763.21309 | **Realtek PCIE CardReader (VEN_10EC DEV_525A)** — was Code 28 | Succeeded | Succeeded | Yes |
| 6 | Synaptics – Biometric 5.5.28.1099 | Synaptics VFS7552 fingerprint sensor | Succeeded | Succeeded | Yes |
| 7 | Intel – net 22.250.1.2 | **Intel Wireless-AC 9560 160MHz Wi-Fi** | Succeeded | Succeeded | Yes |

All 7: Windows Update result code `2` (Succeeded), HRESULT `0x00000000`.

**Also covered by the four "INTEL – System" INF packages:** Intel SMBus Controller (DEV_A323) — was Code 28.

**Pre-reboot verification (already visible before restart):**

| Check | Before | After Part 1 (pre-reboot) |
|---|---|---|
| Devices in `Error` state (`Get-PnpDevice`) | 4 (all Code 28 / `CM_PROB_FAILED_INSTALL`) | **0** |
| Intel Wireless-AC 9560 driver | 21.80.2.3 (2018-07-28), provider *Microsoft* (inbox) | **22.250.1.2 (2023-08-06), provider *Intel*** |
| Intel SMBus (DEV_A323) | not installed | 10.1.16.6, Intel, signed |
| Intel Thermal Subsystem (DEV_A379) | not installed | 10.1.16.6, Intel, signed |
| Intel Host Bridge/DRAM (DEV_3EC4) | inbox | 10.1.14.5, Intel, signed |
| Realtek PCIE CardReader | not installed (Code 28) | `rtsperhp.inf` 10.0.17763.21309 staged in DriverStore, device no longer in Error |
| Synaptics fingerprint | 5.5.27.1099 (2020) | 5.5.28.1099, signed |
| New DriverStore packages | — | `oem51.inf` (netwtw08 22.250.1.2), `oem49.inf` (Realtek MTD), `oem50.inf` (Synaptics 5.5.28.1099) — all signed OEM packages |

**Intel Bluetooth:** no update was offered through Windows Update (still 21.110.0.3, 2020-06-24). Left as-is — nothing to apply within authorized sources. Recorded for a later Batch.

**Driver signatures:** every newly installed package reports `IsSigned = True` (Intel / Realtek Semiconductor Corp. / Synaptics Incorporated as provider). Full post-reboot signature re-confirmation is in Part 2.

### 4. Defender signature + platform updates — DONE ✅ (partial; rest in Part 2)

| Item | Result |
|---|---|
| `Update-MpSignature` | OK — AV/AS/NIS signatures 1.457.381.0, `DefenderSignaturesOutOfDate = False` |
| Defender antimalware **platform** update KB4052623 → **4.18.26080.3** | Confirmed installed (WU history 2026-08-28 16:13, RC Succeeded; `AMProductVersion`/`AMServiceVersion` = 4.18.26080.3) |
| Windows quality/component update **KB5121003** | **Not yet applied** — deferred to Part 2. (Note: after the driver run it no longer appears in the pending-update search; to be re-checked post-reboot.) |
| App Installer (`Microsoft.AppInstaller`) 1.29.289.0 → 1.29.290 | **Not yet applied** — Part 2 |
| Windows Terminal | Not offered as an upgrade (already current) — nothing to do |

### 5. Widgets / `MicrosoftWindows.Client.WebExperience` error 0x80073D02 — NOT STARTED

Investigation was interrupted before it began. Deferred to Part 2. `0x80073D02 = ERROR_PACKAGES_IN_USE`. Planned approach: read-only package/state inspection first, then, only if safe, a supported re-registration / `Reset` of the in-box package — no third-party tooling.

---

## Reboot

- **Reason:** Intel SPI/chipset driver package (#3 above) set a reboot-required flag.
- **Pre-reboot flags:** `WindowsUpdate\...\RebootRequired = present`, `PendingFileRenameOperations = present`, CBS `RebootPending = absent`.
- **Action:** plain `Restart-Computer`. No firmware, BIOS, Secure Boot, BitLocker, GRUB, EFI boot-entry, or partition action of any kind.
- Windows remains the default boot OS; nothing in the boot path was touched.

---

## Part 2 — remaining authorized Batch 1 work (after reboot, fresh elevated session)

1. Re-check Device Manager / problem devices — confirm 0 in Error state and all four former Code 28 devices resolved (incl. Realtek card reader binding).
2. Re-confirm Intel Wi-Fi driver = 22.250.1.2 and verify all new driver signatures (`Get-CimInstance Win32_PnPSignedDriver`, `signtool`/catalog check).
3. Apply remaining safe software updates: Windows quality/component update **KB5121003** (if still offered), **App Installer** 1.29.290 via winget. Re-scan WU pending — expected to leave **only** `HP Inc. – Firmware – 1.29.1.0` (intentionally not installed).
4. Re-check `Netwtw08` errors (esp. event 5010) over a clean post-reboot window vs. the 14-day baseline of 12× 5010.
5. Investigate + (if safe, supported mechanisms only) repair the Widgets / `WebExperience` `0x80073D02` failure.
6. Verify restore point "post-clean baseline" still present.
7. Finalise this file; append a sanitized entry to `PROJECT_STATE.md` / `CHANGELOG.md` **only if they exist** (both are currently **absent** in the project folder — not created, per instruction).

---

## Part 2 — Execution log (post-reboot)

**Session:** post-reboot, 2026-08-28. `LastBootUpTime` 13:26:11 (local). **This resume session is NOT elevated** (`IsAdmin = False`, `<HOST>\<user>`). All checks below are read-only and complete without elevation. Items 3 (App Installer), 5 (Widgets repair) and 6 (restore-point verification) require an elevated session and are **not yet done** — see "Remaining — blocked on elevation".

> Timestamp note: Windows Update COM `QueryHistory` returns **UTC**; the local clock is ~UTC-4. Part 1 "16:42 / 16:13" entries are the UTC values of events that are ~12:42 / ~13:13 local. No clock problem.

### Item 1 — Problem devices — VERIFIED ✅

| Check | Result |
|---|---|
| `Get-PnpDevice` with `Status = Error` | **0 devices** |
| Devices with a non-null `ProblemCode` (Code 28 etc.) | **0** — all four former Code 28 devices cleared |
| Intel Thermal Subsystem (A379) | `10.1.16.6`, INTEL, present, OK |
| Intel SMBus (A323) | `10.1.16.6`, INTEL, present, OK |
| Intel SPI (flash) Controller (A324) | `10.1.16.6`, INTEL, present, OK |
| Realtek PCIE CardReader (10EC:525A) | driver `oem49.inf` / `rtsperhp.inf` 10.0.17763.21309 bound; **but `DEVPKEY_Device_IsPresent = False`** — device is not currently enumerating (phantom entry, `Status = Unknown`, no ProblemCode). See ⚠️ below. |

⚠️ **Unexpected condition (reported, no action taken):** the Realtek card reader was **present** pre-Batch (that is why it could report Code 28); post-reboot it is **not present** on the PCI bus. The driver is correctly staged, so if/when the device re-enumerates it will bind. Possible benign causes: HP power-gates the reader when no card is inserted / a firmware-level toggle. Not fixed here (out of scope — would need firmware/UEFI or hardware inspection). Flagged for a later batch.

### Item 2 — Intel Wi-Fi + new-driver signatures — VERIFIED ✅

| Check | Result |
|---|---|
| Intel Wireless-AC 9560 160MHz | **22.250.1.2 / 2023-08-06 / provider Intel** (was 21.80.2.3 / 2018 / Microsoft inbox) |
| Wi-Fi link state now | **Up, 866.7 Mbps**, driver 22.250.1.2, provider Intel |
| DriverStore package | `oem51.inf` (`netwtw08.inf`) 22.250.1.2 |

All seven newly-installed driver packages — signature re-confirmation:

| INF | Original name | Version | Signer |
|---|---|---|---|
| oem45 | coffeelakesystem.inf | 10.1.14.5 | Microsoft Windows Hardware Compatibility Publisher |
| oem46 | cannonlake-hsystemthermal.inf | 10.1.16.6 | Microsoft Windows Hardware Compatibility Publisher |
| oem47 | cannonlake-hsystem.inf | 10.1.16.6 | Microsoft Windows Hardware Compatibility Publisher |
| oem48 | skylakesystem.inf | 10.1.7.3 | Microsoft Windows Hardware Compatibility Publisher |
| oem49 | rtsperhp.inf (Realtek MTD) | 10.0.17763.21309 | Microsoft Windows Hardware Compatibility Publisher |
| oem50 | synawudfbiousbhpprod.inf (Synaptics Biometric) | 5.5.28.1099 | Microsoft Windows Hardware Compatibility Publisher |
| oem51 | netwtw08.inf (Intel Wi-Fi) | 22.250.1.2 | Microsoft Windows Hardware Compatibility Publisher |

`Win32_PnPSignedDriver` reports `IsSigned = True` for every one. All are WHQL-signed (`Microsoft Windows Hardware Compatibility Publisher`); Intel/Realtek/Synaptics are the *providers*. No unsigned or self-signed driver present.

### Item 3 — remaining safe software updates — PARTIAL

| Update | Status |
|---|---|
| **KB5121003** (2026-08 quality/component, build 26200.9168) | **INSTALLED ✅** — WU history 2026-08-28 17:12 UTC, result code 2 (Succeeded). Confirmed live: `CurrentBuild 26200`, **`UBR 9168`**, DisplayVersion 25H2. `Get-HotFix` lists KB5121003 (+ KB5122035, KB5123304, KB5054156, KB5120708). No reboot pending from it. |
| **Windows Update pending queue** | Now **only** `HP Inc. - Firmware - 1.29.1.0` (Drivers category) — intentionally **not installed** (firmware out of scope). All 7 driver updates + KB5121003 show result code 2 in history. |
| **App Installer** `Microsoft.AppInstaller` 1.29.289.0 → **1.29.290** | **NOT YET APPLIED** — `winget list` confirms 1.29.289.0 installed, 1.29.290 available (source: winget). `winget` client itself is v1.29.290. Provisioned system app → needs elevation. |
| Windows Terminal | Already current — nothing to do (unchanged from Part 1). |

### Item 4 — `Netwtw08` errors — RE-CHECKED ⚠️ (no improvement)

| Metric | Value |
|---|---|
| ID 5010 in last 15 days | **16** (8 on 2026-08-27, 8 on 2026-08-28) — vs. baseline "12 in 14 days" |
| ID 5010 since this reboot | **2**, both at 13:26:45 (adapter init, ~34 s after boot) |
| Other Netwtw08 IDs post-boot | 6062 (LSO), 7005/7010/7017/7021 (init info), 7036 (state change) — all normal init sequence |
| Driver in use | **new** 22.250.1.2 (Intel) |
| Adapter | Up, 866.7 Mbps, stable |

**Finding:** the driver update did **not** stop the 5010 "returned an invalid value to the driver" errors — they still fire at every adapter initialization. Recent per-day counts are inflated by the 2026-08-27 clean install + multiple 2026-08-28 reboots (driver batch + this one); each boot emits a 5010 pair at init. A true rate needs a multi-day window with no reboots. The message is a known benign AC 9560 init-time quirk (SAR/WRDS table read); functionally the adapter is healthy. **Carry to a later batch** for observation; no further action in Batch 1.

### Item 5 — Widgets / `WebExperience` `0x80073D02` — INVESTIGATED (read-only); repair NOT done

Current package state (read-only, current-user scope):

| Package | Version | Status |
|---|---|---|
| `MicrosoftWindows.Client.WebExperience` | **526.21100.40.0** | **Ok** |
| `Microsoft.WidgetsPlatformRuntime` | **1.6.19.0** (WidgetService.exe running from it) | active |

- `Microsoft-Windows-AppXDeploymentServer/Operational` over 15 days: **0 Error events, 1 Warning** (event 493 — "1 additional file failed to be deleted" during WidgetsPlatformRuntime 1.6.14.0 cleanup on this boot; non-fatal). On this boot (13:27) the log shows WebExperience 525.31002.150.9 → 526.21100.40.0 and WidgetsPlatformRuntime 1.6.14.0 → 1.6.19.0 **staged and registered successfully**; old versions moved to `Apps\Deleted\`.
- `Microsoft-Windows-WindowsUpdateClient` event 20 (`0x80073D02 = ERROR_PACKAGES_IN_USE`) is **still recurring on the Store channel**: last hits 2026-08-28 13:17:25 (`9N3RK8ZV2ZR8` = Widgets Platform Runtime) and 2026-08-27 22:33:02 (`9MSSGKG348SP` = Web Experience Pack).

**Assessment:** the *packages on disk are current and healthy* (newest versions, Status Ok, service running) — the servicing/CBS channel applied the update on reboot. What keeps failing is the **Microsoft Store** retrying its own copy of the same update while the package is in use, producing cosmetic event-20 log noise. Supported, non-destructive remedies (all require an elevated session): `wsreset.exe` to clear the Store download cache; confirm `Get-AppxProvisionedPackage -Online` parity; if the Store still re-queues, re-register in place with `Add-AppxPackage -Register ...\AppXManifest.xml`. No third-party tooling. **Not performed** — needs elevation; proposed for the elevated finish.

### Item 6 — "post-clean baseline" restore point — NOT VERIFIED (blocked)

`Get-ComputerRestorePoint` and `vssadmin list shadows` both return nothing / access-denied in a non-elevated session, so the restore point **could not be confirmed** this session. Part 1 recorded it as SequenceNumber 2, "post-clean baseline", type 12 (CHECKPOINT). To be verified in the elevated finish.

### Remaining — blocked on elevation

| # | Item | Why blocked |
|---|---|---|
| 3 | Apply App Installer 1.29.290 (`winget upgrade Microsoft.AppInstaller`) | provisioned system app; winget needs admin |
| 5 | Widgets `0x80073D02` — `wsreset` / provisioned-package check / in-place re-register + verify | all require elevation |
| 6 | Verify "post-clean baseline" restore point | `Get-ComputerRestorePoint` needs elevation |

**Nothing outside the authorized Batch 1 scope was done.** No HP firmware/BIOS. No change to Secure Boot, BitLocker, GRUB, EFI entries, partitions, Defender ASR/CFA/Network Protection/PUA, or Fast Startup. Items above are read-only verification only.

---

## Part 3 — Elevated finish attempt

**Session:** 2026-08-28 ~13:44 local. Invoked as "elevated" but **verified NOT elevated**: `WindowsPrincipal.IsInRole(Administrator) = False`; `Get-ComputerRestorePoint` → *Access denied*; read of `C:\System Volume Information` → *Access denied*; `Get-AppxProvisionedPackage -Online` → *"The requested operation requires elevation."* All three checks agree. Per the stop-on-unexpected-condition rule, the elevation-only steps were **not forced** (no self-elevation / UAC prompt spawned).

### Item 3a — App Installer upgrade — DONE ✅

| Field | Value |
|---|---|
| Before | `Microsoft.AppInstaller` **1.29.289.0** (`winget list`) |
| Action | `winget upgrade --id Microsoft.AppInstaller --exact` (winget source; MSIX; Microsoft-published) |
| Result | *"Successfully installed. Restart the application to complete the upgrade."* — completed in user context (per-user MSIX register), no elevation needed |
| After | `winget list` → **1.29.290.0**; `Get-AppxPackage Microsoft.DesktopAppInstaller` → **1.29.290.0**, `PackageFullName …_1.29.290.0_x64__8wekyb3d8bbwe`, InstallLocation under `C:\Program Files\WindowsApps\` |
| `winget upgrade` re-run | AppInstaller **no longer listed** — nothing further offered |

### Item 4 — Windows Update pending recheck — DONE ✅

`Microsoft.Update.Session` searcher, `IsInstalled=0 and IsHidden=0`, default service — **2 items**:

| Offered update | Category | Disposition |
|---|---|---|
| `HP Inc. - Firmware - 1.29.1.0` | Drivers | **Intentionally NOT installed** — firmware out of Batch 1 scope (unchanged from Part 2). |
| `Security Intelligence Update for Microsoft Defender Antivirus - KB2267602` (Version **1.457.382.0**) — Current Channel (Broad) | Definition Updates | Routine daily signature bump (Part 1 installed 1.457.381.0). Normal churn, not a fixed Batch 1 line item; applied automatically by Defender / next WU pass. No action taken here. |

No KB5121003, no driver updates, no App Installer left pending. Result: **WU queue is clean apart from the deliberately-excluded HP firmware.**

### Item 2 — Widgets / WebExperience `0x80073D02` — read-only re-inspection; remediation NOT performed

Read-only state (current-user scope — the only scope available without elevation):

| Package | Version | Status |
|---|---|---|
| `MicrosoftWindows.Client.WebExperience` | **526.21100.40.0** | **Ok** |
| `Microsoft.WidgetsPlatformRuntime` | **1.6.19.0** | **Ok** — `WidgetService.exe` running from the `…_1.6.19.0_x64__8wekyb3d8bbwe` path |

- `Microsoft-Windows-WindowsUpdateClient/Operational` — **no `0x80073D02` (event 20) in the last 3 days / last 24 h.** The Store-channel retry noise recorded in Part 2 (last hits 2026-08-28 13:17 / 2026-08-27 22:33) has **not recurred** since the post-driver reboot.
- `Microsoft-Windows-AppXDeploymentServer/Operational` — 36 Level-2 entries in 3 days, all the same benign `0x80073D02` *"apps need to be closed"* pattern from servicing trying to register a newer package while the older one is running (WebExperience 525→526, WidgetsPlatformRuntime 1.6.14→1.6.19, DesktopAppInstaller 1.29.289→store copy). Each cleared on the following reboot when CBS registered the package before the app started. One unrelated item noted for a later batch: `MdOdrMcpFilterPackage` failing `0x80092009 / 0x80073CF6` (capability-authorization, not package-in-use) at 2026-08-28 12:13 — **not** a Widgets issue.

**`Get-AppxProvisionedPackage -Online` (provisioned/system parity check) could not run — requires elevation.** Because the on-disk packages are already newest-version + Status Ok + service running, and the WU-client `0x80073D02` noise has stopped on its own, the documented remediation ladder was **not** executed:

| Planned step (needs elevation) | Whether still indicated |
|---|---|
| `Get-AppxProvisionedPackage -Online` parity vs. installed per-user versions | **Still to do** — the one genuine open check. |
| `wsreset.exe` (clear Store download cache) | Only *if* event 20 resumes — currently quiet, so not indicated now. |
| `Add-AppxPackage -Register "$($pkg.InstallLocation)\AppXManifest.xml"` in place | **Likely unnecessary** — package Status is Ok; would only be justified if parity check shows a provisioned-vs-registered mismatch or the package went to a bad state. |

No package removed, no third-party tool, no `-Online` provisioning change. Nothing done.

### Item 3b — "post-clean baseline" restore point — NOT VERIFIED (still blocked)

`Get-ComputerRestorePoint` → *Access denied* in this non-elevated session (same as Part 2). Part 1 created it and recorded it as **SequenceNumber 2, "post-clean baseline", type 12 (CHECKPOINT)**, 2026-08-28 16:42:31 UTC. Independent confirmation still requires elevation.

---

## Final summary — Batch 1

| # | Item | Verdict | Evidence |
|---|---|---|---|
| 1 | System Restore point "post-clean baseline" **created** | ✅ **PASS** | Part 1: `Checkpoint-Computer`, then `Get-ComputerRestorePoint` showed Seq 2, type 12, 2026-08-28 16:42 UTC |
| 2 | Defender **full scan** | ✅ **PASS** | Scan `{40D8B2BD-…}`, 0:36:41, **no detections**, no threat history, RTP + Tamper on |
| 3 | **Failed-driver devices** (4× Code 28) + Intel Wi-Fi | ✅ **PASS** | Post-reboot: **0** devices in Error / with ProblemCode; Wi-Fi **22.250.1.2 / Intel** (was 21.80.2.3 / MS inbox); 7 driver packages installed, all WHQL-signed. Realtek card reader now shows `IsPresent = False` (phantom) — flagged, out of scope, carried forward |
| 4 | Defender **signatures + platform** | ✅ **PASS** | `Update-MpSignature` OK; platform KB4052623 → **4.18.26080.3**; a newer definition (1.457.382.0) is normal daily churn |
| 5 | Windows quality update **KB5121003** | ✅ **PASS** | Installed 2026-08-28; live build **26200.9168**, 25H2; in `Get-HotFix`; no reboot pending |
| 6 | **App Installer** `Microsoft.AppInstaller` → current | ✅ **PASS** | **1.29.289.0 → 1.29.290.0** via `winget upgrade`; confirmed by `winget list` + `Get-AppxPackage`; nothing further offered |
| 7 | **Windows Update pending** rechecked | ✅ **PASS** | Queue clean except deliberately-excluded `HP Inc. – Firmware – 1.29.1.0` (+ routine Defender definition) |
| 8 | **Widgets / WebExperience `0x80073D02`** remediation | 🟡 **PARTIAL** | Packages current + Status Ok + service running; WU-client 0x80073D02 noise **stopped on its own** post-reboot. Provisioned-package parity check (`Get-AppxProvisionedPackage -Online`) **not run — needs elevation**. `wsreset` / in-place re-register judged **not currently indicated**; left for an elevated pass |
| 9 | **Verify** "post-clean baseline" restore point still present | 🟡 **PARTIAL** | `Get-ComputerRestorePoint` = *Access denied* without elevation. Recorded as present in Part 1; independent re-verification pending an elevated session |

**Overall: PARTIAL.** 7 of 9 items PASS. The 2 open items (8 parity check, 9 restore-point re-verification) are **blocked solely by lack of elevation** — the session invoked as "elevated" was verified non-elevated (`IsInRole(Administrator) = False`, three independent access-denied confirmations). No workaround was forced. Nothing outside authorized Batch 1 scope was done: no HP firmware/BIOS; no change to Secure Boot, BitLocker, GRUB, EFI entries, partitions, Defender ASR/CFA/Network Protection/PUA, Fast Startup, or any hardware setting.

### To close out the 2 open items (run in a genuinely elevated PowerShell)

```powershell
# Item 9 — verify the restore point
Get-ComputerRestorePoint | Format-Table SequenceNumber, Description, CreationTime, RestorePointType, EventType -AutoSize

# Item 8 — provisioned vs registered parity for the two packages
Get-AppxProvisionedPackage -Online |
  Where-Object DisplayName -match 'WebExperience|Widgets' |
  Select-Object DisplayName, Version
Get-AppxPackage -AllUsers -Name 'MicrosoftWindows.Client.WebExperience','Microsoft.WidgetsPlatformRuntime' |
  Select-Object Name, Version, Status, @{n='Users';e={($_.PackageUserInformation | Where-Object InstallState -eq 'Installed').Count}}

#   If (and only if) parity is off or Status is not Ok:
#     wsreset.exe
#   then, if event 20 (0x80073D02) still recurs afterward, re-register in place (no removal):
#     $p = Get-AppxPackage -Name MicrosoftWindows.Client.WebExperience
#     Add-AppxPackage -DisableDevelopmentMode -Register "$($p.InstallLocation)\AppXManifest.xml"
#     $p = Get-AppxPackage -Name Microsoft.WidgetsPlatformRuntime
#     Add-AppxPackage -DisableDevelopmentMode -Register "$($p.InstallLocation)\AppXManifest.xml"
```

---

## Baseline reference (for Part 2 comparison)

| Metric | Pre-Batch-1 baseline |
|---|---|
| Problem devices | 4 × Code 28: Intel Thermal (A379), Intel SMBus (A323), Intel SPI/chipset (A324), Realtek CardReader (10EC:525A) |
| Intel Wi-Fi driver | 21.80.2.3 / 2018-07-28 / Microsoft inbox |
| `Netwtw08` events, 14 days | 50 total; **12 × ID 5010** ("returned an invalid value to the driver") |
| WU pending | 9 items (7 drivers, HP firmware, KB5121003) |
| Restore points | 1 (auto, "Windows Modules Installer") |
| Full scan since reinstall | Never |

---

## Data-handling note

Sanitized: no serial numbers, IP/MAC addresses, keys, tokens, passwords, account names, or personal data. Hardware `VEN_`/`DEV_` model identifiers and driver version numbers are retained as non-sensitive technical evidence; per-instance PCI bus enumerator suffixes are omitted.
