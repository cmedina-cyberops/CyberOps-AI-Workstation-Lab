# RECOVERY_MEDIA_INVENTORY.md

Sanitized inventory of recovery and installation media for the workstation.
**Last updated:** 2026-08-28 (Batch 5).

Do **not** record device serial numbers, volume GUIDs, product keys, or BitLocker
recovery keys in this file. Keep any such values offline.

---

## 1. Media on hand

| ID | Type | Purpose | Created | Boot-tested | Status |
|---|---|---|---|---|---|
| RM-01 | USB flash drive | Windows 11 recovery / reinstall media (clean) | 2026-08 | **Yes** — verified it boots on this machine | Current / keep |
| RM-02 | (reserved) | Kali Linux live/installer USB | — | — | Track when re-made |
| RM-03 | (reserved) | Full-disk image / backup target for Batch 3 firmware work | — | — | Required before firmware/Secure Boot changes |

> RM-01 corresponds to the "Clean Windows recovery USB created and boot-tested"
> milestone referenced in `PRE_FIRMWARE_VALIDATION.md` and `PROJECT_STATE.md`.

## 2. What each item should contain

- **RM-01 (Windows recovery):** Microsoft-sourced Windows 11 install/recovery image,
  matching the installed edition. Used to reach WinRE, run Startup Repair, or
  reinstall. No personal data stored on it.
- **RM-02 (Kali):** official Kali Linux ISO written to USB. Rebuild when the Kali
  release is updated or before major boot changes.
- **RM-03 (backup image):** a verified full image of the Windows system volume plus
  any needed data, created immediately before any Batch 3 firmware/BIOS or Secure
  Boot change (HIGH-RISK / BACKUP REQUIRED).

## 3. Verification log

| Date | Media | Test | Result |
|---|---|---|---|
| 2026-08 | RM-01 | Boot to Windows recovery environment from USB | Pass |
| _pending_ | RM-03 | Create + verify restore of full system image | Required before Batch 3 |

## 4. Integrity / provenance notes

- Windows media: written from an image obtained directly from Microsoft.
- Kali media: verify the ISO checksum/signature against `kali.org` before writing.
- Store media physically secure. Treat any media that has been in an untrusted
  machine as suspect.

## 5. Open items

- Rebuild RM-02 (Kali installer USB) and boot-test it.
- Produce RM-03 (verified system image) as the explicit precondition for Batch 3.
- Re-boot-test RM-01 after any firmware update.
