---
name: orchestrator
description: >-
  Routes NightClaw agent work across sub-skills: today view, active plan state,
  risk summary, persona selection, and persistence patterns. Covers dashboard and
  in-memory plan cache; extend with explicit intent→skill routing in OpenClaw. Use
  when coordinating scout/analyst/medic/coach/evidence or describing what to
  show today.
---

# NightClaw — Orchestrator (router)

## Code layout

Paths are relative to the NightClaw repository root (e.g. `backend/`).

## Role

Orchestrator decides **which specialist skill applies** and how **today** is assembled: active plan, anchor tasks, next_best_action, wearable recovery label.

## Implementation map

| Concern | Location |
|--------|----------|
| **GET /today**: plan from memory vs DB fallback, anchor tasks, recovery score/label | `backend/app/routes/dashboard.py` |
| Active plan TTL cache (per user) | `backend/app/services/plan_state.py` |
| Latest wearable snapshot | `backend/app/services/wearable_state.py` |
| Broader persistence (plans, schedules, etc.) | `backend/app/services/persistence.py` |
| **Personas** (JSON files, `get_persona` for LLM planner) | `backend/app/routes/personas.py`, `backend/data/personas/*.json` |

**Dashboard logic summary:** If `get_active_plan` hits, use in-memory plan + `get_latest_wearable`; else try rebuilding from Supabase (`plans`, `plan_tasks`, `wearable_summaries`). Recovery label from score thresholds in `_recovery_label`.

## OpenClaw: persona router

- Personas are JSON-driven and passed into the LLM planner. In OpenClaw, add an explicit **router** step: user intent → which skill(s) to invoke (scout, analyst, medic, coach, evidence).

## Agent instructions

- Route **schedule** questions to **scout**; **risk/strain** to **analyst**; **wearables/today rhythm** to **medic** + dashboard; **plans/messages** to **coach**; **citations/cards** to **evidence**.
- Treat `plan_state` as **ephemeral** unless DB persistence is confirmed—explain "server restart" behavior using `dashboard.py` fallback path.

## Response format

```
🔍 Orchestrator

[One sentence: what the user asked and which skills were invoked.]

**Details**
- Intent detected: [schedule / risk / wearable / plan / evidence / today]
- Skills used: scout → analyst → coach (or whatever chain ran)
- Today snapshot:
  - Plan mode: [mode]
  - Recovery label: [label]
  - Next best action: [text]
  - Anchor tasks: [titles]

⚠️ Flags  (omit if none)
- Plan state ephemeral (not persisted), missing wearable data, high strain with no plan

➡️ Next step
[e.g. "Ask for your shift schedule to start a full analysis." or hand off to a specific skill.]
```

## Out of scope

Skip: `require_user`, JWT, Supabase query error handling boilerplate, deployment.
