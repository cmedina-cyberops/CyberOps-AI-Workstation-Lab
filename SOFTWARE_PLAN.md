# SOFTWARE_PLAN.md

Planned, installed, and held software for the workstation. Sanitized.
**Last updated:** 2026-08-28 (Batch 5).

Sourcing rules:
- Official vendor sources, Microsoft Store, or trusted winget packages only.
- Verify publisher, source, signature, and version on install.
- Prefer winget where practical; do not bypass installer hash verification.
- No cracked, "activated", mirrored, or optimizer/debloat software.

---

## Installed — engineering baseline (Batch 5)

| Software | Version | Source | Publisher | Notes |
|---|---|---|---|---|
| Git | 2.55.0.windows.3 | pre-existing | The Git Development Community | Current; not reinstalled |
| Visual Studio Code | 1.135.0 | pre-existing | Microsoft | Current; not reinstalled |
| Claude Code CLI | 2.1.248 | winget `Anthropic.ClaudeCode` | Anthropic PBC | Current |
| Windows PowerShell | 5.1.26100.9168 | OS component | Microsoft | Preserved; not replaced |
| PowerShell 7 | 7.6.5 | winget `Microsoft.PowerShell` | Microsoft | MSIX, hash-verified |
| Python | 3.13.15 (x64) | winget `Python.Python.3.13` | Python Software Foundation | Per-user; `pip` + `py` launcher included |
| pip | 26.2.1 | bundled with Python | PSF/PyPA | No third-party packages installed yet |
| GitHub CLI | 2.98.0 | winget `GitHub.cli` | GitHub, Inc. | Installed only; **not authenticated** |
| Sysinternals Suite | 2026.8.1.0 | Microsoft Store `9P7KNL5RWT25` | Microsoft Corporation | Store-signed; tools not auto-run |

## Installed — applications (earlier batches)

| Software | Batch | Source | Notes |
|---|---|---|---|
| KeePassXC | 4 | winget / official | Password manager |
| VLC | 4 | winget `VideoLAN.VLC` | Media player |
| Adobe Acrobat Reader (64-bit) | 4 | winget / official | PDF reader |
| Google Drive for desktop | 4 | winget / official | Sign-in was held for interactive login |
| OneDrive | 4 | OS / already current | Unchanged |
| ChatGPT Desktop | 4D | Microsoft Store (OpenAI) | Login held for user |
| Claude Desktop | 4D | winget `Anthropic.Claude` | Login held for user |
| Google Chrome | 4D | winget `Google.Chrome` (64-bit) | Clean profile; sign-in optional |

## Held / pending (require separate authorization or a precondition)

| Software | Blocker |
|---|---|
| Microsoft Office | Institutional portal sign-in required (interactive) |
| Epson WF-2950 printer software | Printer not yet connected (Batch 4C) |
| GitHub authentication (`gh auth login`) + remote repo | Not authorized in Batch 5 |
| Python third-party packages | Deliberately deferred; install per-project in a venv when needed |

## Candidate future tooling (not yet authorized)

- Windows Terminal (if not already present via OS)
- Wireshark (capture on owned/lab networks only)
- A Python virtual-environment workflow (`python -m venv`) for project scripts
- `git` global identity configuration for local commits (currently unset)
- Kali-side tooling tracked separately once Batch 3 boot work is resolved

## Explicitly excluded

- Registry cleaners, "debloat" scripts, aggressive optimizers.
- Any software from non-official mirrors, download portals, or activators.
- Anything that weakens the Windows host to accommodate a lab tool.
