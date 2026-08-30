# Post-Clean Windows 11 — Elevated Read-Only Verification (Appendix A)

**Scope:** Execution of *Appendix A — Elevated Read-Only Verification Script* from `POST_CLEAN_WINDOWS_AUDIT.md`, to close the elevation-gated blind spots (`[NEEDS ELEVATION]`) left open by the non-elevated audit pass.
**Date collected:** 2026-08-28 (local)
**Elevation:** Confirmed — session token was Administrator / High integrity (`WindowsPrincipal.IsInRole(Administrator) = True`), Windows PowerShell `5.1.26100.9168`.
**Mode:** READ-ONLY. The script queried state only. It temporarily mounted the ESP as `S:` and unmounted it in the same step (no persisted change), and wrote one diagnostic file (`battery-report-<stamp>.html`) into the project folder. **No** configuration, registry, boot, firmware, service, account, partition, or security-setting changes were made.
**Repair actions:** None. `DISM /Online /Cleanup-Image /CheckHealth` (flag-check only) and `sfc /verifyonly` were run — neither repairs anything. `RestoreHealth`, `ScanHealth`, and `sfc /scannow` were **not** run.

---

## 1. Results Summary

| Appendix A check | Result | Audit item(s) closed |
|---|---|---|
| Secure Boot | **Disabled** — `Confirm-SecureBootUEFI = False` | H1 (confirmed) |
| TPM | **TPM 2.0 present, ready, enabled, activated, owned**; Infineon (IFX); lockout count 0 | M7 (TPM half), §4 |
| Boot entries | Windows Boot Manager + Windows 11 loader intact; **`kali` firmware entry present** (`\EFI\kali\grubx64.efi`); no unknown OS loaders | §4.1, §5.2, I5 |
| Shared ESP `\EFI\` contents | Windows, HP firmware, and **`\EFI\kali\grubx64.efi` (152 KB)** all present; **no `shimx64.efi` under `\EFI\kali`** | §5.2, I5 |
| Defender exclusions (authoritative) | **All empty** — no path / process / extension / IP exclusions; no CFA-allowed apps; no ASR rules | §6.3, §25 indicator #5 |
| Optional features / capabilities | Only default/benign features; **no SMB1, Telnet, TFTP, IIS, WSL, Hyper-V, VM Platform, Containers**; **OpenSSH Client only — no OpenSSH Server** | §19, L6, I4 |
| Remote management / SSH server | `winrm` Stopped/Manual, **no WinRM listeners**; `sshd` not installed; `TermService` Stopped/Manual | §16 |
| Windows Recovery Environment | **Enabled**, on disk 0 partition 4, WinRE `10.0.26100.9168`; `reagentc` OK | §20, L7 |
| System Restore / VSS | **Protection ON for `C:`** (cap ~16.8 GB / 1%, ~913 MB used); **1 restore point exists** ("Windows Modules Installer", 2026-08-28 02:04) | §21, M5 (partial) |
| BitLocker | **Not enabled** — `C:` and `D:` fully decrypted, protection Off, no key protectors | H1 / Batch 2 prerequisite |
| NVMe SMART / endurance | **Wear 0%**, temperature 47 °C; power-on-hours / error counts **not exposed** by this drive even when elevated | §3.5, I3 (partial) |
| Battery report | Generated: `battery-report-20260828-122056.html` in project folder | §3.6, I3 |
| `C:\Windows.old` size | Directory exists (timestamp 2026-08-28 01:54) but is **verifiably empty** — 0 items recursively, 0 access-denied errors | H2 (residual data closed) |
| Security event log (30 d) | Account create/enable/group-add/password-reset events **only during install/OOBE (2026-08-27 → 08-28 01:01)**; **no `1102` (audit-log-cleared) events**; nothing since setup | §25, H* baseline |
| DISM component store (CheckHealth) | **"No component store corruption detected."** | §22 |
| SFC verify-only | **"Windows Resource Protection did not find any integrity violations."** | §23 |

**Net effect:** every `[NEEDS ELEVATION]` gap from the audit is now resolved. No corruption, no persistence, no unexpected boot/OS-loader entries, no Defender exclusions, no log tampering. Kali's GRUB loader **and** its UEFI boot entry both survived the Windows reinstall — Kali is bootable today.

---

## 2. Detail by Section

### 2.1 Secure Boot — finding H1 (confirmed)

```
Confirm-SecureBootUEFI : False
```

Secure Boot is **disabled** in firmware, confirming the non-elevated registry read (`UEFISecureBootEnabled = 0`). No change made. Remediation remains a HIGH-RISK / BACKUP REQUIRED item (Batch 2.3) — see the Kali/shim note in §2.4 below, which is directly relevant to enabling it.

### 2.2 TPM — finding M7 (TPM portion resolved)

| Field | Value |
|---|---|
| TpmPresent / TpmReady / TpmEnabled / TpmActivated / TpmOwned | **True / True / True / True / True** |
| Manufacturer | `IFX` (Infineon) |
| Manufacturer version | `7.63.3353.0` |
| Lockout count | `0` |
| Spec version | **2.0** (`2.0, 0, 1.16`) |

TPM 2.0 is present and fully ready. This underpins BitLocker and measured boot and satisfies the TPM prerequisite for Credential Guard. (Credential Guard itself is still *not enabled* — the remaining half of M7, a SYSTEM CHANGE deferred to Batch 3.4.)

### 2.3 Boot entries — §4.1 / §5.2 resolved

**Firmware boot manager (`{fwbootmgr}`)** display order (`timeout 0`):

| Order | Entry | Identity |
|---|---|---|
| 1 | `{a7591db7-…}` | **`kali`** → `\EFI\kali\grubx64.efi` |
| 2 | `{bootmgr}` | **Windows Boot Manager** → `\EFI\Microsoft\Boot\bootmgfw.efi` (partition = ESP / HarddiskVolume1) |
| 3–8 | misc device, Kingston USB `<redacted>`, two "Generic USB Storage `<redacted>`", `Network Boot IPV4`, `Network Boot IPV6` | Removable / PXE — benign |

**Windows Boot Manager (`{bootmgr}`):** `default = {current}`, `displayorder = {current}` only, `timeout 30`, `toolsdisplayorder = {memdiag}`.

**OS loaders:** `{current}` = "Windows 11" on `partition=C:` → `\WINDOWS\system32\winload.efi`, `recoveryenabled Yes`; plus two "Windows Recovery Environment" loaders (ramdisk from `\Recovery\WindowsRE\Winre.wim` on HarddiskVolume4). **No unknown, extra, or user-path OS loader entries.**

> **Observation (no action taken):** the firmware boot order lists the `kali` GRUB entry ahead of the Windows Boot Manager, yet the host boots Windows unattended (GRUB's own default entry selects Windows, or HP firmware falls through). This is a normal GRUB-first dual-boot layout and is consistent with "Windows boots by default" as observed. Any change to firmware boot order is HIGH-RISK / BACKUP REQUIRED and is **not** proposed here.

### 2.4 Shared ESP `\EFI\` contents — §5.2 / I5 resolved

Mounted read-only as `S:`, enumerated, unmounted. Key entries:

| Path | Size | Meaning |
|---|---|---|
| `\EFI\Microsoft\Boot\bootmgfw.efi` | 3,086,848 | Windows Boot Manager |
| `\EFI\Boot\bootx64.efi` | 3,086,848 | Removable-media fallback loader (= Windows bootmgr) |
| **`\EFI\kali\grubx64.efi`** | **155,648** | **Kali GRUB loader — PRESENT** |
| `\EFI\Microsoft\Boot\CIPolicies\Active\*.cip` | 4 files | WDAC / Code-Integrity policies — normal on Win11 25H2 |
| `\EFI\Microsoft\Boot\SecureBootRecovery.efi` | 174,584 | Standard MS Secure Boot recovery loader |
| `\EFI\HP\BIOS\Current\Q72_012901.bin` | 16,777,216 | Currently-installed HP BIOS image (`01.29.01`) |
| `\EFI\HP\BIOS\Previous\Q72_012800.bin` | 16,777,216 | Prior HP BIOS image (`01.28.00`) |
| `\EFI\HP\BIOS\New\` | *(empty)* | **No BIOS flash staged** |
| `\EFI\HP\DEVFW\ME.bin`, `CCG5.bin` | 12.2 MB / 132 KB | HP-staged Intel ME + USB-C controller firmware images |

**Kali dual-boot verdict:** both the GRUB EFI loader (`\EFI\kali\grubx64.efi`) and the UEFI/NVRAM `kali` boot entry (§2.3) are intact. The audit's one real open question — "did the clean install drop the Kali boot path?" — is answered: **no, Kali is bootable.**

> **Relevant to H1 (enable Secure Boot):** `\EFI\kali` contains **only `grubx64.efi` — no `shimx64.efi`**. With Secure Boot enabled, this GRUB binary will very likely fail firmware signature validation and Kali will not boot. Before any attempt to enable Secure Boot (Batch 2.3), Kali must be updated so a Microsoft-signed `shim` (`shimx64.efi`) is installed in `\EFI\kali` and set as the boot entry target, and that path must be tested from the UEFI menu first. This is a HIGH-RISK / BACKUP REQUIRED task — recorded here, not performed.

### 2.5 Defender exclusions (authoritative) — §6.3 / §25 indicator #5 resolved

```
ExclusionPath      : (empty)
ExclusionProcess   : (empty)
ExclusionExtension : (empty)
ExclusionIpAddress : (empty)
CFA allowed apps   : (empty)
ASR rule IDs       : (empty)
ASR rule actions   : (empty)
```

Elevated `Get-MpPreference` confirms **zero** Defender exclusions of any kind and **zero** ASR rules. The historical "old Defender exclusions" compromise indicator is **authoritatively absent**. (PUA=Audit, CFA=Off, Network Protection=Off remain as hardening gaps — finding M3, Batch 3.)

### 2.6 Optional features & capabilities — §19 / L6 / I4 resolved

**Enabled Windows optional features:** `MediaPlayback`, `Microsoft-RemoteDesktopConnection` (the `mstsc` *client* only), `MSRDC-Infrastructure`, `NetFx4-AdvSrvs`, `Printing-Foundation-Features`, `Printing-Foundation-InternetPrinting-Client`, `Printing-PrintToPDFServices-Features`, `SearchEngine-Client-Package`, `SmbDirect`, `WCF-Services45`, `WCF-TCP-PortSharing45`, `Windows-Defender-Default-Definitions`, `WindowsMediaPlayer`, `WorkFolders-Client`.

**Not present** (explicitly checked): SMB 1.0/CIFS, Telnet Client, TFTP Client, IIS / `Internet-Information-Services`, Windows Subsystem for Linux, Virtual Machine Platform, Hyper-V, Containers, Windows Sandbox feature.

**Capabilities (filtered):** `OpenSSH.Client~~~~0.0.1.0` **only**. `OpenSSH.Server` is **not installed** — resolves I4 and §16. No Telnet/TFTP/SNMP/RSAT/legacy capabilities installed.

All enabled items are Windows defaults for this edition or benign (printing, .NET, media, Work Folders client). `C:\inetpub` on disk does **not** correspond to an enabled IIS feature (consistent with I2 — servicing mitigation artifact).

### 2.7 Remote management / SSH server — §16 resolved

| Service | Status | Start type |
|---|---|---|
| `sshd` | *(not installed — no object returned)* | — |
| `winrm` | Stopped | Manual |
| `TermService` (RDP) | Stopped | Manual |

`winrm enumerate winrm/config/listener` returned **no listeners**. WinRM is not configured or listening; RDP service is stopped/manual (matches §17 `fDenyTSConnections = 1`). No remote-management exposure.

### 2.8 Windows Recovery Environment — §20 / L7 resolved

```
Windows RE status:   Enabled
Windows RE location:  \\?\GLOBALROOT\device\harddisk0\partition4\Recovery\WindowsRE
BCD identifier:       35e50c6c-…
Windows RE version:   10.0.26100.9168
REAGENTC.EXE: Operation Successful.
```

WinRE is enabled and healthy on the dedicated ~0.84 GB recovery partition (disk 0, partition 4). Recovery is functional.

### 2.9 System Restore / VSS — §21 / M5 (partial)

- **Restore points:** one — `SequenceNumber 1`, "Windows Modules Installer", created **2026-08-28 02:04** (auto-created during post-install component servicing, not a deliberate baseline).
- **Shadow storage on `C:`:** Used **913 MB**, Allocated **4.86 GB**, Maximum **16.8 GB (~1%)** — System Protection **is enabled** on `C:` with a cap.
- **Shadow copies present:** two sets —
  - `2026-08-27 22:04:23` — originating machine `<HOSTNAME-PRIOR>` (the default name assigned at install, before rename)
  - `2026-08-28 12:08:18` — originating machine `<HOSTNAME>` (current name), type "No writers" (System-Restore-style checkpoint)

M5 is partly satisfied: SR protection is on and a cap is set. A **restore point labelled "post-clean baseline"** is still worth creating before the driver/firmware/hardening batches (LOW-RISK CHANGE — not done here).

### 2.10 BitLocker — Batch 2 prerequisite resolved

| Volume | Status | Protection | Method | Key protectors |
|---|---|---|---|---|
| `C:` | FullyDecrypted | **Off** | None | none |
| `D:` | FullyDecrypted | **Off** | None | none |

**BitLocker is not in use.** There is no recovery key to record and nothing to suspend before HP firmware flashing or enabling Secure Boot (removes one precondition from Batch 2.1/2.2).

### 2.11 NVMe SMART / endurance — §3.5 / I3 (partial)

| Disk | Wear | Temp | Power-on hours | Read/Write errors | Start/stop cycles |
|---|---|---|---|---|---|
| 0 (system NVMe SSD) | **0** | **47 °C** | *(blank)* | *(blank)* | *(blank)* |
| 1 (USB) | 0 | 0 | *(blank)* | *(blank)* | *(blank)* |

Wear indicator is 0% and temperature is normal. This drive/driver does **not** surface power-on-hours or error counters through `Get-StorageReliabilityCounter` even elevated — the deeper endurance baseline in I3 cannot be obtained this way. The generated `battery-report-<stamp>.html` covers the battery half of I3.

### 2.12 `C:\Windows.old` — finding H2 (residual-data concern closed)

```
Windows.old : 0.00 GB across 0 files
```

Follow-up check: the directory `C:\Windows.old` **does still exist** (timestamp 2026-08-28 01:54) but is **verifiably empty** — an elevated recursive enumeration returned **0 items with 0 access-denied errors** (i.e. not an ACL blind spot; it is genuinely empty). The old, suspected-compromised OS/user tree flagged by the non-elevated audit is gone — no large dormant copy of the previous installation remains to review or reclaim. H2's residual-data-exposure concern is closed. Only an empty folder shell is left; it can be cleared later via Disk Cleanup / Storage Sense as tidy-up (SYSTEM CHANGE, still never a manual `rd`).

### 2.13 Security event log — account & log-clear activity, last 30 days

- **No `1102` (security audit log was cleared) events.** No evidence of log tampering.
- Account lifecycle events (`4720` created, `4722` enabled, `4724` password reset, `4728`/`4732` group membership) all fall between **2026-08-27 22:11 and 2026-08-28 01:01**, plus one `4726` (account deleted) at **2026-08-27 22:29**. This clustering matches Windows OOBE / first-run: creation of the interactive account, cleanup of the temporary `defaultuser0`, and the subsequent machine rename (`<HOSTNAME-PRIOR>` → `<HOSTNAME>`).
- **No account or group changes after 2026-08-28 01:01** — nothing in the window since setup.

Interpretation: benign install-time activity only.

### 2.14 DISM component store — §22 resolved

```
DISM /Online /Cleanup-Image /CheckHealth
No component store corruption detected.
The operation completed successfully.
```

Flag-check only. No corruption flagged; no repair run.

### 2.15 SFC verify-only — §23 resolved

```
sfc /verifyonly
Windows Resource Protection did not find any integrity violations.
```

Full verification pass, 0–100%, no repairs performed. System files intact.

---

## 3. Items Still Open After This Pass

| Ref | Status |
|---|---|
| H1 — Secure Boot disabled | Confirmed. Blocked on: install Microsoft-signed `shim` in Kali `\EFI\kali` and validate Kali boots with Secure Boot (see §2.4). HIGH-RISK / BACKUP REQUIRED. |
| H3 / L5 — HP firmware 1.29.1.0 + Intel platform/ME/Wi-Fi updates | Not applied. HP staged ME/CCG5 images exist in ESP; no BIOS flash staged. Batch 2.2 (firmware) / Batch 1.4 (drivers). |
| M1 / M2 — Wi-Fi driver + 4 failed chipset/DPTF/ME/GNA devices | Not addressed (out of scope for this read-only pass). Batch 1.4. |
| M3 — Defender hardening (PUA=Block, Network Protection, ASR, CFA) | Confirmed all off / unconfigured. Batch 3. |
| M4 — Fast Startup on dual-boot host | Not addressed. Batch 2.5. |
| M5 — labelled "post-clean baseline" restore point | SR protection confirmed ON; deliberate baseline point still to be created. Batch 1.2. |
| M6 — full Defender scan since reinstall | Not run in this pass. Batch 1.3. |
| M7 — Credential Guard | TPM 2.0 readiness confirmed; Credential Guard still not enabled. Batch 3.4. |
| I3 — SSD power-on-hours / endurance counters | Not exposed by this drive via `Get-StorageReliabilityCounter`; would need vendor tooling. |

---

## 4. Change/Safety Attestation

- No registry, service, account, scheduled-task, firewall, boot, partition, firmware, Secure Boot, TPM, BitLocker, or Defender setting was modified.
- ESP was mounted read-only as `S:` and unmounted within the same script step; drive letter `S:` is not persisted.
- One file was created in the project folder by the script as designed: `battery-report-20260828-122056.html`. It contains hardware identifiers (battery serial, host name) — **exclude it from any Git commit / privacy review before sharing.**
- `DISM ... /CheckHealth` and `sfc /verifyonly` are diagnostic-only; **no `RestoreHealth` / `ScanHealth` / `scannow` was executed.**

---

## Appendix — Data Handling

Sanitized before saving. Deliberately excluded / genericised: host name(s) (`<HOSTNAME>`, `<HOSTNAME-PRIOR>`), the primary account login name (`<USER>`), removable-device serial strings (`<redacted>`), and volume path GUIDs where not needed. BCD entry GUIDs, firmware image file names/sizes, TPM manufacturer version, and SSD temperature/wear are retained as non-sensitive technical evidence. No passwords, tokens, keys, recovery keys, or personal file contents were accessed or recorded.

*End of verification report.*
