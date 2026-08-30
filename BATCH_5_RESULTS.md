# BATCH 5 — Engineering Baseline — RESULTS

**Date:** 2026-08-28
**Scope:** Establish the local engineering toolchain (PowerShell 7, Python 3, Sysinternals,
GitHub CLI), verify existing tools, create the local project structure and documentation,
initialize a **local** Git repository, and perform a pre-staging privacy review — all while
preserving the clean Windows security baseline.
**Work confined to:** `C:\Users\<user>\Documents\CyberOps-AI-Workstation-Lab`

**Concurrency rule honored:** `Recovered-Desktop` was not scanned, enumerated, moved,
renamed, deleted, or reorganized. No recursive searches were run against cloud storage.
No personal backup files were accessed. No heavy disk scan was performed. Batch 4C remains
on HOLD.

**Overall verdict: PASS** (one authorized deviation: Sysinternals installed from the
Microsoft Store instead of the winget `winget` source — see §5).

---

## 1. Pre-check (read-only) — before any change

### 1.1 Engineering tools

| Tool | Found | Version | Action |
|---|---|---|---|
| Git | Yes | 2.55.0.windows.3 | none — current |
| Visual Studio Code | Yes | 1.135.0 | none — current |
| Claude Code CLI | Yes | 2.1.248 | none — current |
| Windows PowerShell | Yes | 5.1.26100.9168 | preserve (not replaced) |
| PowerShell 7 (`pwsh`) | **No** | — | install |
| Python 3 | **No** (only a 0-byte `WindowsApps\python.exe` App Execution Alias stub) | — | install |
| `py` launcher | **No** | — | installed with Python |
| `pip` | **No** (not on PATH) | — | installed with Python |
| GitHub CLI (`gh`) | **No** | — | install |
| Sysinternals | **No** | — | install |

### 1.2 Security baseline — before

| Control | State |
|---|---|
| Defender Real-Time Protection | On |
| Tamper Protection | On |
| Behavior Monitor | On |
| PUA Protection | Block (`1`) |
| Network Protection | Enabled (`1`) |
| ASR rules | 9 configured, all Audit mode (`2`) |
| Firewall Domain / Private / Public | Enabled / Enabled / Enabled |
| CBS reboot pending | No |
| Windows Update reboot required | No |

Baseline healthy — proceeded.

---

## 2. PowerShell 7

- Installed: `winget install --id Microsoft.PowerShell --exact --source winget` — exit 0,
  **"Successfully verified installer hash"**.
- Package: **Microsoft.PowerShell 7.6.5.0**, Publisher `CN=Microsoft Corporation`,
  SignatureKind **Store** (MSIX bundle from the official PowerShell GitHub release,
  SHA256 pinned in the winget manifest).
- `pwsh.exe` Authenticode signature: **Valid**, signer `CN=Microsoft Corporation`.
- Version check: `pwsh -v` → **7.6.5** (edition Core).
- **Windows PowerShell 5.1 preserved:** `powershell.exe` still at
  `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`, `powershell -v` →
  **5.1.26100.9168**. Both shells available.
- No new service, scheduled task, or Run-key entry.

---

## 3. Python 3

- Installed: `winget install --id Python.Python.3.13 --exact --source winget` — exit 0,
  installer downloaded from `https://www.python.org/ftp/python/3.13.15/python-3.13.15-amd64.exe`,
  **"Successfully verified installer hash"**.
- Package: **Python 3.13.15 (64-bit)**, Publisher **Python Software Foundation**
  (registry components all `3.13.15150.0`, incl. "Python Launcher").
- `python.exe` Authenticode signature: **Valid**, signer `CN=Python Software Foundation`.
- Install type: **per-user**, home `C:\Users\<user>\AppData\Local\Programs\Python\Python313`.
- Verification:
  - `python --version` → **Python 3.13.15**
  - `py --version` → **Python 3.13.15**   (`py -0p` lists `-V:3.13 *` as the default)
  - `pip --version` → **pip 26.2.1** (from the Python 3.13 site-packages)
