---
name: orchestrator
description: >-
  Routes NightClaw agent work across sub-skills: today view, active plan state,
  risk summary, persona selection, and persistence patterns. Maps to Noxturn
  dashboard + in-memory plan cache; NightClaw persona/router behavior may extend
  beyond the reference repo. Use when coordinating scout/analyst/medic/coach/evidence
  or describing what to show today.
---

# NightClaw — Orchestrator (router)

## Reference codebase (read-only)

Noxturn dashboard and state live in **HackASU**. Paths: `HackASU/backend/...`.

## Role

Orchestrator decides **which specialist skill applies** and how **today** is assembled: active plan, anchor tasks, next_best_action, wearable recovery label.

## Noxturn source map

| Concern | Location |
|--------|----------|
| **GET /today**: plan from memory vs DB fallback, anchor tasks, recovery score/label | `HackASU/backend/app/routes/dashboard.py` |
| Active plan TTL cache (per user) | `HackASU/backend/app/services/plan_state.py` |
| Latest wearable snapshot | `HackASU/backend/app/services/wearable_state.py` |
| Broader persistence (plans, schedules, etc.) | `HackASU/backend/app/services/persistence.py` |
| **Personas** (JSON files, `get_persona` for Claude) | `HackASU/backend/app/routes/personas.py`, `HackASU/backend/data/personas/*.json` |

**Dashboard logic summary:** If `get_active_plan` hits, use in-memory plan + `get_latest_wearable`; else try rebuilding from Supabase (`plans`, `plan_tasks`, `wearable_summaries`). Recovery label from score thresholds in `_recovery_label`.

## NightClaw-only: persona router

- **Persona** in Noxturn is JSON-driven (`personas` router) passed into Claude. For OpenClaw **NightClaw**, define an explicit **router** step: user intent → which skill(s) to invoke (scout, analyst, medic, coach, evidence). Implement in this repo; not fully encoded in HackASU.

## Agent instructions

- Route **schedule** questions to **scout**; **risk/strain** to **analyst**; **wearables/today rhythm** to **medic** + dashboard; **plans/messages** to **coach**; **citations/cards** to **evidence**.
- Treat `plan_state` as **ephemeral** unless DB persistence is confirmed—explain "server restart" behavior using `dashboard.py` fallback path.

## Out of scope

Skip: `require_user`, JWT, Supabase query error handling boilerplate, deployment.
