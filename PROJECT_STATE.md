# PROJECT_STATE.md

Sanitized snapshot of the workstation's current state.
**Last updated:** 2026-08-30 (Batch 5E — Remote Hygiene + Portfolio Review).

No machine identifiers (username, hostname, serial, IP/MAC, SSID, emails, keys) are
included by design.

---

## 1. Platform

| Aspect | State |
|---|---|
| Primary OS | Windows 11 Pro (24H2 family, clean install) |
| Secondary OS | Kali Linux 2026.2 — **physical** install on the same disk, UEFI/GPT dual boot |
| Boot default | Windows boots by default; Kali selectable at the boot menu |
| Kali status | Installed and **boot-tested working** |
| Firmware type | UEFI (GPT) |
| Laptop firmware (BIOS) | Running vendor build `Q72 Ver. 01.29.01` (2024-09-23). A newer vendor firmware package is offered via Windows Update but is **on HOLD** (see Batch 3). |

## 2. Security / platform integrity

| Control | State | Notes |
|---|---|---|
| Windows clean install | **Verified** | Reinstalled clean after malicious persistence linked to cracked software was found. Old executables/scripts/startup items are **not** being restored. |
| Secure Boot | **Intentionally disabled** | Currently disabled for compatibility with the present Kali boot configuration. Re-enabling is a change-controlled item under Batch 3. |
| TPM | **2.0, healthy** | Present and functional. |
| BitLocker | Not modified by this project | Any change is change-controlled. |
| Microsoft Defender — real-time protection | **On** | |
| Defender — Tamper Protection | **On** | |
| Defender — PUA protection | **Block** | Set in Batch 2. |
| Defender — Network Protection | **Enabled** | Set in Batch 2. |
| Defender — Attack Surface Reduction | **9 rules in Audit mode** | Deliberately Audit (not Block) to observe impact before enforcing. Set in Batch 2. |
| Windows Firewall | **Enabled** on Domain, Private, Public | |
| Windows Update | Functional | |
| Recovery environment (WinRE) | Functional | |
| System Restore | Enabled; baseline restore point created in Batch 1 | |

## 3. Recovery media

| Item | State |
|---|---|
| Windows recovery USB | **Created and boot-tested** |
| Detail | Tracked in `RECOVERY_MEDIA_INVENTORY.md` (sanitized) |

## 4. Backup restoration

- Personal data is being restored **selectively** from cloud backup.
- A `Recovered-Desktop` copy is **still in progress** (copying from cloud storage).
- Until that copy completes it is treated as **off-limits**: not scanned, enumerated,
  moved, renamed, reorganized, or deleted. No custom antivirus scan is run against it yet.
- Old backups are treated as **data sources only**, reviewed before any use.
- File-recovery follow-up work (Batch 4C) is **on HOLD** pending copy completion.

## 5. Engineering toolchain (Batch 5)

| Tool | State |
|---|---|
| Git | Installed, current |
| Visual Studio Code | Installed, current |
| Claude Code CLI | Installed, current |
| Windows PowerShell 5.1 | Present (system component, preserved) |
| PowerShell 7 | Installed alongside 5.1 |
| Python 3.13 (x64, PSF) | Installed, with `pip` and `py` launcher (per-user) |
| GitHub CLI | Installed and **authenticated** (personal GitHub account); used to publish the private remote in Batch 5D |
| Sysinternals Suite | Installed from official Microsoft source |
| Git identity | Repository-local only (GitHub no-reply address). Global Git identity left unset by choice. |

Exact versions, sources, signatures, and PATH changes: see `BATCH_5_RESULTS.md`.

## 6. Batch status

| Batch | Scope | Status |
|---|---|---|
| Batch 1 | Post-clean low-risk maintenance (drivers, full AV scan, restore point, App Installer) | **PARTIAL** — pre-reboot work done; a couple of elevated verification items remained open |
| Batch 2 | Security hardening (PUA → Block, Network Protection → Enabled, 9 ASR rules → Audit) | **PASS** |
| Batch 3 | Firmware update + Secure Boot re-enablement | **HOLD** — high-risk; requires separate authorization and backup |
| Batch 4 | Essential software (KeePassXC, VLC, Acrobat Reader, Google Drive; OneDrive already current) | **PARTIAL** — core apps done; Microsoft Office held for institutional portal sign-in; printer deferred |
| Batch 4C | File-recovery follow-up | **HOLD** — waiting for `Recovered-Desktop` copy to finish |
| Batch 4D | Daily desktop apps (ChatGPT Desktop, Claude Desktop, Google Chrome) | **PASS** |
| Batch 5 | Engineering baseline (PowerShell 7, Python 3.13, Git, GitHub CLI, Sysinternals) | **PASS** — see `BATCH_5_RESULTS.md` |
| Batch 5B | Identifier sanitization + full privacy/secret review | **PASS** (staging gated to 5C) |
| Batch 5C | Privacy cleanup, branch `master → main`, repo-local Git identity, first local commit `c4f4842` | **PASS** |
| Batch 5D | Private GitHub repository created; `origin` added; `main` pushed | **PASS** |
| Batch 5E | Remote hygiene (Issues/Projects disabled) + portfolio documentation polish | **PASS** — see `BATCH_5E_RESULTS.md` |

## 7. Repository / publication state

- Published to a GitHub repository that is and remains **PRIVATE**. Default branch
  `main`; local `HEAD` synchronized with `origin/main` (`c4f4842`).
- No extra branches or tags. No GitHub Actions workflows, Pages site, releases,
  collaborators, branch protection, or Actions secrets.
- GitHub **Issues** and **Projects** are disabled (documentation/portfolio repository).
- Making the repository public is a **future, separately-authorized** decision. See the
  "remaining steps before public publication" section of `BATCH_5E_RESULTS.md`.
- `BATCH_5C_RESULTS.md` and `BATCH_5D_RESULTS.md` are kept **local / untracked**
  (workflow reports with limited portfolio value).

## 8. Explicit HOLD items (require separate authorization)

- **Batch 3:** vendor firmware/BIOS update and Secure Boot re-enablement (+ any
  matching Kali boot reconfiguration). High-risk / backup required.
- **Batch 4C:** review and selective recovery from `Recovered-Desktop` once copying completes.
- **Microsoft Office:** install via the institutional portal after interactive sign-in.
- **Public release:** switching repository visibility to public is not authorized yet.
