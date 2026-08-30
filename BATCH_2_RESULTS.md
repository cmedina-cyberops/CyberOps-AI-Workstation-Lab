# BATCH 2 — Security Hardening — RESULTS

**Date:** 2026-08-28
**Elevated run:** 2026-08-28 14:14–14:18 (local)
**Overall status:** **PASS — all 4 authorized steps applied and verified**

---

## 0. Elevation check (precondition) — PASS

Confirmed immediately before Step 3 and before Steps 1/2/4:

| Check | Result |
|---|---|
| `WindowsPrincipal.IsInRole(Administrator)` | **True** |
| Mandatory integrity level | **High Mandatory Level** (`S-1-16-12288`) |
| User context | `<HOST>\<user>` (elevated) |
| ASR baseline before Step 3 | **no rules configured** (`_Ids` and `_Actions` both empty) |

---

## 1. Before state (rollback baseline — confirmed this run)

| Setting | Before | Meaning |
|---|---|---|
| `PUAProtection` | `2` | AuditMode |
| `EnableNetworkProtection` | `0` | Disabled |
| `AttackSurfaceReductionRules_Ids` | *(empty)* | no ASR rules |
| `AttackSurfaceReductionRules_Actions` | *(empty)* | — |
| `EnableControlledFolderAccess` | `0` | Disabled (untouched — out of scope) |
| Defender exclusions (path/process/ext/IP) | *(all empty)* | — |
| `HiberbootEnabled` | `1` (DWord) | Fast Startup ENABLED |
| `%SystemDrive%\hiberfil.sys` present | **False** | pre-existing; not changed by this batch |
| `IsTamperProtected` / `RealTimeProtectionEnabled` / `AntivirusEnabled` | True / True / True | — |

---

## 2. Exact changes made

| # | Change | Command | Result |
|---|---|---|---|
| 1 | PUA Protection → Block | `Set-MpPreference -PUAProtection Enabled` | applied |
| 2 | Network Protection → Enabled | `Set-MpPreference -EnableNetworkProtection Enabled` | applied |
| 4 | Fast Startup → disabled | `Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -Name HiberbootEnabled -Value 0 -Type DWord` | applied |
| 3 | 9 ASR rules → AuditMode (action 2) | `Add-MpPreference -AttackSurfaceReductionRules_Ids <9 GUIDs> -AttackSurfaceReductionRules_Actions AuditMode ×9` | applied |

`Add-MpPreference` was used (not `Set-`), so no unrelated ASR entries or other Defender
settings were replaced.

### The 9 ASR rules applied (all action = 2 / AuditMode)

| GUID | Rule | Action |
|---|---|---|
| `56a863a9-875e-4185-98a7-b882c64b5ce5` | Block abuse of exploited vulnerable signed drivers | 2 (AuditMode) |
| `e6db77e5-3df2-4cf1-b95a-636979351e5b` | Block persistence through WMI event subscription | 2 (AuditMode) |
| `7674ba52-37eb-4a4f-a9a1-f0f9a1619a2c` | Block Adobe Reader from creating child processes | 2 (AuditMode) |
| `d4f940ab-401b-4efc-aadc-ad5f3c50688a` | Block all Office applications from creating child processes | 2 (AuditMode) |
| `be9ba2d9-53ea-4cdc-84e5-9b1eeee46550` | Block executable content from email client and webmail | 2 (AuditMode) |
| `5beb7efe-fd9a-4556-801d-275e5ffc04cc` | Block execution of potentially obfuscated scripts | 2 (AuditMode) |
| `d3e037e1-3eb8-44c8-a917-57927947596d` | Block JavaScript or VBScript from launching downloaded executable content | 2 (AuditMode) |
| `3b576869-a4ec-4529-8536-b80a7769e899` | Block Office applications from creating executable content | 2 (AuditMode) |
| `75668c1f-73b5-4cf0-bb93-3ecf5cb7cc84` | Block Office applications from injecting code into other processes | 2 (AuditMode) |

**The LSASS credential-stealing rule (`9e6c4e1f-…`) was deliberately NOT added** — it was
not part of the authorized 9-rule set.

### Explicitly NOT done

No `powercfg` (neither `/h on` nor `/h off`). Hibernation was not enabled or disabled.
`hiberfil.sys` was already absent and remains absent. No firmware, BIOS, Secure Boot, TPM,
BitLocker, GRUB, EFI, partition, firewall, driver, CFA, or Defender-exclusion changes.
No Warn-mode (action 6) or Block-mode (action 1) ASR rules.

---

## 3. After state (verified this run)

