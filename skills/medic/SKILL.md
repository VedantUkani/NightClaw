---
name: medic
description: >-
  Interprets wearable vitals and recovery signals for NightClaw and relates
  them to dashboard recovery labels. Covers wearable import heuristics; optional
  web research is an OpenClaw extension (no built-in crawler in core). Use when
  wearables payload, recovery_score, or sleep/resting_hr context matters.
---

# NightClaw — Medic (vitals + web)

## Code layout

Paths are relative to the NightClaw repository root (e.g. `backend/`).

## Role

Medic is the **physiological layer**: map sleep hours, restlessness, resting HR into a **recovery_score**, keep latest snapshot for “today,” and optionally **fetch or summarize web** content when the user asks (higher-level agent feature—not a requirement of the core API).

## Implementation map

| Concern | Location |
|--------|----------|
| Wearable import, recovery heuristic, persistence hooks | `backend/app/routes/wearables.py` |
| In-memory latest wearable per user | `backend/app/services/wearable_state.py` |
| Today dashboard: merge plan + wearable, `_recovery_label` from score | `backend/app/routes/dashboard.py` |
| `WearableImportRequest` / `WearableImportResponse` | `backend/app/models/schemas.py` |

**Recovery heuristic (MVP):** `sleep_score` from `sleep_hrs` vs 8h; subtract restlessness and HR-vs-60 penalties; clamp 0–100.

**Fitbit / devices:** OAuth and token exchange typically live in the **client app** or a dedicated auth route; the backend accepts a normalized **wearable import** payload. Profile may include a “device connected” flag (e.g. `UserProfile.fitbit_connected`) for planner tone—use the same import shape for any vendor.

## OpenClaw extension: web

- Constrained web read/fetch when the user requests external sources; prefer curated clinical evidence from the evidence skill when both apply.

## Agent instructions

- Use `_recovery_label` semantics when describing rhythm: `unknown` / `steady` / `rebuilding` / `interrupted` (see `dashboard.py`).
- Do not conflate wearable recovery with **circadian_strain_score**—they are different signals; combine only with explicit user or product rules.

## Response format

```
🔍 Medic

[One sentence: recovery label + score.]

**Details**
- Recovery score: XX/100 — [unknown / steady / rebuilding / interrupted]
- Sleep: X hrs (score contribution: +/-)
- Restlessness penalty: -X
- Resting HR: X bpm (penalty: -X)

⚠️ Flags  (omit if none)
- Score < 40, interrupted label, HR outlier, missing wearable data

➡️ Next step
[e.g. "Load coach to adjust today's plan for low recovery." or ask for wearable data if missing.]
```

## Out of scope

Skip: auth middleware, Supabase table details in routine answers, JWT, rate limiting.
