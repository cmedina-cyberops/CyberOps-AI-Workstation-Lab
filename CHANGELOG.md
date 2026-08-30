# Changelog

Chronological, sanitized record of completed changes to the workstation and this
project. Dates are local. No machine identifiers are included.

The format is loosely based on [Keep a Changelog](https://keepachangelog.com/).
This project does not yet use semantic version tags; entries are grouped by batch.

---

## [Batch 5] – 2026-08-28 – Engineering baseline

### Added
- **PowerShell 7** (7.6.5) installed via winget (Microsoft, MSIX, hash-verified),
  side by side with Windows PowerShell 5.1 (5.1 left intact).
- **Python 3.13** (3.13.15, x64, Python Software Foundation) installed via winget
  (hash-verified), including `pip` (26.2.1) and the `py` launcher. Per-user install;
  user `PATH` updated (see `BATCH_5_RESULTS.md`). No third-party packages installed.
- **GitHub CLI** (2.98.0) installed via winget (GitHub, Inc., MSI, hash-verified).
  Not authenticated; no remote operations performed.
- **Sysinternals Suite** installed from the official Microsoft Store package
  (Publisher: Microsoft Corporation, Store-signed). The winget `winget`-source
  package was rejected because its pinned installer hash no longer matched the
  live download; hash verification was **not** bypassed.
- Local project structure: `docs/`, `scripts/`, `reports/`, `powershell/`,
  `python/`, `bash/`.
- Project documentation: `README.md`, `PROJECT_STATE.md`, `CHANGELOG.md`,
  `SOFTWARE_PLAN.md`, `RECOVERY_MEDIA_INVENTORY.md`.
- Security-focused `.gitignore` (keys, secrets, `.env`, password vaults, BitLocker
  recovery material, hardware reports, `Recovered-Desktop`, backups, Downloads,
  transient/cache/log files, IDE local state).
- **Local** Git repository initialized (`git init`, branch `master`). No remote
  configured. Nothing staged or committed.

### Verified (unchanged, healthy)
- Git 2.55.0, Visual Studio Code 1.135.0, Claude Code CLI 2.1.248 — current, not reinstalled.
- Security baseline held: Defender real-time protection On, Tamper Protection On,
  PUA Block, Network Protection Enabled, 9 ASR rules in Audit mode, firewall enabled
  on all three profiles, no pending reboot.

---

## [Batch 4D] – 2026-08-28 – Daily desktop applications

### Added
- ChatGPT Desktop (Microsoft Store, Publisher OpenAI).
- Claude Desktop (winget `Anthropic.Claude`, EV-signed, hash-verified).
- Google Chrome (winget `Google.Chrome`, 64-bit, EV-signed, hash-verified).

### Notes
- No profiles, extensions, cookies, sessions, or credentials imported. All sign-ins
  left for the user to perform interactively.
- One new component: `GoogleChromeElevationService` (standard Chrome component,
  manual start). Security baseline unchanged. **PASS.**

---

## [Batch 4] – 2026-08-28 – Essential software reinstallation

### Added
- KeePassXC, VLC, Adobe Acrobat Reader (64-bit), Google Drive for desktop — all
  from official sources / winget with verified signatures.

### Held
- Microsoft Office — to be installed through the institutional portal after
  interactive sign-in.
- Printer (Epson WF-2950) — deferred until the printer is connected.
- Google Drive sign-in — pending interactive user login.

**Status: PARTIAL.**

---

## [Batch 2] – 2026-08-28 – Security hardening

### Changed
- Defender PUA Protection: Audit → **Block**.
- Defender Network Protection: Disabled → **Enabled**.
- Attack Surface Reduction: no rules → **9 rules configured in Audit mode**
  (deliberately Audit, not Block, to observe impact first).

### Unchanged (explicitly out of scope)
- Controlled Folder Access, firewall, Defender exclusions, Fast Startup, BitLocker,
  Secure Boot, TPM, firmware, bootloader, partitions.

**Status: PASS.**

---

## [Batch 1] – 2026-08-28 – Post-clean low-risk maintenance

### Changed
- Installed 7 pending WHQL-signed driver updates via Windows Update (Intel chipset /
  thermal / SPI / PCIe / Wi-Fi), resolving 4 devices previously in an error state.
- Installed the pending Windows quality/component update.
- Updated App Installer (winget) to the current version.
- Created a System Restore baseline point (restore-point creation throttle set to 0
  only for the duration of the operation, then reverted to default).

### Not done / out of scope
- HP firmware/BIOS update `1.29.1.0` — intentionally left uninstalled (high-risk).
- No change to Secure Boot, BitLocker, bootloader, EFI entries, or partitions.

### Open items
- A small number of elevated verification checks remained outstanding.

**Status: PARTIAL.**

---

## Earlier

- Windows 11 Pro reinstalled clean after malicious persistence linked to cracked
  software was discovered. Old executables, scripts, and startup items are not being
  restored. Baseline audits recorded in `POST_CLEAN_WINDOWS_AUDIT.md` and
  `POST_CLEAN_ELEVATED_VERIFY.md`.
- Kali Linux installed as a physical UEFI/GPT dual boot and boot-tested.
- Windows recovery USB created and boot-tested.
- Secure Boot disabled for current Kali boot compatibility (change-controlled;
  revisit under Batch 3).
