---
name: medic
description: >-
  Interprets wearable vitals and recovery signals for NightClaw and relates
  them to dashboard recovery labels. Covers backend wearable import heuristics;
  optional web research is NightClaw-only (no Noxturn crawler). Use when
  wearables payload, recovery_score, or sleep/resting_hr context matters.
---

# NightClaw — Medic (vitals + web)

## Reference codebase (read-only)

Noxturn wearables/dashboard behavior is in **HackASU**. Paths: `HackASU/backend/...`.

## Role

Medic is the **physiological layer**: map sleep hours, restlessness, resting HR into a **recovery_score**, keep latest snapshot for “today,” and (in NightClaw) optionally **fetch or summarize web** content when the user asks—there is no Noxturn web-crawl implementation.

## Noxturn source map

| Concern | Location |
|--------|----------|
| Wearable import, recovery heuristic, persistence hooks | `HackASU/backend/app/routes/wearables.py` |
| In-memory latest wearable per user | `HackASU/backend/app/services/wearable_state.py` |
| Today dashboard: merge plan + wearable, `_recovery_label` from score | `HackASU/backend/app/routes/dashboard.py` |
| `WearableImportRequest` / `WearableImportResponse` | `HackASU/backend/app/models/schemas.py` |

**Recovery heuristic (MVP):** `sleep_score` from `sleep_hrs` vs 8h; subtract restlessness and HR-vs-60 penalties; clamp 0–100.

**Fitbit:** There is **no** dedicated Fitbit import module in the reference backend. OAuth/callback lives in **HackASU frontend**; device connection is reflected in profile (`UserProfile.fitbit_connected`) and Claude persona text. Treat Fitbit as **upstream OAuth → same wearable import shape** as other devices.

## NightClaw-only: web

- **New capability** for OpenClaw: constrained web read/fetch when the user requests external sources; prefer curated clinical evidence from the evidence skill when both apply.

## Agent instructions

- Use `_recovery_label` semantics when describing rhythm: `unknown` / `steady` / `rebuilding` / `interrupted` (see `dashboard.py`).
- Do not conflate wearable recovery with **circadian_strain_score**—they are different signals; combine only with explicit user or product rules.

## Out of scope

Skip: auth middleware, Supabase table details in routine answers, JWT, rate limiting.
