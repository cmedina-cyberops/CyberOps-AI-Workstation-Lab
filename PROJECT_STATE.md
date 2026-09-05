# PROJECT_STATE.md

Sanitized snapshot of the workstation's current state.
**Last updated:** 2026-09-05 (Batch 5J — Published documentation refresh, first public script, MIT license).

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

- Personal data was restored **selectively** from cloud backup.
- The `Recovered-Desktop` review is **complete** (Batch 4C / 4C-3 / 4C-4): the tree was
  verified read-only, install-media / cracked-software artifacts were isolated and then
  permanently disposed of, and personal documents were left untouched. Details in the
  local `BATCH_4C*` reports.
- Old backups are treated as **data sources only**, reviewed before any use.
- A cloud copy of the original recovered folder is retained in personal cloud storage
  (outside this repository).

## 5. Engineering toolchain (Batch 5)

| Tool | State |
|---|---|
| Git | Installed, current |
| Visual Studio Code | Installed, current |
| Claude Code CLI | Installed, current — verified installed version 2.1.258; `winget` reports no newer version available |
| Windows PowerShell 5.1 | Present (system component, preserved) |
| PowerShell 7 | Installed alongside 5.1 |
| Python 3.13 (x64, PSF) | Installed, with `pip` and `py` launcher (per-user) |
| GitHub CLI | Installed and **authenticated** (personal GitHub account); used to publish the remote in Batch 5D (repository later switched to **public** in Batch 5H) |
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
| Batch 5F | Final public-readiness review; internal files untracked; institution name redacted | **PASS** — see `BATCH_5F_RESULTS.md` |
| Batch 5G | Hardware-fingerprint trim in the public-candidate audit docs | **PASS** (local report) |
| Batch 5H | Repository switched **PRIVATE → PUBLIC**; final verification | **PASS** (local report) |
| Batch 4C / 4C-3 / 4C-4 | `Recovered-Desktop` verification, selective cleanup, quarantine disposal | **PASS** — recovery review complete (local reports) |
| Batch 6A | Cybersecurity-lab discovery + architecture baseline (read-only) | **PASS** (local report) |
| Batch 6B (1–4) | Virtualization enablement; Kali-Lab VM; persistent isolated lab networking; baseline checkpoints; safe disk cleanup | **PASS** (local reports) |

Batch reports 5G onward, and 4C onward, are kept **local / untracked** — internal
execution logs, not portfolio evidence.

## 7. Repository / publication state

- GitHub repository is **PUBLIC** (switched from private in Batch 5H). Default branch
  `main`; local `HEAD` synchronized with `origin/main`.
- The public repository is **sanitized and curated**: only privacy-reviewed documentation
  and code is tracked. Internal / raw batch reports and machine-local state stay local
  and are git-excluded.
- No extra branches or tags. No GitHub Actions workflows, Pages site, releases,
  collaborators, branch protection, or Actions secrets.
- GitHub **Issues** and **Projects** are disabled (documentation/portfolio repository).
- Licensed under the **MIT License** (`LICENSE`, copyright holder `cmedina-cyberops`).
- First public automation published: `powershell/Backup-BraveBookmarks.ps1`.
- Kept **local only** (not tracked): `CLAUDE.md` (AI-assistant operating agreement);
  `docs/ORGANIZACION_DIGITAL.md` (local organizational manual); the internal batch logs
  `BATCH_4C*`, `BATCH_5B`–`5H`, `BATCH_6A`, `BATCH_6B1`–`6B4`, `BRAVE_BOOKMARK_BACKUP_RESULTS.md`,
  `RECOVERED_DESKTOP_CURRENT_STATE.md`, and machine / hardware reports — internal workflow
  records with limited portfolio value.

## 8. Explicit HOLD items (require separate authorization)

- **Batch 3:** vendor firmware/BIOS update and Secure Boot re-enablement (+ any
  matching Kali boot reconfiguration). High-risk / backup required.
- **Microsoft Office:** install via the institutional portal after interactive sign-in.

## 9. Organizational manual (LOCAL note)

`docs/ORGANIZACION_DIGITAL.md` (kept **local / private**) is the organizational source of
truth for workstation, browser, lab, backup, and AI-workflow structure. Meaningful
organizational changes should update this manual as part of the same change/batch.

## 10. Recent milestones

- **Chrome profile organization — COMPLETE.** Two primary profiles, `Personal-Study` and
  `Work-CyberOps`, operationally separated. Detail in `docs/ORGANIZACION_DIGITAL.md` §4.
- **Brave bookmarks backup automation — COMPLETE.** `powershell/Backup-BraveBookmarks.ps1`
  performs a bookmarks-only, SHA256-verified copy to a Google Drive destination; first run
  **PASS**. Bookmarks files only — no passwords, cookies, history, sessions, tokens, or
  other sensitive browser databases.
- **Claude Code maintenance — COMPLETE.** Verified installed version 2.1.258; `winget`
  reports no newer version available.
- **Epson WF-2950 print + scan — operational.**
- **Cisco Packet Tracer — installed** (network-lab / study use).
- **Batch 6B-4 — PASS.** Kali-Lab on a persistent `Lab-NAT` address; `Lab-Isolated`
  reserved and isolated; `Baseline-Clean` checkpoint retained; `Baseline-Networked`
  checkpoint created; verified-redundant Kali source files cleaned up safely.
