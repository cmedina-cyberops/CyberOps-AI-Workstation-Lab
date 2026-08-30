# PRE_FIRMWARE_VALIDATION.md

**Subject:** HP EliteBook 1050 G1 — read-only validation of pending Windows Update item
`HP Inc. - Firmware - 1.29.1.0`
**Date:** 2026-08-28
**Scope:** READ ONLY. No firmware downloaded, staged, flashed, modified, or hidden. No update executed.
**Classification of this task:** READ ONLY (diagnostic). Any subsequent install is **HIGH-RISK / BACKUP REQUIRED**.

---

## 1. Current BIOS (Win32_BIOS / Get-ComputerInfo)

| Field | Value |
|---|---|
| Manufacturer | HP |
| SMBIOSBIOSVersion / Name | `Q72 Ver. 01.29.01` |
| BIOSVersion array | `HPQOEM - 0`, `Q72 Ver. 01.29.01`, `HP - 11D01` |
| Internal version | `HPQOEM - 0` |
| ReleaseDate | 2024-09-23 |
| PrimaryBIOS | True |
| BiosFirmwareType | UEFI |
| SMBIOS | 3.1 |
| Serial number | _[redacted]_ |

Running BIOS = **Q72 01.29.01**, build date **2024-09-23**.

---

## 2. Firmware / UEFI devices (Get-PnpDevice -Class Firmware, Win32_PnPEntity, Win32_PnPSignedDriver)

| Device | Instance / Hardware ID | Driver (INF) | Driver version | Notes |
|---|---|---|---|---|
| System Firmware | `UEFI\RES_{96E58EF2-2114-48C1-B1DE-1A596272494E}\0` — HWID `...&REV_12901` | `c_firmware.inf` (Microsoft) | 10.0.26100.4768 | Wrapper only. `REV_12901` = firmware-resource revision **1.29.01**. Status OK, Present. |
| Microsoft UEFI-Compliant System | `ACPI_HAL\UEFI\0` | `uefi.inf` (Microsoft) | 10.0.26100.8972 | Inbox. |
| ACPI-Compliant Embedded Controller | `ACPI\PNP0C09\1` | `machine.inf` (Microsoft) | 10.0.26100.1150 | EC firmware version not exposed to Windows. |
| Intel(R) Management Engine Interface #1 | `PCI\VEN_8086&DEV_A360&SUBSYS_84E9103C` | `oem28.inf` (Intel, MEIx64) | 2452.7.1.0 (2024-12-21) | Interface **driver**, not ME firmware. |
| Intel(R) Management Engine WMI Provider | `SWC\06657A6D-...` | `oem40.inf` (Intel) | 2408.5.4.0 (2024-02-20) | Software component. |
| UCM-UCSI ACPI Device (USB-C connector mgr) | `ACPI\USBC000\1` (Class UCM) | Microsoft inbox | 10.0.26100.8972 | Cypress/Infineon **CCG5** PD controller sits behind this; its firmware version is **not** surfaced by Windows. |

**Intel ME firmware version** (`root\Intel_ME` → `ME_System.FWVersion`): **`12.0.95.2489`**
ManageabilityMode 2 (AMT), CryptoFuseEnabled True, HealthState 5.

**Secure Boot:** `Confirm-SecureBootUEFI` = **False (disabled)**.
**BitLocker:** Off (per task input).

---

## 3. Pending Windows Update item — full metadata

Source: `Microsoft.Update.Session` COM searcher, `IsInstalled=0` (read-only online search).

| Field | Value |
|---|---|
| Title | `HP Inc. - Firmware - 1.29.1.0` |
| Type | 2 = **Driver** |
| Categories | Drivers |
| Driver class | **Firmware** |
| Manufacturer / Provider | HP Inc. / HP Inc. |
| Driver model | `HP Q72 System Firmware` |
| Driver hardware ID | `uefi\res_{96e58ef2-2114-48c1-b1de-1a596272494e}` (base system-firmware resource GUID; **no REV floor advertised in metadata**) |
| Driver version | `1.29.1.0` |
| Driver date | 2024-09-24 |
| Description | "HP Inc. Firmware driver update released in September 2024" |
| Update identity (UpdateID) | `56869ddb-5ee4-4d2b-b593-b0d1bb3e5842` |
| Revision number | 1 |
| DeploymentAction | 1 = Installation |
| IsMandatory / IsBeta / IsUninstallable | False / False / **False** |
| AutoSelectOnWebSites | False |
| RebootRequired flag | False *(firmware application still forces a reboot cycle regardless of this flag)* |
| KBArticleIDs / SecurityBulletinIDs | none / none |
| MoreInfoUrls | generic MS hardware-dashboard support link only |
| MaxDownloadSize | **12,723,678 bytes (~12.1 MiB)** |
| BundledUpdates | 0 (single package, one payload) |
| Payload host | `tlu.dl.delivery.mp.microsoft.com` (WU / Delivery Optimization CDN) — signed URL _[token redacted]_ |