| Setting | After | Expected | Verdict |
|---|---|---|---|
| `PUAProtection` | `1` (Block) | Block | ✅ PASS |
| `EnableNetworkProtection` | `1` (Enabled) | Enabled | ✅ PASS |
| `HiberbootEnabled` | `0` (DWord) | `0` | ✅ PASS |
| ASR rules — count | `9` | 9 | ✅ PASS |
| ASR rules — GUID set | exactly the 9 above; **0 extra, 0 missing** | exact match | ✅ PASS |
| ASR rules — actions | every rule `= 2`; distinct action values `[2]` | all AuditMode / 2 | ✅ PASS |
| ASR rules — any Block (action 1) | **False** | none | ✅ PASS |
| ASR rules — any Warn (action 6) | **False** | none | ✅ PASS |
| `EnableControlledFolderAccess` | `0` | unchanged (`0`) | ✅ unchanged |
| Defender exclusions (path/process/ext/IP) | all empty | empty | ✅ unchanged |
| `ControlledFolderAccessAllowedApplications` | empty | empty | ✅ unchanged |
| `%SystemDrive%\hiberfil.sys` | absent | unchanged (absent) | ✅ unchanged |
| `IsTamperProtected` / RTP / AV | True / True / True | unchanged | ✅ unchanged |

> The Fast Startup change (`HiberbootEnabled = 0`) takes effect on the next full
> shutdown/boot cycle. No reboot was performed by this batch.

---

## 4. PASS / PARTIAL / FAIL

**PASS.**

| Step | Result |
|---|---|
| 1 — PUA Protection → Block | **PASS** |
| 2 — Network Protection → Enabled | **PASS** |
| 3 — 9 ASR rules → AuditMode (action 2) | **PASS** — exactly 9, all action 2, none Block, none Warn |
| 4 — Fast Startup → disabled (`HiberbootEnabled = 0`) | **PASS** (effective next boot) |

No rollback required — all four applied changes are the intended end state and verified.

---

## 5. Rollback reference (exact pre-batch state)

| Setting | Restore to | Command |
|---|---|---|
| PUAProtection | AuditMode (`2`) | `Set-MpPreference -PUAProtection AuditMode` |
| Network Protection | Disabled (`0`) | `Set-MpPreference -EnableNetworkProtection Disabled` |
| ASR rules | none configured | `Remove-MpPreference -AttackSurfaceReductionRules_Ids <GUID>` for each of the 9 GUIDs listed in §2 |
| HiberbootEnabled | `1` | `Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -Name HiberbootEnabled -Value 1 -Type DWord` |
| CFA | unchanged (`0`) | *(not modified — no action)* |
| Defender exclusions | unchanged (empty) | *(not modified — no action)* |

One-shot ASR rollback:

```powershell
'56a863a9-875e-4185-98a7-b882c64b5ce5','e6db77e5-3df2-4cf1-b95a-636979351e5b',
'7674ba52-37eb-4a4f-a9a1-f0f9a1619a2c','d4f940ab-401b-4efc-aadc-ad5f3c50688a',
'be9ba2d9-53ea-4cdc-84e5-9b1eeee46550','5beb7efe-fd9a-4556-801d-275e5ffc04cc',
'd3e037e1-3eb8-44c8-a917-57927947596d','3b576869-a4ec-4529-8536-b80a7769e899',
'75668c1f-73b5-4cf0-bb93-3ecf5cb7cc84' | ForEach-Object {
  Remove-MpPreference -AttackSurfaceReductionRules_Ids $_
}
```

---

## 6. ASR audit events already present

`Get-WinEvent` Microsoft-Windows-Windows Defender/Operational, IDs 1121 (block) / 1122
(audit): **none present** at finalization. Rules were just placed in AuditMode; audit
events (1122) will accumulate as matching activity occurs. Review after 1–2 weeks before
considering any move to Block.

---

## 7. Remaining risks / notes

- All 9 ASR rules are **AuditMode only** — they log (Event ID 1122) but do not block.
  No workflow impact expected. Review the Defender Operational log before promoting any
  rule to Block in a later batch.
- PUA Protection (Block) and Network Protection (Enabled) are now enforcing. Monitor for
  false positives on lab tooling / outbound security-research traffic.
- Fast Startup is disabled in the registry; effective after the next shutdown. Gives
  Windows a true full shutdown so the shared NTFS/ESP volumes are left clean for Kali.
- Hibernation state unchanged; `hiberfil.sys` still absent (pre-existing). No `powercfg`
  was run.
- Tamper Protection remained on throughout; all changes applied successfully via
  `Set-MpPreference` / `Add-MpPreference`.
- No firmware, BIOS, Secure Boot, TPM, BitLocker, GRUB, EFI, partition, firewall, driver,
  CFA, or Defender-exclusion actions were taken.

---

*Sanitised: contains no passwords, tokens, keys, BitLocker recovery keys, serial numbers,
IP/MAC addresses, or personal data.*
