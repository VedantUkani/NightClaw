---
name: coach
description: >-
  Authors recovery plans and messages for NightClaw—Claude JSON plan with system
  prompt and tiered modes, or rule-based fallback templates. Use when generating
  PlanTask lists, next_best_action, avoid_list, or tone by plan_mode
  (protect/recover/stabilize/perform).
---

# NightClaw — Coach (message / plan writer)

## Code layout

Paths are relative to the NightClaw repository root (e.g. `backend/`).

## Role

Coach is the **plan generator**: from `RiskComputeResponse`, produce `PlanGenerateResponse`—`plan_mode`, `tasks`, `avoid_list`, `next_best_action`, optional `evidence_refs` (LLM path + RAG).

## Implementation map

| Concern | Location |
|--------|----------|
| **SYSTEM_PROMPT**, JSON schema, category rules (sleep/nap/light/caffeine/meal/social/safety, plan_mode by strain), persona/user_profile sections | `backend/app/planner/claude_planner.py` |
| Fallback when LLM unavailable: template tasks, sorting, `_plan_mode` from strain, `_next_best_action` | `backend/app/planner/rule_planner.py` |
| Plan **shape** in API: generate/replan, risk→plan wiring | `backend/app/routes/plans.py` |
| Plan/task/next_best_action models | `backend/app/models/schemas.py` |

**Strain tiers (LLM + rule planner alignment):** protect ≥75, recover 50–74, stabilize 25–49, perform below 25 (see prompts and `rule_planner._plan_mode`).

## Agent instructions

- Match **task categories** to `TaskCategory` enum; respect anchor rules (sleep, nap, safety typically `anchor_flag=true` per prompts).
- Prefer **traceable** `source_reason` and real risk references; do not invent `evidence_ref`—use RAG numbering when evidence is supplied (LLM path).
- Without API keys, mirror **rule planner** patterns: one core task per risk episode, then fill category coverage (caffeine, light, movement, etc.) as in `RulePlanner._tasks_from_risks`.

## Response format

```
🔍 Coach

[One sentence: plan mode + core intent.]

**Details**
- Plan mode: protect / recover / stabilize / perform
- Next best action: [next_best_action text]
- Tasks:
  1. [category] [title] — [time] (anchor: yes/no)
  2. …
- Avoid: [avoid_list items]
- Evidence refs: [1] title, [2] title … (omit if none)

⚠️ Flags  (omit if none)
- Missing anchor (sleep/safety), strain ≥ 75 with no protect mode, invented evidence

➡️ Next step
[e.g. "Send /plans/generate with this payload." or ask for risk data if not provided.]
```

## Out of scope

Skip: `rate_limiter`, `token_tracker`, Supabase `save_plan` internals, FastAPI decorators, verbose Pydantic boilerplate.