- **No third-party packages installed.** No Python alias/App-Execution-Alias setting was
  modified; the winget/PSF installer only prepended `PATH` (see §8). The 0-byte
  `WindowsApps` stub still exists but the real interpreter now precedes it on `PATH`.

---

## 4. GitHub CLI

- Installed: `winget install --id GitHub.cli --exact --source winget` — exit 0,
  installer `gh_2.98.0_windows_amd64.msi` from `github.com/cli/cli` releases,
  **"Successfully verified installer hash"**.
- Package: **GitHub CLI 2.98.0**, Publisher **GitHub, Inc.**
- `gh.exe` Authenticode signature: **Valid**, signer `CN="GitHub, Inc."`.
- Version check: `gh --version` → **gh version 2.98.0 (2026-08-20)**.
- **No remote or auth operation performed.** `gh auth login`, `gh repo create/delete/fork`,
  `gh api`, and every other remote call were **not** run. `gh` is installed only.

---

## 5. Sysinternals Suite

- **Deviation (authorized-source, integrity-preserving):** the winget `winget`-source
  package `Microsoft.Sysinternals.Suite` **failed** with
  **"Installer hash does not match"** (exit 17) — the live
  `download.sysinternals.com/files/SysinternalsSuite.zip` had been updated in place and
  no longer matches the SHA256 pinned in the winget manifest. Installer-hash verification
  was **not** bypassed (`--ignore-security-hash` was not used).
- Installed instead from the **official Microsoft Store** package
  (`winget install --id 9P7KNL5RWT25 --source msstore`) — exit 0.
- Package: **Microsoft.SysinternalsSuite 2026.8.1.0**, Publisher
  `CN=Microsoft Corporation`, SignatureKind **Store**, install location
  `C:\Program Files\WindowsApps\Microsoft.SysinternalsSuite_2026.8.1.0_x64__8wekyb3d8bbwe`.
- Command aliases registered under `%LOCALAPPDATA%\Microsoft\WindowsApps` (e.g.
  `procexp.exe`, `Autoruns.exe`, `autorunsc.exe`, `Procmon.exe`, `pslist.exe`,
  `sigcheck.exe`, `strings.exe`, `tcpview.exe`, `handle.exe`).
- **No diagnostic tool was run** after installation.
- No Windows service or scheduled task added (MSIX app).

---

## 6. Existing engineering tools — verified, not reinstalled

| Tool | `--version` | Result |
|---|---|---|
| `git --version` | git version 2.55.0.windows.3 | current — untouched |
| `code --version` | 1.135.0 (commit 08d4889f…, x64) | current — untouched |
| `claude --version` | 2.1.248 (Claude Code) | current — untouched |

---

## 7. Local project structure

Working folder was **not** a Git repository before this batch.

### 7.1 Directories created

`docs/`, `scripts/`, `reports/`, `powershell/`, `python/`, `bash/`
(each seeded with a `.gitkeep` so it can be tracked).

### 7.2 Files created

| File | Purpose |
|---|---|
| `README.md` | Professional project overview; states this is a **personal** cybersecurity/workstation lab, not employment experience |
| `PROJECT_STATE.md` | Sanitized current state (see §9) |
| `CHANGELOG.md` | Chronological sanitized change record, grouped by batch |
| `SOFTWARE_PLAN.md` | Installed / held / candidate software with sourcing rules |
| `RECOVERY_MEDIA_INVENTORY.md` | Sanitized recovery-media tracking |
| `.gitignore` | Security-focused ignore rules (see §8) |

### 7.3 Files preserved (not moved, not edited)