### What it maps to
- Targets the **System Firmware resource** `{96E58EF2-2114-48C1-B1DE-1A596272494E}` — HP's **combined platform firmware package** for the Q72 board.
- On this platform HP delivers it via the **"HP BIOS Update" UEFI mechanism**, not a Microsoft UEFI capsule:
  - no `HKLM\SYSTEM\CurrentControlSet\Control\FirmwareResources` (ESRT) registry key present,
  - no `\EFI\UpdateCapsule\` directory,
  - install path is staging `.bin` files into `\EFI\HP\BIOS\New` and `\EFI\HP\DEVFW`, applied by the HP flash app on next boot.
- The package scope for this model = **System BIOS + Intel ME + CCG5 USB-C PD controller** (and EC where applicable) under one WU "Firmware" item.
- Download size (~12.1 MiB) is close to the on-disk **ME image size** (11.7 MiB) and far below a full 16 MiB BIOS image — see Inferences.

---

## 4. Current firmware driver versions (summary)

| Component | Installed / running | How obtained |
|---|---|---|
| System BIOS | Q72 **01.29.01** (2024-09-23) | Win32_BIOS |
| Firmware resource revision | `REV_12901` (= 1.29.01) | System Firmware PnP HWID |
| System Firmware wrapper driver | 10.0.26100.4768 (`c_firmware.inf`) | Win32_PnPSignedDriver |
| Intel ME firmware | **12.0.95.2489** | `root\Intel_ME` `ME_System.FWVersion` |
| Intel MEI driver | 2452.7.1.0 (2024-12-21) | Win32_PnPSignedDriver |
| CCG5 USB-C PD firmware | present; **version not OS-visible** | UCM-UCSI node only |
| EC firmware | present; **version not OS-visible** | ACPI\PNP0C09 node only |

---

## 5. EFI\HP firmware directories (read-only inspection)

ESP = Disk 0, Partition 1, GPT type `{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}` (System), FAT32, label `BOOT`, ~495 MB, no drive letter. Shared ESP — also holds `\EFI\Microsoft`, `\EFI\Boot`, and `\EFI\kali\grubx64.efi` (Kali dual boot present). Inspected via volume-GUID path; **no mount point created, nothing written**.

### `\EFI\HP\BIOS\`
| Path | Size | Timestamp | Meaning |
|---|---|---|---|
| `Previous\Q72_012800.bin` | 16,777,216 B | 2024-12-02 12:56 | Prior BIOS level **01.28.00** (rollback image) |
| `Current\Q72_012901.bin` | 16,777,216 B | 2024-12-02 12:57 | **01.29.01** = currently running version |
| `New\` | *(empty)* | dir 2024-12-02 | **No BIOS image staged for flash** |

### `\EFI\HP\DEVFW\`
| Path | Size | Timestamp | Meaning |
|---|---|---|---|
| `ME.bin` | 12,230,656 B | 2024-12-02 12:57 | Intel ME firmware image (contains `FTPR` partition marker) |
| `CCG5.bin` | 132,096 B | 2024-12-02 13:00 | Cypress/Infineon **CCG5** USB-C PD controller firmware (`Cypress` strings present) |

All staged artifacts are dated **2024-12-02** — the *previous* Windows installation's firmware run that moved the box **01.28.00 → 01.29.01**. No 2026-dated firmware artifacts. `New\` empty **and** no `\EFI\UpdateCapsule` ⇒ **no firmware flash is currently armed or pending.**

---

## 6. Installed state vs offered `1.29.1.0`

| Item | Installed / running | Offered WU package | Delta |
|---|---|---|---|
| System BIOS | Q72 **01.29.01**, build 2024-09-23 | `1.29.1.0`, driver date 2024-09-24, "Sept 2024" | **Same version** |
| FW resource revision | `REV_12901` | targets resource GUID, no REV floor in metadata | **Same / not raised** |
| Intel ME firmware | `12.0.95.2489` | bundled; sub-version **not exposed** by WU | **Unknown** |
| CCG5 USB-C PD firmware | present; not OS-visible | bundled; sub-version **not exposed** | **Unknown** |
| Staged for flash | none (`New\` empty) | would stage `.bin` files on install | n/a |
| Payload size | — | 12,723,678 B (~ ME-image sized) | payload ≠ full BIOS-only |
| HP public docs | list 01.29.01 as current | — | consistent, no newer level published |
| Local WU install history | **0** firmware/BIOS/HP-firmware installs in 76 entries | — | clean reinstall wiped prior record |

**Why it is still offered:** the recent clean Windows reinstall erased the WU install history (confirmed: 76 history entries, none for firmware/BIOS — only a set of Dec-2024 `.bin` files left on the ESP by the old OS). With no local record that resource `{96E58EF2…}` was serviced, and the HP firmware driver still ranking as applicable to the System Firmware PnP node, WU re-advertises the model's last-published package. Expected post-reinstall behaviour — not evidence of a downgrade or of missing firmware.

---

## 7. Classification

- **Primary: B — same-version re-offer** of the platform firmware package. Running BIOS already equals the offered level (01.29.01 / 1.29.1.0), build dates match (Sept 2024), HP publishes nothing newer, nothing is staged.
- **Also C — auxiliary firmware**: the item is a bundle that always carries Intel ME + CCG5 USB-C PD firmware alongside the BIOS; the download size (~12.1 MiB ≈ the on-disk ME image) suggests the ME/DEVFW component is the bulk of this payload rather than a full BIOS reflash.
- **Residual D — unresolved** on one narrow point only: whether the **bundled ME / CCG5 sub-versions** inside `1.29.1.0` are numerically newer than the running `12.0.95.2489` (ME) and the current CCG5 level. WU does not expose those sub-versions, and Windows does not report the CCG5 version at all. This cannot be resolved read-only from the OS; it would need HP's SoftPaq release notes for the Q72 firmware or a post-install comparison.
- **Not A** (newer and necessary): no measured evidence of a newer BIOS or a raised firmware floor.

---

## VERIFIED FACTS

1. Running BIOS is **HP Q72 Ver. 01.29.01**, build date 2024-09-23 (Win32_BIOS, Get-ComputerInfo).
2. The System Firmware PnP node reports firmware-resource revision **`REV_12901`** = 1.29.01.
3. The pending WU item is **`HP Inc. - Firmware - 1.29.1.0`**, Type Driver, Driver class **Firmware**, provider **HP Inc.**, model **`HP Q72 System Firmware`**, HWID `uefi\res_{96e58ef2-2114-48c1-b1de-1a596272494e}`, driver version **1.29.1.0**, driver date **2024-09-24**, UpdateID **`56869ddb-5ee4-4d2b-b593-b0d1bb3e5842`**, revision **1**, DeploymentAction Installation, not mandatory, not uninstallable, no KB, no security-bulletin ID, single package (0 bundled), max download **12,723,678 bytes**.
4. It targets the **System Firmware resource `{96E58EF2-2114-48C1-B1DE-1A596272494E}`** — HP's combined BIOS + ME + CCG5 platform package.
5. No Microsoft UEFI-capsule infrastructure is in use on this box: **no `FirmwareResources` (ESRT) registry key**, **no `\EFI\UpdateCapsule\`**.
6. `\EFI\HP\BIOS\` contains `Current\Q72_012901.bin` (= running), `Previous\Q72_012800.bin` (rollback), and an **empty `New\`**. `\EFI\HP\DEVFW\` contains `ME.bin` and `CCG5.bin`. **All dated 2024-12-02** — from the previous OS install. **Nothing is staged for flash.**
7. Intel **ME firmware version is `12.0.95.2489`** (AMT mode) — measured from `root\Intel_ME`.
8. **Secure Boot is disabled.** BitLocker is Off. Clean Windows recovery USB created and boot-tested. Kali `grubx64.efi` present on the shared ESP.
9. **Local WU history shows zero prior firmware/BIOS installs** (76 entries) — the clean reinstall wiped that record.
10. HP's public documentation currently lists **01.29.01** as the model's BIOS (per task input); the offered package's date (Sept 2024) matches the running firmware's build date.

## INFERENCES

1. WU is re-offering because the reinstalled OS has **no record** the firmware resource was serviced, and the HP firmware driver still ranks as applicable — **not** because firmware is missing or downgraded. (High confidence.)
2. The offered `1.29.1.0` corresponds to the **same BIOS level already running** (01.29.01). Installing it would be a **same-version reflash**, not an upgrade of the BIOS. (High confidence.)
3. The ~12.1 MiB payload — close to the on-disk `ME.bin` size and far under a 16 MiB BIOS image — implies the package's dominant content is the **Intel ME / DEVFW** component (possibly compressed BIOS + ME + CCG together). (Medium confidence — size heuristic only.)
4. Whether the bundled ME `12.0.95.xxxx` / CCG5 sub-levels are newer than what's installed **cannot be determined read-only**. If HP rolled a newer ME build into this package, deferring leaves an ME-level gap; if not, there is no delta at all. (Unresolved.)
5. Because Secure Boot is currently off and HP firmware updates commonly reset BIOS setup toward defaults, an install could **re-enable Secure Boot / change boot order**, which can disrupt the unsigned Kali GRUB path. (Medium confidence — typical HP behaviour.)

## RECOMMENDATION

**Defer / HOLD.** This validation cannot show the update delivers anything newer than what is already running: BIOS is byte-for-byte the same published level (01.29.01 / 1.29.1.0), nothing is staged, HP publishes nothing newer, and the item carries no KB, no security-bulletin reference, and no HP change notes. That is not enough benefit to justify a HIGH-RISK firmware write on a machine that was just rebuilt for trust reasons.

Hold unless/until **one** of these is true:
- HP publishes a BIOS **> 01.29.01** for the EliteBook 1050 G1 (Q72), or
- HP's SoftPaq release notes for this firmware show a **newer Intel ME or CCG5 sub-version** than `12.0.95.2489` / the current PD level (i.e. a real security or functional fix), or
- you deliberately choose to let WU reconcile its records with a same-version reflash, accepting the risk below.

If you later decide to proceed, treat it as **HIGH-RISK / BACKUP REQUIRED** and run the pre-flash checklist in "Rollback / recovery" first. Do the firmware **before** ever enabling BitLocker.

### Risk if installed
- **Firmware-write brick risk** (power loss / interrupted flash) on BIOS + ME + CCG5. Low but non-zero on any flash. Mitigation: HP emergency BIOS recovery (Win+B + power) and HP Sure Recover exist on this model; `Previous\Q72_012800.bin` is retained on the ESP.
- **BIOS settings reset toward defaults** — Secure Boot (currently off) may be re-enabled, boot order may change. Can drop or block the **Kali/GRUB** boot entry (unsigned GRUB + Secure Boot on). Requires post-flash re-check of boot order and Secure Boot state.
- **Intel ME reset** during ME flash; AMT/manageability settings may revert. Minor.
- **CCG5 USB-C PD update**: rare dock/charger/USB-C behaviour changes; usually benign.
- **Opacity**: WU-delivered firmware with no KB, no bulletin, no HP changelog in the metadata — conflicts with the "prefer official HP packages/docs, verify before change" posture.
- **Operational**: 2–3 reboots, several minutes flashing, must not be interrupted; AC power required.
- **No uninstall**: `IsUninstallable = False`. ME/CCG downgrades are normally fuse/SVN-blocked (effectively one-way).

### Risk if deferred
- If the bundle's ME sub-version is actually newer, you forgo whatever **Intel ME 12.x fixes** it contains until a later flash. Unverified in either direction — main downside of waiting.
- WU keeps surfacing the item, and **driver-class updates can install automatically** during a routine "check for updates" unless updates are paused / the item is hidden (`wushowhide`) / driver updates via WU are policy-blocked.
- **No functional impact** on Windows or Kali from waiting — 01.29.01 is HP's current published BIOS level and the machine is fully operational.

### Rollback / recovery considerations
- **BIOS**: `Previous\Q72_012800.bin` retained on ESP; HP BIOS menu / HP PC Hardware Diagnostics (F2) supports "restore previous BIOS"; HP Sure Recover + emergency recovery (Win+B + power) as fallback. Downgrade may be refused if the new BIOS raises the lowest-supported version.
- **Intel ME / CCG5**: treat as **non-reversible** (SVN/fuse anti-rollback). No user rollback path.
- **Recovery USB**: clean, boot-tested — covers **OS** recovery only; it does **not** restore firmware.
- **BitLocker**: Off — no recovery-key prompt on reflash (one less failure mode). Keep it off until after any firmware work.
- **Kali dual boot**: after any flash, verify (a) Windows Boot Manager is first in UEFI boot order, (b) the Kali/GRUB entry still exists, (c) Secure Boot state — if it flipped back on, unsigned GRUB will not load until Secure Boot is turned off again or MOK is enrolled.
- **Pre-flash checklist (only if you proceed):** AC connected + battery > 50%; record current BIOS settings (boot order, Secure Boot, TPM, virtualization) to re-apply; close all apps; expect multiple reboots; do not power off; have recovery USB + HP Win+B recovery method on hand; confirm HP release notes justify the flash.

---

## PASS / HOLD

# ⟶ HOLD

Same-version re-offer (Category B) with auxiliary-firmware content (Category C) and one unresolved sub-component-version question (Category D). No demonstrated newer firmware, nothing staged, no HP change notes, no security-bulletin reference. Insufficient benefit to justify a HIGH-RISK firmware write at this time. Re-evaluate if HP publishes a BIOS above 01.29.01 or documents a newer bundled Intel ME / CCG5 level. **Do not execute the update.**
