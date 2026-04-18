---
name: coach
description: >-
  Authors recovery plans and messages for NightClaw using Noxturn planner
  behavior—Claude JSON plan with system prompt and tiered modes, or rule-based
  fallback templates. Use when generating PlanTask lists, next_best_action,
  avoid_list, or tone by plan_mode (protect/recover/stabilize/perform).
---

# NightClaw — Coach (message / plan writer)

## Reference codebase (read-only)

Noxturn planners live in **HackASU**. Paths: `HackASU/backend/...`.

## Role

Coach is the **plan generator**: from `RiskComputeResponse`, produce `PlanGenerateResponse`—`plan_mode`, `tasks`, `avoid_list`, `next_best_action`, optional `evidence_refs` (Claude path + RAG).

## Noxturn source map

| Concern | Location |
|--------|----------|
| **SYSTEM_PROMPT**, JSON schema, category rules (sleep/nap/light/caffeine/meal/social/safety, plan_mode by strain), persona/user_profile sections | `HackASU/backend/app/planner/claude_planner.py` |
| Fallback when Claude unavailable: template tasks, sorting, `_plan_mode` from strain, `_next_best_action` | `HackASU/backend/app/planner/rule_planner.py` |
| Plan **shape** in API: generate/replan, risk→plan wiring | `HackASU/backend/app/routes/plans.py` |
| Plan/task/next_best_action models | `HackASU/backend/app/models/schemas.py` |

**Strain tiers (Claude + rule planner alignment):** protect ≥75, recover 50–74, stabilize 25–49, perform below 25 (see prompts and `rule_planner._plan_mode`).

## Agent instructions

- Match **task categories** to `TaskCategory` enum; respect anchor rules (sleep, nap, safety typically `anchor_flag=true` per prompts).
- Prefer **traceable** `source_reason` and real risk references; do not invent `evidence_ref`—use RAG numbering when evidence is supplied (Claude path).
- For NightClaw without API keys, mirror **rule planner** patterns: one core task per risk episode, then fill category coverage (caffeine, light, movement, etc.) as in `RulePlanner._tasks_from_risks`.

## Out of scope

Skip: `rate_limiter`, `token_tracker`, Supabase `save_plan` internals, FastAPI decorators, verbose Pydantic boilerplate.
