# CyberOps & AI Workstation Lab

## Overview

A **personal**, self-directed cybersecurity and systems-engineering lab built around a
single laptop. This repository is the sanitized source of truth for the documentation,
change records, and (over time) automation used to run that laptop as a hardened
Windows 11 workstation and a hands-on security learning environment.

Everything here is a learning and portfolio project. It does **not** represent
professional employment, client engagements, or any organization's systems.

## Objectives

- Run one laptop as a hardened **Windows 11 Pro** workstation with a physically
  dual-booted **Kali Linux** environment for Linux and security practice.
- Apply every meaningful change through a security-first, change-controlled workflow:
  discover → baseline → verify → propose → authorize → execute → verify → document.
- Treat partitions, firmware, Secure Boot, TPM, BitLocker, the bootloader, and
  Defender / firewall architecture as change-controlled — never modified automatically.
- Produce readable, reusable automation (PowerShell / Python / Bash) and sanitized
  technical reports suitable for a future public portfolio.
- Practice disciplined recovery planning: tested recovery media, verified images before
  any high-risk work.

## Architecture

| Layer | Detail |
|---|---|
| Primary OS | Windows 11 Pro (clean install) — daily workstation, boots by default |
| Secondary OS | Kali Linux 2026.2 — **physical** install on the same disk (not a VM) |
| Boot | UEFI / GPT dual boot; Kali selectable at the boot menu |
| Firmware | UEFI; Secure Boot currently disabled for Kali boot compatibility (change-controlled) |
| Workspace | Visual Studio Code as the engineering workspace |
| Source of truth | Git + a private GitHub repository for sanitized code and documentation |
| AI assistance | LLM assistants used as planning / review aids; every change is human-authorized before execution |

## Security Approach

- **Read-only first.** Diagnostics and baselining precede any change.
- **Risk classification.** Every action is labelled READ-ONLY, LOW-RISK CHANGE,
  SYSTEM CHANGE, or HIGH-RISK / BACKUP REQUIRED. High-risk actions require a separate
  named authorization, a stated rollback, and a verified backup.
- **Batched execution.** Related changes are grouped, executed, then re-verified against
  the security baseline. Failures are reported verbatim, never hidden.
- **Host integrity preserved.** The Windows host is not weakened to accommodate a lab
  tool. Defender, firewall, Windows Update, and the recovery environment stay functional.
- **Clean-install baseline.** Windows was reinstalled clean after malicious persistence
  linked to cracked software was found; old executables, scripts, and startup items are
  not restored.

## Current Status

Summary as of the latest batch — full detail in `PROJECT_STATE.md`:

- Windows 11 Pro clean install verified; Kali 2026.2 physical dual boot working; Windows
  boots by default.
- TPM 2.0 healthy. Secure Boot intentionally disabled (Kali compatibility). BitLocker
  off (unchanged by this project).
- Defender real-time protection, Tamper Protection, and Network Protection on; PUA set to
  **Block**; 9 Attack Surface Reduction rules in **Audit** mode; firewall enabled on all
  profiles.
- Windows recovery USB created and boot-tested.
- Security-hardening batch: **PASS**. Engineering-baseline batch: **PASS**.
- Firmware update + Secure Boot re-enablement: **HOLD** (high-risk, backup required).
- Personal-data recovery review: **HOLD** pending a cloud copy completing.
- This repository is published as a **private** GitHub repository and is being prepared
  for possible future public portfolio use.

## Tooling

| Area | Tools |
|---|---|
| Shell / automation | Windows PowerShell 5.1 and PowerShell 7 (side by side), Bash (Kali) |
| Languages | PowerShell, Python 3.13, Bash |
| Version control | Git, GitHub CLI, GitHub (private remote) |
| Editor | Visual Studio Code |
| Diagnostics | Sysinternals Suite (official Microsoft source), built-in Windows tooling |
| Sourcing rule | Official vendor sources / Microsoft Store / trusted winget packages; installer hash verification is never bypassed; no cracked or optimizer software |

Exact versions, publishers, and signatures are recorded in `SOFTWARE_PLAN.md` and
`BATCH_5_RESULTS.md`.

## Project Structure

| Path | Purpose |
|---|---|
| `docs/` | Longer-form notes, design docs, procedures |
| `scripts/` | Cross-cutting helper scripts |
| `powershell/` | Windows automation (PowerShell 5.1 / 7) |
| `python/` | Cross-platform tooling (Python 3) |
| `bash/` | Linux / Kali automation |
| `reports/` | Sanitized generated reports |
| `PROJECT_STATE.md` | Current sanitized state of the workstation |
| `CHANGELOG.md` | Chronological, sanitized record of completed changes |
| `SOFTWARE_PLAN.md` | Planned / installed / held software |
| `RECOVERY_MEDIA_INVENTORY.md` | Recovery media tracking (sanitized) |
| `BATCH_*_RESULTS.md` | Per-batch execution records: pre-check, commands, results, verification, verdict |
| `CLAUDE.md` | Working agreement / guardrails for AI-assisted execution |

Language directories currently hold `.gitkeep` placeholders; automation is added as
batches produce it.

## Key Accomplishments

- Clean Windows 11 Pro rebuild after a malware-persistence finding, with documented
  post-clean audits.
- Kali Linux 2026.2 established as a physical UEFI / GPT dual boot and boot-tested.
- Windows recovery USB created and boot-tested.
- Driver remediation: pending WHQL-signed updates applied; devices previously in an error
  state cleared.
- Security hardening: PUA → Block, Network Protection → Enabled, 9 ASR rules staged in
  Audit mode; baseline re-verified afterwards.
- Essential and daily software reinstalled from official sources with signature / hash
  verification.
- Engineering baseline standardized (PowerShell 7, Python 3.13, Git, GitHub CLI,
  Sysinternals) with versions and sources recorded.
- Repository sanitized, privacy-reviewed, committed, and published to a private GitHub
  remote.

## Planned Work

- **Firmware / Secure Boot (HOLD):** vendor BIOS update and Secure Boot re-enablement
  with matching Kali boot reconfiguration — only after a verified full system image.
- **Personal-data recovery review (HOLD):** selective recovery once the cloud copy
  completes.
- Move the 9 ASR rules from Audit to Block after reviewing impact.
- Rebuild and boot-test the Kali installer USB.
- Add automation to `powershell/`, `python/`, and `bash/` (e.g. a security-baseline
  auditor, system inventory, network diagnostics).
- Decide on a `LICENSE` before any public release.

## Safety / Ethics

- Security testing is limited to systems the owner controls or is explicitly authorized
  to test. Isolated environments (Kali, VMs, Windows Sandbox, WSL2, lab networks) are
  preferred for experiments.
- This is not a penetration-testing drop, an offensive-security toolkit, or a Windows
  "debloat" project. Registry cleaners and aggressive optimizers are intentionally
  avoided.
- No destructive, evasion, or mass-targeting tooling is included.

## Portfolio Disclaimer

- Self-directed personal learning project. **No claim of professional employment, client
  work, or organizational experience** is made or implied.
- Contains **no** machine or personal identifiers: no usernames, hostnames, serial
  numbers, IP / MAC addresses, Wi-Fi SSIDs, account emails, passwords, tokens, API keys,
  or recovery keys. Machine-local state, personal backups, and hardware reports are
  excluded via `.gitignore` and a manual privacy review before every commit.
- Descriptions aim to be factual and to not overstate expertise; the intent is to show
  method and discipline, not seniority.

## License

No license granted yet. Until a `LICENSE` file is added, all rights reserved by the
author for the custom scripts and documentation. Third-party tools referenced here remain
under their own licenses.