`BATCH_1_RESULTS.md`, `BATCH_2_RESULTS.md`, `BATCH_4_RESULTS.md`, `BATCH_4D_RESULTS.md`,
`CLAUDE.md`, `POST_CLEAN_ELEVATED_VERIFY.md`, `POST_CLEAN_WINDOWS_AUDIT.md`,
`PRE_FIRMWARE_VALIDATION.md`, `battery-report-20260828-122056.html`.

### 7.4 Local Git repository

- `git init` → `Initialized empty Git repository … /.git/`, branch **`master`**.
- **No remote configured** (`git remote -v` empty).
- **Nothing staged, committed, or pushed.**

---

## 8. `.gitignore` and PATH impact

### 8.1 `.gitignore` coverage

Explicitly excludes (at minimum, as required):
`*.key *.pem *.pfx *.p12 *.cer *.crt *.kdbx .env .env.* *.token *.secret
credentials* secrets* battery-report-*.html`

Also excludes: `Recovered-Desktop/`, personal-backup / `Backups/` paths, `Downloads/`,
temp/log/cache files, Python `__pycache__`/`.venv`, IDE local state (`.vscode/*` with a
couple of sample allow-list exceptions), shell history files, `SysinternalsSuite*.zip`,
`*.evtx`, private-key filenames, GPG material.

Verified with `git check-ignore`:
`battery-report-20260828-122056.html`, `Recovered-Desktop`, `.env`, `secrets.txt`,
`test.kdbx` → all correctly ignored. `git status --ignored` confirms the battery report
is the only currently-present ignored file. No project source or sanitized doc is hidden
by these rules.

### 8.2 PATH changes from this batch

