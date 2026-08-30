# CyberOps & AI Workstation Lab

A **personal** cybersecurity and workstation-engineering lab. This repository is the
sanitized source of truth for the scripts, documentation, and change history used to
build and maintain a single laptop as a secure professional workstation and a
hands-on security learning environment.

> This is a self-directed personal project for learning and portfolio purposes.
> It does not represent professional employment, client work, or any organization.

---

## Goals

- Keep one laptop running as a hardened Windows 11 workstation with a physically
  dual-booted Kali Linux environment for Linux and security practice.
- Do all meaningful changes in small, reviewed **batches**: discover → baseline →
  verify → propose → authorize → execute → verify → document.
- Prefer **read-only diagnostics first**; treat partitions, firmware, Secure Boot,
  TPM, BitLocker, the bootloader, and Defender/firewall architecture as
  change-controlled and never modified automatically.
- Produce reusable, documented automation (PowerShell / Python / Bash) and
  sanitized reports suitable for a public portfolio.

## Non-goals

- Not a penetration-testing toolkit or an offensive-security drop. Any security
  testing is limited to systems the owner controls or is explicitly authorized to test.
- Not a Windows "debloat" / registry-cleaner project. Aggressive optimization tools
  are intentionally avoided.
- No credentials, keys, personal documents, or machine identifiers are committed
  here (see `.gitignore` and the privacy note below).

---

## Repository layout

| Path | Purpose |
|---|---|
| `docs/` | Longer-form notes, design docs, procedures |
| `scripts/` | Cross-cutting helper scripts |
| `powershell/` | Windows automation (PowerShell 5.1 / 7) |
| `python/` | Cross-platform tooling (Python 3) |
| `bash/` | Linux / Kali automation |
| `reports/` | Sanitized generated reports |
| `*_RESULTS.md` | Per-batch execution records (what was checked, changed, verified) |
| `PROJECT_STATE.md` | Current sanitized state of the workstation |
| `CHANGELOG.md` | Chronological, sanitized record of completed changes |
| `SOFTWARE_PLAN.md` | Planned / installed / held software |
| `RECOVERY_MEDIA_INVENTORY.md` | Recovery media tracking (sanitized) |

## Engineering baseline (Batch 5)

Local toolchain standardized on:

- Git, Visual Studio Code, Claude Code CLI
- Windows PowerShell 5.1 **and** PowerShell 7 (side by side)
- Python 3.13 (x64, Python Software Foundation) with `pip` and the `py` launcher
- GitHub CLI (installed; **not** authenticated in this project)
- Sysinternals Suite (official Microsoft source)

Exact versions and PATH impact are recorded in `BATCH_5_RESULTS.md`.

---

## Working method

Each batch is authorized explicitly before execution and is captured in a
`BATCH_<n>_RESULTS.md` file with: pre-check state, exact commands, results,
verification, security-baseline re-check, and a PASS / PARTIAL / FAIL verdict.
High-risk areas (firmware, Secure Boot, TPM, BitLocker, bootloader, partitions)
are handled only under a separate, named authorization.

## Privacy & safety

- No usernames, hostnames, serial numbers, IP/MAC addresses, Wi-Fi SSIDs, account
  emails, passwords, tokens, or recovery keys are stored in this repository.
- Machine-local state, personal backups, and hardware reports are excluded via
  `.gitignore`.
- A manual privacy/security review is performed before anything is staged for a
  future commit. Git history is currently **local only** — no remote is configured.

## License

No license granted yet. Until a `LICENSE` file is added, all rights reserved by the
author for the custom scripts and documentation. Third-party tools referenced here
remain under their own licenses.