| Scope | Entries added | By |
|---|---|---|
| **User** `PATH` | `%LOCALAPPDATA%\Programs\Python\Python313\` | Python installer ("Add to PATH") |
| **User** `PATH` | `%LOCALAPPDATA%\Programs\Python\Python313\Scripts\` | Python installer |
| **User** `PATH` | `%LOCALAPPDATA%\Programs\Python\Launcher\` | Python launcher |
| **Machine** `PATH` | `C:\Program Files\GitHub CLI\` | GitHub CLI MSI |
| (aliases, not PATH) | `%LOCALAPPDATA%\Microsoft\WindowsApps\` already on PATH; now also resolves `pwsh`, `procexp`, `Autoruns`, etc. | MSIX app execution aliases (PowerShell 7, Sysinternals) |

No Machine `PATH` entry was added for Python or PowerShell. No existing PATH entry was
removed or reordered by hand.

---

## 9. Documentation content (sanitized)

`PROJECT_STATE.md` records, without machine identifiers:

- Windows 11 Pro = primary OS, clean install **verified**.
- Kali Linux 2026.2 = physical UEFI/GPT dual boot, **boot-tested working**; Windows boots by default.
- **Secure Boot intentionally disabled** for current Kali boot compatibility (change-controlled).
- **TPM 2.0 present and healthy.**
- Defender/Firewall hardening state: RTP On, Tamper On, PUA Block, Network Protection Enabled,
  9 ASR rules in Audit, firewall on all profiles.
- Windows recovery USB **created and boot-tested**.
- Batch status: **1 = PARTIAL**, **2 = PASS**, **4 = PARTIAL**, **4D = PASS**,
  **3 (firmware / Secure Boot) = HOLD**, **4C (file recovery) = HOLD**.
- Backup restoration **in progress** (`Recovered-Desktop` still copying).

`CHANGELOG.md` records Batches 1, 2, 4, 4D, and 5 chronologically with sanitized descriptions.

`README.md` is a professional overview that **explicitly states this is a personal
cybersecurity/workstation lab** and does **not** claim professional employment experience.
It contains no usernames, hostnames, serial numbers, IP/MAC addresses, SSIDs, emails,
passwords, tokens, keys, or personal file names.

---

## 10. Local Git safety check / privacy review

- `git status` inspected (see §7.4). **Not** a repo before this batch; now a bare local
  repo with only untracked files.
- **No** `git add`, `git add .`, `git commit`, `git push`, or `git remote` was run.
- Every candidate file was scanned for identifiers (`<user>`, `<HOST>`, IPv4, MAC,
  email, serial, SSID, BitLocker/recovery/product key).

### 10.1 Files that appear SAFE to commit later

| File / dir | Notes |
|---|---|
| `.gitignore` | clean |
| `README.md` | clean (created this batch) |
| `PROJECT_STATE.md` | clean (created this batch) |
| `CHANGELOG.md` | clean (created this batch) |
| `SOFTWARE_PLAN.md` | clean (created this batch) |
| `RECOVERY_MEDIA_INVENTORY.md` | clean (created this batch) |
| `BATCH_5_RESULTS.md` | this file — clean |
| `BATCH_4_RESULTS.md` | no identifiers found |
| `BATCH_4D_RESULTS.md` | no identifiers found |
| `PRE_FIRMWARE_VALIDATION.md` | serial already shown as `_[redacted]_`; no other identifiers |
| `POST_CLEAN_ELEVATED_VERIFY.md` | already sanitized (`<USER>`, `<HOSTNAME>`, `<redacted>`) |
| `CLAUDE.md` | project instructions; no secrets |
| `docs/ scripts/ reports/ powershell/ python/ bash/` (`.gitkeep`) | placeholders only |

### 10.2 Files that need a 1-line redaction BEFORE any commit

| File | Line | Content to sanitize | Suggested fix |
|---|---|---|---|
| `BATCH_1_RESULTS.md` | 128 | `<HOST>\<user>` token | replace with `<HOST>\<user>` |
| `BATCH_2_RESULTS.md` | 17 | `<HOST>\<user>` token | replace with `<HOST>\<user>` |
| `POST_CLEAN_WINDOWS_AUDIT.md` | 709 | `C:\Users\<user>\Documents\CyberOps-AI-Workstation-Lab` (inside an embedded script block) | replace user path with `C:\Users\<user>\Documents\CyberOps-AI-Workstation-Lab` or `$PWD` |

These three files were **left untouched** in this batch (editing their content was not in
scope). They should not be staged until the above edits are made and re-reviewed.

### 10.3 Files that must stay OUT of Git

| Item | Handling |
|---|---|
| `battery-report-20260828-122056.html` | already covered by `.gitignore` (`battery-report-*.html`) — machine/hardware report |
| `Recovered-Desktop` (when it appears) | already covered by `.gitignore` |
| Any future `*.kdbx`, `.env`, key/cert, token files | covered by `.gitignore` |

---

## 11. Post-check

| Item | Expected | Observed | Result |
|---|---|---|---|
| PowerShell 7 | installed, 5.1 intact | `pwsh` 7.6.5 + `powershell` 5.1.26100.9168 | PASS |
| Python / pip | 3.13 x64 + pip + `py` | python 3.13.15, pip 26.2.1, py 3.13.15 | PASS |
| Sysinternals | official Microsoft, verified | Microsoft.SysinternalsSuite 2026.8.1.0, Store-signed, `CN=Microsoft Corporation` | PASS |
| GitHub CLI | installed, not authed | gh 2.98.0, signer `CN="GitHub, Inc."`, no auth/remote calls | PASS |
| Git | current | 2.55.0.windows.3 | PASS |
| VS Code | current | 1.135.0 | PASS |
| Claude Code | current | 2.1.248 | PASS |
| Defender Real-Time Protection | On | True | PASS |
| Tamper Protection | On | True | PASS |
| PUA Protection | Block | `1` | PASS |
| Network Protection | Enabled | `1` | PASS |
| 9 ASR rules remain Audit | 9 / Audit | 9 total, 9 Audit, 0 non-audit | PASS |
| Firewall profiles enabled | all 3 | Domain / Private / Public = True | PASS |
| Unexpected startup entries / services | none | Run keys unchanged from baseline; no new service referencing pwsh 7 / Python313 / GitHub CLI / Sysinternals | PASS |
| Unexpected scheduled tasks | none | zero task definition files written today | PASS |
| Unexpected reboot pending | none | CBS `RebootPending` = False, WU `RebootRequired` = False | PASS |

**Note on `PendingFileRenameOperations`:** present with 3 real entries
(`C:\Program Files\Google\Chrome`, `C:\Program Files\BraveSoftware`,
`…\BraveSoftware\Brave-Browser`) — all pre-existing browser versioned-folder cleanups
carried over from Batch 4D / earlier, **not** produced by Batch 5. The authoritative
CBS and Windows Update reboot flags are both False; no reboot is required and none was
performed.

---

## 12. Result

**PASS.**

### Installed versions (this batch)

| Software | Version | Source | Publisher / signer |
|---|---|---|---|
| PowerShell 7 | 7.6.5.0 | winget `Microsoft.PowerShell` (MSIX, hash-verified) | Microsoft Corporation (Store) |
| Python 3.13 | 3.13.15 (x64) | winget `Python.Python.3.13` (hash-verified) | Python Software Foundation |
| pip | 26.2.1 | bundled with Python | PyPA |
| `py` launcher | 3.13.15150.0 | bundled with Python | Python Software Foundation |
| GitHub CLI | 2.98.0 | winget `GitHub.cli` (MSI, hash-verified) | GitHub, Inc. |
| Sysinternals Suite | 2026.8.1.0 | Microsoft Store `9P7KNL5RWT25` | Microsoft Corporation (Store) |

### Verified current, unchanged

Git 2.55.0.windows.3 · VS Code 1.135.0 · Claude Code 2.1.248 · Windows PowerShell 5.1.26100.9168

### PATH changes

- **User PATH +3:** `…\Python313\`, `…\Python313\Scripts\`, `…\Launcher\`
- **Machine PATH +1:** `C:\Program Files\GitHub CLI\`
- MSIX execution aliases now resolve `pwsh` and the Sysinternals tools via the existing
  `WindowsApps` alias directory.
- No PATH entry removed or manually reordered.

### Local Git state

Local repo initialized (`master`), **no remote**, **nothing staged/committed**. `.gitignore`
in place and verified.

### Documentation created

`README.md`, `PROJECT_STATE.md`, `CHANGELOG.md`, `SOFTWARE_PLAN.md`,
`RECOVERY_MEDIA_INVENTORY.md`, `.gitignore` (+ `docs/ scripts/ reports/ powershell/
python/ bash/` with `.gitkeep`).

### Files considered safe for a future Git commit

`.gitignore`, `README.md`, `PROJECT_STATE.md`, `CHANGELOG.md`, `SOFTWARE_PLAN.md`,
`RECOVERY_MEDIA_INVENTORY.md`, `BATCH_5_RESULTS.md`, `BATCH_4_RESULTS.md`,
`BATCH_4D_RESULTS.md`, `PRE_FIRMWARE_VALIDATION.md`, `POST_CLEAN_ELEVATED_VERIFY.md`,
`CLAUDE.md`, and the six `*/​.gitkeep` placeholders.

### Needs redaction before commit (left untouched this batch)

`BATCH_1_RESULTS.md` (line 128), `BATCH_2_RESULTS.md` (line 17),
`POST_CLEAN_WINDOWS_AUDIT.md` (line 709) — each has a single `<HOST>\<user>` /
user-path occurrence.

### Items requiring separate authorization

- Editing the three files in §10.2 to redact identifiers.
- `git add` / `git commit` / configuring a remote / `git push`.
- GitHub CLI authentication (`gh auth login`) and any remote GitHub operation.
- Installing any Python third-party packages.
- Batch 3 (firmware / Secure Boot) and Batch 4C (`Recovered-Desktop` review) remain on HOLD.
